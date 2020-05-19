import QtQuick 2.1

BarTodayTile {
	id: heatTodayTile
	titleText: qsTr("Heat today")
	lowerRectColor: dimmableColors.graphGasDistrictHeat
	upperRectColor: dimmableColors.graphGasDistrictHeatSelected

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "heat", unitType: "energy", intervalType: "hours"})

	function updateTileInfo() {
		if (!app.heatUsageDataRead)
			return;

		dayUsage = app.heatUsageData['dayUsage'];
		if (displayInEuro) {
			var dayCst = app.heatUsageData["dayCost"];
			valueText = isNaN(dayCst) ? "-" : i18n.currency(dayCst);
		} else {
			valueText = isNaN(dayUsage) ? "-" : app.usageTileRounding("heat", "hours", dayUsage / 1000) + " GJ";
		}

		avgDayValue = app.heatUsageData['avgDayValue'];

		updateTileGraphic();
	}

	function init() {
		updateTileInfo();
		app.heatUsageDataChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.heatUsageDataChanged.disconnect(updateTileInfo);
	}
}
