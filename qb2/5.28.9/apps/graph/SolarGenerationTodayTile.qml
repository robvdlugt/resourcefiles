import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile

	titleText: qsTr("Solar today")
	isPowerTile: true
	lowerRectColor: dimmableColors.graphSolar
	upperRectColor: dimmableColors.graphSolarSelected

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "energy", intervalType: "hours", consumption: false, production: true})

	function updateTileInfo() {
		if(!app.powerUsageDataRead)
			return;

		dayUsage = app.powerUsageData.solarProducedToday;

		if (displayInEuro) {
			var totalDayCost = app.powerUsageData["solarProducedTodaySavings"];
			valueText = isNaN(totalDayCost) ? "-" : i18n.currency(totalDayCost);
		} else {
			var totalDayUsage = dayUsage;
			valueText = (isNaN(totalDayUsage) ? "-" : app.usageTileRounding("electricity", "hours", totalDayUsage / 1000, 0) + " kWh");
		}

		avgDayValue = app.powerUsageData['avgDayProduValue'];
		updateTileGraphic();
	}

	function init() {
		updateTileInfo();
		app.powerUsageDataChanged.connect(updateTileInfo);
		app.billingInfoElecProduChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.powerUsageDataChanged.disconnect(updateTileInfo);
		app.billingInfoElecProduChanged.disconnect(updateTileInfo);
	}
}
