import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import qb.energyinsights 1.0 as EnergyInsights

import BxtClient 1.0
import GraphUtils 1.0

App {
	id: solarApp

	property SolarScreen solarScreen
	property url solarScreenUrl: "SolarScreen.qml"

	property variant billingInfos: ({})

	property Popup requestDataThrobber
	property url requestDataThrobberUrl: "qrc:/qb/components/FullScreenThrobber.qml"
	property url estimatedGenerationScreenUrl: "qrc:/apps/eMetersSettings/EstimatedGenerationScreen.qml"

	property double totalProduced: 0.0
	property double totalProducedMoney: 0.0
	property double monthProduced: 0.0
	property double monthProducedMoney: 0.0

	// only used by SolarMonthPerformanceTile
	property int expectedProduced: 0
	property int actualMonth: 0

	property double produPrice: billingInfos['elec_produ'] ? billingInfos['elec_produ'].price : 0

	function init() {
		if (globals.productOptions["solar"]) {
			registry.registerWidget("screen", solarScreenUrl, solarApp, "solarScreen", {lazyLoadScreen: true});
			registry.registerWidget("menuItem", null, solarApp, null, {objectName: "solarMenuItem", label: qsTr("Solar"), image: p.menuIconUrl, screenUrl: solarScreenUrl, weight: 99, args: {isYield: true, isUsage: true, intervalType: 0}});
			registry.registerWidget("tile", p.revenueTileUrl, solarApp, null, {thumbLabel: qsTr("Total revenue"), thumbIcon: p.revenueKwhThumbnailUrl, thumbCategory: "solar", thumbWeight: 120, baseTileWeight: 10});
			registry.registerWidget("tile", p.revenueTileEuroUrl, solarApp, null, {thumbLabel: qsTr("Total revenue"), thumbIcon: p.revenueCurrencyThumbnailUrl, thumbCaption: i18n.currency(), thumbCategory: "solar", thumbWeight: 110, baseTileWeight: 20});
			registry.registerWidget("popup", requestDataThrobberUrl, solarApp, "requestDataThrobber");
			registry.registerWidget("tile", p.solarMonthProductionTileUrl, solarApp, null, {thumbLabel: qsTr("Month"), thumbIcon: p.thumbnailSolarMonthProduction, thumbCategory: "solar", thumbWeight: 100});
			registry.registerWidget("tile", p.solarMonthCostTileUrl, solarApp, null, {thumbLabel: qsTr("Month"), thumbIcon: p.thumbnailSolarMonthCost, thumbCaption: i18n.currency(), thumbCategory: "solar", thumbWeight: 90});
		}
		produPriceChanged.connect(requestSolarProductionForTiles);
	}

	QtObject {
		id: p

		property url menuIconUrl: "drawables/SolarAppMenu.svg"
		property url revenueTileUrl: "RevenueTile.qml"
		property url revenueTileEuroUrl: "RevenueTileEuro.qml"
		property url revenueCurrencyThumbnailUrl: "drawables/TotalCurrency.svg"
		property url revenueKwhThumbnailUrl: "drawables/TotalKwh.svg"
		property url solarMonthProductionTileUrl: "SolarMonthPerformanceTile.qml"
		property url solarMonthCostTileUrl: "SolarMonthCostTile.qml"
		property url thumbnailSolarMonthProduction: "drawables/ChooseTileSolarProductionMonth.svg"
		property url thumbnailSolarMonthCost: "drawables/ChooseTileSolarCostMonth.svg"

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
				initVarDone(0);

				if (!doneLoading)
					requestSolarProductionForTiles();
			}
		}

		function updateActualMonthExpectedProduction() {
			var now = new Date();
			actualMonth = now.getMonth();
			var daysValidForEstimation = new Date(now.getFullYear(), now.getMonth() + 1, 0).getDate();
			var daysAlreadyGone = now.getDate() - 1; // -1 to exclude current day
			// reduce daysAlreadyGone in case solar was installed in current month
			if (billingInfos && billingInfos['elec_produ']) {
				var installDate = new Date(billingInfos['elec_produ'].installedDate * 1000);
				if (installDate.getFullYear() === now.getFullYear() && installDate.getMonth() == actualMonth) {
					daysAlreadyGone -= installDate.getDate() - 1;
				}
			}
			expectedProduced = Math.round((monthExpectedProduction(now.getFullYear(), actualMonth) / 1000) * daysAlreadyGone / daysValidForEstimation);
		}
	}

	function monthExpectedProduction(year, month) {
		var monthData = monthDataDataset.getMonth("solar", new Date(year, month));
		return monthData ? monthData.targetUsage : 0;
	}

	function requestSolarProductionForTiles() {
		var argList = [];
		var args1 = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "quantity");
		args1.from = graphUtils.dateToISOString(new Date(billingInfos['elec_produ'].installedDate * 1000));
		args1.to = graphUtils.dateToISOString(new Date());
		args1.isCost = false;
		args1.callbackArgs = ["totalProduced"];
		argList.push(args1);

		var args2 = Object.create(args1);
		args2.isCost = true;
		args2.callbackArgs = ["totalProducedMoney"];
		argList.push(args2);

		var args3 = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "quantity");
		var now = new Date();
		args3.from = graphUtils.dateToISOString(new Date(now.getFullYear(), now.getMonth(), 1));
		args3.to= graphUtils.dateToISOString(new Date(now.getFullYear(), now.getMonth() + 1, 0));
		args3.interval = "months"
		args3.isCost = false;
		args3.callbackArgs = ["monthProduced"];
		argList.push(args3);

		var args4 = Object.create(args3);
		args4.isCost = true;
		args4.callbackArgs = ["monthProducedMoney"];
		argList.push(args4);

		EnergyInsights.Functions.requestBatchData(argList, util.partialFn(dataRequestForTilesCallback, 2))
	}

	function dataRequestForTilesCallback(initVar, varName, success, response, batchDone) {
		if (success) {
			if (varName && response.data.length) {
				try {
					solarApp[varName] = response.data[0].value;
					if (!response.currency)
						solarApp[varName] /= 1000;
				} catch(e) {
					console.log("dataRequestForTilesCallback: Exception on writing to destination variable!", e);
				}
			}
		}
		if (batchDone && initVar >= 0 && initVar < initVarCount) {
			totalProducedTileTimer.restart();
			initVarDone(initVar);
		}
	}

	// 0=billingInfo 1=monthData 2=totalProduced (for tiles)
	initVarCount: 3

	BxtDiscoveryHandler {
		id: pwrusageDiscoHandler
		deviceType: "happ_pwrusage"
	}

	MonthDataDataset {
		id: monthDataDataset
		discoHandler: pwrusageDiscoHandler
		onMonthDataUpdated: {
			p.updateActualMonthExpectedProduction();
			initVarDone(1);
		}
	}

	BxtDatasetHandler {
		id: billingInfoDataset
		dataset: "billingInfo"
		discoHandler: pwrusageDiscoHandler
		onDatasetUpdate: p.parseBillingInfo(update)
	}

	Timer {
		id: totalProducedTileTimer
		interval: 1000*60*5
		onTriggered: requestSolarProductionForTiles();
	}
}
