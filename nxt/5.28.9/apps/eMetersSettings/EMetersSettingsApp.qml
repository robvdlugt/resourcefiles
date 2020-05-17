import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

import "Constants.js" as Constants

App {
	id: eMetersSettingsApp
	property url overviewEMetersScreenUrl: "OverviewEMetersScreen.qml"
	property url eMetersOverviewButtonUrl: "EMetersOverviewButton.qml"
	property url eMetersScreenUrl: "EMetersScreen.qml"
	property url eMeterChangeScreenUrl: "EMeterChangeScreen.qml"
	property url repeaterChangeScreenUrl: "RepeaterChangeScreen.qml"
	property url zwaveControlScreenUrl: "ZwaveControlScreen.qml"
	property url eMeterAdvancedScreenUrl: "EMeterAdvancedScreen.qml"

	property url eMeterIndicationScreenUrl: "EMeterIndicationScreen.qml"

	property url eMetersFrameUrl: "EMeterFrame.qml"

	property url addDeviceScreenUrl: "AddDeviceScreen.qml"
	property url removeDeviceScreenUrl: "RemoveDeviceScreen.qml"
	property url connectionQualityScreenUrl: "ConnectionQualityScreen.qml"
	property url manualConfigurationScreenUrl: "ManualConfigurationScreen.qml"

	property url eMeterLowRateHoursScreenUrl: "EMeterLowRateHoursScreen.qml"
	property url eMeterLowRateHoursPopupUrl: "EMeterLowRateHoursPopup.qml"

	property url solarInstalledScreenUrl: "SolarInstalledScreen.qml"
	property url solarConnectionFailedScreenUrl: "SolarConnectionFailedScreen.qml"
	property url checkSolarConnectionScreenUrl: "CheckSolarConnectionScreen.qml"
	property url estimatedGenerationScreenUrl: "EstimatedGenerationScreen.qml"
	property url selectSolarEMeterScreenUrl: "SelectSolarEMeterScreen.qml"
	property url solarOverviewScreenUrl: "SolarOverviewScreen.qml"
	property url solarWriteConfigurationScreenUrl: "SolarWriteConfigurationScreen.qml"

	property url metersWizardOverviewItemUrl: "MetersWizardOverviewItem.qml"
	property url meterConfigurationInstallScreenUrl: "MeterConfigurationInstallScreen.qml"

	property url maUpdateScreenUrl: "qrc:/apps/systemSettings/MaUpdateScreen.qml"

	// For unit test
	property BxtDatasetHandler tst_usageDevicesInfoDsHandler: usageDevicesInfoDsHandler
	property BxtDatasetHandler tst_billingInfoDsHandler: billingInfoDsHandler

	property variant connectedInfo: {
		'smartMeter': 0,
		'zw_status': 0,
		'dev_status': 0,
		'elec_status': 0,
		'gas_status': 0,
		'heat_status': 0,
		'solar_status': 0,
		'lowRateStartHour': 0,
		'lowRateStartMinute': 0,
		'highRateStartHour': 0,
		'highRateStartMinute': 0,
		'showErrorIndicator': 0,
		'gas_smartMeter': 0,
		'heat_smartMeter': 0,
		'solar_smartMeter': 0,
		'gridMeteringConfiguration': 0
	}

	property int errors: 0
	property int systrayErrors: 0

	property variant usageDevicesInfo: []
	property int showErrorIndicator: 0

	property string commonStatusString: ""
	property variant maDevices: []
	property variant maConfiguration: []
	// Translation of the maConfiguration[i].status bitfield to a string
	// bit 0   - gas
	// bit 1   - electricty
	// bit 2   - solar
	// bit 3   - heat
	// bit 4   - water
	// bit 5-7 - unused

	// Bit 0: indicates if at least one metering device is not OK
	// Bits [1-n]: indicates if a usage type is not OK (based on Constants.meterType)
	property int overallStatus: 0

	property variant enabledUtilities: []

	property variant meterConfiguration: ({})

	property variant smartplugDevices: []
	property variant repeaterDevices: []

	property int elecRate
	property bool zwaveControlEnabled: false
	property bool localAccessEnabled: false
	property int estimatedGeneration: 0
	property real waterTariff: 0

	// Used by the solar wizard
	property string solarWizardUuid
	property int solarWizardDivider
	property int solarWizardDividerType
	property int solarWizardEstimatedGeneration

	property variant deviceInfo: ({})

	signal zwaveDevicesUpdated
	signal sensorConfigurationUpdated

	QtObject {
		id: p
		property string p1Uuid
		property string zwaveUuid
		property string pwrUsageUuid
		property string smartplugUuid
		property string scsyncUuid
		property string netconUuid
	}

	function init() {
		registry.registerWidget("settingsFrame", eMetersFrameUrl, eMetersSettingsApp, null, {categoryName: qsTr("Energy meters"), categoryWeight: 450});
		registry.registerWidget("screen", overviewEMetersScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", addDeviceScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", connectionQualityScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", manualConfigurationScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", removeDeviceScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", eMetersScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen:true});
		registry.registerWidget("screen", eMeterChangeScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen:true});
		registry.registerWidget("screen", repeaterChangeScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen:true});
		registry.registerWidget("screen", eMeterAdvancedScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", eMeterLowRateHoursScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("statusButton", eMetersOverviewButtonUrl, eMetersSettingsApp, null, {weight: 20});
		registry.registerWidget("screen", eMeterIndicationScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", solarInstalledScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", solarConnectionFailedScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", estimatedGenerationScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", checkSolarConnectionScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", zwaveControlScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", selectSolarEMeterScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", solarOverviewScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", solarWriteConfigurationScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", meterConfigurationInstallScreenUrl, eMetersSettingsApp, null, {lazyLoadScreen: true});
		
		if (isWizardMode)
			registry.registerWidget("installationWizardOverviewItem", metersWizardOverviewItemUrl, eMetersSettingsApp, null, {weight: 30});
		
		notifications.registerSubtype("update", "metermodule", eMetersScreenUrl, {});
		notifications.registerSubtype("error", "energymeter", overviewEMetersScreenUrl, {});

		setEnabledUtilities();
		globals.productOptionsChanged.connect(setEnabledUtilities);
	}

	function setEnabledUtilities() {
		var tmp = [];
		if (parseInt(globals.productOptions["electricity"]))
			tmp.push("elec");
		if (parseInt(globals.productOptions["gas"]))
			tmp.push("gas");
		if (parseInt(globals.productOptions["district_heating"]))
			tmp.push("heat");
		if (parseInt(globals.productOptions["solar"]) && feature.appSolarEnabled())
			tmp.push("solar");
		if (feature.featWaterInsightsEnabled())
			tmp.push("water");
		enabledUtilities = tmp;
	}

	function setStandardYearTargets(target) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrUsageUuid, "", "SetStandardYearTargets");
		msg.addArgument("elecProduTarget", target * 1000);
		bxtClient.sendMsg(msg);
	}

	function setDeviceName(uuid, name) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "", "SetDeviceName");
		msg.addArgument("DeviceName", name);
		msg.addArgument("devUuid", uuid);
		bxtClient.sendMsg(msg);
	}

	function getAdapterUuidForMeter(type) {
		for (var i = 0; i < usageDevicesInfo.length; i++) {
			for (var j = 0; j < usageDevicesInfo[i].usage.length; j++) {
				 if (usageDevicesInfo[i].usage[j].type === type) {
					 return usageDevicesInfo[i].deviceUuid;
				 }
			}
		}
		console.log("Could not find adapter uuid for meter type", type)
		return ""
	}

	function getAllMeterConfigurations() {
		getMeterConfiguration()
	}

	function getMeterConfiguration(uuid) {
		if (p.p1Uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetMeterConfiguration");
			if (uuid)
				msg.addArgument("devUuid", uuid);
			bxtClient.sendMsg(msg);
		}
	}

	function setMeterConfiguration(uuid, resource, meterType, divider, dividerType) {
		if (typeof resource === "undefined")
			return;

		// uuid is an optional argument, so if it's undefined, use the uuid for
		// the configType
		if (typeof uuid === 'undefined' || uuid === "") {
			uuid = getAdapterUuidForMeter(resource);
		}

		if (uuid && p.p1Uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "SetMeterConfiguration");
			msg.addArgument("devices", null);
			var devicesNode = msg.getArgumentXml("devices");

			var deviceNode = devicesNode.addChild("device", null, 0);
			deviceNode.setAttribute("uuid", uuid);
			var resourceNode = deviceNode.addChild(resource, null, 0);
			if (typeof meterType === "number" && isFinite(meterType))
				resourceNode.addChild("meterType",meterType, 0);
			if (typeof divider === "number" && isFinite(divider))
				resourceNode.addChild("divider",divider, 0);
			if (typeof dividerType === "number" && isFinite(dividerType))
				resourceNode.addChild("dividerType",dividerType, 0);

			bxtClient.sendMsg(msg);
		}
	}

	function sendSensorConfiguration(newSensorConfiguration, callback) {
		if (!p.p1Uuid) {
			console.log("Cannot send SetSensorConfiguration before discovery of the p1Uuid.")
			return;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "SetSensorConfiguration");
		msg.addArgument("devices", null);
		var devicesNode = msg.getArgumentXml("devices");

		var hasElecSensor = false;
		var hasGasSensor = false;

		for (var i = 0; i < newSensorConfiguration.length; i++) {
			var deviceNode = devicesNode.addChild("device", null, 0);
			deviceNode.addChild("deviceUuid", newSensorConfiguration[i].deviceUuid, 0);
			var sensorNode = deviceNode.addChild("sensors", null, 0);
			for(var j = 0; j < newSensorConfiguration[i].sensors.length; j++) {
				sensorNode.addChild("sensor", newSensorConfiguration[i].sensors[j], 0);
				if (newSensorConfiguration[i].sensors[j].indexOf("Elec") !== -1) {
					hasElecSensor = true;
				}
				if (newSensorConfiguration[i].sensors[j].indexOf("Gas") !== -1) {
					hasGasSensor = true;
				}
			}
		}

		function cb(message) {
			if (message && message.getArgument("success") === "true") {
				if (isWizardMode) {
					console.log("Checking wizard stage in sendSensorConfiguration()");
					var wizardStageCompleted = true;
					if ((globals.productOptions["electricity"] === "1" && ! hasElecSensor)) {
						console.log("User has electricity commodity, but no electricity sensor. Cannot complete 'emeters' wizard stage.");
						wizardStageCompleted = false;
					}
					if (globals.productOptions["gas"] === "1" && ! hasGasSensor) {
						console.log("User has gas commodity, but no gas sensor. Cannot complete 'emeters' wizard stage.");
						wizardStageCompleted = false;
					}
					wizardstate.setStageCompleted("emeters", wizardStageCompleted);
				}
			}
			if (callback instanceof Function)
				callback(message);
		}

		bxtClient.doAsyncBxtRequest(msg, cb, 5000);
	}

	function getAvailableSensorsForConfiguration(deviceUuid, sensors, callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetAvailableSensorsForConfiguration");
		msg.addArgument("devices", null);

		var devicesNode = msg.getArgumentXml("devices");
		var deviceNode = devicesNode.addChild("device", null, 0);
		deviceNode.addChild("deviceUuid", deviceUuid, 0);
		for(var i = 0; i < sensors.length; i++) {
			var sensorNode = deviceNode.addChild("sensor", sensors[i].name, 0);
			sensorNode.setAttribute("resource", sensors[i].resource);
			sensorNode.setAttribute("type", sensors[i].type);
		}

		if (typeof callback === 'undefined') {
			bxtClient.sendMsg(msg);
		} else {
			bxtClient.doAsyncBxtRequest(msg, callback, 5000);
		}
	}

	function getSensorConfiguration() {
		if (p.p1Uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetSensorConfiguration");
			bxtClient.sendMsg(msg);
		} else {
			console.log("Cannot send GetSensorConfiguration before discovery of the p1Uuid.")
		}
	}

	function getMeasureCapabilities(uuid, callback) {
		if (p.p1Uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetMeasureCapabilities");
			msg.addArgument("deviceUuid", uuid);
			bxtClient.doAsyncBxtRequest(msg, callback, 30);
		} else {
			console.log("Cannot send GetMeasureCapabilities before discovery of the p1Uuid.")
		}
	}


	function getDividerConfigurable(uuid, type, callback) {
		if (p.p1Uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetDividerConfigurable");
			msg.addArgument("deviceUuid", uuid);
			msg.addArgument("type", type);
			bxtClient.doAsyncBxtRequest(msg, callback, 10);
		} else {
			console.log("Cannot send GetDividerConfigurable before discovery of the p1Uuid.")
		}
	}

	function checkMeasureCapability(supportedList, checkList) {
		// return true if at least one capability in checkList is found in supportedList
		var length = checkList.length;
		for (var i=0; i < length; i++)
			if(supportedList.indexOf(checkList[i]) >= 0)
				return true;

		return false;
	}

	function checkDeviceHasSensor(uuid, sensor) {
		var hasSensor = false

		for (var idx = 0; idx < maConfiguration.length; idx++) {
			if (maConfiguration[idx].deviceUuid === uuid) {
				hasSensor = (maConfiguration[idx].sensors.indexOf(sensor) !== -1)
				break
			}
		}

		return hasSensor
	}

	function getInformationSourceStatus(uuid) {
		for(var i=0; i < maConfiguration.length; i++) {
			if(maConfiguration[i].deviceUuid === uuid) {
				return maConfiguration[i].status;
			}
		}
		return "";
	}

	function getInformationSourceStatusInt(uuid) {
		for(var i=0; i < maConfiguration.length; i++) {
			if(maConfiguration[i].deviceUuid === uuid) {
				return maConfiguration[i].statusInt;
			}
		}
		return 0;
	}

	function checkAvailableMeasureType(uuid, sensorList) {
		// return false if at least one sensor this type is configured for other adapters
		var length = (sensorList.constructor === Array) ? sensorList.length : 1;
		for (var i=0; i < length; i++) {
			var text  = (sensorList.constructor === Array) ? sensorList[i] : sensorList;
			for (var j=0; j < maConfiguration.length; j++) {
				if (uuid !== maConfiguration[j].deviceUuid) {
					if(maConfiguration[j].sensors.indexOf(text) >= 0) {
						return false;
					}
				}
			}
		}
		return true;
	}

	function getDeviceType(index) {
		if (index < maDevices.length) {
			return maDevices[index].type;
		} else {
			return "";
		}
	}

	function getZwaveDeviceByUuid(uuid) {
		for (var i=0; i < maDevices.length; i++ ) {
			if (maDevices[i].uuid === uuid) {
				return maDevices[i]
			}
		}
		return null;
	}

	function getDeviceTypeWithId(uuid) {
		var dev = getZwaveDeviceByUuid(uuid);
		if (dev)
			return dev.type;
		else
			return "";
	}

	// Returns the first found usage child of a specific usageDevice matching the type given
	function getUsageByTypeFromDevice(usageDevice, type) {
		if (typeof usageDevice === "object" && Array.isArray(usageDevice.usage)) {
			for (var j=0; j < usageDevice.usage.length; j++) {
				if (usageDevice.usage[j].type === type) {
					return usageDevice.usage[j];
				}
			}
		}
	}

	// Returns the first found usage child of the first usageDevice found matching the type given
	function getUsageByType(type) {
		for (var i=0; i < usageDevicesInfo.length; i++ ) {
			for (var j=0; j < usageDevicesInfo[i].usage.length; j++) {
				if (usageDevicesInfo[i].usage[j].type === type) {
					return {usage: usageDevicesInfo[i].usage[j], usageIndex: j, deviceIndex: i};
				}
			}
		}
		return {usage: undefined};
	}

	function hasUsageOfType(usageDevice, type) {
		if (!usageDevice || !usageDevice.usage)
			return false;

		for (var j=0; j < usageDevice.usage.length; j++) {
			if ((typeof type === "string" && usageDevice.usage[j].type === type) ||
					(Array.isArray(type) && type.indexOf(usageDevice.usage[j].type) >= 0)) {
				return true;
			}
		}
		return false;
	}

	function removeAllRepeaters() {
		if (!repeaterDevices.length)
			return;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "RemoveDevice");
		for (var idx in repeaterDevices) {
			msg.addArgument("uuid", repeaterDevices[idx].uuid);
		}
		bxtClient.sendMsg(msg);
	}

	function removeMeasureDevices() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "RemoveDevice");
		for (var idx in maDevices) {
			msg.addArgument("uuid", maDevices[idx].uuid);
		}
		bxtClient.sendMsg(msg);
	}

	function removeZwaveDevice(uuid) {
		if (!uuid)
			return;
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "RemoveDevice");
		bxtClient.sendMsg(msg);
	}

	function getDividerString(resource, dividerType, divider, addUnit) {
		var dividerAsString = "";
		var resourceUnits = Constants.cValueUnits[resource];
		if (Constants.cValueUnits[resource] === "undefined")
			return "";
		resourceUnits.some(function (obj) {
			return obj.units.some(function (unit) {
				if (unit.id === dividerType) {
					if (unit.divisor) {
						dividerAsString = i18n.number(unit.divisor / divider, 2, i18n.omit_trail_zeros);
					} else if (unit.multi) {
						dividerAsString = i18n.number(divider / unit.multi, 2, i18n.omit_trail_zeros);
					} else {
						dividerAsString = i18n.number(divider, 2, i18n.omit_trail_zeros);
					}

					if (addUnit) {
						if (typeof unit.unitNames[0] === "object" && unit.unitNames[0].unitBefore) {
							dividerAsString = unit.unitNames[0].name + " " + dividerAsString;
						} else {
							dividerAsString = dividerAsString + " " + unit.unitNames[0];
						}
					}

					return true;
				}
			});
		});
		return dividerAsString;
	}

	function setDividerMeterType(uuid, resource, meterType)
	{
		if (Constants.cValueUnits[resource] === undefined || Constants.cValueUnits[resource][meterType] === undefined)
			return false;

		var resourceUnits = Constants.cValueUnits[resource][meterType];
		if (!resourceUnits.units.length)
			return false;

		var newDividerType = resourceUnits.units[0].id
		var newDivider = resourceUnits.units[0].defVal;

		var dividerFloat = 0.0;
		if (resourceUnits.units[0].divisor) {
			dividerFloat = resourceUnits.units[0].divisor / newDivider;
		} else if (resourceUnits.units[0].multi) {
			dividerFloat = newDivider * resourceUnits.units[0].multi;
		} else {
			dividerFloat = newDivider;
		}

		setMeterConfiguration(uuid, resource, meterType, dividerFloat, newDividerType);
		return true;
	}

	function parseConnectedInfo(update) {
		var tmpConnectedInfo = {};
		var node = update.child;
		while (node) {
			tmpConnectedInfo[node.name] = parseInt(node.text);
			node = node.sibling;
		}
		connectedInfo = tmpConnectedInfo;
		initVarDone(0);
	}

	function parseUsageDevicesInfo(update) {
		if (update) {
			var tmpInfo = [];
			var indicator = parseInt(update.getChildText("showErrorIndicator"));
			var status = update.getChildText("statusString");
			showErrorIndicator = indicator;
			commonStatusString = status;
			var hasElecSensor = false;
			var hasGasSensor = false;
			var hasWaterSensor = false;

			for (var info = update.getChild("usageDeviceInfo"); info; info = info.next) {
				var usage = [];
				var usageItem = {}
				for(var sensor = info.getChild("usage"); sensor; sensor = sensor.next) {
					usageItem = {};
					usageItem["type"] = sensor.getChildText("type");
					usageItem["status"] = parseInt(sensor.getChildText("status"));
					usageItem["measureType"] = parseInt(sensor.getChildText("measureType"));
					["meterType", "dividerType", "divider"].forEach(function (field) {
						var tmpString = sensor.getChildText(field);
						if (tmpString)
							usageItem[field] = parseFloat(tmpString);
					});
					var usageErrorCode = sensor.getChildText("errorCode");
					if (usageErrorCode)
						usageItem["errorCode"] = usageErrorCode;
					usage.push(usageItem);

					if (usageItem["type"] === "elec") {
						hasElecSensor = true;
					} else if (usageItem["type"] === "gas") {
						hasGasSensor = true;
					} else if (usageItem["type"] === "water") {
						hasWaterSensor = true;
					}
				}
				var tmp = {
					'statusString': info.getChildText("statusString"),
					'showErrorIndicator': info.getChildText("showErrorIndicator") === "1" ? true : false,
					'deviceUuid': info.getChildText("deviceUuid"),
					'deviceIdentifier': info.getChildText("deviceIdentifier"),
					'deviceStatus': parseInt(info.getChildText("deviceStatus")),
					'usage': usage
				};
				var errorCode = info.getChildText("errorCode");
				if (errorCode)
					tmp["errorCode"] = errorCode;
				tmpInfo.push(tmp);
			}

			// check if there was no water measuring device before the update, but there is now
			// and if so, send notification about water tiles
			if ((initVars & (1 << 1)) === 0 && !getUsageByType("water").usage && hasWaterSensor) {
				util.delayedCall(5000, function() {
					notifications.send("feature", "newTile", false, qsTr("new-water-tile-add"), "category=water");
				});
			}

			usageDevicesInfo = tmpInfo;
			updateErrors();
			initVarDone(1);

			if (isWizardMode) {
				checkWizardState(hasElecSensor, hasGasSensor);
			}
		}
	}

	function checkWizardState(hasElecSensor, hasGasSensor) {
		var wizardStageCompleted = true;
		if (globals.productOptions["electricity"] === "1") {
			if (! hasElecSensor) {
				// If there is no sensor configured...
				console.log("User has electricity commodity, but no electricity sensor. Cannot complete 'emeters' wizard stage.");
				wizardStageCompleted = false;
			} else {
				// Or if the sensor is not operational/commissioning
				var elecStatus = getUsageByType("elec").usage.status;
				switch (elecStatus) {
				case Constants.meterStatusValues.ST_OPERATIONAL:
				case Constants.meterStatusValues.ST_COMMISSIONING:
					break;
				default:
					console.log("Elec sensor status is not operational/commissioning", elecStatus);
					wizardStageCompleted = false;
					break;
				}
			}
		}
		if (globals.productOptions["gas"] === "1") {
			if (! hasGasSensor) {
				console.log("User has gas commodity, but no gas sensor. Cannot complete 'emeters' wizard stage.");
				wizardStageCompleted = false;
			} else {
				var gasStatus = getUsageByType("gas").usage.status;
				switch (gasStatus) {
				case Constants.meterStatusValues.ST_OPERATIONAL:
				case Constants.meterStatusValues.ST_COMMISSIONING:
					break;
				default:
					console.log("Gas sensor status is not operational/commissioning", gasStatus);
					wizardStageCompleted = false;
					break;
				}
			}
		}
		if (! wizardstate.stageCompleted("activation")) {
			console.log("User is not activated yet. Cannot determine if their product options are completed if we don't know their product options yet.");
			wizardStageCompleted = false;
		}

		wizardstate.setStageCompleted("emeters", wizardStageCompleted);
	}

	function getUsageDeviceByUuid(uuid) {
		for (var i=0; i<usageDevicesInfo.length; i++) {
			if (usageDevicesInfo[i].deviceUuid === uuid)
				return usageDevicesInfo[i];
		}
	}

	function getStatusString(uuid) {
		for (var i=0; i<usageDevicesInfo.length; i++) {
			if (usageDevicesInfo[i].deviceUuid === uuid)
				return usageDevicesInfo[i].statusString;
		}
		return qsTr("Not installed");
	}

	function getDeviceIdentifier(uuid){
		for (var i=0; i<usageDevicesInfo.length; i++){
			if (usageDevicesInfo[i].deviceUuid === uuid)
				return usageDevicesInfo[i].deviceIdentifier;
		}
		return "";
	}

	function getDeviceSerialNumber(uuid) {
		if (deviceInfo[uuid]) {
			var deviceSerialNumber = deviceInfo[uuid]["SerialNumber"];
			if (deviceSerialNumber === undefined || deviceSerialNumber === "-") {
				deviceSerialNumber = qsTr("Generic meter module");
			}
			return deviceSerialNumber;
		}
		return "-";
	}

	function getZwaveStatus(uuid) {
		for (var i=0; i<usageDevicesInfo.length; i++){
			if (usageDevicesInfo[i].deviceUuid === uuid)
				return usageDevicesInfo[i].deviceStatus;
		}
		console.log("No device known in usageDevicesInfo with uuid", uuid, "status reported as 'not configured'");
		return Constants.USAGEDEVICE_STATUS.CONN_NOT_CONFIGURED;
	}

	function getUsageStatus(usage) {
		if (!usage || typeof usage.status === "undefined")
			return;
		return Constants.meterStatusCodes[usage.status];
	}

	function parseBillingInfo(update) {
		var node = update.getChild("info");
		while (node) {
			var type = node.getChildText("type");
			if (node.getChildText("error")) {
				node = node.next;
				continue;
			}

			if (type === "elec") {
				elecRate = parseInt(node.getChildText("rate"));
			} else if (type === "elec_produ") {
				estimatedGeneration = node.getChildText("usage") / 1000;
			} else if (type === "water") {
				waterTariff = parseFloat(node.getChildText("price"));
			}
			node = node.next;
		}
	}

	function parseDeviceConfigInfo(update) {
		var newSmartplugDevices = [];
		var node = update.getChild("device");
		while (node) {
			var zwUuid = node.getChildText("ZWUuid");
			if (zwUuid) {
				newSmartplugDevices.push(zwUuid);
			}
			node = node.next;
		}
		// Save smartplug devices
		smartplugDevices = newSmartplugDevices;
	}

	function getPeakPeriods(screenCallback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "GetPeakPeriods");
		bxtClient.doAsyncBxtRequest(msg, screenCallback, 3);
	}

	// Convenience function for transforming a GetPeakPeriodsResponse message to a Javascript map
	function parsePeakPeriodsResponse(msg) {
		if (msg) {
			var tmpPeakPeriodConfig = ({});
			var peakPeriods = msg.getArgumentXml("peakPeriods");

			for (var curPeriod = peakPeriods.getChild("peakPeriod"); curPeriod; curPeriod = curPeriod.next) {
				var id         = curPeriod.getChildText("id");
				var peakStart  = curPeriod.getChildText('peakStart');
				var peakEnd    = curPeriod.getChildText('peakEnd');
				var active     = ('1' === curPeriod.getChildText('active'));
				var defaultVar = ('1' === curPeriod.getChildText('default'));

				var peakStartHour, peakStartMinute, peakEndHour, peakEndMinute;
				if (peakStart.length === 4) {
					peakStartHour   = parseInt(peakStart.substring(0,2), 10)
					peakStartMinute = parseInt(peakStart.substring(2), 10);
				}
				if (peakEnd.length === 4) {
					peakEndHour   = parseInt(peakEnd.substring(0,2), 10);
					peakEndMinute = parseInt(peakEnd.substring(2), 10);
				}

				var values = {
					'peakStartHour':   peakStartHour,
					'peakStartMinute': peakStartMinute,
					'peakEndHour':     peakEndHour,
					'peakEndMinute':   peakEndMinute,
					'active': active,
					'default': defaultVar
				};

				tmpPeakPeriodConfig[id] = values;
			}

			return tmpPeakPeriodConfig;
		} else {
			// timeout
			console.log("Timeout on requesting peak period configuration.");
			return null;
		}
	}

	function setPeakPeriod(periodId) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "SetPeakPeriod");
		msg.addArgument("id", periodId);
		bxtClient.sendMsg(msg);
	}

	function activateSolar() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "", "ActivateSolar");
		bxtClient.sendMsg(msg);
	}

	function getCanActivateSolar(callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "", "CanActivateSolar");
		bxtClient.doAsyncBxtRequest(msg, callback, 3);
	}

	function getDeviceInfo() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "", "GetDeviceInfo");
		bxtClient.doAsyncBxtRequest(msg, getDeviceInfoCallback, 30);
	}

	function sendResetMaSensor(uuid, type) {
		if (!type)
			return;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "ResetMaSensor");
		if (uuid)
			msg.addArgument("devUuid", uuid);
		msg.addArgument("type", type);
		bxtClient.sendMsg(msg);
	}

	function setZwaveControlState(newStatus) {
		if (newStatus === zwaveControlEnabled)
			return;

		zwaveControlEnabled = newStatus;
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "SetControlStatus");
		msg.addArgument("status", newStatus ? "1" : "0");
		bxtClient.sendMsg(msg);
	}

	function requestZwaveControlState() {
		function callback(message) {
			zwaveControlEnabled = message.getArgument("status") === "true" ? true : false;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "GetControlStatus");
		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function requestLocalAccessState() {
		function callback(message) {
			localAccessEnabled = message.getArgument("enabled") === "true" ? true : false;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.netconUuid, "specific1", "CheckServiceEnable");
		msg.addArgument("name", "http");
		bxtClient.doAsyncBxtRequest(msg, callback, 30);
	}

	function updateErrors() {
		var meterError = 0;
		var errorCount = 0;
		var kpiString = "";
		for (var i = 0; i < usageDevicesInfo.length; i++) {
			var connected = true;
			if (usageDevicesInfo[i].deviceStatus < Constants.USAGEDEVICE_STATUS.CONN_OK) {
				connected = false;
				errorCount++;
			} else if (!usageDevicesInfo[i].usage.length) {
				errorCount++;
			}
			for (var j = 0; j < usageDevicesInfo[i].usage.length; j++) {
				var type = usageDevicesInfo[i].usage[j].type;
				var mType = Constants.measureTypeStrings[usageDevicesInfo[i].usage[j].measureType];
				var typeIndex = Constants.meterType[type];
				var status = getUsageStatus(usageDevicesInfo[i].usage[j]);
				if (status === Constants.STATUS.ERROR || (!connected && usageDevicesInfo[i].showErrorIndicator)) {
					meterError |= (1 << typeIndex);
					if (connected) {
						kpiString += "_" + mType.toUpperCase() + "_" + type.toUpperCase();
						errorCount++;
					}
				}
			}
		}

		if (!usageDevicesInfo.length)
			errorCount = -1;

		var newStatus = (meterError << 1) | (showErrorIndicator ? 1 : 0);

		errors = errorCount;
		if (errorCount <= 0) {
			if (errors > 0 && typeof hcblog !== "undefined")
				hcblog.logKpi("ErrorIconCauseFixed", "EMETERS_OK");
			systrayErrors = 0;
		} else {
			systrayErrors = newStatus ? 1 : 0;
			if (newStatus & 0x1)
				kpiString = "_MA_CONN" + kpiString;
			if (overallStatus !== newStatus && systrayErrors && typeof hcblog !== "undefined")
				hcblog.logKpi("ErrorIconCause", "EMETERS" + kpiString + "_ERROR");
		}
		overallStatus = newStatus;
	}

	function getMaConfigurationStatusString(status) {
		if (status <= 0)
			return qsTr("Not configured");

		var resources =  [];
		if (status & 1)
			resources.push(qsTr("configured_gas"));
		if (status & 2)
			resources.push(qsTr("configured_elec"));
		if (status & 4)
			resources.push(qsTr("configured_solar"));
		if (status & 8)
			resources.push(qsTr("configured_heat"));
		if (status & 16)
			resources.push(qsTr("configured_water"));

		if (resources.length) {
			return qsTr("Configured for %1").arg(i18n.arrayToSentence(resources, "", qsTr("and")));
		} else {
			return qsTr("Not configured");
		}
	}

	/**
	 * @brief Sets the tariff for water utility
	 * @param[in]	tariff		tariff for water in m3
	 */
	function setWaterTariff(tariff) {
		if (isNaN(parseFloat(tariff)))
			return;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrUsageUuid, "specific1", "BaseData");
		var node = msg.addArgumentXmlText("<BaseField><Type>WATER</Type><SeparateBilling>false</SeparateBilling><TariffPeak>%1</TariffPeak></BaseField>".arg(tariff));
		bxtClient.sendMsg(msg);
		countly.sendEvent("Water.TariffChanged", null, null, -1, null);
	}

	// 0=connectedInfo
	// 1=usageDevicesInfo
	initVarCount: 2

	BxtDiscoveryHandler {
		id: p1DiscoHandler
		deviceType: "hdrv_p1"
		onDiscoReceived: {
			p.p1Uuid = deviceUuid;
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
		id: pwrUsageDiscoHandler
		deviceType: "happ_pwrusage"
		onDiscoReceived: {
			p.pwrUsageUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: smartplugDiscoHandler
		deviceType: "happ_smartplug"
		onDiscoReceived: {
			p.smartplugUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid
			getDeviceInfo();
		}
	}

	BxtDiscoveryHandler {
		deviceType: "hcb_netcon"
		onDiscoReceived: p.netconUuid = deviceUuid;
	}

	BxtDatasetHandler {
		id: deviceConfigInfoDSHandler
		dataset: "deviceConfigInfo"
		discoHandler: smartplugDiscoHandler
		onDatasetUpdate: parseDeviceConfigInfo(update)
	}

	BxtDatasetHandler {
		id: billingInfoDsHandler
		dataset: "billingInfo"
		discoHandler: pwrUsageDiscoHandler
		onDatasetUpdate: parseBillingInfo(update)
	}

	BxtDatasetHandler {
		id: connectedInfoDsHandler
		dataset: "connectedInfo"
		discoHandler: p1DiscoHandler
		onDatasetUpdate: parseConnectedInfo(update)
	}

	BxtDatasetHandler {
		id: usageDevicesInfoDsHandler
		discoHandler: p1DiscoHandler
		dataset: "usageDevicesInfo"
		onDatasetUpdate: parseUsageDevicesInfo(update)
	}

	BxtRequestCallback {
		id: getDeviceInfoCallback
		onMessageReceived: {
			if (message) {
				var devicesNode = message.getArgumentXml("devices");
				var device = devicesNode ? devicesNode.getChild("device") : undefined;

				var tmpDeviceInfo = {};
				for (; device; device = device.next) {
					var deviceUuid = device.getChildText("deviceUuid");
					if (deviceUuid) {
						var deviceObj = {}
						for (var param = device.child; param; param = param.sibling) {
							// skip param used as key
							if (param.name === "deviceUuid")
								continue;

							if (param.text === "true" || param.text === "false")
								deviceObj[param.name] = (param.text === "true");
							else
								deviceObj[param.name] = param.text;
						}
						tmpDeviceInfo[deviceUuid] = deviceObj;
					}
				}
				deviceInfo = tmpDeviceInfo;
			}
		}
	}

	Connections {
		target: zWaveUtils
		onDevicesChanged: {
			var repeaters = [];
			var adapters = [];

			for (var uuid in zWaveUtils.devices) {
				var dev = zWaveUtils.devices[uuid];
				var isMeasureDevice = getZwaveStatus(uuid);
				console.log("Device - Name:", dev.name, "uuid:", dev.uuid, "isMeasureDevice:", isMeasureDevice);
				if (isMeasureDevice) {
					adapters.push(dev);
				} else {
					var battPowered = dev["CurrentBatteryLevel"];
					// Add as repeater if no smartplug and not battery powered
					if (!~smartplugDevices.indexOf(uuid) && battPowered === undefined) {
						repeaters.push(dev);
					}
				}
			}

			// Save devices
			repeaterDevices = repeaters;
			maDevices = adapters

			zwaveDevicesUpdated();
		}
	}

	BxtResponseHandler {
		response: "GetMeterConfigurationResponse"
		onResponseReceived: {
			var tmpConfig = meterConfiguration;

			for (var device = message.getArgumentXml("device"); device; device = device.next) {
				var devUuid = device.getAttribute("uuid");
				var resourcesObj = tmpConfig[devUuid] ? tmpConfig[devUuid] : {};
				for (var resource = device.child; resource; resource = resource.sibling) {
					var type = parseInt(resource.getChildText("meterType"));
					var divider = parseInt(resource.getChildText("divider"));
					var dividerType = parseInt(resource.getChildText("dividerType"));
					resourcesObj[resource.name] = {
						"type": !isNaN(type) ? type : undefined,
						"divider": !isNaN(divider) ? divider : undefined,
						"dividerType": !isNaN(dividerType) ? dividerType : undefined
					};
				}
				tmpConfig[devUuid] = resourcesObj;
			}
			meterConfiguration = tmpConfig;
		}
	}

	BxtResponseHandler {
		response: "GetSensorConfigurationResponse"
		onResponseReceived: {
			var newSensorConfiguration = [];

			for (var device = message.getArgumentXml("device"); device; device = device.next) {
				var status = 0;
				var node = device.getChild("sensors");
				var sensors = [];
				for (var sensor = node.getChild("sensor"); sensor; sensor = sensor.next) {
					var text = sensor.text;
					if(text === 'analogGas'|| text === 'p1Gas') {
						status |= Constants.CONFIG_STATUS.GAS;
					}
					if(text === 'analogElec'|| text === 'p1Elec'|| text === 'laserElec') {
						status |= Constants.CONFIG_STATUS.ELEC;
					}
					if(text === 'analogSolar') {
						status |= Constants.CONFIG_STATUS.SOLAR;
					}
					if(text === 'analogHeat') {
						status |= Constants.CONFIG_STATUS.HEAT;
					}
					if(text === 'analogWater') {
						status |= Constants.CONFIG_STATUS.WATER;
					}
					sensors.push(text);
				}
				var newDev = {
					'deviceUuid': device.getChildText("deviceUuid"),
					'sensors': sensors,
					'status': getMaConfigurationStatusString(status),
					'statusInt': status
				};
				newSensorConfiguration.push(newDev);
			}

			maConfiguration = newSensorConfiguration;
			sensorConfigurationUpdated();
		}
	}
}

