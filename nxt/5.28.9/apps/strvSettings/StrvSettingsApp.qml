import QtQuick 2.1
import BxtClient 1.0
import ThermostatUtils 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: strvSettingsApp

	property url strvFrameUrl: "StrvFrame.qml"
	property url deviceOverviewScreen: "StrvDeviceOverviewScreen.qml"
	property url deviceDetailsScreen: "StrvDeviceDetailsScreen.qml"
	property url zoneTemperaturePresetScreenUrl: "ZoneTemperaturePresetScreen.qml"
	property url editZonePresetScreenUrl: "EditZonePresetScreen.qml"
	property url programScreenUrl: "StrvProgramScreen.qml"
	property url strvRemoveDeviceScreenUrl: "StrvRemoveDeviceScreen.qml"

	property url heatingModeWizardOverviewItemUrl: "HeatingModeWizardOverviewItem.qml"
	property url heatingModeSelectionScreenUrl: "HeatingModeSelectionScreen.qml"

	property url homePresetSidePanelUrl: "HomePresetSidePanel.qml"
	property url homePresetSidePanelButtonUrl: "HomePresetSidePanelButton.qml"

	property url zoneTempSidePanelUrl: "ZoneTemperatureSidePanel.qml"
	property url zoneTempSidePanelButtonUrl: "ZoneTemperatureSidePanelButton.qml"

	property url noConnectionPopupUrl: "NoConnectionPopup.qml"

	property url strvOverviewButtonUrl: "StrvOverviewButton.qml"
	property url overviewHeatingScreenUrl: "OverviewHeatingScreen.qml"

	property url strvInstallIntroScreenUrl : "StrvInstallIntroScreen.qml"
	property url addStrvWizardScreenUrl    : "AddStrvWizardScreen.qml"
	property url addDeviceOverviewScreenUrl: "AddDeviceOverviewScreen.qml"
	property url strvMountDevicesScreenUrl : "StrvMountDevicesScreen.qml"
	property url strvInstallDoneScreenUrl  : "StrvInstallDoneScreen.qml"
	property url addConnectFrameUrl        : "AddConnectFrame.qml"
	property url addNameDeviceFrameUrl     : "AddNameDeviceFrame.qml"

	property url editDayScreenUrl:   "EditDayScreen.qml"
	property url editBlockScreenUrl: "EditBlockScreen.qml"
	property url copyProgramDayScreenUrl : "CopyProgramDayScreen.qml"

	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"

	property variant strvDevicesList: []
	property variant zoneList: []
	property variant presetList: []
	property variant trajectory: []
	property string scheduleUuid: ""
	property var schedule: []
	property var scheduleEdited: undefined
	property int scheduleEditingDay: -1
	property string currentTrajectoryJson: ""
	property string activePresetUUID: ""
	property var strvJustAddedUuids: []

	property bool presetsFirstUse: true

	property bool scheduleEnabled: false
	// True if one of the STRVs has a higher setpoint than measured temperature
	property bool heatingState: false

	property int errors: 0
	property int systrayErrors: 0

	readonly property int _STRV_NAME_MAX_LENGTH: 18
	readonly property int _STRV_NAME_MIN_LENGTH: 2
	readonly property int _STRV_LOW_BATTERY_THRESHOLD: 10
	readonly property int _STRV_ADD_CHECK_TIMEOUT: 60

	readonly property int _BLOCK_ACTION_ADD: 1
	readonly property int _BLOCK_ACTION_EDIT: 2

	readonly property var presetNames:  [ qsTr('Comfort'), qsTr('Active'), qsTr('Sleep'), qsTr('Away') ]
	readonly property var presetColors: [colors.tpModeComfort, colors.tpModeHome, colors.tpModeSleep, colors.tpModeAway]

	signal zoneRenamed

	function init() {
		registry.registerWidget("settingsFrame", strvFrameUrl, strvSettingsApp, "strvFrame", {categoryName: qsTr("STRVs"), categoryWeight: 310});
		registry.registerWidget("screen", deviceOverviewScreen, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", deviceDetailsScreen, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", strvRemoveDeviceScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("screen", zoneTemperaturePresetScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, strvSettingsApp, null, {objectName: "presetsMenuItem", label: qsTr("Presets"), image: p.temperaturePresetImageUrl, screenUrl: zoneTemperaturePresetScreenUrl, weight: 20});
		registry.registerWidget("screen", editZonePresetScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, strvSettingsApp, null, {objectName: "programMenuItem", label: qsTr("Program"), image: p.programImageUrl, screenUrl: programScreenUrl, weight: 10});
		registry.registerWidget("screen", programScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("prominent", homePresetSidePanelUrl, strvSettingsApp);
		registry.registerWidget("prominentTabButton", homePresetSidePanelButtonUrl, strvSettingsApp);
		registry.registerWidget("prominent", zoneTempSidePanelUrl, strvSettingsApp);
		registry.registerWidget("prominentTabButton", zoneTempSidePanelButtonUrl, strvSettingsApp);

		registry.registerWidget("installationWizardOverviewItem", heatingModeWizardOverviewItemUrl, strvSettingsApp, null, {weight: 15});
		registry.registerWidget("screen", heatingModeSelectionScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("statusButton", strvOverviewButtonUrl, strvSettingsApp, null, {weight: 10});
		registry.registerWidget("screen", overviewHeatingScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("screen", strvInstallIntroScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", addStrvWizardScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", addDeviceOverviewScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", strvMountDevicesScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", strvInstallDoneScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("screen", editDayScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editBlockScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", copyProgramDayScreenUrl, strvSettingsApp, null, {lazyLoadScreen: true});

		notifications.registerSubtype("settings", "strvLowBattery", deviceOverviewScreen, {});
		notifications.registerSubtype("settings", "strvLostConnection", overviewHeatingScreenUrl, {});

		if (isDemoBuild) {
			initVarDone(0);
			initVarDone(1);
			initVarDone(2);
		}
	}

	QtObject {
		id: p

		property string zwaveUuid
		property string hvacUuid
		property string scsyncUuid
		property string hcbConfigUuid

		property bool setZoneSetpointInProgress: false

		property url temperaturePresetImageUrl : "drawables/Temperature.svg"
		property url programImageUrl : "drawables/program.svg"
	}

	function getBatteryImage(_hasCommunicationError, _currentBatteryLevel) {
		var source;
		if (isInvalidBatteryLevel(_hasCommunicationError, _currentBatteryLevel)) {
			source = "battery-unknown.svg";
		} else if (_currentBatteryLevel >= 51) {
			source = "battery-full.svg";
		} else if (_currentBatteryLevel >= 26) {
			source = "battery-high.svg";
		} else if (_currentBatteryLevel >= 11) {
			source = "battery-mid.svg";
		} else if (_currentBatteryLevel >= 0) {
			source = "battery-low.svg";
		} else {
			source = "battery-unknown.svg";
		}
		return "image://scaled/images/" + source;
	}

	function isInvalidBatteryLevel(_hasCommunicationError, _currentBatteryLevel) {
		return (_hasCommunicationError || _currentBatteryLevel === null || typeof(_currentBatteryLevel) === "undefined" || _currentBatteryLevel < 0)
	}

	// Using the webrequest API is a bit of a hack, but we don't see any other way of doing this right now.
	// Paths that didn't work:
	// hdrv_zwave/Naming: n=SetDeviceName
	// hdrv_thermostat/specific1: n=SetDeviceName
	function setDeviceName(uuid, name) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "webRequest");
		msg.addArgument("action", "SetDeviceName")
		msg.addArgument("uuid", uuid);
		msg.addArgument("deviceName", name);
		bxtClient.doAsyncBxtRequest(msg, setDeviceNameCallback, 30);
	}

	function getMinimumZoneTemperature(zoneUuid) {
		// Current implementation is fixed, but in the future we could use
		// the UUID to inspect the STRV what minimum temperature it supports.
		return 8.0;
	}

	function getMaximumZoneTemperature(zoneUuid) {
		// Current implementation is fixed, but in the future we could use
		// the UUID to inspect the STRV what maximum temperature it supports.
		return 28.0;
	}

	function getZoneStepValue(zoneUuid) {
		// Current implementation is fixed, but in the future we could use
		// the UUID to inspect the STRV what step value it supports.
		return 0.5;
	}

	function getCurrentPresetTemperatureForZone(zoneUuid) {
		var curZone = getZoneByUuid(zoneUuid);
		if (curZone === undefined) {
			return undefined;
		}

		for (var i = 0; i < curZone.presetSetpoints.length; ++i) {
			if (curZone.presetSetpoints[i].preset.uuid === activePresetUUID) {
				return curZone.presetSetpoints[i].setpoint;
			}
		}
		return undefined;
	}

	function presetNameToString(presetName) {
		switch (presetName) {
		case "away":    return qsTr("Away");
		case "home":    return qsTr("Active");
		case "sleep":   return qsTr("Sleep");
		case "comfort": return qsTr("Comfort");
		default:        return undefined;
		}
	}

	function presetUuidToString(presetUUID) {
		return presetNameToString(presetUuidToName(presetUUID));
	}

	function presetNameToColor(presetName) {
		switch (presetName) {
		case "away":    return colors.presetAway;
		case "home":    return colors.presetHome;
		case "sleep":   return colors.presetSleep;
		case "comfort": return colors.presetComfort;
		default:        return colors._hercules;
		}
	}

	function presetNameToUuid(presetName) {
		for (var i = 0; i < presetList.length; ++i) {
			if (presetList[i].name === presetName)
				return presetList[i].uuid;
		}
		return undefined;
	}

	function presetUuidToName(presetUUID) {
		for (var i = 0; i < presetList.length; ++i) {
			if (presetList[i].uuid === presetUUID)
				return presetList[i].name;
		}
		return undefined;
	}

	function presetUuidToMinMaxTemperature(presetUUID) {
		var min = 30.0;
		var max = 6.0;
		for (var i = 0; i < zoneList.length; ++i) {
			var curZone = zoneList[i];
			var curPresetList = curZone.presetSetpoints;
			for (var j = 0; j < curPresetList.length; ++j) {
				var curPreset = curPresetList[j];
				if (curPreset.preset.uuid === presetUUID) {
					if (curPreset.setpoint < min)
						min = curPreset.setpoint;
					if (curPreset.setpoint > max)
						max = curPreset.setpoint;
				}
			}
		}

		var retVal = { "min": min, "max": max };
		return retVal;
	}

	function presetStateToName(presetState) {
		switch (presetState) {
		case 0: return "comfort";
		case 1: return "home";
		case 2: return "sleep";
		case 3: return "away";
		default:        return undefined;
		}
	}

	function presetStateToUuid(presetState) {
		return presetNameToUuid(presetStateToName(presetState));
	}

	function presetStateToString(presetState) {
		return presetNameToString(presetStateToName(presetState));
	}

	function getPreset(presetUUID) {
		for (var i = 0; i < presetList.length; ++i) {
			if (presetList[i].uuid === presetUUID)
				return presetList[i];
		}
		return undefined;
	}

	function getDeviceByUuid(uuid) {
		for (var i = 0; i < strvDevicesList.length; ++i) {
			if (strvDevicesList[i].uuid === uuid)
				return strvDevicesList[i];
		}
		return undefined;
	}

	function getMultipleDevicesByUuid(uuidList) {
		var devices = [];
		for (var i = 0; i < strvDevicesList.length; ++i) {
			if (~uuidList.indexOf(strvDevicesList[i].uuid))
				devices.push(strvDevicesList[i]);
		}
		return devices;
	}

	function setZoneSetpoint(zoneUuid, setpoint) {
		var uri = "/hvac/zones/" + zoneUuid;
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "PATCH"},
			"body": {"setpoint": setpoint}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));
		p.setZoneSetpointInProgress = true;
		bxtClient.doAsyncBxtRequest(msg, handleSetZoneSetpointCallback, 10);
	}

	function handleSetZoneSetpointCallback(response) {
		p.setZoneSetpointInProgress = false;
	}

	function setZonePresetSetpoint(zoneUuid, presetName, setpoint) {
		var uri = "/hvac/zones/" + zoneUuid;
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "PATCH"},
			"body": {"presetSetpoints": [
					{
						"preset": {
							"name": presetName,
							"uuid": presetNameToUuid(presetName)
						},
						"setpoint": setpoint
					}
				]
			}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));
		bxtClient.sendMsg(msg);
	}

	function toggleUserFeature(featureName) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "features", "SetUserToggle");
		msg.addArgument("featureName", featureName);
		bxtClient.sendMsg(msg);
	}

	// Value should be either true or false
	function setUserFeature(featureName, value) {
		if (! (value === true || value === false))
			return;
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "features", "SetUserToggle");
		msg.addArgument("featureName", featureName);
		msg.addArgument("enable", value);
		bxtClient.sendMsg(msg);
	}

	// Checks if Hvac API response is welformed. Returns false if the response was not well formed (and prints a message)
	// Otherwise returns true.
	function checkHvacResponse(response, context) {
		if (!response) {
			console.log("Did not receive response for ", context);
			return false;
		}

		var jsonText = response.getArgument("json");
		try {
			var jsonResponse = JSON.parse(jsonText);
		} catch (e) {
			console.log("Error while parsing response in ", context, ":", response.stringContent);
			return false;
		}

		if (!jsonResponse) {
			console.log("Error while parsing response in ", context, ":", response.stringContent);
			return false;
		}
		if (!jsonResponse["responseHeader"] || jsonResponse["responseHeader"]["statusCode"] >= 203) {
			console.log("Response in", context, "did not have OK/created/accepted statusCode 20x", response.stringContent);
			return false;
		}
		if (!jsonResponse["body"]) {
			console.log("Response in", context, "did not have body content", response.stringContent);
			return false;
		}
		return true;
	}

	// Callback parameter is optional. If no callback function is passed, this app will use
	// its handleGetZonesCallback function to update the zoneList.
	function getZones(callback) {
		var uri = "/hvac/zones";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "GET"},
			"body": {}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		if (typeof(callback) === "undefined") {
			callback = handleGetZonesCallback;
		}

		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function handleGetZonesCallback(response) {
		if (!checkHvacResponse(response, "handleGetZonesCallback")) {
			return;
		}
		// If we just sent a setZoneSetpoint request, ignore any zone updates while the request is pending.
		// This prevents the UI from updating to the previous setpoint while the request for a new setpoint
		// is being processed.
		if (p.setZoneSetpointInProgress) {
			console.log("Ignoring zone update while setZoneSetpoint request is in progress.");
			return;
		}

		var jsonText = response.getArgument("json");
		var jsonResponse = JSON.parse(jsonText);

		if (!jsonResponse["body"]["zones"]) {
			console.log("Response in handleGetZonesCallback() did not have zones content", response.stringContent);
			return;
		}

		zoneList = jsonResponse["body"]["zones"];
		updateHeatingState();
		initVarDone(1);
	}

	function getZoneByUuid(uuid) {
		for (var i = 0; i < zoneList.length; ++i) {
			if (zoneList[i].uuid === uuid) {
				return zoneList[i];
			}
		}
		return undefined;
	}

	function getZoneWithDeviceUuid(deviceUuid) {
		for (var i = 0; i < zoneList.length; ++i) {
			var hasDevice = zoneList[i].devices.some(function (device) {
				return device.uuid === deviceUuid;
			});
			if (hasDevice)
				return zoneList[i];
		}
		return undefined;
	}

	function getZoneUuidsWithDevices(deviceUuids) {
		var zones = [];
		if (Array.isArray(deviceUuids)) {
			for (var i = 0; i < zoneList.length; ++i) {
				var hasDevice = zoneList[i].devices.some(function (device) {
					return ~deviceUuids.indexOf(device.uuid);
				});
				if (hasDevice)
					zones.push(zoneList[i].uuid);
			}
		}
		return zones;
	}

	function getPresets(callback) {
		var uri = "/hvac/presets";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "GET"},
			"body": {}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		if (typeof(callback) === "undefined") {
			callback = handleGetPresetsCallback;
		}

		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function handleGetPresetsCallback(response) {
		if (!checkHvacResponse(response, "handleGetPresetsCallback")) {
			return;
		}

		var jsonText = response.getArgument("json");
		var jsonResponse = JSON.parse(jsonText);

		if (!jsonResponse["body"]["presets"]) {
			console.log("Response in handleGetPresetsCallback() did not have presets content", response.stringContent);
			return;
		}

		presetList = jsonResponse["body"]["presets"];
		if (!schedule.length)
			getSchedules();
		initVarDone(2);
	}

	function getPresetsTrajectory() {
		var uri = "/hvac/presets/trajectory";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "GET"},
			"body": {}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		bxtClient.doAsyncBxtRequest(msg, handlePresetsTrajectoryCallback, 3);
	}

	function handlePresetsTrajectoryCallback(response) {
		if (!checkHvacResponse(response, "handleGetPresetsTrajectoryCallback")) {
			return;
		}

		var jsonText = response.getArgument("json");
		var jsonResponse = JSON.parse(jsonText);

		if (!jsonResponse["body"]["presetTrajectory"]) {
			console.log("Response in handleActivePresetCallback() did not have active preset content", response.stringContent);
			return;
		}

		// Compare the incoming trajectory JSON text with the previous trajectory JSON text
		// to prevent accidental triggers of 'onTrajectoryChanged'.
		if (jsonText !== currentTrajectoryJson) {
			currentTrajectoryJson = jsonText;
			trajectory = jsonResponse["body"]["presetTrajectory"];
		}
	}

	// Callback parameter is optional. If no callback function is passed, this app will use
	// its handleGetDevicesCallback function to update the device list.
	function getDevices(callback) {
		var uri = "/hvac/devices";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "GET"},
			"body": {}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		if (typeof(callback) === "undefined") {
			callback = handleGetDevicesCallback;
		}

		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function handleGetDevicesCallback(response) {
		if (!checkHvacResponse(response, "handleGetDevicesCallback")) {
			return;
		}

		var jsonText = response.getArgument("json");
		var jsonResponse = JSON.parse(jsonText);

		if (!jsonResponse["body"]["devices"]) {
			console.log("Response in handleGetDevicesCallback() did not have devices property", response.stringContent);
			return;
		}

		strvDevicesList = jsonResponse["body"]["devices"];
		initVarDone(0);
	}

	// Callback parameter is optional. If no callback function is passed, this app will use
	// its handleGetDevicesCallback function to update the zoneList.
	function getSchedules(callback) {
		var uri = "/hvac/schedules";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "GET"},
			"body": {}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		if (typeof(callback) === "undefined") {
			callback = handleGetSchedulesCallback;
		}

		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function handleGetSchedulesCallback(response) {
		if (!checkHvacResponse(response, "handleGetSchedulesCallback")) {
			return;
		}

		var jsonText = response.getArgument("json");
		var jsonResponse = JSON.parse(jsonText);

		if (!jsonResponse["body"]["schedules"]) {
			console.log("Response in handleGetSchedulesCallback() did not have schedules property", response.stringContent);
			return;
		}

		if (Array.isArray(jsonResponse["body"]["schedules"]) &&
				jsonResponse["body"]["schedules"][0].weeklyEntries) {
			scheduleUuid = jsonResponse["body"]["schedules"][0].uuid;
			schedule = ThermostatUtils.parseHvacSchedule(jsonResponse["body"]["schedules"][0].weeklyEntries, presetList);
		}
	}

	onTrajectoryChanged: {
		if (trajectory.length === 0) {
			return;
		} else if ('overrideType' in trajectory[0] &&
				trajectory[0].overrideType === "indefinite") {
			scheduleEnabled = false;
		} else {
			scheduleEnabled = true;
		}
		scheduleEnabledChanged();
		activePresetUUID = trajectory[0]["presetUUID"];
		updateScreenStateController();
	}

	onStrvDevicesListChanged: {
		updateErrorCount();
	}

	function updateErrorCount() {
		var _errorCount = 0;
		for (var i = 0; i < strvDevicesList.length; ++i) {
			var curDevice = strvDevicesList[i];
			if (curDevice.hasCommunicationError) {
				_errorCount += 1;
			}
		}
		errors = _errorCount;
		systrayErrors = errors ? 1 : 0;
	}

	function updateScreenStateController() {
		var activeStateHasScreenOff; // bool
		var nextStateHasScreenOff; // bool
		var nextProgramStart; // Date
		var activeStateIsOverride; // bool

		var activePresetName = presetUuidToName(trajectory[0]["presetUUID"]);
		activeStateHasScreenOff = (activePresetName === "away" ||
									   activePresetName === "sleep");

		if ('overrideType' in trajectory[0]) {
			activeStateIsOverride = true;
		} else {
			activeStateIsOverride = false;
		}

		if (trajectory.length >= 2) {
			var nextPresetName = presetUuidToName(trajectory[1]["presetUUID"]);
			nextStateHasScreenOff = (nextPresetName === "away" ||
									 nextPresetName === "sleep");

			nextProgramStart = qtUtils.fromISOString(trajectory[1].startTime);
		} else {
			nextStateHasScreenOff = true;
			nextProgramStart = new Date(0);
		}
		screenStateController.setProgramBasedScreenOffParameters(activeStateHasScreenOff, nextStateHasScreenOff, nextProgramStart, activeStateIsOverride);
	}

	function sendScheduleEnabled(scheduleEnabled) {
		var method;
		var body;

		if (scheduleEnabled) {
			method = "DELETE";
			body = { };
		} else {
			method = "PUT";
			body = {
				"presetUUID": trajectory[0].presetUUID,
				"type": "indefinite"
			};
		}

		var uri = "/hvac/presets/override";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": method},
			"body": body
		};
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		// Clear cached trajectory to erase displayed state, awaiting the updated values from the driver
		trajectory = [];
		bxtClient.doAsyncBxtRequest(msg, handlePutPresetsOverrideCallback, 30);
	}

	function handlePutPresetsOverrideCallback(response) {
		handlePresetsTrajectoryCallback(response);
		// Restart the timer to immediately request the new Zone status
		getZoneTimer.restart();
	}

	function setPresetsOverride(presetName) {
		activePresetUUID = presetNameToUuid(presetName);
		var type;
		if (typeof(trajectory[0].overrideType) === "undefined") {
			type = "nextScheduleTransition";
		} else {
			type = trajectory[0].overrideType;
		}

		var uri = "/hvac/presets/override";
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "PUT"},
			"body": {
				"presetUUID": presetNameToUuid(presetName),
				"type": type
			}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		// Clear cached trajectory to erase displayed state, awaiting the updated values from the driver
		trajectory = [];
		bxtClient.doAsyncBxtRequest(msg, handlePutPresetsOverrideCallback, 30);
	}

	function sendStrvSettingsAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("strvSettingsApp", null, 0);
		node.addChild("package", "qt-gui", 0);
		node.addChild("internalAddress", "strvSettingsApp", 0);

		node.addChild("presetsFirstUse", presetsFirstUse ? 1 : 0, 0);
		// If there are more configuration parameters that we need to save, add them here

		bxtClient.sendMsg(msg);
	}

	function updateHeatingState() {
		var newHeatingState = false;

		for (var i = 0; i < zoneList.length; ++i) {
			if (zoneList[i].setpoint > zoneList[i].temperature) {
				newHeatingState = true;
				break;
			}
		}
		heatingState = newHeatingState;
	}

	function showNoConnectionPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("strv-no-connection-popup-title"), noConnectionPopupUrl, qsTr("Repeaters"), function() {
			stage.openFullscreen(Qt.resolvedUrl("../eMetersSettings/RepeaterChangeScreen.qml"));
			return false;
		});
		qdialog.context.closeBtnForceShow = true;
	}

	function showMountInstructionsPopup() {
		qdialog.showDialog(qdialog.SizeLarge, "", strvSettingsApp.tipsPopupUrl);
		//qdialog.context.titleFontPixelSize = qfont.navigationTitle;
		var tips = [
			{
				title: qsTr("mountTip1Title"),
				text:  qsTr("mountTip1Text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/strvSettings/drawables/popup-mount-1.svg")
			},
			{
				title: qsTr("mountTip2Title"),
				text:  qsTr("mountTip2Text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/strvSettings/drawables/popup-mount-2.svg")
			},
			{
				title: qsTr("mountTip3Title"),
				text:  qsTr("mountTip3Text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/strvSettings/drawables/popup-mount-3.svg")
			}
		];
		//qdialog.context.dynamicContent.showSeparator = false;
		qdialog.context.dynamicContent.carousel = true;
		qdialog.context.dynamicContent.imageContainerWidth = 258;
		qdialog.context.dynamicContent.tips = tips;
	}

	function startEditSchedule() {
		scheduleEdited = ThermostatUtils.createProgramCopy(schedule);
	}

	function saveEditedSchedule() {
		schedule = ThermostatUtils.simplifyProgram(scheduleEdited);
		scheduleEdited = undefined;
		scheduleEditingDay = -1;

		var hvacSchedule = ThermostatUtils.generateHvacSchedule(schedule, presetList);

		var uri = "/hvac/schedules/" + scheduleUuid;
		var jsonVar = {
			"requestHeader": {"uri": uri, "method": "PATCH"},
			"body": {
				"uuid": scheduleUuid,
				"weeklyEntries": hvacSchedule
			}
		};

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hvacUuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(jsonVar));

		bxtClient.doAsyncBxtRequest(msg, handleGetSchedulesCallback, 30);
	}

	function cancelEditedSchedule() {
		scheduleEdited = undefined;
		scheduleEditingDay = -1;
	}

	// 0=getDevices, 1=getZones, 2=getPresets
	initVarCount: 3

	Timer {
		id: getZoneTimer
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			getZones();
			getPresetsTrajectory();
		}
	}

	Timer {
		id: getDevicesTimer
		interval: 5 * 60 * 1000 // 5 minutes
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			getDevices();
		}
	}

	BxtDiscoveryHandler {
		id: zwaveDiscoHandler
		equivalentDeviceTypes: ["hdrv_zwave", "happ_zware"]
		onDiscoReceived: {
			p.zwaveUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: hvacDiscoHandler
		deviceType: "happ_hvac"
		onDiscoReceived: {
			p.hvacUuid = deviceUuid;
			// triggers getZones() on start.
			getZoneTimer.start();
			getPresets();
			getDevicesTimer.start();
		}
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: hcbConfigDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.hcbConfigUuid = deviceUuid;
			getStrvSettingsAppConfig();
		}
	}

	BxtRequestCallback {
		id: setDeviceNameCallback
		onMessageReceived: {
			// Log the response
			if (message) {
				console.log(message.stringContent);
			} else {
				console.log("Received null response for setDeviceName()");
			}
			getDevices();
			zoneList = [];
			zoneRenamed();
		}
		onTimeout: {
			console.log("Timeout for setDeviceName()");
		}
	}

	function getStrvSettingsAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "strvSettingsApp");

		bxtClient.doAsyncBxtRequest(msg, getConfigCallback, 30);
	}

	BxtRequestCallback {
		id: getConfigCallback

		onMessageReceived: {
			console.log(message.stringContent);
			var configNode = message.getArgumentXml("Config").getChild("strvSettingsApp");

			if (configNode) {
				presetsFirstUse = (parseInt(configNode.getChild("presetsFirstUse").text) === 1);
			} else {
				console.log("No StrvSettingsApp configuration available, creating defaults...");
				sendStrvSettingsAppConfig();
			}
		}
	}
}
