import QtQuick 2.1

BarTodayTile {
	id: waterTodayTile
	titleText: qsTr("Water today")
	lowerRectColor: dimmableColors.graphWater
	upperRectColor: dimmableColors.graphWaterSelected

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "water", unitType: "energy", intervalType: "hours"})

	function updateTileInfo() {
		if (!app.waterUsageDataRead)
			return;

		dayUsage = app.waterUsageData["dayUsage"];
		if (displayInEuro) {
			var dayCst = app.waterUsageData["dayCost"];
			valueText = isNaN(dayCst) ? "-" : i18n.currency(dayCst);
		} else {
			valueText = isNaN(dayUsage) ? "-" : app.usageTileRounding("water", "hours", dayUsage / 1000) + " m³";
		}

		avgDayValue = app.waterUsageData["avgDayValue"];

		updateTileGraphic();
	}

	function init() {
		updateTileInfo();
		app.waterUsageDataChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.waterUsageDataChanged.disconnect(updateTileInfo);
	}
}
