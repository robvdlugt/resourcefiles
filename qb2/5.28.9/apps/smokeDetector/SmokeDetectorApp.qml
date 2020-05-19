import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

App {
	id: smokeDetectorApp

	property int _NOTIFY_TEXT_PHONE1:	1
	property int _NOTIFY_TEXT_PHONE2:	2
	property int _NOTIFY_VOICE_PHONE1:	4
	property int _NOTIFY_VOICE_PHONE2:	8

	property url smokeDetectorImageUrl: "drawables/smokedetector.svg"
	property url smokeDetectorScreenUrl: "SmokeDetectorScreen.qml"
	property url notificationPreferencesScreenUrl: "NotificationPreferencesScreen.qml"
	property url welcomeScreenUrl: "WelcomeScreen.qml"
	property url addSmokeDetectorScreenUrl: "AddSmokeDetectorWizard.qml"
	property url editSmokeDetectorScreenUrl: "EditSmokeDetectorScreen.qml"
	property url linkErrorScreenUrl: "LinkErrorScreen.qml"
	property url editSensitivityScreenUrl: "EditSensitivityScreen.qml"
	property url alarmPopupUrl: "AlarmPopup.qml"
	property url trayUrl: "SmokeDetectorTray.qml"
	property url restoreSmokedetectorPopupUrl: "RestoreSmokeDetectorPopup.qml"
	property url statusExplanationPopupUrl: "StatusExplanationPopup.qml"
	property url colorExplanationPopupUrl: "ColorExplanationPopup.qml"

	// Wizard frame urls, displayed after the test alarm screen
	property url connectSmokeDetectorFrameUrl: "ConnectSmokeDetectorFrame.qml"
	property url connectionQualityFrameUrl: "ConnectionQualityFrame.qml"
	property url qualityAcknowledgeFrameUrl: "QualityAcknowledgeFrame.qml"
	property url nameFrameUrl: "NameFrame.qml"
	property url wizardFinishFrame: "WizardFinishFrame.qml"

	// MainScreen frame urls
	property url smokeDetectorsFrameUrl: "SmokeDetectorsFrame.qml"
	property url alertFrameUrl: "AlertFrame.qml"

	// Settings
	property url settingsScreenUrl: "qrc:/apps/settings/SettingsScreen.qml"
	property url notificationsFrameUrl: "qrc:/apps/systemSettings/NotificationsFrame.qml"

	property MenuItem smokeDetectorMenu
	property Popup alarmPopup
	property SmokeDetectorTray smokeDetectorTray

	property variant linkedSmokedetectors: []
	property string currentSmokedetectorUuid: ""
	property string currentSmokedetectorName: ""
	property bool zwaveCommandStopped

	property variant eventUserInfo: {
		'phone1': '',
		'phone2': ''
	}

	property variant eventUserContactPref: {
		'enableVoice': '',
		'enableText': '',
		'textPhone1': '',
		'textPhone2': '',
		'voicePhone1': '',
		'voicePhone2': ''
	}

	// For unit test
	property BxtDatasetHandler tst_smokedetectorDsHandler: smokedetectorDataset
	property BxtDatasetHandler tst_eventContactsDsHandler: eventContactsDsHandler
	property BxtDatasetHandler tst_eventScenariosDsHandler: eventScenariosDsHandler

	signal currentSmokedetectorRemoved(string byebyeUuid)

	QtObject {
		id: p

		property string zwaveUuid
		property string eventmgrUuid

		property string lastNotifyUuid
		property string lastNotifyTime

		function gotoNotificationsFrame() {
			stage.openFullscreen(settingsScreenUrl, {categoryUrl: notificationsFrameUrl});
		}
	}

	function init() {
		registry.registerWidget("menuItem", null, smokeDetectorApp, "smokeDetectorMenu", {objectName: "smokeMenuItem", label: qsTr("Smoke detector"), image: smokeDetectorImageUrl, args:{showDefault: true}, weight: 140});
		registry.registerWidget("screen", smokeDetectorScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", notificationPreferencesScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editSensitivityScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("smokeDetectorFrame", smokeDetectorsFrameUrl, smokeDetectorApp, "smokeDetectorsFrame", {categoryName: qsTr("Overview"), categoryWeight: 100, showDefault: true});
		registry.registerWidget("smokeDetectorFrame", alertFrameUrl, smokeDetectorApp, "alertFrame", {categoryName: qsTr("Alert"), categoryWeight: 200});
		registry.registerWidget("screen", addSmokeDetectorScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editSmokeDetectorScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", linkErrorScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", welcomeScreenUrl, smokeDetectorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("popup", alarmPopupUrl, smokeDetectorApp, "alarmPopup");
		registry.registerWidget("systrayIcon", trayUrl, smokeDetectorApp, "smokeDetectorTray");
	}

	function checkWarnEmptyPhoneNumbers() {
		if (eventUserInfo["phone1"] === "" && eventUserInfo["phone2"] === "") {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Smoke detection warnings"), qsTr("configure-phonenumbers-popup-text"), qsTr("Configure notifications"), p.gotoNotificationsFrame, qsTr("Not now"));
			qdialog.context.bodyFontPixelSize = qfont.tileTitle;
			return false;
		}
		return true;
	}

	function isLinkedSmokedetector(uuid) {
		for (var i in linkedSmokedetectors) {
			if (linkedSmokedetectors[i].intAddr === uuid) {
				return true;
			}
		}
		return false;
	}

	function getSmokedetectorName(uuid) {
		for (var i in linkedSmokedetectors) {
			if (linkedSmokedetectors[i].intAddr === uuid) {
				return linkedSmokedetectors[i].name;
			}
		}
		return null;
	}

	function notifyUser(smokedetectorUUid, stateChangeTime, curState) {
		if ((curState === "alarmTest" || curState === "alarm") && (smokedetectorUUid !== p.lastNotifyUuid || stateChangeTime !== p.lastNotifyTime)) {
			var smokedetectorName = "";

			// Fetch the smokedetector name from the known smokedetectors
			for (var i in linkedSmokedetectors) {
				if (linkedSmokedetectors[i].intAddr === smokedetectorUUid) {
					smokedetectorName = linkedSmokedetectors[i].name;
					break;
				}
			}

			// Only show if the smoke detector is currently known
			if (smokedetectorName !== "") {
				// Show the overlay popup
				screenStateController.wakeup();
				alarmPopup.curState = curState;
				alarmPopup.smokedetectorName = smokedetectorName;
				if (alarmPopup.visible === false) {
					alarmPopup.show();
				}

				p.lastNotifyTime = stateChangeTime;
				p.lastNotifyUuid = smokedetectorUUid;
			}
		}
	}

	function parseSmokedetectors(update) {
		var smokedetectorNode = update.getChild("device", 0);
		var tmpSmokedetectors = [];

		while (smokedetectorNode) {
			var smokedetector = {};
			var childNode = smokedetectorNode.child;
			while (childNode) {
				smokedetector[childNode.name] = childNode.text;
				childNode = childNode.sibling;
			}
			tmpSmokedetectors.push(smokedetector);
			smokedetectorNode = smokedetectorNode.next;
		}
		linkedSmokedetectors = tmpSmokedetectors;

		// If there are already smokedetectors linked show the main smokedetectorScreen
		if (linkedSmokedetectors.length > 0) {
			smokeDetectorMenu.screenUrl = smokeDetectorScreenUrl
		} else {
			smokeDetectorMenu.screenUrl = welcomeScreenUrl
		}

		initVarDone(0);
	}

	function addDeviceToScenario(uuid, type) {
		if (p.eventmgrUuid && uuid && type) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.eventmgrUuid, "specific1", "AddSmokeDetector");
			msg.addArgument("devUuid", uuid);
			msg.addArgument("devType", type);

			bxtClient.sendMsg(msg);

			// Store the current uuid of the smokedetector in the app
			currentSmokedetectorUuid = uuid;
		}
	}

	function removeDeviceFromScenario(uuid) {
		if (p.eventmgrUuid && uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.eventmgrUuid, "specific1", "RemoveDevice");
			msg.addArgument("devUuid", uuid);
			msg.addArgument("scenarioType", "all");

			bxtClient.sendMsg(msg);
		}
	}

	function forceRemoveDevice(uuid) {
		if (uuid) {
			// Remove from hdrv_zwave
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, "specific1", "RemoveDevice");
			bxtClient.sendMsg(msg);

			// Remove from happ_eventmgr
			removeDeviceFromScenario(uuid);
		}
	}

	function setDeviceName(name) {
		if (p.eventmgrUuid && name) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.eventmgrUuid, "specific1", "SetDeviceName");
			msg.addArgument("devUuid", currentSmokedetectorUuid);
			msg.addArgument("devName", name);

			bxtClient.sendMsg(msg);

			// Store the current smokedetector name in the app
			currentSmokedetectorName = name;
		}
	}

	function onEventContactsChanged(update) {
		var tempEventUserInfo = eventUserInfo;

		var contact = update.getChild("contact");
		for (; contact; contact = contact.next) {
			if (contact.getChildText("contactType") === "user") {
				tempEventUserInfo["phone1"] = contact.getChildText("phone1");
				tempEventUserInfo["phone2"] = contact.getChildText("phone2");
			}
			// TODO: not yet parsing buddies
		}

		eventUserInfo = tempEventUserInfo;
		initVarDone(1);
	}

	function removeVoiceTextPrefs(isPhone1) {
		if (isPhone1) {
			setVoiceTextPref(true, false, eventUserContactPref["voicePhone2"]);
			setVoiceTextPref(false, false, eventUserContactPref["textPhone2"]);
		} else {
			setVoiceTextPref(true, eventUserContactPref["voicePhone1"], false);
			setVoiceTextPref(false, eventUserContactPref["textPhone1"], false);
		}
		return false;
	}

	function setSDPrefsAutomatic(isPhone1) {
		setVoiceTextEnabled(true, true);
		setVoiceTextEnabled(false, true);
		if(isPhone1) {
			setVoiceTextPref(true, true, eventUserContactPref["voicePhone2"]);
			setVoiceTextPref(false, true, eventUserContactPref["textPhone2"]);
		} else {
			setVoiceTextPref(true, eventUserContactPref["voicePhone1"], true);
			setVoiceTextPref(false, eventUserContactPref["textPhone1"], true);
		}
		return false;
	}

	function setSDSensitivity(uuid, sensitivity) {
		console.debug("sending to uuid " + uuid);
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, "specific1", "SetSmokeDetectorSensitivity");
		msg.addArgument("sensitivityLevel", sensitivity);
		bxtClient.sendMsg(msg);
	}

	function onEventScenariosChanged(update) {
		var tempEventUserContactPref = {};

		var scenario = update.getChild("scenario");
		for (; scenario; scenario = scenario.next) {
			if (scenario.getChildText("sType") === "smokeScenario") {
				var states = scenario.getChild("states");
				var state = states.getChild("state");
				for (; state; state = state.next) {
					if (state.getChildText("ssType") === "alarm") {
						var notifies = state.getChild("notifies");
						if (notifies)
						{
							var notify = notifies.getChild("notify");
							if (notify)
							{
								var notifyPref = notify.getChildText("pref");
								tempEventUserContactPref["enableVoice"] = (notify.getChildText("enableVoice") === "1");
								tempEventUserContactPref["enableText"] = (notify.getChildText("enableText") === "1");
								tempEventUserContactPref["textPhone1"] = (notifyPref & _NOTIFY_TEXT_PHONE1) > 0;
								tempEventUserContactPref["textPhone2"] = (notifyPref & _NOTIFY_TEXT_PHONE2) > 0;
								tempEventUserContactPref["voicePhone1"] = (notifyPref & _NOTIFY_VOICE_PHONE1) > 0;
								tempEventUserContactPref["voicePhone2"] = (notifyPref & _NOTIFY_VOICE_PHONE2) > 0;
							}
						}
					}
				}
				var curState = scenario.getChildText("curState");
				var lastStateChangeByDev = scenario.getChildText("lastStateChangeByDev");
				var lastStateChangeTime = scenario.getChildText("lastStateChangeTime");
				notifyUser(lastStateChangeByDev, lastStateChangeTime, curState);
			}
		}

		eventUserContactPref = tempEventUserContactPref;
		initVarDone(2);
	}

	function setVoiceTextEnabled(isVoice, isEnabled) {
		var tempEventUserContactPref = eventUserContactPref;
		if (isVoice) {
			tempEventUserContactPref["enableVoice"] = isEnabled;
		} else {
			tempEventUserContactPref["enableText"] = isEnabled;
		}
		eventUserContactPref = tempEventUserContactPref;
		sendUserContactPref();
	}

	function setVoiceTextPref(isVoice, phone1, phone2)
	{
		var tempEventUserContactPref = eventUserContactPref;
		if (isVoice) {
			tempEventUserContactPref["voicePhone1"] = phone1;
			tempEventUserContactPref["voicePhone2"] = phone2;
		} else {
			tempEventUserContactPref["textPhone1"] = phone1;
			tempEventUserContactPref["textPhone2"] = phone2;
		}
		eventUserContactPref = tempEventUserContactPref;
		sendUserContactPref();
	}

	function sendUserContactPref() {
		var tempEventUserContactPref = eventUserContactPref;
		var notifyPref = 0;
		if (tempEventUserContactPref["textPhone1"]) {
			notifyPref += _NOTIFY_TEXT_PHONE1;
		}
		if (tempEventUserContactPref["textPhone2"]) {
			notifyPref += _NOTIFY_TEXT_PHONE2;
		}
		if (tempEventUserContactPref["voicePhone1"]) {
			notifyPref += _NOTIFY_VOICE_PHONE1;
		}
		if (tempEventUserContactPref["voicePhone2"]) {
			notifyPref += _NOTIFY_VOICE_PHONE2;
		}

		var esXml = "<eventScenarios><eventScenario>smokeScenario</eventScenario><eventScenario>batteryScenario</eventScenario><eventScenario>connectedScenario</eventScenario></eventScenarios>";
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.eventmgrUuid, "specific1", "SetUserContactPreferences");
		msg.addArgumentXmlText(esXml);
		msg.addArgument("notifyType", notifyPref);
		msg.addArgument("enableVoice", tempEventUserContactPref["enableVoice"] ? 1 : 0);
		msg.addArgument("enableText", tempEventUserContactPref["enableText"] ? 1 : 0);
		bxtClient.sendMsg(msg);
	}

	onLinkedSmokedetectorsChanged: {
		var showTray = false;
		for (var i in linkedSmokedetectors) {
			var battLevel = parseInt(linkedSmokedetectors[i].batteryLevel);
			if (linkedSmokedetectors[i].connected === "0" ||
					(battLevel >= 0 && battLevel <= 10)) {
				showTray = true;
			}
		}
		if (smokeDetectorTray) {
			if (showTray)
				smokeDetectorTray.show();
			else
					smokeDetectorTray.hide();
		}
	}

	BxtDiscoveryHandler {
		id: zwaveDiscoHandler
		equivalentDeviceTypes: ["hdrv_zwave", "happ_zware"]
		onDiscoReceived: {
			p.zwaveUuid = deviceUuid;

			if (!isHello) {
				var byeByeUuid = devNode.getChild("device").getAttribute("uuid");
				if (byeByeUuid === currentSmokedetectorUuid) {
					currentSmokedetectorUuid = "";
					currentSmokedetectorName = "";
					currentSmokedetectorRemoved(byeByeUuid);
				}
			}
		}
	}

	initVarCount: 3

	BxtDiscoveryHandler {
		id: eventmgrDiscoHandler
		deviceType: "happ_eventmgr"
		onDiscoReceived: {
			p.eventmgrUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: smokedetectorDataset
		dataset: "smokeDetectors"
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: parseSmokedetectors(update)
	}

	BxtDatasetHandler {
		id: eventContactsDsHandler
		dataset: "eventContacts"
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: onEventContactsChanged(update)
	}

	BxtDatasetHandler {
		id: eventScenariosDsHandler
		dataset: "eventScenarios"
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: onEventScenariosChanged(update)
	}
}
