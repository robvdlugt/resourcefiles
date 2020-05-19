import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

import "Notifications.js" as NotificationsJS

App {
	id: notificationsApp

	property int count: dataModel.length
	property variant dataset: []
	property variant dataModel: []

	// number of notifications in total needed to trigger grouping
	/*readonly*/ property int conf_GROUPING_THRESHOLD: 4
	// amount of miliseconds to be elapsed before hiding the notification bar after coming out of dim
	/*readonly*/ property int conf_HIDE_TIMEOUT: 5000
	// amount of seconds in which the notification bar will be shown on screen "off" (black) mode
	/*readonly*/ property int conf_SHOW_TIME_SCREENOFF: 120
	// amount of seconds in which the notification bar will be hidden (and the backlight off) on screen "off" (black) mode
	/*readonly*/ property int conf_HIDE_TIME_SCREENOFF: 480

	/*readonly*/ property int prio_HIGHEST: 5
	/*readonly*/ property int prio_HIGH: 4
	/*readonly*/ property int prio_NORMAL: 3
	/*readonly*/ property int prio_LOW: 2
	/*readonly*/ property int prio_LOWEST: 1

	signal datasetUpdated(bool removed);
	signal notificationsAddedOrUpdated();

	// 0 = notifications
	initVarCount: 1

	QtObject {
		id: p
		property url notificationSystrayUrl: "qrc:/qb/notifications/NotificationSystray.qml"
		property string usermsgUuid
		property alias tst_notificationsDsHandler: notificationsDsHandler
		property bool typesRegistered
	}

	function datasetUpdatedHandler(removed) {
		var orderedDataset = dataset.slice(0).reverse();
		orderedDataset.sort(function (a, b) {
			var prioA = getPriority(a.type);
			var prioB = getPriority(b.type);
			if (prioA === prioB) {
				var aDate = parseInt(a.creationDate);
				var bDate = parseInt(b.creationDate);
				return bDate - aDate;
			} else {
				return prioB - prioA;
			}
		});

		var groupedByType = {};
		for (var i = 0, len = orderedDataset.length; i < len; i++) {
			var item = orderedDataset[i];
			if (!groupedByType[item.type])
				groupedByType[item.type] = {"count": 0, /*"items": [], */"grouped": false};
			groupedByType[item.type].count++;
		}

		var tmpData = [];
		for (i = 0, len = orderedDataset.length; i < len; i++) {
			var type = orderedDataset[i].type;
			var typeItemsCount = groupedByType[type].count;
			if (len > conf_GROUPING_THRESHOLD && typeItemsCount > 1) {
				if (groupedByType[type].grouped === false) {
					tmpData.push({
						"type" : type,
						"subType": "_grouped",
						"text": getGroupedText(type, typeItemsCount)
					});
					groupedByType[type].grouped = true;
				}
			} else {
				tmpData.push(orderedDataset[i]);
			}
		}

		dataModel = tmpData;
		if (!removed)
			notificationsAddedOrUpdated();
	}

	function init() {
		registry.registerWidget("systrayIcon", p.notificationSystrayUrl, notificationsApp);
		dependencyResolver.addDependencyTo("Notifications.typesRegistration", "Canvas.appsInitialized");
		dependencyResolver.getDependantSignals("Notifications.typesRegistration").resolved.connect(function () {
			p.typesRegistered = true;
			datasetUpdatedHandler(false);
			datasetUpdated.connect(datasetUpdatedHandler);
		});
	}

	function show(expanded) {
		notificationBar.show(expanded);
	}

	function send(type, subType, unique, text, args, expirationDate) {
		if (!type || !subType || !text)
			return;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.usermsgUuid, "Notification", "CreateNotification");
		msg.addArgument("type", type);
		msg.addArgument("subType", subType);
		msg.addArgument("unique", unique === true ? "true" : "false");
		msg.addArgument("text", text);
		if (args)
			msg.addArgument("args", args);
		if (expirationDate instanceof Date && qtUtils.isDateValid(expirationDate))
			msg.addArgument("expiryDate", expirationDate.getTime() / 1000);

		bxtClient.sendMsg(msg);
	}

	function remove(uuid) {
		if (uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.usermsgUuid, "Notification", "DeleteNotification");
			msg.addArgument("uuid", uuid);
			bxtClient.sendMsg(msg);
		}
	}

	function removeByType(type) {
		if (type) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.usermsgUuid, "Notification", "DeleteNotification");
			msg.addArgument("type", type);
			bxtClient.sendMsg(msg);
		}
	}

	function removeByTypeSubType(type, subType, args) {
		if (type && subType) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.usermsgUuid, "Notification", "DeleteNotification");
			msg.addArgument("type", type);
			msg.addArgument("subType", subType);
			if (args && args.length)
				msg.addArgument("args", args);
			bxtClient.sendMsg(msg);
		}
	}

	function registerType(type, priority, iconUrl, groupedActionUrl, groupedActionArgsFormat, groupedText) {
		if (!NotificationsJS.registeredTypes[type])
			NotificationsJS.registeredTypes[type] = {"subTypes": {"default" : {"actionUrl": groupedActionUrl, "actionArgsFormat" : groupedActionArgsFormat}}};
		else
			console.log("Notifications.registerType: replacing type ", type, " with groupedActionUrl", groupedActionUrl, "!");

		NotificationsJS.registeredTypes[type]["priority"] = priority;
		NotificationsJS.registeredTypes[type]["iconUrl"] = iconUrl;
		NotificationsJS.registeredTypes[type]["actionUrl"] = groupedActionUrl;
		NotificationsJS.registeredTypes[type]["actionArgsFormat"] = groupedActionArgsFormat;
		NotificationsJS.registeredTypes[type]["text"] = groupedText;

		// trigger redraw of notifications in order to use updated registration data
		if(p.typesRegistered)
			dataModelChanged();
	}

	function registerSubtype(type, subType, actionUrl, actionArgsFormat) {
		if (!NotificationsJS.registeredTypes[type]) {
			console.log("Notifications.registerSubtype: type ", type, "not found, register type first!");
			return;
		}

		if (!subType)
			subType = "default";

		if (!NotificationsJS.registeredTypes[type]["subTypes"][subType])
			NotificationsJS.registeredTypes[type]["subTypes"][subType] = {};
		else
			console.log("Notifications.registerSubtype: replacing subType", type + "-" + subType, "with actionUrl", actionUrl);

		NotificationsJS.registeredTypes[type]["subTypes"][subType]["actionUrl"] = actionUrl;
		NotificationsJS.registeredTypes[type]["subTypes"][subType]["actionArgsFormat"] = actionArgsFormat;

		// trigger redraw of notifications in order to use updated registration data
		if(p.typesRegistered)
			dataModelChanged();
	}

	function deregisterType(type, subType) {
		if (type && NotificationsJS.registeredTypes[type]) {
			if (subType) {
				if (NotificationsJS.registeredTypes[type]["subTypes"][subType]) {
					delete NotificationsJS.registeredTypes[type]["subTypes"][subType];
				} else {
					console.log("Notifications.deregisterType: registered type ", type, "and subType", subType, "not found!");
					return false;
				}
			} else {
				delete NotificationsJS.registeredTypes[type];
			}
			// trigger redraw of notifications in order to use updated registration data
			if(p.typesRegistered)
				dataModelChanged();
			return true;
		} else {
			console.log("Notifications.deregisterType: registered type ", type, "not found!");
			return false;
		}
	}

	function getHandlerInfo(type, subType) {
		if (type && NotificationsJS.registeredTypes[type]) {
			if (subType) {
				if (subType === "_grouped")
					return NotificationsJS.registeredTypes[type];
				else if (NotificationsJS.registeredTypes[type]["subTypes"][subType])
					return NotificationsJS.registeredTypes[type]["subTypes"][subType];
			} else if (NotificationsJS.registeredTypes[type]["subTypes"]["default"]){
				return NotificationsJS.registeredTypes[type]["subTypes"]["default"];
			}
		}
		return undefined;
	}

	function formatActionArgs(argsFormat, argsString) {
		if (typeof argsFormat !== "object")
			return  {};

		var argsObj;
		try {
			argsObj = JSON.parse('{"' + argsString.replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}')
		} catch (e) {
			argsObj = {"argsAsString" : argsString };
		}

		var actionArgs = {};
		for (var arg in argsFormat) {
			var argValueName = argsFormat[arg];
			if (argsObj[argValueName])
				actionArgs[arg] = argsObj[argValueName];
			else
				actionArgs[arg] = argValueName;
		}
		return actionArgs;
	}

	function getPriority(type) {
		var handlerInfo = NotificationsJS.registeredTypes[type];
		if (handlerInfo) {
			return handlerInfo["priority"];
		} else {
			return 0;
		}
	}

	function getIconUrl(type) {
		var handlerInfo = NotificationsJS.registeredTypes[type];
		if (handlerInfo) {
			return handlerInfo["iconUrl"];
		} else {
			return "";
		}
	}

	function getActionUrl(type, subType) {
		var handlerInfo = getHandlerInfo(type, subType);
		if (handlerInfo && handlerInfo["actionUrl"]) {
			return handlerInfo["actionUrl"];
		} else {
			return "";
		}
	}

	function getActionArgsFormat(type, subType) {
		var handlerInfo = getHandlerInfo(type, subType);
		if (handlerInfo && handlerInfo["actionArgsFormat"]) {
			return handlerInfo["actionArgsFormat"];
		} else {
			return "";
		}
	}

	function getGroupedText(type, number) {
		var handlerInfo = NotificationsJS.registeredTypes[type];
		var str = handlerInfo && handlerInfo["text"] ? handlerInfo["text"] : qsTr("notification-unregistered-type-grouped");
		return str.replace("%n", number);
	}

	function parseNotificationsDS(update) {
		if (update) {
			var tmpDataset = [];
			for (var node = update.getChild("notification"); node; node = node.next) {
				var child = node.child;
				if (child) {
					var tmpObject = {};
					while (child) {
						tmpObject[child.name] = child.text;
						child = child.sibling;
					}
					// add optional "args" property when it wasn't present on dataset, needed for model (roles cannot change)
					if (!tmpObject.hasOwnProperty("args"))
						tmpObject["args"] = "";
					tmpDataset.push(tmpObject);
				}
			}
			var removed = (dataset.length > tmpDataset.length || tmpDataset.length === 0);
			dataset = tmpDataset;
			datasetUpdated(removed);
			initVarDone(0);
		}
	}

	BxtDiscoveryHandler {
		id: usermsgDiscoHandler
		deviceType: "happ_usermsg"
		onDiscoReceived: {
			p.usermsgUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: notificationsDsHandler
		discoHandler: usermsgDiscoHandler
		dataset: "notifications"
		onDatasetUpdate: parseNotificationsDS(update)
	}
}
