import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: thermostatSettingsApp
	property url heatingFrameUrl: "HeatingFrame.qml"
	property url temperatureCorrectionScreenUrl: "TemperatureCorrectionScreen.qml"
	property url heatingInstManualSettingsScrUrl: "HeatingInstManualSettingsScr.qml"
	property url heatingInstSelectScreenUrl: "HeatingInstSelectScreen.qml"
	property url dhwTemperatureSettingScreenUrl: "DHWTempSettingScreen.qml"
	property url overviewHeatingScreenUrl: "OverviewHeatingScreen.qml"
	property url thermostatOverviewButtonUrl: "ThermostatOverviewButton.qml"
	property url heatingTypeSelectScreenUrl: "HeatingTypeSelectScreen.qml"
	property url districtHeatingTypeSelectScreenUrl: "DistrictHeatingTypeSelectScreen.qml"
	property url districtHeatingRemoveDeviceScreenUrl: "DistrictHeatingRemoveDeviceScreen.qml"

	property url addDeviceScreenUrl: "AddDeviceScreen.qml"
	property url connectionQualityScreenUrl: "ConnectionQualityScreen.qml"
	property url selectBoilerModuleTypeScreenUrl: "SelectBoilerModuleTypeScreen.qml"
	property url editBoilerModuleScreenUrl: "EditBoilerModuleScreen.qml"

	property url boilerHeatingWizardOverviewItemUrl: "BoilerHeatingWizardOverviewItem.qml"
	property url boilerHeatingWizardUrl: "BoilerHeatingWizard.qml"

	property variant thermostatStates: {
		'CONNECTIVITY_BOILER_MODULE': (1 << 0),
		'CONNECTIVITY_OPENTHERM': (1 << 1),
		'CONNECTIVITY_HEAT_RECOVERY': (1 << 2),
		'HEATREC_ERROR': (1 << 3),
		'BOILER_ERROR': (1 << 4),
	}
	property int thermostatState: 0

	property string boilerManufacturer: "Prodrive"
	property bool testingBoilerType: false
	property int errors : 0
	property int systrayErrors :0

	property bool hasHeatRecovery: feature.appHeatRecoveryEnabled() && typeof heatRecoveryInfo !== "undefined"

	property variant boilerInfo: {
		'otBoiler' : false,
		'brand': "-",
		'model': "-",
		'tempDeviation' : "-",
		'tempMeasured' : "-",
		'dhwTemp' : "-",
		'dhwTempMin': "-",
		'dhwTempMax': "-",
		'dhwPreheat' : false,
	}

	property variant heatRecoveryInfo

	property int tempManualHeatingMaxTemp
	property int tempManualHeatingHeatRate

	property variant heatingInstInfo: {
		'type' : "-",
		'maxTemp' : "80",
		'heatRate' : "3",
		'heaterFuelType': 'unknown'
	}

	property variant thermInfo: {
		'boilerModuleConnected' : 0,
		'otCommError' : 0,
		'errorFound' : 0,
		'hasBoilerFault' : 0
	}

	property variant boilerModuleTypeStrings: [
		qsTr("Boiler module"),
		qsTr("Wired boiler module"),
		qsTr("Wireless boiler module")
	]
	// boilerType 0 = No boiler module selected
	// boilerType 1 = Wired boiler module
	// boilerType 2 = Wireless boiler module
	property int boilerModuleType: 0
	property variant boilerModuleInfos: []

	property variant heatingDevices: []

	readonly property string _HEATINGTYPE_GAS:        "heatingType-gas"
	readonly property string _HEATINGTYPE_OIL:        "heatingType-oil"
	readonly property string _HEATINGTYPE_ELECTRIC:   "heatingType-elec"
	readonly property string _HEATINGTYPE_HEATPUMP:   "heatingType-elecHeatPump"
	readonly property string _HEATINGTYPE_COLLECTIVE: "heatingType-collective"
	readonly property string _HEATINGTYPE_UNKNOWN:    "heatingType-unknown"

	property string heatingSourceType: _HEATINGTYPE_UNKNOWN

	property bool doHeat: globals.productOptions["district_heating"] === "1"
	property bool hasSmartHeat: globals.features["pilot-UtrechtWarmte"] === true
	property bool doSetupSmartHeat: false

	// For unit test
	property BxtDatasetHandler tst_ThermostatInfoDsHandler: thermstatInfoDsHandler

	function init() {
		registry.registerWidget("settingsFrame", heatingFrameUrl, thermostatSettingsApp, "heatingFrame", {categoryName: qsTr("Heating"), categoryWeight: 300});
		registry.registerWidget("screen", temperatureCorrectionScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", heatingInstSelectScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", heatingInstManualSettingsScrUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", heatingTypeSelectScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", districtHeatingTypeSelectScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", districtHeatingRemoveDeviceScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", addDeviceScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", connectionQualityScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", selectBoilerModuleTypeScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", editBoilerModuleScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("statusButton", thermostatOverviewButtonUrl, thermostatSettingsApp, null, {weight: 10});
		registry.registerWidget("screen", overviewHeatingScreenUrl, thermostatSettingsApp, null, {lazyLoadScreen: true});

		notifications.registerSubtype("error", "boiler", overviewHeatingScreenUrl, {});

		if (isWizardMode && wizardstate.hasStage("boiler")) {
			registry.registerWidget("installationWizardOverviewItem", boilerHeatingWizardOverviewItemUrl, thermostatSettingsApp, null, {weight: 20});
			registry.registerWidget("screen", boilerHeatingWizardUrl, thermostatSettingsApp, "");
			if (boilerModuleType === 0) {
				wizardstate.setStageCompleted("boiler", false);
			}
			zWaveUtils.getDevices();
		}
	}

	QtObject {
		id: p

		property string thermostatUuid
		property string scsyncUuid
		property string eventmgrUuid
		property string zwaveUuid
		property string hcbConfigUuid
	}

	function getTempDeviationInfo() {
		var getTempDeviationMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetTempOffset");
		bxtClient.sendMsg(getTempDeviationMessage);
	}

	function getDeviceInfo() {
		var getDeviceInfoMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "GetDeviceInfo");
		bxtClient.doAsyncBxtRequest(getDeviceInfoMessage, getDeviceInfoCallback, 30);
	}

	function getHeatInstInfo() {
		var getInstTypeMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetChSettings");
		bxtClient.sendMsg(getInstTypeMessage);
	}

	function getDWHInfo() {
		var getDWHInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetDhwSettings");
		bxtClient.sendMsg(getDWHInfoMessage);
	}

	function setBoilerType(otBoiler) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetBoilerType");
		msg.addArgument("ot", otBoiler ? "0" : "1");
		bxtClient.sendMsg(msg);
	}

	function testBoilerType() {
		testingBoilerType = true;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "TestBoilerType");
		bxtClient.sendMsg(msg);
	}

	function storeDHWInfo() {
		var setDHWInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetDhwSettings");
		setDHWInfoMessage.addArgument("dhwEnabled", boilerInfo.dhwPreheat ? 1 : 0);
		setDHWInfoMessage.addArgument("dhwSetpoint", boilerInfo.dhwTemp);
		bxtClient.sendMsg(setDHWInfoMessage);
	}

	function setDHWTemp(temp) {
		var tmpInfo = boilerInfo;
		tmpInfo.dhwTemp = temp;
		boilerInfo = tmpInfo;
		storeDHWInfo();
	}

	function setDHWEnabled(enabled) {
		var tmpInfo = boilerInfo;
		tmpInfo.dhwPreheat = enabled;
		boilerInfo = tmpInfo;
		storeDHWInfo();
	}

	function setHeatInstInfo(type, maxTemp, heatRate) {
		var newHeatingInstInfo = heatingInstInfo;

		newHeatingInstInfo.type = type
		newHeatingInstInfo.maxTemp = maxTemp;
		newHeatingInstInfo.heatRate = heatRate;

		heatingInstInfo = newHeatingInstInfo;

		var setInstSettingsMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetChSettings");

		setInstSettingsMessage.addArgument("heatingType", heatingInstInfo.type);
		setInstSettingsMessage.addArgument("maxHeaterTemp", heatingInstInfo.maxTemp);
		setInstSettingsMessage.addArgument("maxHeatingRate", heatingInstInfo.heatRate);

		bxtClient.sendMsg(setInstSettingsMessage);
	}

	function setHeatingSourceType(type) {
		heatingSourceType = type;
		// Write to qt-gui config
		sendThermostatSettingsAppConfig();

		// The different heating types are mapped to either the gasFuel algorithm, or
		// the oilFuel algorithm. (The latter limits how quickly the heating source
		// can be turned on and off, necessary to increase the lifetime of the
		// heating source.)
		var fuelType;
		switch (type) {
		case _HEATINGTYPE_GAS:
		case _HEATINGTYPE_ELECTRIC:
		case _HEATINGTYPE_COLLECTIVE:
			fuelType = 'gasFuel';
			break;
		case _HEATINGTYPE_OIL:
			fuelType = 'oilFuel';
			break;
		case _HEATINGTYPE_HEATPUMP:
			fuelType = 'electricHeatPump';
			break;
		default:
			console.log("Warning: Unknown fuel type:", type)
			return;
		}

		var newHeatingInstInfo = heatingInstInfo;
		newHeatingInstInfo.heaterFuelType = fuelType;
		heatingInstInfo = newHeatingInstInfo;

		var setInstSettingsMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetChSettings");
		setInstSettingsMessage.addArgument("heaterFuelType", heatingInstInfo.heaterFuelType);
		bxtClient.sendMsg(setInstSettingsMessage);
	}

	function setTempCorrection(tempCorrection) {
		var tmpInfo = boilerInfo;
		tmpInfo.tempDeviation = tempCorrection;
		boilerInfo = tmpInfo;

		var adjustTempOffsetMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "AdjustTempOffset");
		adjustTempOffsetMessage.addArgument("offset", tempCorrection);
		bxtClient.sendMsg(adjustTempOffsetMessage);
	}

	function onThermostatInfoChanged(update) {
		var tempThermInfo = thermInfo;

		if (update.getChild("boilerModuleConnected")) {
			tempThermInfo.boilerModuleConnected = parseInt(update.getChild("boilerModuleConnected").text);
			if (tempThermInfo.boilerModuleConnected === 1 && boilerModuleType <= 1 && globals.thermostatFeatures["FF_BoilerControl_Edge_approve"]) {
				boilerModuleType = 1;
			}
		}
		tempThermInfo.otCommError = parseInt(update.getChildText("otCommError"));
		tempThermInfo.errorFound = parseInt(update.getChildText("errorFound"));
		tempThermInfo.hasBoilerFault = parseInt(update.getChildText("hasBoilerFault"));
		tempThermInfo.haveOTBoiler = parseInt(update.getChildText("haveOTBoiler"));
		thermInfo = tempThermInfo;

		var tempBoilerInfo = boilerInfo;
		tempBoilerInfo['otBoiler'] = parseInt(update.getChildText("haveOTBoiler")) === 1;
		boilerInfo = tempBoilerInfo;

		updateErrors();
		initVarDone(0);
	}

	function updateErrors() {
		if (!thermInfo)
			return;

		var prevThermostatState = thermostatState;
		var tmpThermostatState = 0, tmpErrors = 0;
		if (!thermInfo.boilerModuleConnected) {
			tmpThermostatState |= thermostatStates.CONNECTIVITY_BOILER_MODULE;
			tmpErrors++;
		} else if (thermInfo.otCommError) {
			tmpThermostatState |= thermostatStates.CONNECTIVITY_OPENTHERM;
			tmpErrors++;
		} else if (hasHeatRecovery && !heatRecoveryInfo["IsConnected"]) {
			tmpThermostatState |= thermostatStates.CONNECTIVITY_HEAT_RECOVERY;
			tmpErrors++;
		}
		if (thermInfo.haveOTBoiler && thermInfo.hasBoilerFault === 1) {
			tmpThermostatState |= thermostatStates.BOILER_ERROR;
			tmpErrors++;
		}
		if (hasHeatRecovery && (heatRecoveryInfo["BlockingState"] || heatRecoveryInfo["CurrentFaultcode"])) {
			tmpThermostatState |= thermostatStates.HEATREC_ERROR;
			tmpErrors++;
		}

		if (tmpThermostatState > 0)
			errors = tmpErrors;
		else
			errors = 0;
		systrayErrors = errors ? 1 : 0;


		thermostatState = tmpThermostatState;
		if (thermostatState != prevThermostatState) {
			if (thermostatState !== 0) {
				hcblog.logKpi("ErrorIconCause", "HEATING_"+thermostatState);
			} else {
				hcblog.logKpi("ErrorIconCauseFixed", "HEATING_OK");
			}
		}
	}

	function getHeatingType() {
		if (parseInt(globals.productOptions.gas)) {
			return 1;
		} else if (parseInt(globals.productOptions.district_heating)) {
			return 2;
		} else {
			return -1;
		}
	}

	function updateHeatRecoveryInfo(update) {
		var tempInfo = heatRecoveryInfo;
		var tempNode = update.child;
		if (!tempNode) {
			heatRecoveryInfo = undefined;
		} else {
			if (typeof tempInfo === "undefined")
				tempInfo = {};
			while (tempNode) {
				tempInfo[tempNode.name] = parseInt(tempNode.text);
				tempNode = tempNode.sibling;
			}
			heatRecoveryInfo = tempInfo;
		}
		updateErrors();
	}

	function openRemoveWirelessBoilerModuleScreen() {
		stage.openFullscreen(removeDeviceScreenUrl, {state: "wirelessBoilerModule", postSuccessCallbackFcn: removeSucceededCallbackFcn});
	}

	function removeSucceededCallbackFcn() {
		boilerModuleType = 0;
	}

	onBoilerModuleTypeChanged: {
		if (isWizardMode) {
			if (boilerModuleType === 0) {
				wizardstate.setStageCompleted("boiler", false);
			} else if (! wizardstate.stageCompleted("boiler") && !app.doHeat) {
				wizardstate.setStageCompleted("boiler", true);
			}
		}
	}

	onDoSetupSmartHeatChanged: {
		updateDistrictHeatingWizardState();
		if (isWizardMode && doSetupSmartHeat)
			zWaveUtils.getDevices();
	}

	Connections {
		target: zWaveUtils
		onDevicesChanged: {
			var heaters = [];
			for (var uuid in zWaveUtils.devices) {
				var dev = zWaveUtils.devices[uuid];
				var isHeaterDevice = (dev.name.indexOf("ZMNHVD") >= 0);
				console.log("Device - Name:", dev.name, "uuid:", dev.uuid, "isHeaterDevice:", isHeaterDevice);
				if (isHeaterDevice)
					heaters.push(dev);
			}
			heatingDevices = heaters;
			updateDistrictHeatingWizardState();
		}
	}

	function updateDistrictHeatingWizardState() {
		if (!isWizardMode || !doHeat)
			return;

		var validSmartDistrictHeat = (doSetupSmartHeat || hasSmartHeat) && heatingDevices.length !== 0;
		wizardstate.setStageCompleted("boiler", !doSetupSmartHeat || validSmartDistrictHeat);

		if (globals.features["pilot-UtrechtWarmte"] && !validSmartDistrictHeat ||
				!globals.features["pilot-UtrechtWarmte"] && validSmartDistrictHeat) {
			setSmartHeatToggle(validSmartDistrictHeat);
			setScheduleState(validSmartDistrictHeat);
		}
	}

	function setSmartHeatToggle(enabled) {
		// set or clear feature flag
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "features", "SetUserToggle");
		msg.addArgument("featureName", "pilot-UtrechtWarmte");
		msg.addArgument("enable", enabled ? "true" : "false");
		bxtClient.sendMsg(msg);
	}

	function setScheduleState(enabled) {
		// Enable or disable schedule
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "specific1", "ChangeSchemeState");
		msg.addArgument("state", enabled ? "1" : "0");
		bxtClient.sendMsg(msg);
	}

	function parseHeatingSourceType(type) {
		if (type === "" || type === _HEATINGTYPE_UNKNOWN) {
			if (heatingInstInfo.heaterFuelType === 'gasFuel')
				return _HEATINGTYPE_GAS;
			else if (heatingInstInfo.heaterFuelType === 'oilFuel')
				return _HEATINGTYPE_OIL;
			else
				return _HEATINGTYPE_UNKNOWN;
		} else {
			switch (type) {
			case _HEATINGTYPE_GAS:
			case _HEATINGTYPE_OIL:
			case _HEATINGTYPE_ELECTRIC:
			case _HEATINGTYPE_HEATPUMP:
			case _HEATINGTYPE_COLLECTIVE:
				return type;
			default:
				return _HEATINGTYPE_UNKNOWN;
			}
		}
	}

	function getThermostatSettingsAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "thermostatSettingsApp");

		bxtClient.doAsyncBxtRequest(msg, getConfigCallback, 30);
	}

	BxtRequestCallback {
		id: getConfigCallback
		onMessageReceived: {
			var configNode = message.getArgumentXml("Config").getChild("thermostatSettingsApp");
			if (configNode) {
				var _heatingSourceType = configNode.getChildText("heatingSourceType");
				heatingSourceType = parseHeatingSourceType(_heatingSourceType);
			} else {
				console.log("No ThermostatSettingsApp configuration available, creating defaults...");
				if (heatingInstInfo.heaterFuelType === 'gasFuel')
					heatingSourceType = _HEATINGTYPE_GAS;
				else if (heatingInstInfo.heaterFuelType === 'oilFuel')
					heatingSourceType = _HEATINGTYPE_OIL;
				sendThermostatSettingsAppConfig();
			}
		}
	}

	function sendThermostatSettingsAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("thermostatSettingsApp", null, 0);
		node.addChild("package", "qt-gui", 0);
		node.addChild("internalAddress", "thermostatSettingsApp", 0);

		node.addChild("heatingSourceType", heatingSourceType, 0);
		// If there are more configuration parameters that we need to save, add them here

		bxtClient.sendMsg(msg);
	}


	// 0=thermostatInfo
	initVarCount: 1

	BxtDiscoveryHandler {
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: thermostatDiscoHandler
		deviceType: "happ_thermstat"
		onDiscoReceived: {
			p.thermostatUuid = deviceUuid;
			// Populate heating installation information, so we don't show "unknown" for a moment the first
			// time we open the HeatingFrame
			getHeatInstInfo();
		}
	}

	BxtDiscoveryHandler {
		id: eventmgrDiscoHandler
		deviceType: "happ_eventmgr"
		onDiscoReceived: {
			p.eventmgrUuid = deviceUuid;
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
		id: hcbConfigDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.hcbConfigUuid = deviceUuid;
		}
	}

	BxtRequestCallback {
		id: getDeviceInfoCallback
		onMessageReceived: {
			var devicesNode = message.getArgumentXml("devices");
			var device = devicesNode.getChild("device");

			for (; device; device = device.next) {
				var deviceType = device.getChildText("DeviceType");
				switch (deviceType) {
					case "Display":
						break;
					case "MeterAdapter":
						break;
					case "BoilerAdapter":
						boilerManufacturer = device.getChildText("Manufacturer");
						break;
				}
			}
		}
	}

	BxtResponseHandler {
		response: "TestBoilerTypeResponse"
		serviceId: "Thermostat"
		onResponseReceived: {
			var result = message.getArgument("result");
			if (result == "ok")
			{
				var tmpInfo = boilerInfo;
				tmpInfo.otBoiler = (message.getArgument("ot") == "0");
				if (!tmpInfo.otBoiler) {
					wizardstate.setStageCompleted("boiler", true);
				}

				boilerInfo = tmpInfo;
			}
			testingBoilerType = false;
		}
	}

	BxtResponseHandler {
		response: "GetTempOffsetResponse"
		serviceId: "Thermostat"
		onResponseReceived: {
			var newBoilerInfo = boilerInfo;
			newBoilerInfo.tempDeviation = message.getArgument("offset");
			newBoilerInfo.tempMeasured = message.getArgument("measuredTemp");
			boilerInfo = newBoilerInfo;
		}
	}

	BxtResponseHandler {
		response: "GetChSettingsResponse"
		serviceId: "Thermostat"
		onResponseReceived: {
			var newHeatingInstInfo = heatingInstInfo;
			newHeatingInstInfo.type = message.getArgument("heatingType");
			newHeatingInstInfo.maxTemp = message.getArgument("maxHeaterTemp");
			newHeatingInstInfo.heatRate = message.getArgument("maxHeatingRate");
			newHeatingInstInfo.heaterFuelType = message.getArgument("heaterFuelType");

			heatingInstInfo = newHeatingInstInfo;

			getThermostatSettingsAppConfig();
		}
	}

	BxtResponseHandler {
		response: "GetDhwSettingsResponse"
		serviceId: "Thermostat"
		onResponseReceived: {
			var newBoilerInfo = boilerInfo;

			newBoilerInfo.dhwTemp = message.getArgument("dhwSetpoint");
			newBoilerInfo.dhwPreheat = message.getArgument("dhwEnabled") == 1;

			var dhwMin = message.getArgument("dhwMinSetpoint");
			if (dhwMin === "0") { dhwMin = "40"; }
			newBoilerInfo.dhwTempMin = dhwMin;

			var dhwMax = message.getArgument("dhwMaxSetpoint");
			if (dhwMax === "0") { dhwMax = "90"; }
			newBoilerInfo.dhwTempMax = dhwMax;

			boilerInfo = newBoilerInfo;
		}
	}

	BxtDatasetHandler {
		id: thermstatInfoDsHandler
		dataset: "thermostatInfo"
		discoHandler: thermostatDiscoHandler
		onDatasetUpdate: onThermostatInfoChanged(update)
	}

	BxtDatasetHandler {
		id: heatRecoveryInfoDsHandler
		dataset: "heatRecoveryInfo"
		discoHandler: thermostatDiscoHandler
		onDatasetUpdate: updateHeatRecoveryInfo(update)
	}
}
