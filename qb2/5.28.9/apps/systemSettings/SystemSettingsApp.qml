import QtQuick 2.1
import BxtClient 1.0
import FileIO 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: systemSettingsApp
	property url screenFrameUrl: "ScreenFrame.qml"
	property url productFrameUrl: "ProductFrame.qml"
	property url overviewFrameUrl: "OverviewFrame.qml"
	property url softwareFrameUrl: "SoftwareFrame.qml"
	property url notificationsFrameUrl: "NotificationsFrame.qml"
	property url brightnessSetScrUrl: "BrightnessSettingsScreen.qml"
	property url languageScreenUrl: "LanguageScreen.qml"
	property url softwareUpdateScreenUrl: "SoftwareUpdateScreen.qml"
	property url parentalControlScreenUrl: "ParentalControlScreen.qml"
	property url parentalControlEditPinScreenUrl: "ParentalControlEditPinScreen.qml"
	property url parentalControlRecoveryScreenUrl: "ParentalControlResetScreen.qml"
	property url scrOffSettingScreenUrl: "ScrOffSettingScreen.qml"
	property url restartScreenUrl: "RestartScreen.qml"
	property url factoryResetScreenUrl: "FactoryResetScreen.qml"
	property url cleanLoadingPopupUrl: "CleanLoadingPopup.qml"
	property Popup cleanLoadingPopup
	property url softwareUpdateInProgressPopupUrl: "SoftwareUpdateInProgressPopup.qml"
	property Popup softwareUpdateInProgressPopup
	property url maUpdateScreenUrl: "MaUpdateScreen.qml"
	property url maUpdateInProgressPopupUrl: "MaUpdateInProgressPopup.qml"
	property Popup maUpdateInProgressPopup
	property Popup fullScreenThrobber
	property url rebootInProgressPopupUrl: "RebootInProgressPopup.qml"
	property Popup rebootInProgressPopup
	property url errorSystrayIconUrl: "SystemSettingsErrorTray.qml"
	property url updateSystrayIconUrl: "SystemUpdateTray.qml"
	property url settingsScreenUrl: "qrc:/apps/settings/SettingsScreen.qml"
	property url softwareUpdateWizardOverviewUrl: "SoftwareUpdateWizardOverview.qml"
	property url softwareUpdateWizardScreenUrl: "SoftwareUpdateWizardScreen.qml"
	property url smeSetScreenUrl: "SMESetScreen.qml"

	property url eMetersScreenUrl: "qrc:/apps/eMetersSettings/EMetersScreen.qml"
	property url activationScreenUrl: "../internetSettings/ActivationScreen.qml"

	property variant boilerAdapterInfo: {
		'AvailableVersion': '-',
		'SoftwareVersion': '-',
		'HardwareVersion': '-',
		'UpdateAvailable': false,
		'Manufacturer': '-',
		'SerialNumber': '-',
		'DeviceModel': '-',
	}

	property variant meterAdapterInfo: []
	property variant usageDevicesInfo: ({})

	property variant displayInfo: {
		'AvailableVersion': '-',
		'SoftwareVersion': '-',
		'HardwareVersion': '-',
		'UpdateAvailable': false,
		'CheckingForUpdate': false,
		'Manufacturer': '-',
		'SerialNumber': '-',
		'DeviceModel': '-',
	}

	property variant eventUserInfo: {
		'phone1': '',
		'phone2': ''
	}

	property bool disableFactoryReset: false

	property int maFwUpdateStatus
	property string maFwUpdateStatusMsg
	property int maFwUpdatePercentage: 0

	property int _FIRMWARE_UPDATE_INACTIVE:		0
	property int _FIRMWARE_UPDATE_STARTWAIT:	1
	property int _FIRMWARE_UPDATE_INPROGRESS:	2
	property int _FIRMWARE_UPDATE_FAILED:		3
	property int _FIRMWARE_UPDATE_COMPLETE:		4
	property int errorCount: 0
	property int systrayErrorCount: 0

	property variant languageList : globals.languageList

	property Popup waitPopup
	property url waitPopupUrl: "qrc:/qb/components/WaitPopup.qml"
	property Popup smeWaitPopup

	property bool enableSME: globals.productOptions["SME"] === "1"

	signal systemInfoUpdate
	signal maFwUpdateStatusUpdate
	signal checkFirmwareUpdateResponseReceived

	onEnableSMEChanged: {
		if (smeWaitPopup !== null && smeWaitPopup.showing)
			smeWaitPopup.hide();
	}

	// 0 = eventScenarios, 1 = eventContacts, 2 = usageDeviceInfo
	initVarCount: 3

	FileIO {
		id: downloadStatusFile
		source: "file:///tmp/update.status.vars"
		onError: console.log("Can't open /tmp/update.status.vars")
	}

	function init() {
		disableFactoryReset = feature.appSystemSettingsFactoryResetDisabled()

		registry.registerWidget("settingsFrame", screenFrameUrl, systemSettingsApp, "screenFrame", {categoryName: qsTr("Screen"), categoryWeight: 200});
		registry.registerWidget("settingsFrame", productFrameUrl, systemSettingsApp, "productFrame", {categoryName: qsTr("Product"), categoryWeight: 500});
		registry.registerWidget("settingsFrame", overviewFrameUrl, systemSettingsApp, "overviewFrame", {categoryName: qsTr("Overview"), categoryWeight: 100});
		registry.registerWidget("settingsFrame", softwareFrameUrl, systemSettingsApp, "softwareFrame", {categoryName: qsTr("Software"), categoryWeight: 250});
		if (feature.featContactSettingsTabEnabled()) {
			registry.registerWidget("settingsFrame", notificationsFrameUrl, systemSettingsApp, "notificationsFrame", {categoryName: qsTr("Notifications"), categoryWeight: 480});
		}
		registry.registerWidget("screen", brightnessSetScrUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", scrOffSettingScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", restartScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", softwareUpdateScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", factoryResetScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", maUpdateScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", languageScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", parentalControlScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", parentalControlEditPinScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", parentalControlRecoveryScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
		if (feature.featSMEEnabled()) {
			registry.registerWidget("screen", smeSetScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});
			registry.registerWidget("popup", waitPopupUrl, systemSettingsApp, "smeWaitPopup");
		}
		registry.registerWidget("popup", cleanLoadingPopupUrl, systemSettingsApp, "cleanLoadingPopup");
		registry.registerWidget("popup", softwareUpdateInProgressPopupUrl, systemSettingsApp, "softwareUpdateInProgressPopup");
		registry.registerWidget("popup", maUpdateInProgressPopupUrl, systemSettingsApp, "maUpdateInProgressPopup");
		registry.registerWidget("popup", Qt.resolvedUrl("qrc:/qb/components/FullScreenThrobber.qml"), systemSettingsApp, "fullScreenThrobber");
		registry.registerWidget("popup", rebootInProgressPopupUrl, systemSettingsApp, "rebootInProgressPopup");
		registry.registerWidget("systrayIcon", errorSystrayIconUrl, systemSettingsApp);
		registry.registerWidget("systrayIcon", updateSystrayIconUrl, systemSettingsApp);

		registry.registerWidget("screen", softwareUpdateWizardScreenUrl, systemSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("popup", waitPopupUrl, systemSettingsApp, "waitPopup");
		waitPopup.title = qsTr("Data is now destroyed");
		waitPopup.text = qsTr("There is no way back...");

		notifications.registerType("update", notifications.prio_HIGHEST, Qt.resolvedUrl("drawables/notification-update.svg"),
								   settingsScreenUrl, {"categoryUrl": softwareFrameUrl}, qsTr("notification-update-grouped"));
		notifications.registerSubtype("update", "display", softwareUpdateScreenUrl, {});

		notifications.registerType("error", notifications.prio_HIGH, Qt.resolvedUrl("drawables/notification-error.svg"),
								   settingsScreenUrl, {"categoryUrl": overviewFrameUrl}, qsTr("notification-error-grouped"));

		notifications.registerType("task", notifications.prio_HIGH, Qt.resolvedUrl("qrc:/images/notification-task.svg"));

		// error subtypes are registered on each app that can represent errors
	}

	QtObject {
		id: p

		property string scsyncMsgUuid
		property string configMsgUuid
		property string hdrv_p1Uuid
		property string hdrv_zwaveUuid
		property string happ_eventmgrUuid

		property variant contactPrefs
		property variant showContactPopupValues

		property int showContactPopups
		property int _POPUP_SD: 1
		property int _POPUP_BM: 2
		property int _NOTIFY_TEXT_PHONE1:	1
		property int _NOTIFY_TEXT_PHONE2:	2
		property int _NOTIFY_VOICE_PHONE1:	4
		property int _NOTIFY_VOICE_PHONE2:	8

		property bool smeToSet

		property url notificationsPopupUrl: "NotificationsPopup.qml"

		function isVersionUpdate(currentVersion, latestVersion) {
			var cur, latest;

			// Split major, minor, build
			var curSplit = currentVersion.split(".");
			var latestSplit = latestVersion.split(".");

			// Iterate over major, minor, build
			for (var i = 0; i < curSplit.length && curSplit.length === latestSplit.length; i++) {
				cur = parseInt(curSplit[i]);
				latest = parseInt(latestSplit[i]);

				if (!isNaN(cur) && !isNaN(latest)) {
					if (latest > cur)
						return true;
					else if (latest < cur)
						return false;
				}
			}
			return false; // equal if this point is reached
		}

		// currentVersion, latestVersion may contain multiple versions; e.g. 36/34 or 0.16/0.11
		function isReleaseUpdate(currentVersion, latestVersion) {
			var isVersionInfoNotAvailable = ((currentVersion === "-") || (latestVersion === "-"));
			if (isVersionInfoNotAvailable)
				return false;

			var curRelease = currentVersion.split("/");
			var latestRelease = latestVersion.split("/");
			var doUpdate = false;

			// Check for all the releases
			for (var i = 0; i < curRelease.length && curRelease.length === latestRelease.length; i++) {
				doUpdate |= isVersionUpdate(curRelease[i], latestRelease[i]);
			}
			return Boolean(doUpdate);
		}

		/*  This function expects that p.showContactPopupValues contains a JSON object
		 *  with subobjects of the following format:
		 * {
		 *		contactChannelFieldName1 (one of the availableFields from the var below):
				{
		 *			value: "%string with contact channel information",
		 *			service: %integer containing the OR'd p._POPUP_XXX constants for the services to be checked for this channel%
		 *		},
		 *		...
		 *	}
		 * It also expects that all the services set on the .service property of the
		 * subobjects above are also OR'd to p.showContactPopups, i.e:
		 * p.showContactPopups = p._POPUP_XXX1 | p._POPUP_XXX2 | ...;
		 *
		 * This function will go thru this data structure and display a popup asking the
		 * user to confirm the usage of the specified comm. channels for each specificed
		 * service. Channels belonging to the same category will be combined on one popup.
		 */
		function checkShowContactPopup() {
			// this array contains the name of the possible contact fields and are
			// grouped by same field types in order for them to be combined in the popup
			var availableFields = [["phone1", "phone2"]];
			var source = [];
			var userValue = [];
			var serviceToShow = 0;
			var popupState = "";

			if (typeof p.showContactPopupValues !== "object" || !p.showContactPopups)
				return;

			if (p.showContactPopups & p._POPUP_SD) {
				serviceToShow = p._POPUP_SD;
				popupState = "SD";
			} else if (p.showContactPopups & p._POPUP_BM) {
				serviceToShow = p._POPUP_BM;
				popupState = "BM";
			}

			availableFields.some(function(category) {
				var found = false;
				category.forEach(function(sourceName) {
					if (p.showContactPopupValues[sourceName] &&
							p.showContactPopupValues[sourceName].services & serviceToShow) {
						source.push(sourceName);
						userValue.push(p.showContactPopupValues[sourceName].value);
						found = true;
					}
				});
				return found;
			});

			if (!source.length) {
				// there are no more fields to show for the current service, so disable it
				p.showContactPopups &= ~serviceToShow;
				// when there are other services still to check, reschedule the call to this function
				if (p.showContactPopups)
					checkShowContactPopup();
				return;
			}

			var popupTitle = "";
			if (source.length > 1) {
				popupTitle = qsTr("use-these-phonenumbers");
			} else {
				popupTitle = qsTr("use-this-phonenumber");
			}

			qdialog.showDialog(qdialog.SizeLarge, popupTitle, p.notificationsPopupUrl,
					qsTr("Confirm"), function(){ p.contactPrefCB(serviceToShow, source, true); },
					qsTr("Not now"), function(){ p.contactPrefCB(serviceToShow, source, false); });
			qdialog.context.dynamicContent.state = popupState;
			qdialog.context.dynamicContent.userValue = userValue;
		}

		function contactPrefCB(type, source, set) {
			if (!Array.isArray(source))
				return;

			if (set === true) {
				setContactPref(type, source);
			}

			source.forEach(function(sourceName) {
				var newValues = p.showContactPopupValues;
				newValues[sourceName].services &= ~type;
				p.showContactPopupValues = newValues;
			});

			// Show next popup
			if (moreContactPopupsToShow()) {
				checkNextContactPopupTimer.start();
			}
		}

		function moreContactPopupsToShow() {
			if (typeof p.showContactPopupValues !== "object")
				return false;

			return Object.keys(p.showContactPopupValues).some(function(source) {
				// some() returns true when one of the elements still contains a service to be shown
				return (p.showContactPopupValues[source].services !== 0 ? true : false);
			});
		}

		signal smeWaitPopupTimerTriggered
		onSmeWaitPopupTimerTriggered: {
			sendSetSMEOptionMsg(smeToSet);
			smeWaitPopup.actionTimer.triggered.disconnect(smeWaitPopupTimerTriggered);
		}

		function sendSetSMEOptionMsg(enableSME) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncMsgUuid, "specific1", "SetSMEOption");
			msg.addArgument("enableSME", enableSME ? "1" : "0");
			bxtClient.sendMsg(msg);
		}
	}

	function setSMEOption(enable) {
		p.smeToSet = enable;
		smeWaitPopup.title = qsTr("One moment...");
		smeWaitPopup.text = enable ? qsTr("sme-wait-popup-set-business") : qsTr("sme-wait-popup-set-home");
		smeWaitPopup.actionTimer.triggered.connect(p.smeWaitPopupTimerTriggered);
		smeWaitPopup.show();
		smeWaitPopup.actionTimer.start();
	}

	function parseUndefOrInt(value) {
		return (typeof value !== "undefined" ? parseInt(value) : 0);
	}

	/*
	 * This function sets the contact preferences for the service determined by the "type"
	 * argument (one of the p._POPUP_XXX options), based on the array of strings given to the
	 * "source" parameter ("phone1", ...)
	 */
	function setContactPref(type, source) {
		var pref, esXml, enableVoice, enableText;
		var fieldPrefix, voiceAllowed, textAllowed;

		// Get old preferences and eventScenarios based on service type
		if (type === p._POPUP_SD) {
			esXml = "<eventScenarios><eventScenario>smokeScenario</eventScenario><eventScenario>batteryScenario</eventScenario><eventScenario>connectedScenario</eventScenario></eventScenarios>";
			fieldPrefix = "sd";
			voiceAllowed = true;
			textAllowed = true;
		} else if (type === p._POPUP_BM) {
			esXml = "<eventScenarios><eventScenario>boilerScenario</eventScenario></eventScenarios>";
			fieldPrefix = "bm";
			voiceAllowed = false;
			textAllowed = true;
		} else {
			return false;
		}

		pref = parseUndefOrInt(p.contactPrefs[fieldPrefix+"_pref"]);
		enableVoice = parseUndefOrInt(p.contactPrefs[fieldPrefix+"_enableVoice"]);
		enableText = parseUndefOrInt(p.contactPrefs[fieldPrefix+"_enableText"]);

		if (textAllowed || voiceAllowed) {
			if (source.indexOf("phone1") >= 0) {
				if (!enableVoice)
					pref &= ~(p._NOTIFY_VOICE_PHONE1 | p._NOTIFY_VOICE_PHONE2);
				if (!enableText)
					pref &= ~(p._NOTIFY_TEXT_PHONE1 | p._NOTIFY_TEXT_PHONE2);
				if (voiceAllowed) {
					pref |= p._NOTIFY_VOICE_PHONE1;
					enableVoice = 1;
				}
				if (textAllowed) {
					pref |= p._NOTIFY_TEXT_PHONE1;
					enableText = 1;
				}
			}
			if (source.indexOf("phone2") >= 0) {
				if (!enableVoice)
					pref &= ~(p._NOTIFY_VOICE_PHONE1 | p._NOTIFY_VOICE_PHONE2);
				if (!enableText)
					pref &= ~(p._NOTIFY_TEXT_PHONE1 | p._NOTIFY_TEXT_PHONE2);
				if (voiceAllowed) {
					pref |= p._NOTIFY_VOICE_PHONE2;
					enableVoice = 1;
				}
				if (textAllowed) {
					pref |= p._NOTIFY_TEXT_PHONE2;
					enableText = 1;
				}

			}
		}

		// Build msg
		var msg =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.happ_eventmgrUuid, "specific1", "SetUserContactPreferences");
		msg.addArgumentXmlText(esXml);
		msg.addArgument("notifyType", pref);
		msg.addArgument("enableVoice", enableVoice);
		msg.addArgument("enableText", enableText);
		bxtClient.sendMsg(msg);

		return true;
	}

	function getMeterAdapterInfo(index, name) {
		if (index < meterAdapterInfo.length) {
			return meterAdapterInfo[index][name];
		} else {
			return "-";
		}
	}

	function getMeterAdapterUpdateAvailable(index) {
		if (index < meterAdapterInfo.length) {
			return meterAdapterInfo[index]['UpdateAvailable'];
		} else {
			return false;
		}
	}

	function hasUpdateMeterAdapter() {
		for (var i=0; i < meterAdapterInfo.length; i++)
			if (meterAdapterInfo[i]['UpdateAvailable'])
				return true;

		return false;
	}

	function getDeviceInfo() {
		var getDeviceInfoMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncMsgUuid, "specific1", "GetDeviceInfo");
		bxtClient.sendMsg(getDeviceInfoMessage);
	}

	function factoryReset() {
		var factoryResetMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "FactoryReset");
		bxtClient.sendMsg(factoryResetMessage);
	}

	function restartToon() {
		var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "RequestReboot");
		bxtClient.sendMsg(restartToonMessage);
	}

	function checkFirmwareUpdate() {
		var checkFirmwareUpdateMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "CheckFirmwareUpdate");
		bxtClient.sendMsg(checkFirmwareUpdateMessage);
	}

	function getDeviceIdentifier(uuid){
		var info = usageDevicesInfo[uuid];
		return info ? info.deviceIdentifier : "";
	}

	/**
	 * Parse string in format
	 * action=Installing&item=100&items=100&pkg=
	 * Where action can be 'Downloading' or 'Installing'.
	 * Number after item= is the status of the update.
	 */
	function getSoftwareUpdateStatus() {
		var downloadStatusText = downloadStatusFile.read();
		var keysAndValues = downloadStatusText.split('&');
		var retVal = {'action': '', 'item': 0}
		var keyvaluepair = ''

		for (var i = 0; i < keysAndValues.length; i++) {
			keyvaluepair = keysAndValues[i].split('=');
			retVal[keyvaluepair[0]] = keyvaluepair[1];
		}
		return retVal;
	}

	function startSoftwareUpdate(callback) {
		var startSoftwareUpdateMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "DoFirmwareUpdate");
		startSoftwareUpdateMessage.addArgument("version", displayInfo.AvailableVersion);
		// Give a timeout of ten hours because the response comes after downloading of new fw is done.
		bxtClient.doAsyncBxtRequest(startSoftwareUpdateMessage, callback, 36000);
	}

	function startMeterAdapterUpdate(uuid) {
		var startMeterAdapterUpdateMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hdrv_p1Uuid, "specific1", "ForceEnableUpgrade");
		startMeterAdapterUpdateMessage.addArgument("devUuid", uuid);
		bxtClient.sendMsg(startMeterAdapterUpdateMessage);
	}

	function getMeterAdapterUpdateStatus() {
		var meterAdapterStatusMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hdrv_p1Uuid, "specific1", "GetFirmwareUpdateStatus");
		bxtClient.sendMsg(meterAdapterStatusMessage);
	}

	function onEventContactsChanged(update) {
		var tempEventUserInfo = {"phone1": "", "phone2": ""};

		var contact = update.getChild("contact");
		for (; contact; contact = contact.next) {
			if (contact.getChildText("contactType") === "user") {
				tempEventUserInfo["phone1"] = contact.getChildText("phone1");
				tempEventUserInfo["phone2"] = contact.getChildText("phone2");
			}
			// TODO: not yet parsing buddies
		}
		eventUserInfo = tempEventUserInfo
		initVarDone(1);
	}

	function saveUserContactInfo(phone, primary) {
		var tmpUserInfo = eventUserInfo;
		tmpUserInfo[primary ? "phone1" : "phone2"] = phone;
		eventUserInfo = tmpUserInfo;

		sendUserContactInfo();
	}

	function sendUserContactInfo() {
		if (p.happ_eventmgrUuid) {
			var addContactMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.happ_eventmgrUuid, "specific1", "AddContact");
			addContactMsg.addArgument("type", "user");
			if (eventUserInfo["phone1"])
				addContactMsg.addArgument("phone1", eventUserInfo["phone1"]);
			if (eventUserInfo["phone2"])
				addContactMsg.addArgument("phone2", eventUserInfo["phone2"]);
			bxtClient.sendMsg(addContactMsg);
		}
	}

	function onEventScenariosChanged(update) {
		var tempContactPref = {};
		var states, state, notifies, notify;

		var scenario = update.getChild("scenario");
		for (; scenario; scenario = scenario.next) {
			if (scenario.getChildText("sType") === "smokeScenario") {
				states = scenario.getChild("states");
				state = states.getChild("state");
				for (; state; state = state.next) {
					if (state.getChildText("ssType") === "alarm") {
						notifies = state.getChild("notifies");
						if (notifies) {
							notify = notifies.getChild("notify");
							if (notify) {
								tempContactPref["sd_pref"] = parseInt(notify.getChildText("pref"));
								tempContactPref["sd_enableVoice"] = parseInt(notify.getChildText("enableVoice"));
								tempContactPref["sd_enableText"] = parseInt(notify.getChildText("enableText"));
							}
						}
					}
				}
			} else if (scenario.getChildText("sType") === "boilerScenario") {
				states = scenario.getChild("states");
				state = states.getChild("state");
				for (; state; state = state.next) {
					if (state.getChildText("ssType") === "alarm") {
						notifies = state.getChild("notifies");
						if (notifies) {
							notify = notifies.getChild("notify");
							if (notify)	{
								tempContactPref["bm_pref"] = parseInt(notify.getChildText("pref"));
								tempContactPref["bm_enableVoice"] = parseInt(notify.getChildText("enableVoice"));
								tempContactPref["bm_enableText"] = parseInt(notify.getChildText("enableText"));
							}
						}
					}
				}
			}
		}
		p.contactPrefs = tempContactPref;
		initVarDone(0);
	}

	function setLocale(locale) {
		var localeMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "DatetimeControl", "SetLocale");
		localeMessage.addArgument("locale", locale);
		bxtClient.sendMsg(localeMessage);
	}

	function parseUsageDevicesInfo(update) {
		if (update) {
			var tmpInfo = {};
			for (var info = update.getChild("usageDeviceInfo"); info; info = info.next) {
				var tmp = {
					'statusString': info.getChildText("statusString"),
					'showErrorIndicator': info.getChildText("showErrorIndicator"),
					'deviceUuid': info.getChildText("deviceUuid"),
					'deviceIdentifier': info.getChildText("deviceIdentifier"),
					'deviceStatus': info.getChildText("deviceStatus")
				};

				tmpInfo[tmp.deviceUuid] = tmp;
			}
			usageDevicesInfo = tmpInfo;
		}
		initVarDone(2);
	}

	Timer {
		id: checkNextContactPopupTimer
		interval: 500
		running: false
		repeat: false
		onTriggered: {
			p.checkShowContactPopup();
		}
	}

	BxtDiscoveryHandler {
		deviceType: "happ_scsync"

		onDiscoReceived: {
			p.scsyncMsgUuid = deviceUuid;
			getDeviceInfo();
		}
	}

	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"

		onDiscoReceived: {
			p.configMsgUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: p1DiscoHandler
		deviceType: "hdrv_p1"

		onDiscoReceived:  {
			p.hdrv_p1Uuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: eventmgrDiscoHandler
		deviceType: "happ_eventmgr"

		onDiscoReceived:  {
			p.happ_eventmgrUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		equivalentDeviceTypes: ["hdrv_zwave", "happ_zware"]

		onDiscoReceived: {
			if (devNode) {
				var device = devNode.getChild("device");
				for (; device; device = device.next) {
					var type = device.getAttribute("type");
					if (type.indexOf("HAE_METER") !== -1) {
						maFwUpdateNotifyHandler.sourceUuid = device.getAttribute("uuid");
					}
				}
			}
		}
	}

	BxtNotifyHandler {
		id: maFwUpdateNotifyHandler
		serviceId: "FirmwareUpdate"

		onNotificationReceived: {
			var current = parseInt(message.getArgument("progress"));
			var total = parseInt(message.getArgument("total"));
			maFwUpdatePercentage = (current / total) * 100;

			maFwUpdateStatusUpdate();
		}
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "GetDeviceInfoResponse"
		onResponseReceived: {
			var devicesNode = message.getArgumentXml("devices");
			var device = devicesNode.getChild("device");
			var tmpInfo = [];

			for (; device; device = device.next) {
				var newinfo = {};

				var SoftwareVersion = device.getChildText("SoftwareVersion");
				newinfo.SoftwareVersion = SoftwareVersion === "00/00" ? "-" : SoftwareVersion;
				newinfo.AvailableVersion = device.getChildText("AvailableVersion");
				newinfo.SerialNumber = device.getChildText("SerialNumber");
				newinfo.DeviceModel = device.getChildText("DeviceModel");
				newinfo.deviceUuid = device.getChildText("deviceUuid");

				//Update available is an option entry in the DeviceInfo message. If it is available use it, otherwise try to decide it ourselfs
				var updateAvailable = device.getChild("UpdateAvailable");

				if (updateAvailable) {
					newinfo.UpdateAvailable = (updateAvailable.text === "true");
				} else {
					newinfo.UpdateAvailable = p.isReleaseUpdate(newinfo.SoftwareVersion, newinfo.AvailableVersion);
				}

				var deviceType = device.getChild("DeviceType").text;
				switch (deviceType) {
					case "Display":
						var displayVerionArray = newinfo.SoftwareVersion.split("/");
						newinfo.SoftwareVersion = (displayVerionArray && displayVerionArray.length === 3) ? displayVerionArray[2] : "-";
						// UpdateAvailable for display is set in checkFirmwareUpdateCallback
						newinfo.UpdateAvailable = displayInfo.UpdateAvailable;
						newinfo.CheckingForUpdate = displayInfo.CheckingForUpdate;
						displayInfo = newinfo;
						break;
					default:
						// If the device is in usageDevicesInfo, it is a measure device. Use fallthrough
						if (!usageDevicesInfo[device.getChildText("deviceUuid")])
							break;
						// fallthrough
					case "MeterModule":
					case "MeterAdapter":
						tmpInfo.push(newinfo);
						break;
					case "BoilerAdapter":
						boilerAdapterInfo = newinfo;
						break;
				}
			}
			meterAdapterInfo = tmpInfo;
			systemInfoUpdate();
		}
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "CheckFirmwareUpdateResponse"

		onResponseReceived: {
			var version = message.getArgument("version");
			var latestVersion = message.getArgument("latestVersion");
			if (version && latestVersion) {
				var newDisplayInfo = displayInfo;
				newDisplayInfo.UpdateAvailable = p.isReleaseUpdate(version, latestVersion);
				displayInfo = newDisplayInfo;
				systemInfoUpdate();
			}
			checkFirmwareUpdateResponseReceived(message);
		}
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "GetFirmwareUpdateStatusResponse"

		onResponseReceived: {
			maFwUpdateStatus = parseInt(message.getArgument("status"));
			var statusMsg = message.getArgument("statusMsg");
			if (statusMsg)
				maFwUpdateStatusMsg = statusMsg;

			maFwUpdateStatusUpdate();
		}
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "AddContactResponse"

		onResponseReceived: {
			p.showContactPopups = 0;

			if (parseInt(message.getArgument("popupSD")) === 1 && feature.appSmokeDetectorEnabled()) {
				p.showContactPopups |= p._POPUP_SD;
			}
			var newContactPopupPrefs = {};
			var initField = message.getArgumentXml("initFields").child;
			while (initField) {
				var fieldName = initField.name;
				newContactPopupPrefs[fieldName] = {};
				newContactPopupPrefs[fieldName].value = initField.text;
				newContactPopupPrefs[fieldName].services = p.showContactPopups;
				initField = initField.sibling;
			}

			p.showContactPopupValues = newContactPopupPrefs;
			p.checkShowContactPopup();
		}
	}

	/* This BxtAction expects a "service" string argument with the name
	 * of the service to be used. A confirmation of usage of all available
	 * communication channels for this specific service will be requested to the user.
	 *
	 * See p.checkShowContactPopup() for more information on this Action
	 */
	BxtActionHandler {
		action: "ConfirmContactInfoUsageByService"
		onActionReceived: {
			var service = message.getArgument("service");
			if (service === "SD") {
				p.showContactPopups = p._POPUP_SD;
			} else if (service === "BM") {
				p.showContactPopups = p._POPUP_BM;
			} else {
				return;
			}

			var contactPopupPrefs = {};
			if (eventUserInfo["phone1"].length > 0) {
				contactPopupPrefs["phone1"] = {};
				contactPopupPrefs["phone1"].value = eventUserInfo["phone1"];
				contactPopupPrefs["phone1"].services = p.showContactPopups;
			}
			if (eventUserInfo["phone2"].length > 0) {
				contactPopupPrefs["phone2"] = {};
				contactPopupPrefs["phone2"].value = eventUserInfo["phone2"];
				contactPopupPrefs["phone2"].services = p.showContactPopups;
			}

			if (Object.keys(contactPopupPrefs).length) {
				p.showContactPopupValues = contactPopupPrefs;
				p.checkShowContactPopup();
			}
		}
	}

	BxtDatasetHandler {
		id: softwareVersionInfoDsHandler
		discoHandler: configDiscoHandler
		dataset: "softwareVersionInfo"
		onDatasetUpdate: {
			var newDisplayInfo = displayInfo;
			var version = update.getChildText("version");
			var latestVersion = update.getChildText("latestVersion");
			var checkingForUpdate = update.getChildText("currentState") === "FW_UPGRADE_CHECKING";
			newDisplayInfo.CheckingForUpdate = checkingForUpdate;
			newDisplayInfo.UpdateAvailable = update.getChildText("updateAvailable") === "true";
			displayInfo = newDisplayInfo;
			systemInfoUpdate();
		}
	}

	BxtDatasetHandler {
		id: usageDevicesInfoDsHandler
		discoHandler: p1DiscoHandler
		dataset: "usageDevicesInfo"
		onDatasetUpdate: parseUsageDevicesInfo(update)
	}

	BxtDatasetHandler {
		id: eventContactsDsHandler
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: onEventContactsChanged(update)

		Component.onCompleted: {
			if (feature.appSmokeDetectorEnabled())
				dataset = "eventContacts";
			else
				initVarDone(1);
		}
	}

	BxtDatasetHandler {
		id: eventScenariosDsHandler
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: onEventScenariosChanged(update)

		Component.onCompleted: {
			if (feature.appSmokeDetectorEnabled())
				dataset = "eventScenarios";
			else
				initVarDone(0);
		}
	}

	/**
	 * Invoked when the reset button on bottom of device has been pressed.
	 * Eventually (before the timeout expires) a confirmation, which is
	 * either approving or canceling rebooting, needs to be send back.
	 */
	BxtActionHandler {
		action: "GetRebootConfirmation"
		property url dialogContentSource: "RebootConfirmationPopup.qml"

		function sendConfirmation(reboot) {
			var message = bxtFactory.newBxtMessage(
						BxtMessage.ACTION_RESPONSE, p.configMsgUuid,
						"ConfigProvider", "GetRebootConfirmation");
			message.addArgument("reboot", true === reboot ? "1" : "0");
			bxtClient.sendMsg(message);
		}

		onActionReceived: {
			screenStateController.wakeup();
			qdialog.showDialog(qdialog.SizeMedium, qsTr("Warning"), dialogContentSource,
							   qsTr("Cancel"), function() {sendConfirmation(false);},
							   qsTr("Reboot now"), function() {sendConfirmation(true);});
			var content = qdialog.context.dynamicContent;
			content.timeout = message.getArgument("timeout");
		}
	}

	BxtActionHandler {
		action: "PreExitNotice"

		onActionReceived: {
			if (!isWizardMode && !softwareUpdateInProgressPopup.showing) {
				rebootInProgressPopup.show();
			}
		}
	}
}
