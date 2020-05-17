import QtQuick 2.1

import BxtClient 1.0
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0

App {
	id: controlPanelApp

	property MenuItem controlPanelMenu

	property variant devPlugs: []
	property variant devLamps: []
	property variant plugsTable: ({})
	property variant hueBridges: ({})
	property variant deviceStatusInfo: ({})
	property variant inSwitchAll_total: ({})
	property variant registeredSwitchTiles: ({})
	property variant allPlugsTile
	property variant newPlug: QtObject {}
	property variant hueScenes: []
	property variant heatRecoveryInfo
	property variant alarmInfo: {
		"armedState": undefined,
		"diagnosisStatus": undefined,
		"connected": undefined
	}
	property bool hasAlarmSystem: false
	property variant alarmPinIsSet

	property variant gradientColorTL: []
	property variant gradientColorMiddle: []
	property variant gradientColorBR: []

	property int addToAllOnOff: 1
	property int switchLocked: 0
	property int zwaveHealthTestProgress
	property bool zwaveHealthTestRunning: false
	property int zwaveHealth: 0
	property string smartplugZwaveUuid
	property bool zwaveCommandStopped
	property string linkedBridgeUuid

	property bool hasHeatRecoveryVentLevel: p.ventRecoveryDevUuid && typeof heatRecoveryInfo !== "undefined" && isNumeric(heatRecoveryInfo["TargetVentilationLevel"])
	property bool internetState: true

	property url connectionQualityFrameUrl: "ConnectionQualityFrame.qml"
	property url nameFrameUrl: "NameFrame.qml"
	property url switchLockFrameUrl: "SwitchLockFrame.qml"
	property url allOnOffFrameUrl: "AllOnOffFrame.qml"
	property url resultFrameUrl: "ResultFrame.qml"

	property url plugTabUrl: "PlugTab.qml"
	property url lampTabUrl: "LampTab.qml"
	property url sceneTabUrl: "SceneTab.qml"
	property url bridgeTabUrl: "BridgeTab.qml"
	property url securityTabUrl: "SecurityTab.qml"

	property url wizardScreenUrl: "WizardScreen.qml"
	property url addPlugScreenUrl: "AddPlugScreen.qml"
	property url editLampScreenUrl: "EditLampScreen.qml"
	property url editPlugScreenUrl: "EditPlugScreen.qml"
	property url addBridgeScreenUrl: "AddBridgeScreen.qml"
	property url controlPanelScreenUrl: "ControlPanelScreen.qml"
	property url selectBridgeScreenUrl: "SelectBridgeScreen.qml"
	property url plugWizardErrorScreenUrl: "PlugWizardErrorScreen.qml"
	property url restoreDecouplePlugPopupUrl: "RestoreDecouplePlugPopup.qml"
	property url switchLockScreenUrl: "SwitchLockScreen.qml"
	property url alarmEditPinScreenUrl: "AlarmEditPinScreen.qml"

	signal devicesChanged
	signal bridgeLinked
	signal saveSceneResponseReceived
	signal finishedAlarmSystemLinking(var success, var reason)

	QtObject {
		id: p

		property url controlPanelMenuUrl: "drawables/controlPanelClosed.svg"
		property url controlPanelUrl: "ControlPanel.qml"
		property url alarmPanelUrl: "AlarmPanel.qml"
		property url smartPlugTileUrl: "PlugTile.qml"
		property url allPlugsTileUrl: "AllPlugsTile.qml"
		property url smartPlugTileIconUrl: "drawables/plug-thumb.svg"
		property url allPlugsTileIconUrl: "drawables/triple-plug-thumb.svg"
		property url newBridgeFoundPopup: "NewBridgeFoundPopup.qml"

		property string hueUuid
		property string zwaveUuid
		property string smartplugUuid
		property string thermostatUuid
		property string ventRecoveryDevUuid
		property string alarmPanelUid
		property string alarmSystemDevUuid

		//for unittests
		property alias tst_hueBridgesDataset: hueBridgesDataset
		property alias tst_deviceConfigInfoDataset: deviceConfigInfoDataset
		property alias tst_deviceStatusInfoDataset: deviceStatusInfoDataset

		property bool linkingBridge: false
		property variant homescreenPopup: {'priority': 300, 'uuid': 'bridgeFound'}

		function parseHueBridges(update) {
			var bridgeList = [];
			var bridgeNode = update.getChild("bridge", 0);
			var initialBridge = false;
			var bridgeLinked = false;

			while (bridgeNode) {
				var bridgeUuid = bridgeNode.getChildText("uuid");
				var childNode = bridgeNode.child;
				var bridge = {};
				while (childNode) {
					bridge[childNode.name] = childNode.text;
					childNode = childNode.sibling;
				}

				if (bridge.linkState == 0) {
					initialBridge = true;
				} else if (bridge.linkState == 2) {
					bridgeLinked = true;
					linkedBridgeUuid = bridgeUuid;
				}

				bridgeList[bridgeUuid] = bridge;
				bridgeNode = bridgeNode.next;
			}
			if (!bridgeLinked)
				linkedBridgeUuid = "";
			hueBridges = bridgeList;
			initVarDone(0);

			if (initialBridge && !bridgeLinked) {
				stage.registerHomescreenPopup({priority: homescreenPopup.priority, 'uuid': homescreenPopup.uuid, callback: p.showPopup});
			} else {
				stage.unregisterHomescreenPopup(homescreenPopup.uuid);
			}
		}

		function notifyBridges() {
			stage.unregisterHomescreenPopup(homescreenPopup.uuid);
			for (var bridgeUuid in hueBridges) {
				var bridge = hueBridges[bridgeUuid];
				if (bridge.linkState == 0) {
					var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, hueUuid, "specific1", "BridgeNotified");
					msg.addArgument("macAddr", bridge.serialNumber);
					bxtClient.sendMsg(msg);
				}
			}
		}

		function goToLinkBridge() {
			var newBridges = 0;
			var newBridgeUuid = '';

			stage.unregisterHomescreenPopup(homescreenPopup.uuid);

			for (var bridgeUuid in hueBridges) {
				var bridge = hueBridges[bridgeUuid];
				if (bridge.linkState == 0) {
					newBridges++;
					newBridgeUuid = bridgeUuid;
				}
			}
			notifyBridges();
			if (newBridges == 1) {
				stage.openFullscreen(addBridgeScreenUrl, {bridgeUuid: bridgeUuid});
			} else {
				stage.openFullscreen(selectBridgeScreenUrl);
			}
		}

		function parseDeviceConfigInfo(update) {
			if (update) {
				var deviceChild = update.getChild("device", 0);
				var lampsTmp = [];
				var plugsTmp = [];
				var plugsTableTmp = {};
				var oldPlugs = plugsTable;
				var registeredSwitchTilesTmp = registeredSwitchTiles;
				while (deviceChild) {
					var childChild = deviceChild.child;
					var deviceInfo = {};
					while (childChild) {
						deviceInfo[childChild.name] = childChild.text;
						childChild = childChild.sibling;
					}
					if (deviceInfo.DevType.indexOf('hue_light') >= 0) {
						lampsTmp.push(deviceInfo);
					} else {
						plugsTmp.push(deviceInfo);
						plugsTableTmp[deviceInfo.DevUUID] = deviceInfo;
						//If we did not have this dev before, add tile for it
						var oldInfo = oldPlugs[deviceInfo.DevUUID];
						if (oldInfo == undefined) {
							registeredSwitchTilesTmp[deviceInfo.DevUUID] =
									registry.registerWidget("tile", smartPlugTileUrl, controlPanelApp, null, {thumbLabel: deviceInfo.Name, thumbIcon: smartPlugTileIconUrl, thumbCategory: "smartplugs", config: {devUuid: deviceInfo.DevUUID}, thumbIconVAlignment: "center"});
						} else {
							//See if we need to update stuff
							if (oldInfo.Name != deviceInfo.Name) {
								registry.deregisterWidget(registeredSwitchTilesTmp[deviceInfo.DevUUID]);
								registeredSwitchTilesTmp[deviceInfo.DevUUID] = registry.registerWidget("tile", smartPlugTileUrl, controlPanelApp, null, {thumbLabel: deviceInfo.Name, thumbIcon: smartPlugTileIconUrl, thumbCategory: "smartplugs", config: {devUuid: deviceInfo.DevUUID}, thumbIconVAlignment: "center"});
							}
						}
					}
					deviceChild = deviceChild.next;
				}
				//See if plugs were removed; if so we need to deregister the Tile
				for (var d in oldPlugs) {
					if (plugsTableTmp[d] == undefined) {
						var uuidToRemove = oldPlugs[d].DevUUID;
						//We had it before but don't have it anymore.
						console.log("De-registering tile for removed switch " + uuidToRemove);
						registry.deregisterWidget(registeredSwitchTilesTmp[uuidToRemove]);
						registeredSwitchTilesTmp[uuidToRemove] = undefined;
						var deviceStatusInfoTmp = deviceStatusInfo;
						deviceStatusInfoTmp[uuidToRemove] = undefined;
						deviceStatusInfo = deviceStatusInfoTmp;
					}
				}

				if (plugsTmp.length > 0) {
					if (!allPlugsTile) {
						allPlugsTile = registry.registerWidget("tile", allPlugsTileUrl, controlPanelApp, null, {thumbLabel: qsTr("All plugs"), thumbIcon: allPlugsTileIconUrl, thumbCategory: "smartplugs", thumbWeight: 1, thumbIconVAlignment: "center"});
					}
				} else if (allPlugsTile) {
					registry.deregisterWidget(allPlugsTile);
					allPlugsTile = undefined;
				}

				devPlugs = plugsTmp;
				devLamps = lampsTmp;
				plugsTable = plugsTableTmp;
				registeredSwitchTiles = registeredSwitchTilesTmp;
				devicesChanged();
				initVarDone(3);
				dependencyResolver.setDependencyDone("ControlPanel.smartplugConfig");
			}
		}

		function parseDeviceStatusInfo(update) {
			var infoList = deviceStatusInfo;
			var infoNode = update.getChild("device", 0);
			while (infoNode && infoNode.name === "device") {
				var uuidNode = infoNode.getChild("DevUUID");
				var device = infoList[uuidNode.text];
				if (!device)
					device = {};
				var childNode = infoNode.child;
				while (childNode) {
					device[childNode.name] = childNode.text;
					childNode = childNode.sibling;
				}
				infoList[uuidNode.text] = device;

				infoNode = infoNode.next;
			}
			deviceStatusInfo = infoList;

			infoNode = update.getChild("inSwitchAll_total");
			if (infoNode) {
				childNode = infoNode.child;
				var total = inSwitchAll_total;
				while (childNode) {
					total[childNode.name] = childNode.text;
					childNode = childNode.sibling;
				}
				inSwitchAll_total = total;
			}
			initVarDone(2);
		}

		function parseHueScenes(update) {
			var sceneNode = update.getChild("scene", 0);
			var tmpHueScenes = [];
			while (sceneNode) {
				var scene = {};
				var childNode = sceneNode.child;
				while (childNode) {
					scene[childNode.name] = childNode.text;
					childNode = childNode.sibling;
				}
				tmpHueScenes.push(scene);
				sceneNode = sceneNode.next;
			}
			hueScenes = tmpHueScenes;
			initVarDone(1);
		}

		function parseHeatRecoveryInfo(node) {
			var tempNode = node.child;
			if (tempNode) {
				var tempInfo = heatRecoveryInfo;
				if (typeof tempInfo === "undefined")
					tempInfo = {};

				while (tempNode) {
					tempInfo[tempNode.name] = parseInt(tempNode.text);
					tempNode = tempNode.sibling;
				}
				heatRecoveryInfo = tempInfo;
			} else {
				heatRecoveryInfo = undefined;
			}
		}

		function showPopup() {
			qdialog.showDialog(qdialog.SizeLarge, qsTr('Philips hue found'), p.newBridgeFoundPopup, qsTr('Link'), p.goToLinkBridge, qsTr('Not now'), p.notifyBridges);
		}
	}

	onHueScenesChanged: updateScenes()

	function init() {
		registry.registerWidget("slidePanel", p.controlPanelUrl, controlPanelApp);
		registry.registerWidget("screen", controlPanelScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editPlugScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, controlPanelApp, "controlPanelMenu", {objectName: "controlPanelMenuItem", label: qsTr("Control Panel"), image: p.controlPanelMenuUrl, screenUrl: controlPanelScreenUrl, weight: 100, args: {tab: "first"}});
		registry.registerWidget("screen", addPlugScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", plugWizardErrorScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editLampScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", wizardScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", selectBridgeScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", addBridgeScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", switchLockScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", alarmEditPinScreenUrl, controlPanelApp, null, {lazyLoadScreen: true});

		dependencyResolver.addDependencyTo("Homescreen.loadTileConfig", "ControlPanel.smartplugConfig");
	}

	function updateScenes() {
		var tl = [];
		var br = [];
		var mid = [];
		for (var i = 0; i < hueScenes.length; i++) {
			tl.push("#" + hueScenes[i].color_0);
			mid.push("#" + hueScenes[i].color_1);
			br.push("#" + hueScenes[i].color_2);
		}
		gradientColorBR = br;
		gradientColorMiddle = mid;
		gradientColorTL = tl;
	}

	function getLampByUuid(uuid) {
		for (var idx in devLamps) {
			var lamp = devLamps[idx];
			if (lamp.DevUUID === uuid)
				return lamp;
		}
	}

	function getPlugDeviceName(zwaveUuid) {
		for (var i = 0; i < devPlugs.length; i++) {
			if (devPlugs[i].ZWUuid === zwaveUuid) {
				return devPlugs[i].Name;
			}
		}
		return "";
	}

	function getPlugDeviceUuid() {
		for (var i = 0; i < devPlugs.length; i++) {
			if (devPlugs[i].ZWUuid === smartplugZwaveUuid) {
				newPlug = devPlugs[i];
			}
		}
		devPlugsChanged.disconnect(getPlugDeviceUuid);
	}

	function setInSwitchAll(uuid, isSet) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "SetInSwitchAll");
		msg.addArgument("InSwitchAll", isSet ? "1" : "0");
		bxtClient.sendMsg(msg);
	}

	function setSwitchLocked(uuid, isSet) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "SetSwitchLocked");
		msg.addArgument("SwitchLocked", isSet ? "1" : "0");
		bxtClient.sendMsg(msg);
	}

	function enableSmartplug() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.smartplugUuid, "", "EnableDevice");
		msg.addArgument("ZwUuid", smartplugZwaveUuid);
		bxtClient.sendMsg(msg);
	}

	function formatMAC(mac) {
		if (mac.length != 12) return mac;
		return mac.substr(0,2) + ':' + mac.substr(2,2) + ':' + mac.substr(4,2) + ':' + mac.substr(6,2) + ':' + mac.substr(8,2) + ':' + mac.substr(10,2);
	}

	function sendBridgeLinkMsg(bridgeUuid) {
		p.linkingBridge = true;
		var linkMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, bridgeUuid, "", "LinkBridge");
		bxtClient.doAsyncBxtRequest(linkMsg, handleBridgeLinkResponse, 20000);
	}
	
	function handleBridgeLinkResponse(response) {
		if (!p.linkingBridge) return;
		if (response)
		{
			var success = response.getArgument("Success");
			if (success === "1") {
				p.linkingBridge = false;
				bridgeLinked();
			} else {
				sendBridgeLinkMsg(response.sender);
			}
		}
	}

	function cancelBridgeLink(bridgeUuid) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, bridgeUuid, null, "CancelLinkBridge");
		bxtClient.sendMsg(msg);

		p.linkingBridge = false;
	}

	function discoverBridges(callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hueUuid, "specific1", "DiscoverBridges");
		bxtClient.doAsyncBxtRequest(msg, callback, 25);
	}

	function switchAll(state) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.smartplugUuid, "default", "SwitchAll");
		msg.addArgument("State", state);
		bxtClient.sendMsg(msg);
	}

	function sendBridgeUnlinkMsg(bridgeUuid) {
		var unlinkMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hueUuid, "", "UnlinkBridge");
		unlinkMsg.addArgument("macAddr", hueBridges[bridgeUuid].intAddr);
		bxtClient.doAsyncBxtRequest(unlinkMsg, handleBridgeUnlinkResponse, 20000);
	}

	function setDeviceName(uuid, name) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "SetDeviceName");
		msg.addArgument("Name", name);
		bxtClient.sendMsg(msg);
	}

	function handleBridgeUnlinkResponse(response) {
		console.log('Bridge unlink response: ', response);
	}

	function sendZwaveRemove(zwaveUuid) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, zwaveUuid, null, "RemoveDevice");
		bxtClient.sendMsg(msg);
	}

	function getLinkedBridge() {
		for (var b in hueBridges) {
			if (hueBridges[b].linkState == 2) {
				return b;
			}
		}
		return undefined;
	}

	function loadScene(index) {
		var uuid = getLinkedBridge();
		if (uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "LoadScene");
			msg.addArgument("scene", index);
			bxtClient.sendMsg(msg);
		}
	}

	function saveScene(index) {
		var uuid = getLinkedBridge();
		if (uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "SaveScene");
			msg.addArgument("scene", index);
			bxtClient.doAsyncBxtRequest(msg, saveSceneResponseReceived, 5000);
		}
	}

	function compareDeviceNames(devA, devB) {
		var name1 = devA.Name.toLowerCase();
		var name2 = devB.Name.toLowerCase();
		if (name1 < name2) return -1;
		else if (name1 > name2) return 1;
		else return 0;
	}

	function isNumeric(variable) {
		return (!isNaN(variable) && isFinite(variable));
	}

	/*
	 * level parameter should be a string with a number between 1 to 3,
	 * or +/-1 in order to increase or decrease the level
	 */
	function setVentilationLevel(level) {
		if(typeof p.ventRecoveryDevUuid === "undefined")
			return;

		var levelToSet;
		if(typeof level === "number" && level >= 1 && level <= 3) {
			levelToSet = level;
		} else if (level === "+1") {
			levelToSet = heatRecoveryInfo["TargetVentilationLevel"] + 1;
		} else if (level === "-1") {
			levelToSet = heatRecoveryInfo["TargetVentilationLevel"] - 1;
		} else {
			return;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.ventRecoveryDevUuid, "Ventilation", "SetVentilationLevel");
		msg.addArgument("state", levelToSet);
		bxtClient.sendMsg(msg);

		if (hasHeatRecoveryVentLevel) {
			var tempInfo = heatRecoveryInfo;
			tempInfo["TargetVentilationLevel"] = levelToSet;
			heatRecoveryInfo = tempInfo;
		}
	}

	function setArmedState(state, pinCode, callback) {
		if(!p.alarmSystemDevUuid || !state || !pinCode) {
			if (callback instanceof Function)
				callback(false, "missing-arguments");
			return;
		}

		var cb = function(response) {
			var reason = "timeout"
			if (response) {
				if (response.getArgument("success") === "true") {
					var newState = response.getArgument("securityLevel");
					if (callback instanceof Function)
						callback(true, undefined, newState);
					return;
				} else {
					reason = response.getArgument("reason");
				}
			}
			if (callback instanceof Function)
				callback(false, reason);
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.alarmSystemDevUuid, "HomeSecurity", "SetSecurityLevel");
		msg.addArgument("securityLevel", state);
		msg.addArgument("pinCode", pinCode);
		bxtClient.doAsyncBxtRequest(msg, cb, 15);
	}


	function setAlarmPinCode(pinCode, newPinCode, callback) {
		if(!p.alarmSystemDevUuid || pinCode === undefined || newPinCode === undefined || newPinCode.length === 0) {
			if (callback instanceof Function)
				callback(false, "missing-arguments");
			return;
		}

		var cb = function(response) {
			var reason = "timeout"
			if (response) {
				if (response.getArgument("success") === "true") {
					if (callback instanceof Function)
						callback(true);
					return;
				} else {
					reason = response.getArgument("reason");
				}
			}
			if (callback instanceof Function)
				callback(false, reason);
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.alarmSystemDevUuid, "HomeSecurity", "SetPinCode");
		msg.addArgument("pinCode", pinCode);
		msg.addArgument("newPinCode", newPinCode);
		bxtClient.doAsyncBxtRequest(msg, cb, 15);
	}

	function verifyAlarmPinCode(pinCode, callback) {
		if(!p.alarmSystemDevUuid || pinCode === undefined || pinCode.length === 0) {
			if (callback instanceof Function)
				callback(false, "missing-arguments");
			return;
		}

		var cb = function(response) {
			var reason = "timeout"
			if (response) {
				if (response.getArgument("success") === "true") {
					if (callback instanceof Function)
						callback(true);
					return;
				} else {
					reason = response.getArgument("reason");
				}
			}
			if (callback instanceof Function)
				callback(false, reason);
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.alarmSystemDevUuid, "HomeSecurity", "VerifyPinCode");
		msg.addArgument("pinCode", pinCode);
		bxtClient.doAsyncBxtRequest(msg, cb, 15);
	}

	function hasAlarmPinCode() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.alarmSystemDevUuid, "HomeSecurity", "HasPinCode");
		bxtClient.sendMsg(msg);
	}

	function getAlarmSystemLinkCode(callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hueUuid, "HomeSecurity", "GetLinkCode");

		var cb = function(response) {
			var reason = "timeout"
			if (response) {
				if (response.getArgument("success") === "true") {
					var verificationUrl = response.getArgument("verificationUrl")
					var verificationUrlComplete = response.getArgument("verificationUrlFull")
					var userCode = response.getArgument("userCode")
					var expiresIn = response.getArgument("expiresIn")
					var data = {
						"verificationUrl": verificationUrl,
						"verificationUrlComplete": verificationUrlComplete,
						"userCode": userCode,
						"expiresIn": expiresIn
					};
					if (callback instanceof Function) {
						try {
							callback(true, data);
						} catch(e) {}
					}
					return;
				} else {
					reason = response.getArgument("reason");
				}
			}

			if (callback instanceof Function) {
				try {
					callback(false, reason);
				} catch(e) {}
			}
		}

		bxtClient.doAsyncBxtRequest(msg, cb, 10);
	}

	function unlinkAlarmSystem() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.alarmSystemDevUuid, "HomeSecurity", "UnlinkSystem");
		bxtClient.sendMsg(msg);
	}

	// 0=hueBridges, 1=hueScenes, 2=deviceStatusInfo, 3=deviceConfigInfo
	initVarCount: 4

	BxtDiscoveryHandler {
		id: zwaveDiscoHandler
		equivalentDeviceTypes: ["hdrv_zwave", "happ_zware"]
		onDiscoReceived: p.zwaveUuid = deviceUuid
	}

	BxtDiscoveryHandler {
		id: smartplugDiscoHandler
		deviceType: "happ_smartplug"
		onDiscoReceived: p.smartplugUuid = deviceUuid
	}

	BxtDiscoveryHandler {
		id: hueDiscoHandler
		deviceType: "hdrv_hue"
		onDiscoReceived: p.hueUuid = deviceUuid;
	}

	BxtDiscoveryHandler {
		id: thermstatDiscoHandler
		deviceType: "happ_thermstat"
		onDiscoReceived: {
			p.thermostatUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: netconDiscoHandler
		deviceType: "hcb_netcon"
		onDiscoReceived: statusNotifyHandler.sourceUuid = deviceUuid
	}

	BxtDiscoveryHandler {
		id: heatRecoveryDevDiscoHandler
		deviceType: "ventilationHeatRecovery"
		onDiscoReceived: p.ventRecoveryDevUuid = deviceUuid;
	}

	BxtDiscoveryHandler {
		id: alarmSystemDiscoHandler
		deviceType: "alarmSystem"
		onDiscoReceived: {
			if (!feature.featAlarmControlEnabled())
				return;

			if (isHello) {
				if (!p.alarmPanelUid)
					p.alarmPanelUid = registry.registerWidget("slidePanel", p.alarmPanelUrl, controlPanelApp);
				p.alarmSystemDevUuid = deviceUuid;
				if (alarmPinIsSet === undefined)
					hasAlarmPinCode();
				hasAlarmSystem = true;
			} else {
				registry.deregisterWidget(p.alarmPanelUid);
				hasAlarmSystem = false;
				alarmPinIsSet = undefined;
				p.alarmPanelUid = "";
				p.alarmSystemDevUuid = "";
				// clear alarm data
				var tmpAlarmInfo = alarmInfo;
				for (var prop in tmpAlarmInfo)
					tmpAlarmInfo[prop] = undefined;
				alarmInfo = tmpAlarmInfo;
			}
		}
	}

	BxtDatasetHandler {
		id: hueBridgesDataset
		dataset: "hueBridges"
		discoHandler: hueDiscoHandler
		onDatasetUpdate: p.parseHueBridges(update)
	}

	BxtDatasetHandler {
		id: deviceStatusInfoDataset
		dataset: "deviceStatusInfo"
		discoHandler: smartplugDiscoHandler
		onDatasetUpdate: p.parseDeviceStatusInfo(update)
	}

	BxtDatasetHandler {
		id: deviceConfigInfoDataset
		dataset: "deviceConfigInfo"
		discoHandler: smartplugDiscoHandler
		onDatasetUpdate: p.parseDeviceConfigInfo(update)
	}

	BxtDatasetHandler {
		id: hueScenesDataset
		dataset: "hueScenes"
		discoHandler: hueDiscoHandler
		onDatasetUpdate: p.parseHueScenes(update)
	}

	BxtDatasetHandler {
		id: heatRecoveryInfoDataset
		dataset: "heatRecoveryInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: {
			p.parseHeatRecoveryInfo(update)
		}
	}

	BxtResponseHandler {
		id: hasAlarmPinCodeResponseHandler
		response: "HasPinCodeResponse"
		serviceId: "HomeSecurity"
		onResponseReceived: {
			var success = message.getArgument("success");
			if (success === "true") {
				alarmPinIsSet = message.getArgument("isSet") === "true" ? true : false;
			}
		}
	}

	BxtNotifyHandler {
		id: alarmArmableNotifyHandler
		sourceUuid: p.alarmSystemDevUuid
		serviceId: "Armable"
		initialPoll: true
		variables: ["armedStatus", "diagnosisStatus"]
		onNotificationReceived : {
			var tmpAlarmInfo = alarmInfo, value;
			if ((value = message.getArgument("armedStatus")))
				tmpAlarmInfo.alarmState = value;
			if ((value = message.getArgument("diagnosisStatus")))
				tmpAlarmInfo.diagnosisStatus = value;
			alarmInfo = tmpAlarmInfo;
		}
	}

	BxtNotifyHandler {
		id: alarmConnNotifyHandler
		sourceUuid: p.alarmSystemDevUuid
		serviceId: "ConnectedState"
		initialPoll: true
		variables: ["IsConnected"]
		onNotificationReceived : {
			var tmpAlarmInfo = alarmInfo, value;
			if ((value = message.getArgument("IsConnected")))
				tmpAlarmInfo.connected = (value === "1" ? true : false);
			alarmInfo = tmpAlarmInfo;
		}
	}

	BxtNotifyHandler {
		id: statusNotifyHandler
		serviceId: "status"
		onNotificationReceived : {
			var value;
			if ((value = message.getArgument("internet")))
				internetState = (value === "1");
		}
	}

	BxtActionHandler {
		id: finishedLinkingHandler
		action: "FinishedLinking"
		serviceId: "HomeSecurity"
		onActionReceived: {
			var success = false, reason;
			if (message) {
				success = message.getArgument("success") === "true" ? true : false;
				reason = message.getArgument("reason");
			}
			finishedAlarmSystemLinking(success, reason);
		}
	}
}
