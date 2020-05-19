import QtQuick 2.1
import BxtClient 1.0
import qb.components 1.0
import qb.base 1.0
import GraphUtils 1.0

App {
	id: statusUsageApp

	property int agreementDetailsDistrictHeating
	property int agreementDetailsElectricity
	property int agreementDetailsGas
	property int agreementDetailsSolar: globals.productOptions["solar"] === "1" && globals.solarInHcbConfig
	property string secondaryEnergyType: ""

	property App eMetersSettingsApp: canvas.getAppInstance("eMetersSettings")
	property url statusUsageScreenUrl: "StatusUsageScreen.qml"
	property url graphScreenUrl: "qrc:/apps/graph/GraphScreen.qml"
	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"
	property url estimationsPopupUrl: "EstimationsPopup.qml"

	property variant billingInfos: ({})

	// current day and month to track day- or month-change
	property int day: -1
	property int month: -1

	property int dayOfMonth
	property int daysLeft
	property int daysInMonth

	property bool firstUse: true
	property var dataAvailable: {"isAvailable": false}

	property variant elecDiffValues: emptyMonth()
	property variant gasDiffValues: emptyMonth()
	property variant heatDiffValues: emptyMonth()
	property variant totalDiffValues: emptyMonth()

	property variant configParams: ({})

	property variant energyUnits: ({total: "notUsed", elec: "kWh", gas: "m³", heat: "GJ"})
	property variant energyNames: ({"titles": {total: qsTr("Status"), elec: qsTr("Power"), gas: qsTr("Gas"), heat: qsTr("Heat")},
									 "nouns": {elec: qsTr("power"), gas: qsTr("gas"), heat: qsTr("heat")}})
	property var apiResourceNameMap: ({elec: "electricity", heat: "district-heat", gas: "gas"})

	onMonthChanged: Qt.callLater(updateCurrentMonthValues)
	onDayChanged: Qt.callLater(updateCurrentMonthValues)

	QtObject {
		id: p
		property url menuImageUrl: "drawables/menuIcon.svg"
		property url totalTileUrl: "StatusUsageTile.qml"
		property url powerEuroTileUrl: "PowerEuroTile.qml"
		property url powerEnergyTileUrl: "PowerEnergyTile.qml"
		property url gasOrHeatEnergyTileUrl: "GasOrHeatEnergyTile.qml"
		property url gasOrHeatEuroTileUrl: "GasOrHeatEuroTile.qml"
		property url trayUrl : "StatusUsageSystray.qml"
		property url thumbnailIconTotalUrl: "drawables/tile_total_thumb.svg"
		property url thumbnailIconPowerCurrencyUrl: "drawables/tile_elec_thumb.svg"
		property url thumbnailIconGasCurrencyUrl: "drawables/tile_gas_thumb.svg"
		property url thumbnailIconHeatCurrencyUrl: "drawables/tile_heat_thumb.svg"

		property string pwrusageUuid
		property string scsyncUuid
		property string configUuid

		function parseBillingInfo(msg) {
			if (msg) {
				var newBillingInfos = {};
				var infoChild = msg.getChild("info", 0);
				while (infoChild) {
					var billingInfo = {};
					var childChild = infoChild.child;
					while (childChild) {
						if (childChild.name === "type" || childChild.name === "error")
							billingInfo[childChild.name] = childChild.text;
						else
							billingInfo[childChild.name] = parseFloat(childChild.text);
						childChild = childChild.sibling;
					}

					billingInfo.haveSJV = billingInfo.error !== "notSet" && billingInfo.usage !== 0;
					newBillingInfos[billingInfo.type] = billingInfo;
					infoChild = infoChild.next;
				}
				billingInfos = newBillingInfos;
				initVarDone(1);
			}
		}

		// update property day when a new day has begun
		// update property month on the second day of a new month
		function checkForDateChange() {
			var d = new Date();
			var newDay = d.getDate();
			var newMonth = d.getMonth();
			if (day !== newDay) {
				calculateDaysLeftAndMonthDays();
				day = newDay;
			}
			if ((month !== newMonth && day !== 1) || month === -1)
				month = newMonth;
		}

		// calculates values for properties daysLeft and daysInMonth
		function calculateDaysLeftAndMonthDays() {
			var d = new Date();
			dayOfMonth = d.getDate();
			// go somewhere middle of the month to prevent skipping one month with the following setMonth()
			d.setDate(15);
			// set to next month
			d.setMonth(d.getMonth() + 1);
			// set to last day of previous (current) month
			d.setDate(0);
			daysInMonth = d.getDate();
			daysLeft = daysInMonth - dayOfMonth + 1;
		}

		function containsValidMonth(months) {
			for (var i in months)
				if (parseInt(months[i].visitedMonth) && (months[i].targetUsage || months[i].targetLowUsage) && (months[i].startDay < 2))
					return true;

			return false;
		}

		function getStatusUsageAvailable() {

			function cb(response) {
				if (response) {
					try {
						var available = response.getArgument("statusUsageAvailable");
						var json = JSON.parse(available);
						dataAvailable = json;
					} catch(e) {
						console.log("StatusUsage: failed parsing JSON from GetStatusUsageAvailable response", e)
					}
				} else {
					dataAvailable = {"isAvailable": false};
				}
				initVarDone(0);
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "specific1", "GetStatusUsageAvailable");
			bxtClient.doAsyncBxtRequest(msg, cb, 30);
		}
	}

	function init() {
		agreementDetailsDistrictHeating = parseInt(globals.productOptions["district_heating"]);
		agreementDetailsElectricity = parseInt(globals.productOptions["electricity"]);
		agreementDetailsGas = parseInt(globals.productOptions["gas"]);
		if (agreementDetailsDistrictHeating) {
			secondaryEnergyType = "heat";
		} else if (agreementDetailsGas) {
			secondaryEnergyType = "gas";
		}

		registry.registerWidget("screen", statusUsageScreenUrl, statusUsageApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, statusUsageApp, null, {objectName: "statusUsageMenuItem", label: qsTr("Status usage"), image: p.menuImageUrl, weight: 50, screenUrl: statusUsageScreenUrl, args:{type:"total", unit:"money"}});
		registry.registerWidget("systrayIcon", p.trayUrl, statusUsageApp);
		registry.registerWidget("tile", p.totalTileUrl, statusUsageApp, null, {thumbLabel: qsTr("Total"), thumbIcon: p.thumbnailIconTotalUrl, thumbCategory: "statusUsage", thumbWeight: 10, thumbIconVAlignment: "center", baseTileWeight: 70, baseTileSolarWeight: 70});
		registry.registerWidget("tile", p.powerEuroTileUrl, statusUsageApp, null, {thumbLabel: qsTr("Power"), thumbIcon: p.thumbnailIconPowerCurrencyUrl, thumbCategory: "statusUsage", thumbWeight: 20, thumbIconVAlignment: "center"});
		if (agreementDetailsDistrictHeating) {
			registry.registerWidget("tile", p.gasOrHeatEuroTileUrl, statusUsageApp, null, {thumbLabel: qsTr("Heat"), thumbIcon: p.thumbnailIconHeatCurrencyUrl, thumbCategory: "statusUsage", thumbWeight: 40, thumbIconVAlignment: "center"});
		} else if (agreementDetailsGas) {
			registry.registerWidget("tile", p.gasOrHeatEuroTileUrl, statusUsageApp, null, {thumbLabel: qsTr("Gas"), thumbIcon: p.thumbnailIconGasCurrencyUrl, thumbCategory: "statusUsage", thumbWeight: 40, thumbIconVAlignment: "center"});
		}
	}

	function getBillingInfoValue(type, variable, operator) {
		if (type === "total") {
			if (!secondaryEnergyType)
				return getBillingInfoValue("elec", variable);

			switch (operator) {
			case "or":
				return getBillingInfoValue("elec", variable) || getBillingInfoValue(secondaryEnergyType, variable);
			case "and":
				return getBillingInfoValue("elec", variable) && getBillingInfoValue(secondaryEnergyType, variable);
			case "add":
				return getBillingInfoValue("elec", variable) + getBillingInfoValue(secondaryEnergyType, variable);
			default:
				console.error("Error: Not supported operator " + operator);
				return undefined;
			}
		}
		else
			return billingInfos[type] ? billingInfos[type][variable] : undefined;
	}

	function emptyMonth() {
		return {
			"actualCost": 0,
			"actualUsage": 0,
			"estimatedCost": 0,
			"estimatedUsage": 0,
			"type": "electricity",
			"validUsageData": true
		}
	}

	function getDiffText(diff, title) {
		if (diff > 0) return qsTr("less");
		else if (diff < 0) return qsTr("more");
		else return title ? qsTr("the same") : qsTr("as estimated");
	}

	function calculateDiffValues(data, decimals) {
		var diffValues = {};
		var multiplicator = Math.pow(10, decimals);

		if (data === undefined || data === null) {
			data = emptyMonth();
		}

		diffValues.realCost = Math.round(data.actualCost);
		diffValues.targetCost = Math.round(data.estimatedCost);
		diffValues.targetCostComplete = Math.round(data.completeEstimatedCost);
		diffValues.realUsage = Math.round(data.actualUsage * multiplicator) / 1000;
		diffValues.targetUsage = Math.round(data.estimatedUsage * multiplicator) / 1000;
		diffValues.targetUsageComplete = Math.round(data.completeEstimatedUsage * multiplicator) / 1000;

		diffValues.usageDiff = Math.round(diffValues.targetUsage - diffValues.realUsage);
		diffValues.costDiff = Math.round(diffValues.targetCost - diffValues.realCost);
		diffValues.costDiffUnrounded = diffValues.targetCost - diffValues.realCost;
		diffValues.realUsage /= multiplicator;
		diffValues.targetUsage /= multiplicator;
		diffValues.targetUsageComplete /= multiplicator;
		diffValues.usageDiff /= multiplicator;
		diffValues.validUsageData = data.validUsageData;

		return diffValues;
	}

	//for current month
	function getTotalDiffValues() {
		var otherDiff;
		if (agreementDetailsDistrictHeating)
			otherDiff = heatDiffValues;
		else if (agreementDetailsGas)
			otherDiff = gasDiffValues;

		var totalDiff = {};
		if (otherDiff) {
			for (var i in elecDiffValues)
				totalDiff[i] = elecDiffValues[i] + otherDiff[i];
			totalDiff.costDiff = roundCostDiff(elecDiffValues) + roundCostDiff(otherDiff);
			totalDiff.validUsageData = elecDiffValues.validUsageData || otherDiff.validUsageData;
		} else {
			totalDiff = elecDiffValues;
			totalDiff.costDiff = roundCostDiff(elecDiffValues);
		}

		return totalDiff;
	}

	function updateCurrentMonthValues() {
		var d = new Date();
		// 1st of the year, set year to previous one
		if (d.getMonth() === 0 && month === 11)
			d.setFullYear(d.getFullYear() - 1);
		d.setMonth(month);
		var monthToFetch = d.getMonth() + 1;
		var yearToFetch = d.getFullYear();

		function cb(success, data) {
			if (success) {
				elecDiffValues = calculateDiffValues(data["electricity"], 0);
				gasDiffValues = calculateDiffValues(data["gas"], 0);
				heatDiffValues = calculateDiffValues(data["district-heat"], 2);
				totalDiffValues = getTotalDiffValues();
				console.log("elecDiffValues", JSON.stringify(elecDiffValues), "totalDiffValues", JSON.stringify(totalDiffValues));
			} else {
				console.log("updateCurrentMonthValues failed!");
			}
		}

		getMonthData(monthToFetch, yearToFetch, cb);
	}

	// "round" cost difference - if the rounded usage diff is non-zero and the rounded cost diff is zero,
	// use UNrounded cost diff. Rounded cost diff otherwise
	function roundCostDiff(diff) {
		var value = 0;
		if (diff) {
			value = diff.costDiff;
			if (diff.usageDiff !== 0 && diff.costDiff === 0) {
				value = diff.costDiffUnrounded;
			} else {
				value = diff.costDiff;
			}
		}
		return value;
	}

	// format cost difference value. If 0 < abs(value) < 1 display euro cents.
	function formatCostDiff(value) {
		var formatOption = i18n.curr_round;
		var absValue = Math.abs(value);
		if (absValue < 1)
			formatOption = 0;
		return absValue !== 0 ? i18n.currency(absValue, formatOption) : "";
	}

	function getStatusUsageFirstUse() {
		var msg =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "GetStatusUsageFirstUse");
		bxtClient.sendMsg(msg);
	}

	function setStatusUsageFirstUse(value) {
		var msg =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "SetStatusUsageFirstUse");
		msg.addArgument("firstUse", value ? "1" : "0");
		bxtClient.sendMsg(msg);
		firstUse = value;
	}

	function requestConfig() {
		var getConfigMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		getConfigMessage.addArgument("PackageName", "qt-gui");
		getConfigMessage.addArgument("internalAddress", "statusUsageConfig");
		bxtClient.doAsyncBxtRequest(getConfigMessage, getConfigCallback, 20);
	}

	function saveConfig(updateParam, value) {
		var saveConfigMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "SetObjectConfig");
		saveConfigMessage.addArgument("Config", null);
		var configNode = saveConfigMessage.getArgumentXml("Config");
		var statusUsageConfigNode = configNode.addChild("statusUsageConfig", null, 0);
		statusUsageConfigNode.addChild("package", "qt-gui", 0);
		statusUsageConfigNode.addChild("internalAddress", "statusUsageConfig", 0);
		var statusUsageParamsNode = statusUsageConfigNode.addChild("parameters", null, 0);
		if (updateParam && value) {
			var tempParams = configParams;
			tempParams[updateParam] = value.toString();
			configParams = tempParams;
		}
		for (var param in configParams)
			statusUsageParamsNode.addChild(param, configParams[param], 0);
		if (param)
			bxtClient.sendMsg(saveConfigMessage);
	}

	function getMonthData(month, year, callback) {

		function cb(response) {
			var success = false, data;
			if (response) {
				try {
					var statusUsage = response.getArgument("statusUsage");
					data = JSON.parse(statusUsage);
					success = true;
				} catch(e) {
					console.log("StatusUsage: failed parsing JSON from GetStatusUsage response", e)
				}
			}
			if (callback instanceof Function) {
				callback(success, data)
			}
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrusageUuid, "specific1", "GetStatusUsage");
		msg.addArgument("month", month);
		msg.addArgument("year", year);
		bxtClient.doAsyncBxtRequest(msg, cb, 120);
	}

	// 0=dataAvailable, 1=billingInfo, 2=firstUse
	initVarCount: 3

	Timer {
		id: dayChangedTimer
		interval: 60000
		onTriggered: p.checkForDateChange()
		running: true
		repeat: true
	}

	BxtDiscoveryHandler {
		id: pwrusageDiscoHandler
		deviceType: "happ_pwrusage"
		onDiscoReceived: {
			var firstTime = !p.pwrusageUuid;
			p.pwrusageUuid = deviceUuid;
			if (firstTime) {
				p.getStatusUsageAvailable();
				p.checkForDateChange();
				if (day === 1) {
					month = (month === 0 ? 11 : month - 1);
				}
			}
		}
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
			getStatusUsageFirstUse();
		}
	}

	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.configUuid = deviceUuid;
			requestConfig();
		}
	}

	BxtDatasetHandler {
		id: billingInfoDataset
		dataset: "billingInfo"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: p.parseBillingInfo(update)
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "GetStatusUsageFirstUseResponse"

		onResponseReceived: {
			firstUse = message.getArgument("firstUse") === "0" ? false : true;
			initVarDone(2);
		}
	}

	BxtRequestCallback {
		id: getConfigCallback

		onMessageReceived: {
			var configNode = message.getArgumentXml("Config")
			if (configNode) {
				var statusUsageConfigNode = configNode.getChild("statusUsageConfig");
				if (statusUsageConfigNode) {
					var parametersNode = statusUsageConfigNode.getChild("parameters");
					var configParamsTemp = configParams;
					var parametersNodeChild = parametersNode.child;
					while (parametersNodeChild) {
						configParamsTemp[parametersNodeChild.name] = parametersNodeChild.text;
						parametersNodeChild = parametersNodeChild.sibling;
					}
					configParams = configParamsTemp;
				}
			}
		}
	}
}
