import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0;
import GraphUtils 1.0;

/// Graph Application.

import qb.energyinsights 1.0 as EnergyInsights

App {
	id: graphApp

	property GraphScreen graphScreen

	/// throbber when waiting for rrd response
	property Popup requestDataThrobber
	property url requestDataThrobberUrl: "qrc:/qb/components/FullScreenThrobber.qml"
	property url graphScreenUrl: "GraphScreen.qml"

	property bool hasElectricity: globals.productOptions["electricity"] === "1"
	property bool hasGas: globals.productOptions["gas"] === "1"
	property bool hasDistrictHeating: globals.productOptions["district_heating"] === "1"
	property bool hasSolar: globals.productOptions["solar"] === "1" && globals.solarInHcbConfig === 1
	property bool hasWater: feature.featWaterInsightsEnabled() && (waterUsageData["installed"] ? true : false)

	property variant waterUsageData: ({})
	property bool waterUsageDataRead: false

	property variant heatUsageData: ({})
	property bool heatUsageDataRead: false

	property variant gasUsageData: ({})
	property bool gasUsageDataRead: false

	property variant powerUsageData: ({})
	property bool powerUsageDataRead: false

	property variant boilerUsageData: ({})
	property bool boilerUsageDataRead: false

	property variant billingInfoElec: ({})
	property bool billingInfoElecRead: false
	property variant billingInfoGas: ({})
	property bool billingInfoGasRead: false
	property variant billingInfoHeat: ({})
	property bool billingInfoHeatRead: false
	property variant billingInfoElecProdu: ({})
	property bool billingInfoElecProduRead: false

	property variant dayTilePowerValues: [0, 0, 0]
	property variant dayTileEuroPowerValues: [0, 0, 0]
	property variant dayTilePowerFixedCostsValues: [0, 0, 0]
	property variant dayTileGasValues: [0, 0, 0]
	property variant dayTileEuroGasValues: [0, 0, 0]
	property variant dayTileHeatValues: [0, 0, 0]
	property variant dayTileEuroHeatValues: [0, 0, 0]
	property variant dayTileSolarValues: [0, 0, 0]
	property variant dayTileEuroSolarValues: [0, 0, 0]
	property variant dayTileWaterValues: [0, 0, 0]
	property variant dayTileEuroWaterValues: [0, 0, 0]
	property variant hourTilePowerValues: []
	property variant hourTileGasValues: []
	property variant hourTileHeatValues: []
	property variant hourTileSolarRawValues: []
	property variant hourTileSolarValues: []
	property variant hourTileWaterValues: []
	/// 5 minutes interval start/end time for power and gas without smart meter - used to create period for rrd request and display time in hour tiles
	property variant hourTileStartTime5min: new Date()
	property variant hourTileEndTime5min: new Date()
	/// 1 hour interval start/end time for heat and gas with smart meter - used to create period for rrd request and display time in hour tiles
	property variant hourTileStartTime1h: new Date()
	property variant hourTileEndTime1h: new Date()
	/// 5 minuts interval start/end time for solar (first measured generation since 0:00 hour, last measurement of past 5 minutes if there was
	/// generation. Used to create period for rrd request and display time in hour tiles
	property variant hourTileStartTimeSolar: new Date()
	property variant hourTileEndTimeSolar: new Date()
	/// max values to set correct yScale for area graphs in hour tiles
	property real hourTilePowerMaxValue: 0
	property real hourTileGasMaxValue: 0
	property real hourTileHeatMaxValue: 0
	property real hourTileSolarRawMaxValue: 0
	property real hourTileSolarMaxValue: hourTileSolarRawMaxValue
	property real hourTileWaterMaxValue: 0

	property alias monthDataDataset: monthDataDataset

	/// hdrv_p1 connectedInfo dataset (with default values for high/low rate start hour)
	property variant connectedInfo: {'lowRateStartHour': 23, 'highRateStartHour': 8}

	property int day: -1

	property bool enableSME: globals.productOptions["SME"] === "1"

	signal usageDatasetChanged
	signal isHolidayOrWeekendResponse(bool isLow)

	QtObject {
		id: p
		property string pwrusageUuid
		property string p1Uuid
		property variant heatingBeatTiles: []
		property variant waterTiles: []

		property url graphsMenuUrl: "GraphMenu.qml"
		property url waterTodayTileUrl: "GraphWaterTodayTile.qml"
		property url gasTodayTileUrl: "GraphGasTodayTile.qml"
		property url heatTodayTileUrl: "GraphHeatTodayTile.qml"
		property url powerTodayTileUrl: "GraphPowerTodayTile.qml"
		property url boilerTodayTileUrl: "GraphBoilerTodayTile.qml"
		property url solarTodayTileUrl: "SolarGenerationTodayTile.qml"
		property url euroWaterTodayTileUrl: "GraphEuroWaterTodayTile.qml"
		property url euroGasTodayTileUrl: "GraphEuroGasTodayTile.qml"
		property url euroHeatTodayTileUrl: "GraphEuroHeatTodayTile.qml"
		property url euroPowerTodayTileUrl: "GraphEuroPowerTodayTile.qml"
		property url solarEuroTodayTileUrl: "SolarEuroGenerationTodayTile.qml"
		property url waterDayTileUrl: "GraphWaterDayTile.qml"
		property url gasDayTileUrl: "GraphGasDayTile.qml"
		property url heatDayTileUrl: "GraphHeatDayTile.qml"
		property url powerDayTileUrl: "GraphPowerDayTile.qml"
		property url euroWaterDayTileUrl: "GraphEuroWaterDayTile.qml"
		property url euroGasDayTileUrl: "GraphEuroGasDayTile.qml"
		property url euroHeatDayTileUrl: "GraphEuroHeatDayTile.qml"
		property url euroPowerDayTileUrl: "GraphEuroPowerDayTile.qml"
		property url waterHourTileUrl: "GraphWaterHourTile.qml"
		property url gasHourTileUrl: "GraphGasHourTile.qml"
		property url heatHourTileUrl: "GraphHeatHourTile.qml"
		property url powerHourTileUrl: "GraphPowerHourTile.qml"
		property url solarHourTileUrl: "GraphSolarHourTile.qml"
		property url powerThisMomentTileUrl : "PowerThisMomentTile.qml"
		property url waterThisMomentTileUrl : "WaterThisMomentTile.qml"
		property url lowestUsageTileUrl : "LowestUsageTile.qml"
		property url usageThisMomentTileUrl : "UsageThisMomentTile.qml"
		property url takeAndReturnTileUrl : "TakeAndReturnTile.qml"
		property url solarDayTileUrl: "GraphSolarDayTile.qml"
		property url euroSolarDayTileUrl: "GraphEuroSolarDayTile.qml"
		property url solarThisMomentTileUrl : "SolarThisMomentTile.qml"

		property url thumbnailIconMoment: "drawables/ChooseTileMoment.svg"
		property url thumbnailIconWaterNow: "drawables/waterTapTile-thumb.svg"
		property url thumbnailIconCurrency: "drawables/ChooseTileCurrency.svg"
		property url thumbnailIconBoilerTime: "drawables/boilerTime_thumbIcon.svg"
		property url thumbnailIconM3: "drawables/ChooseTileM3.svg"
		property url thumbnailIconGJ: "drawables/ChooseTileGJ.svg"
		property url thumbnailIconKWh: "drawables/ChooseTileKWh.svg"
		property url thumbnailIconDaysCurrency: "drawables/ChooseTileDaysCurrency.svg"
		property url thumbnailIconDaysM3: "drawables/ChooseTileDaysM3.svg"
		property url thumbnailIconDaysGJ: "drawables/ChooseTileDaysGJ.svg"
		property url thumbnailIconDaysKWh: "drawables/ChooseTileDaysKWh.svg"
		property url thumbnailIconHourTile: "drawables/ChooseHourTile.svg"
		property url thumbnailIconHourSolarTile: "drawables/ChooseHourSolarTile.svg"
		property url thumbnailIconLowestToday: "drawables/LowestUsageThumb.svg"
		property url thumbnailIconUsageMoment: "drawables/ChooseTileUsageNow.svg"
		property url thumbnailIconTakeAndReturn: "drawables/TakeAndReturn.svg"
		property url thumbnailIconSolarMoment: "drawables/ChooseTileSolarNow.svg"

		//for unit tests
		property alias tst_connectedInfoDsHandler: connectedInfoDataset
		property alias tst_monthDataDsHandler: monthDataDataset
		property alias tst_gasUsageDataset: gasUsageDataset
		property alias tst_powerUsageDataset: powerUsageDataset
		property alias tst_heatUsageDataset: heatUsageDataset
		property alias tst_billingInfoDataset: billingInfoDataset

		function updatePeriodLast4Hours(is5MinInterval) {
			var d = new Date();
			//for power and !isSmart gas it is 5 minutes interval, 1 hour otherwise
			var interval = is5MinInterval ? 5 : 60;
			d.setMinutes(Math.floor(d.getMinutes() / interval) * interval, 0, 0);
			if (is5MinInterval)
				hourTileEndTime5min = d;
			else
				hourTileEndTime1h = d;
			d.setMinutes(d.getMinutes() - 240, 0, 0);
			if (is5MinInterval)
				hourTileStartTime5min = d;
			else
				hourTileStartTime1h = d;
		}

		function processSolarHoursTileData(data) {
			// sliceing the data only for any measured (non-zero) values
			var startIdx = -1, endIdx = -1;
			for (var i = 0; i < data.length; i++) {
				if (!isNaN(data[i])) {
					if (startIdx < 0 && data[i] > 0) {
						//first non-zero value index
						startIdx = i;
					}
					if (data[i] > 0) {
						//last non-zero value index
						endIdx = i;
					}
				}
			}

			if (startIdx >= 0) {
				var tmpTime = graphUtils.dayStart(new Date());
				tmpTime.setMinutes(startIdx * 5);
				hourTileStartTimeSolar = tmpTime;
				tmpTime = graphUtils.dayStart(new Date());
				tmpTime.setMinutes(endIdx * 5);
				hourTileEndTimeSolar = tmpTime;
				// use the index of first zero value after the last non-zero value
				hourTileSolarValues = data.slice(startIdx, endIdx + 1);
			} else {
				hourTileSolarValues = [];
			}
		}

		function registerSolarFeatures() {
			if (!globals.productOptions["standalone"]) {
				registry.registerWidget("tile", p.solarHourTileUrl, graphApp, null, {thumbLabel: qsTr("Hours"), thumbIcon: p.thumbnailIconHourSolarTile, thumbCategory: "solar", thumbWeight: 60, thumbIconVAlignment: "center"});
				registry.registerWidget("tile", p.usageThisMomentTileUrl, graphApp, null, {thumbLabel: qsTr("Now"), thumbIcon: p.thumbnailIconUsageMoment, thumbCategory: "solar", thumbWeight: 20, thumbIconVAlignment: "center"});
				registry.registerWidget("tile", p.takeAndReturnTileUrl, graphApp, null, {thumbLabel: qsTr("Take and return"), thumbIcon: p.thumbnailIconTakeAndReturn, thumbCategory: "solar", thumbWeight: 30, baseTileSolarWeight: 50, thumbIconVAlignment: "center"});

				registry.registerWidget("tile", p.solarDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysKWh, thumbCategory: "solar", thumbWeight: 80});
				registry.registerWidget("tile", p.euroSolarDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysCurrency, thumbCaption: i18n.currency(), thumbCategory: "solar", thumbWeight: 70})
				registry.registerWidget("tile", p.solarThisMomentTileUrl, graphApp, null, {thumbLabel: qsTr("Now"), thumbIcon: p.thumbnailIconSolarMoment, thumbCategory: "solar", thumbWeight: 10, baseTileSolarWeight: 20, addAtSolarInstalled: true, thumbIconVAlignment: "center"});
			}
			registry.registerWidget("tile", p.solarTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconKWh, thumbCategory: "solar", thumbWeight: 40});
			registry.registerWidget("tile", p.solarEuroTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconCurrency, thumbCaption: i18n.currency(), thumbCategory: "solar", thumbWeight: 30});
		}

		function registerHeatingBeatTiles(register) {
			if (globals.heatingMode === "none")
				register = false;

			if (register === false && heatingBeatTiles.length) {
				heatingBeatTiles.forEach(function(tileUid) {
					registry.deregisterWidget(tileUid);
				});
				heatingBeatTiles = [];
			} else if(register === true && heatingBeatTiles.length === 0) {
				var tmpRegisteredTiles = [];
				tmpRegisteredTiles.push(registry.registerWidget("tile", p.boilerTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconBoilerTime, thumbCategory: "heating", thumbWeight: 10, baseTileWeight: 40, baseTileSolarWeight: 40, thumbIconVAlignment: "center"}));
				p.heatingBeatTiles = tmpRegisteredTiles;
			}
		}

		function registerWaterTiles(register) {
			if (register === false && waterTiles.length) {
				waterTiles.forEach(function(tileUid) {
					registry.deregisterWidget(tileUid);
				});
				waterTiles = [];
				notifications.removeByTypeSubType("feature", "newTile", "category=water");
			} else if(register === true && waterTiles.length === 0) {
				var tmpRegisteredTiles = [];
				tmpRegisteredTiles.push(registry.registerWidget("tile", p.waterThisMomentTileUrl, graphApp, null, {thumbLabel: qsTr("Now"), thumbIcon: p.thumbnailIconWaterNow, thumbCategory: "water", thumbWeight: 5, baseTileWeight: 50, thumbIconVAlignment: "center"}));
				if (!globals.productOptions["standalone"]) {
					tmpRegisteredTiles.push(registry.registerWidget("tile", p.waterDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysM3, thumbCategory: "water", thumbWeight: 50}));
					tmpRegisteredTiles.push(registry.registerWidget("tile", p.euroWaterDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysCurrency, thumbCaption: i18n.currency(), thumbCategory: "water", thumbWeight: 40}));
					tmpRegisteredTiles.push(registry.registerWidget("tile", p.waterHourTileUrl, graphApp, null, {thumbLabel: qsTr("Hours"), thumbIcon: p.thumbnailIconHourTile, thumbCategory: "water", thumbWeight: 30, thumbIconVAlignment: "center"}));
				}
				tmpRegisteredTiles.push(registry.registerWidget("tile", p.waterTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconM3, thumbCategory: "water", thumbWeight: 20, baseTileWeight: 50}));
				tmpRegisteredTiles.push(registry.registerWidget("tile", p.euroWaterTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconCurrency, thumbCaption: i18n.currency(), thumbCategory: "water", thumbWeight: 10}));
				p.waterTiles = tmpRegisteredTiles;
			}
		}
	}

	function init() {
		if (hasGas) {
			if (!globals.productOptions["standalone"]) {
				registry.registerWidget("tile", p.gasDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysM3, thumbCategory: "gas", thumbWeight: 50});
				registry.registerWidget("tile", p.euroGasDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysCurrency, thumbCaption: i18n.currency(), thumbCategory: "gas", thumbWeight: 40});
				registry.registerWidget("tile", p.gasHourTileUrl, graphApp, null, {thumbLabel: qsTr("Hours"), thumbIcon: p.thumbnailIconHourTile, thumbCategory: "gas", thumbWeight: 30, thumbIconVAlignment: "center"});
			}
			registry.registerWidget("tile", p.gasTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconM3, thumbCategory: "gas", thumbWeight: 20, baseTileWeight: 40, baseTileSolarWeight: 40});
			registry.registerWidget("tile", p.euroGasTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconCurrency, thumbCaption: i18n.currency(), thumbCategory: "gas", thumbWeight: 10});
		}
		if (hasDistrictHeating) {
			if (!globals.productOptions["standalone"]) {
				registry.registerWidget("tile", p.heatDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysGJ, thumbCategory: "heat", thumbWeight: 50});
				registry.registerWidget("tile", p.euroHeatDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysCurrency, thumbCaption: i18n.currency(), thumbCategory: "heat", thumbWeight: 40});
				registry.registerWidget("tile", p.heatHourTileUrl, graphApp, null, {thumbLabel: qsTr("Hours"), thumbIcon: p.thumbnailIconHourTile, thumbCategory: "heat", thumbWeight: 30, thumbIconVAlignment: "center"});
			}
			registry.registerWidget("tile", p.heatTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconGJ, thumbCategory: "heat", thumbWeight: 20, baseTileWeight: 40});
			registry.registerWidget("tile", p.euroHeatTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconCurrency, thumbCaption: i18n.currency(), thumbCategory: "heat", thumbWeight: 10});
		}
		if (hasWater) {
			p.registerWaterTiles(true);
		}
		if (hasSolar) {
			p.registerSolarFeatures();
		}
		if (globals.thermostatFeatures["FF_HeatingBeat_UiElements"]) {
			p.registerHeatingBeatTiles(true);
		}

		registry.registerWidget("tile", p.powerTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconKWh, thumbCategory: "power", thumbWeight: 40});
		registry.registerWidget("tile", p.powerThisMomentTileUrl, graphApp, null, {thumbLabel: qsTr("Now"), thumbIcon: p.thumbnailIconMoment, thumbCategory: "power", thumbWeight: 20, baseTileWeight: 30, baseTileSolarWeight: 30, thumbIconVAlignment: "center"});
		registry.registerWidget("tile", p.euroPowerTodayTileUrl, graphApp, null, {thumbLabel: qsTr("Today"), thumbIcon: p.thumbnailIconCurrency, thumbCaption: i18n.currency(), thumbCategory: "power", thumbWeight: 30});
		if (!globals.productOptions["standalone"]) {
			registry.registerWidget("tile", p.powerDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysKWh, thumbCategory: "power", thumbWeight: 70});
			registry.registerWidget("tile", p.euroPowerDayTileUrl, graphApp, null, {thumbLabel: qsTr("Days"), thumbIcon: p.thumbnailIconDaysCurrency, thumbCaption: i18n.currency(), thumbCategory: "power", thumbWeight: 60});
			registry.registerWidget("tile", p.powerHourTileUrl, graphApp, null, {thumbLabel: qsTr("Hours"), thumbIcon: p.thumbnailIconHourTile, thumbCategory: "power", thumbWeight: 50, baseTileWeight: 60, thumbIconVAlignment: "center"});
			if (feature.appGraphTileLowestUsage())
				registry.registerWidget("tile", p.lowestUsageTileUrl, graphApp, null, {thumbLabel: qsTr("Lowest Today"), thumbIcon: p.thumbnailIconLowestToday, thumbCategory: "power", thumbWeight: 10, thumbIconVAlignment: "center"});

			registry.registerWidget("menuItem", p.graphsMenuUrl, graphApp, null, {weight: 40});
			registry.registerWidget("screen", graphScreenUrl, graphApp, "graphScreen");
			registry.registerWidget("popup", requestDataThrobberUrl, graphApp, "requestDataThrobber");
		}
	}

	function parseUsageDataset(msg, varName, initVar) {
		if (!msg || !graphApp[varName])
			return;

		var tmpData = graphApp[varName];

		var node = msg.child;
		while (node) {
			tmpData[node.name] = parseFloat(node.text);
			node = node.sibling;
		}
		graphApp[varName + "Read"] = true;
		graphApp[varName] = tmpData;
		usageDatasetChanged();
		if (initVar >= 0 && initVar < initVarCount)
			initVarDone(initVar);
	}

	function parseBillingInfo(msg) {
		if (msg) {

			var infoChild = msg.getChild("info", 0);
			while (infoChild) {
				var childChild = infoChild.child;
				var billingInfoUpdate = {};
				while (childChild) {
					if (childChild.name === "type" || childChild.name === "error")
						billingInfoUpdate[childChild.name] = childChild.text;
					else
						billingInfoUpdate[childChild.name] = parseFloat(childChild.text);
					childChild = childChild.sibling;
				}

				var billingInfo;
				switch(billingInfoUpdate.type) {
				case "elec":
					billingInfo = billingInfoElec;
					break;
				case "gas":
					billingInfo = billingInfoGas;
					break;
				case "heat":
					billingInfo = billingInfoHeat;
					break;
				case "elec_produ":
					billingInfo = billingInfoElecProdu;
					break;
				default:
					console.log("Unknown billingInfo type: ", billingInfoUpdate.type);
					infoChild = infoChild.next;
					continue;
				}

				for (var key in billingInfoUpdate) {
					billingInfo[key] = billingInfoUpdate[key]
				}
				if (!billingInfoUpdate.lowPrice) {
					// If there is no lowPrice set lowPrice as price. This way we don have to add checks everywhere
					billingInfo.lowPrice = billingInfo.price;
				}

				switch(billingInfoUpdate.type) {
				case "elec":
					billingInfoElec = billingInfo;
					billingInfoElecRead = billingInfoUpdate.error !== "notSet";
					break;
				case "gas":
					billingInfoGas = billingInfo;
					billingInfoGasRead = billingInfoUpdate.error !== "notSet";
					break;
				case "heat":
					billingInfoHeat = billingInfo;
					billingInfoHeatRead = billingInfoUpdate.error !== "notSet";
					break;
				case "elec_produ":
					billingInfoElecProdu = billingInfo;
					billingInfoElecProduRead = billingInfoUpdate.error !== "notSet";
					break;
				}

				infoChild = infoChild.next;
			}
		}
		if ((initVars & (1 << 7)) === 0) {
			requestRrdDataForDayTiles();
		}

		initVarDone(1);
	}

	function checkForTimeChange() {
		var newDate = new Date();
		var firstTime = day === -1;
		if (day !== newDate.getDay()) {
			day = newDate.getDay();
			if (!firstTime)
				requestRrdDataForDayTiles();
		}
		if (!firstTime) {
			var newRequestRequired = false;
			var minutesDiff = Math.floor((newDate - hourTileEndTime5min) / (1000*60));
			if (minutesDiff >= 5) {
				p.updatePeriodLast4Hours(true);
				newRequestRequired = true;
			}
			minutesDiff = Math.floor((newDate - hourTileEndTime1h) / (1000*60));
			if (minutesDiff >= 60) {
				p.updatePeriodLast4Hours(false);
			}
			if (newRequestRequired)
				requestRrdDataForHourTiles();
		}
	}

	function parseConnectedInfo(msg) {
		var info = connectedInfo;

		var infoNode = msg.child;
		while (infoNode) {
			info[infoNode.name] = parseInt(infoNode.text);
			infoNode = infoNode.sibling;
		}
		connectedInfo = info;
		initVarDone(0);
	}

	function requestRrdDataForDayTiles() {
		var args = [];

		var	startDate, endDate = new Date();
		endDate = graphUtils.dayStart(endDate);
		startDate = new Date(endDate);
		startDate.setDate(endDate.getDate() - 3);
		var from = graphUtils.dateToISOString(startDate);
		var to = graphUtils.dateToISOString(endDate);

		if (hasElectricity) {
			var argsUnitElec = new EnergyInsights.Definitions.RequestArgs("electricity", "consumption", "quantity", false, "days", from, to ,["dayTilePower", false]);
			var argsCostElec = new EnergyInsights.Definitions.RequestArgs("electricity", "consumption", "quantity", true, "days", from, to, ["dayTileEuroPower", false]);
			args.push(argsUnitElec, argsCostElec);
			if (feature.featElecFixedDayCostEnabled())
			{
				var argsCostElecFixed = new EnergyInsights.Definitions.RequestArgs("electricity", "fixed-costs", undefined, false, "days", from, to ,["dayTilePowerFixedCosts", false]);
				args.push(argsCostElecFixed);
			}
		}
		if (hasGas) {
			var argsUnitGas = new EnergyInsights.Definitions.RequestArgs("gas", "consumption", "quantity", false, "days", from, to ,["dayTileGas", false]);
			var argsCostGas = new EnergyInsights.Definitions.RequestArgs("gas", "consumption", "quantity", true, "days", from, to, ["dayTileEuroGas", false]);
			args.push(argsUnitGas, argsCostGas);
		}
		if (hasDistrictHeating) {
			var argsUnitDH = new EnergyInsights.Definitions.RequestArgs("district-heat", "consumption", "quantity", false, "days", from, to ,["dayTileHeat", false]);
			var argsCostDH = new EnergyInsights.Definitions.RequestArgs("district-heat", "consumption", "quantity", true, "days", from, to, ["dayTileEuroHeat", false]);
			args.push(argsUnitDH, argsCostDH);
		}
		if (hasSolar) {
			var argsUnitSolar = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "quantity", false, "days", from, to ,["dayTileSolar", false]);
			var argsCostSolar = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "quantity", true, "days", from, to, ["dayTileEuroSolar", false]);
			args.push(argsUnitSolar, argsCostSolar);
		}
		if (hasWater) {
			var argsUnitWater = new EnergyInsights.Definitions.RequestArgs("water", "consumption", "quantity", false, "days", from, to ,["dayTileWater", false]);
			var argsCostWater = new EnergyInsights.Definitions.RequestArgs("water", "consumption", "quantity", true, "days", from, to, ["dayTileEuroWater", false]);
			args.push(argsUnitWater, argsCostWater);
		}

		EnergyInsights.Functions.requestBatchData(args, util.partialFn(dataRequestForTilesCallback, 6)); // initvar for dayTiles
	}

	function requestRrdDataForHourTiles() {
		var args = [];

		var from1h = graphUtils.dateToISOString(new Date(hourTileStartTime1h));
		var to1h = graphUtils.dateToISOString(new Date(hourTileEndTime1h));
		var from5min = graphUtils.dateToISOString(new Date(hourTileStartTime5min));
		var to5min = graphUtils.dateToISOString(new Date(hourTileEndTime5min));

		if (hasElectricity) {
			var argsElec = new EnergyInsights.Definitions.RequestArgs("electricity", "consumption", "flow", false, undefined, from5min, to5min ,["hourTilePower", true]);
			args.push(argsElec);
		}
		if (hasGas) {
			var gasType, gasInterval, gasFrom, gasTo;
			if (connectedInfo.gas_smartMeter === 1) {
				gasType = "quantity";
				gasInterval = "hours";
				gasFrom = from1h;
				gasTo = to1h;
			} else {
				gasType = "flow";
				gasFrom = from5min;
				gasTo = to5min;
			}
			var argsGas = new EnergyInsights.Definitions.RequestArgs("gas", "consumption", gasType, false, gasInterval, gasFrom, gasTo ,["hourTileGas", true]);
			args.push(argsGas);
		}
		if (hasDistrictHeating) {
			var argsHeat = new EnergyInsights.Definitions.RequestArgs("district-heat", "consumption", "quantity", false, "hours", from1h, to1h ,["hourTileHeat", true]);
			args.push(argsHeat);
		}
		if (hasSolar) {
			var now = new Date();
			var solarFrom = graphUtils.dateToISOString(graphUtils.dayStart(now));
			var solarTo = graphUtils.dateToISOString(now);
			var argsSolar = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "flow", false, undefined, solarFrom, solarTo ,["hourTileSolarRaw", true]);
			args.push(argsSolar);
		}
		if (hasWater) {
			var argsWater = new EnergyInsights.Definitions.RequestArgs("water", "consumption", "flow", false, undefined, from5min, to5min ,["hourTileWater", true]);
			args.push(argsWater);
		}

		EnergyInsights.Functions.requestBatchData(args, util.partialFn(dataRequestForTilesCallback, 5)); // initvar for hourTiles
	}

	onHourTileSolarRawValuesChanged: p.processSolarHoursTileData(hourTileSolarRawValues)

	function dataRequestForTilesCallback(initVar, varPrefix, findMax, success, response, batchDone) {
		if (success) {
			if (varPrefix && response.data.length) {
				try {
					// if data in response is for costs, do not do any division, assign data as is
					if (response.currency)
						graphApp[varPrefix + "Values"] = response.data.map(function (x) { return x.value });
					else
						graphApp[varPrefix + "Values"] = response.data.map(function (x) { return x.value / 1000 });

					if (findMax) {
						graphApp[varPrefix + "MaxValue"] = graphApp[varPrefix + "Values"].reduce(function (max,cur) {
							return Math.max(max,cur)
						});
					}
				} catch(e) {
					console.log("dataRequestForTilesCallback: Exception on writing to destination variable!", e);
				}
			}
		}
		if (batchDone && initVar >= 0 && initVar < initVarCount)
			initVarDone(initVar);
	}

	function isHolidayOrWeekend(date) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.p1Uuid, "specific1", "IsHolidayOrWeekend");
		msg.addArgument("time", date.getTime()/1000);
		bxtClient.sendMsg(msg);
	}

	function parseIsHolidayOrWeekendResponse(message) {
		var isLow = message.getArgument("isLow") === "1";
		isHolidayOrWeekendResponse(isLow);
	}

	function usageTileRoundingDecimals(agreementType, intervalType, value) {
		var decimals = 0;
		if (intervalType === "hours") {
			if (agreementType === "heat" && value < 1.0) decimals = 3;
			else if (value < 10.0) decimals = 2;
			else if (value < 100.0) decimals = 1;
			else decimals = 0;
		}
		else if (intervalType === "days") {
			if (value < 10.0) decimals = 1;
			else decimals = 0;
		}
		return decimals;
	}

	function usageTileRounding(agreementType, intervalType, value) {
		var decimals = usageTileRoundingDecimals(agreementType, intervalType, value);
		return i18n.number(value, decimals);
	}

	onHasSolarChanged: {
		// enabled solar at runtime
		if (hasSolar && doneLoading) {
			p.registerSolarFeatures();
		}
	}

	onHasWaterChanged: {
		p.registerWaterTiles(hasWater);
	}

	Connections {
		target: globals
		onThermostatFeaturesChanged: {
			p.registerHeatingBeatTiles(globals.thermostatFeatures["FF_HeatingBeat_UiElements"] ? true : false);
		}
	}

	onInitVarsChanged: {
		// If connectedInfo and billingInfo are known but we haven't requested data yet
		if ((initVars & 3) == 0 && (initVars & (1 << 7))) {
			// request rrds
			p.updatePeriodLast4Hours(true);
			p.updatePeriodLast4Hours(false);
			requestRrdDataForHourTiles();
			requestRrdDataForDayTiles();

			initVarDone(7);
		}
	}

	// 0=connectedInfo, 1=billingInfo, 2=powerUsage, 3=gasUsage, 4=heatUsage,
	// 5=hourTiles, 6=dayTiles, 7=(connectedInfo && billingInfo), 8=monthData, 9=boilerUsage, 10=waterUsage
	initVarCount: 11

	BxtDiscoveryHandler {
		id: pwrusageDiscoHandler
		deviceType: "happ_pwrusage"
		onDiscoReceived: {
			p.pwrusageUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: billingInfoDataset
		dataset: "billingInfo"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseBillingInfo(update)
	}

	BxtDatasetHandler {
		id: heatUsageDataset
		dataset: "heatUsage"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseUsageDataset(update, "heatUsageData", 4)
	}

	BxtDatasetHandler {
		id: powerUsageDataset
		dataset: "powerUsage"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseUsageDataset(update, "powerUsageData", 2)
	}

	BxtDatasetHandler {
		id: gasUsageDataset
		dataset: "gasUsage"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseUsageDataset(update, "gasUsageData", 3)
	}

	BxtDatasetHandler {
		id: boilerUsageDataset
		dataset: "boilerUsage"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseUsageDataset(update, "boilerUsageData", 9)
	}

	BxtDatasetHandler {
		id: waterUsageDataset
		dataset: "waterUsage"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: parseUsageDataset(update, "waterUsageData", 10)
	}

	Timer {
		id: dayChangedTimer
		interval: 60000
		onTriggered: checkForTimeChange()
		triggeredOnStart: true
		running: true
		repeat: true
	}

	MonthDataDataset {
		id: monthDataDataset
		discoHandler: pwrusageDiscoHandler
		onMonthDataUpdated: {
			initVarDone(8);
		}
	}

	BxtDiscoveryHandler {
		id: p1DiscoHandler
		deviceType: "hdrv_p1"
		onDiscoReceived: {
			p.p1Uuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: connectedInfoDataset
		dataset: "connectedInfo"
		discoHandler: p1DiscoHandler
		onDatasetUpdate: parseConnectedInfo(update)
	}

	BxtResponseHandler {
		id: isHolidayOrWeekendResponseHandler
		response: "IsHolidayOrWeekendResponse"
		serviceId: "specific1"
		onResponseReceived: parseIsHolidayOrWeekendResponse(message)
	}
}
