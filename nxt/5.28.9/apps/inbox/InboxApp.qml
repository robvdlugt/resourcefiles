import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

/**
 * Application Inbox. Provides access to messages sent to device. On main screen (overview) scrollable
 * list of all messages is available (on the left side). Preview of selected message is on the right side.
 * Number of unread messages appears in application title. It is possible to view selected message in full
 * screen view. Fro both (overview and full screen) it is possible to select different message and delete
 * message. Option to delete all messages is vailable in overview screen.
 * Unread message is marked as read if it is selected in overview or full screen for more than 2 seconds.
 */
App {
	id: inboxApp

	property url fullScreenUrl : "InboxScreen.qml"

	property Popup fullScreenMsgPopup
	property url fullScreenMsgUrl : "InboxFullScreenMsg.qml"
	/// List model that contains the messages
	property ListModel messageList: messageList
	/// The total number of messages available in messageList
	property alias totalMsgs: messageList.count
	/// Number of unread messages.
	property int unreadMessageCount: 0

	/// New message was added
	signal messageAdded()
	/// Message at given index was deleted. When all messages were deleted, the index is -1
	signal messageDeleted(int messageIdx)
	/// data of messages were updated
	signal messagesUpdated()

	QtObject {
		id: p
		property string userMsgUuid

		/// temporary var to enable debug log in console.log() msgs below, will be replaced by code in Widget.qml/Stage.qml asap
		property int d: 3 // 1=Error, 2=Warning, 3=Info, 4=Debug

		/// Retrieve list of messages
		function fetchMessages() {
			var requestMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, userMsgUuid, "specific1", "GetMessages");
			bxtClient.doAsyncBxtRequest(requestMessage, getMessagesCallback, 2000);
		}

		/// updates messages dates on day change to follow extra rules (see convertDateEx() description)
		function updateMessageDates() {
			for (var i = 0; i < totalMsgs; i++) {
				var msg = messageList.get(i);
				var dateStrShort = convertDateEx(msg.received_m, "short");
				var dateStrLong = convertDateEx(msg.received_m, "long");
				messageList.setProperty(i, "received", dateStrShort);
				messageList.setProperty(i, "receivedLong", dateStrLong);
			}
			messagesUpdated();
		}
	}

	function init() {
		registry.registerWidget("screen", fullScreenUrl, inboxApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, inboxApp, null, {objectName: "inboxMenuItem", label: qsTr("Notifications"),
								image: Qt.resolvedUrl("drawables/inbox-menu.svg"), screenUrl: fullScreenUrl, weight: 90, args: {resetView: true}});
		registry.registerWidget("popup", fullScreenMsgUrl, inboxApp, "fullScreenMsgPopup", {"app": inboxApp});

		notifications.registerType("message", notifications.prio_LOWEST, Qt.resolvedUrl("drawables/notification-inbox.svg"),
								   fullScreenUrl, {}, qsTr("notification-message-grouped"));
		notifications.registerSubtype("message", "inbox", fullScreenUrl, {"msgUuid" : "argsAsString"});
	}

	/// Delete message with given index from messageList. Update unreadMessageCount if deleted message was not read. Update application title.
	function deleteMessage(index) {
		if (index < 0 || index >= messageList.count) return;
		var messageItem = messageList.get(index);
		var uuid = messageItem.uuid;
		if (!(messageItem.read_t > 0))
			unreadMessageCount--;
		messageList.remove(index);
		var availableMessages = messageList.availableMessages;
		delete availableMessages[index];
		messageList.availableMessages = availableMessages;
		bxtClient.sendMsg(bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "RemoveMessage"));
		messageDeleted(index);
	}

	/// Delete all messages from messageList.
	function deleteAllMessages(uuid) {
		messageList.clear();
		messageList.availableMessages = ({});
		unreadMessageCount = 0;
		bxtClient.sendMsg(bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, null, "RemoveAllMessages"));
		messageDeleted(-1);
	}

	/// Mark message as read. Called after it was selected for specified time.
	function markMessageRead(index) {
		if (index < 0) return;
		if (messageList.get(index).read_t < 1) {
			messageList.setProperty(index, "read_t", 1);
			unreadMessageCount--;
			bxtClient.sendMsg(bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, messageList.get(index).uuid, null, "ReadMessage"));
		}
	}

	function convertFromLegacyActionFormat(action) {
		switch (action.cmdTarget) {
		case "widget-settings": // cmdArg=System.Software
			action.cmdTarget = "settings/SettingsScreen";
			action.cmdArg = {categoryUrl: Qt.resolvedUrl("qrc:/apps/systemSettings/SoftwareFrame.qml")};
			break;
		case "widget-eusage": // cmdArg=enStatus.0
			if (globals.enabledApps.indexOf("statusUsage") > -1) {
				action.cmdTarget = "statusUsage/StatusUsageScreen";
				action.cmdArg = {type: "total", unit: "money"};
			} else {
				action.cmdTarget = "popup";
				action.cmdArg = {title: qsTr("Status usage not available"), text: qsTr("status_usage_not_available_text"), size: qdialog.SizeLarge};
			}
			break;
		case "widget-benchmark": // cmdArg=eneco-001-000001
			action.cmdTarget = "benchmark/BenchmarkFriendsScreen";
			action.cmdArg = {categoryUrl: Qt.resolvedUrl("qrc:/apps/benchmark/InvitationsFrame.qml")};
			break;
		default:
			logE("convertFromLegacyActionFormat(): Unknown target+arg combination:");
		}
		return action;
	}


	/**
	 * replaceSigns Replace substrings in a string with their corresponding sign
	 *
	 * Supported substrings and their signs:
	 * BR -> \n
	 * RR -> ®
	 * EURO -> €
	 *
	 * @param inputText The text containing the strings to be replaced with signs
	 * @return The input text with the signs in place
	 */
	function replaceSigns(inputText) {
		var retText = inputText.replace(/BR/g, "\n");
		retText = retText.replace(/RR/g, "®");
		retText = retText.replace(/EURO/g, "€");
		return retText;
	}

	/// Handling of new message. Message is formatted properly and added to message list.
	function loadMessage(messageNode) {
		var uuid = messageNode.getChildText("uuid");
		var availableMessages = messageList.availableMessages;
		if (availableMessages[uuid])
			return;
		var read_t = parseInt(messageNode.getChildText("read_t"));
		var received_t = parseInt(messageNode.getChildText("received_t"));

		logD("Adding " + (read_t > 0 ? "read" : "unread") + " message " + uuid);

		var actionsN = messageNode.getChild("actions");
		var actions = {};
		if (actionsN) {
			var i = 0, j = 0;
			for (var actionN = actionsN.getChild("action"); actionN; actionN = actionN.next) {
				var info = "";
				var action = { };
				for (var fieldN = actionN.getChild("type"); fieldN; fieldN = fieldN.ordered) {
					info += ", " + fieldN.name + "=" + fieldN.text;
					action[fieldN.name] = fieldN.text;
				}
				logD(" action[" + (i++) + "]" + info);

				if (action.cmdName === "maximize")
					action = convertFromLegacyActionFormat(action);

				actions[action["btnPos"]] = action;
			}
		}

		var content = replaceSigns(messageNode.getChildText("content"));
		var subject = replaceSigns(messageNode.getChildText("subject"));
		addMessage(subject, content, received_t, read_t, uuid, actions);
	}

	/// adding a new message. Message is formatted properly and added to message list.
	function addMessage(subject, content, received_t, read_t, uuid, actions) {
		var availableMessages = messageList.availableMessages;
		if (availableMessages[uuid])
			return;
		var received_m = received_t * 1000;
		var item = {
			"subject": subject,
			"content": content,
			"received_m": received_m,
			"received": convertDateEx(received_m, "short"),
			"receivedLong": convertDateEx(received_m, "long"),
			"read_t": read_t,
			"uuid": uuid,
			"actions": actions,
		};

		if (read_t <= 0)
			unreadMessageCount++;
		messageList.insert(0, item);
		availableMessages[uuid] = 1;
		messageList.availableMessages = availableMessages;
		messageAdded();
	}

	/**
	 * Convert date time from time_t to human readable format.
	 * @param type:long dateSeconds time_t representation of the requested date
	 * @param type:string format Format of the output.
	 *		"short" gives date in format DD MMM YYYY, "long" gives date and time in format DD MMM YYYY HH:MM
	 */
	function convertDate(time_m, format) {
		if (format === "long") {
			return i18n.dateTime(time_m, i18n.mon_short | i18n.time_yes);
		} else {
			return i18n.dateTime(time_m, i18n.mon_short);
		}
	}

	/**
	 * Convert date time from time_t to human readable format with extra rules.
	 *  - date from today are notated as: “vandaag [hh:mm]”. For example "vandaag 11:30"
	 *  - date from yesterday are notated as: “gisteren [hh:mm]”. For example "gisteren 11:30"
	 *  - date till 5 days back are notated as: “[weekday] [hh:mm]”. For example "maandag 11:30"
	 *  - All other dates are notated as: “[dd mmm yyyy] [hh:mm]”. For example “23 nov 2014 11:30”
	 * @param type:long dateSeconds time_t representation of the requested date
	 */
	function convertDateEx(time_m, format) {
		var daysBack = daysTillNow(time_m);

		if (daysBack <= 0) {
			return qsTr("today %1").arg(i18n.dateTime(time_m, i18n.time_yes));
		} else if (daysBack === 1) {
			return qsTr("yesterday %1").arg(i18n.dateTime(time_m, i18n.time_yes));
		} else if (daysBack <= 5) {
			return i18n.dateTime(time_m, i18n.dow_full | i18n.time_yes);
		} else {
			return convertDate(time_m, format);
		}
	}

	/**
	 * Calculates day difference between given date and current date
	 * @param type:long dateSeconds time_t representation of the requested date
	 */
	function daysTillNow(time_m) {
		var msecPerDay = 1000*60*60*24;
		var now = new Date();
		var date = new Date(time_m);
		var nowUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate());
		var dateUtc = Date.UTC(date.getFullYear(), date.getMonth(), date.getDate());
		return Math.floor((nowUtc - dateUtc) / msecPerDay);
	}

	/// calculates miliseconds till midnight from now
	function getMSecTillMidnight() {
		var now = new Date();
		var nowUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds(),now.getMilliseconds());
		var midnightUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0, 0);
		return midnightUtc - nowUtc;
	}

	/// temporary implementations for logging, will be replaced by code in Widget.qml/Stage.qml asap
	function logD(txt) {
		if (p.d >= 4)
			console.log("D " + txt);
	}
	function logI(txt) {
		if (p.d >= 3)
			console.log("I " + txt);
	}
	function logW(txt) {
		if (p.d >= 2)
			console.log("W " + txt);
	}
	function logE(txt) {
		if (p.d >= 1)
			console.log("E " + txt);
	}

	// 0=messages
	initVarCount: 1

	Component.onCompleted: {
		timerNextDay.interval = getMSecTillMidnight() + 5*1000; //5 seconds after midnight
		timerNextDay.start();
	}

	ListModel {
		id: messageList
		property variant availableMessages:({})
	}

	BxtActionHandler {
		action: "addMessage"
		onActionReceived: {
			var messageNode = message.getArgumentXml("messages").getChild("message");
			while (messageNode) {
				loadMessage(messageNode);
				messageNode = messageNode.next;
			}
		}
	}

	BxtRequestCallback {
		id: getMessagesCallback
		onMessageReceived: {
			var messageNode = message.getArgumentXml("messages").getChild("message");
			while (messageNode) {
				loadMessage(messageNode);
				messageNode = messageNode.next;
			}
			initVarDone(0);
		}
	}

	BxtDiscoveryHandler {
		deviceType: "happ_usermsg"
		onDiscoReceived: {
			p.userMsgUuid = deviceUuid;
			p.fetchMessages();
		}
	}

	Timer {
		id: timerNextDay
		repeat: true
		running: false

		onTriggered: {
			p.updateMessageDates();
			interval = getMSecTillMidnight() + 5*1000; //5 seconds after midnight
		}
	}
}
