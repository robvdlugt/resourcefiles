import QtQuick 2.1

BarTodayTile {
	id: gasTodayTile
	titleText: qsTr("Gas today")
	lowerRectColor: dimmableColors.graphGasDistrictHeat
	upperRectColor: dimmableColors.graphGasDistrictHeatSelected

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "gas", unitType: "energy", intervalType: "hours"})

	function updateTileInfo() {
		if (!app.gasUsageDataRead)
			return;

		dayUsage = app.gasUsageData['dayUsage'];
		if (displayInEuro) {
			var dayCst = app.gasUsageData["dayCost"];
			valueText = isNaN(dayCst) ? "-" : i18n.currency(dayCst);
		} else {
			valueText = isNaN(dayUsage) ? "-" : app.usageTileRounding("gas", "hours", dayUsage / 1000) + " m³";
		}

		avgDayValue = app.gasUsageData['avgDayValue'];

		updateTileGraphic();
	}

	function init() {
		updateTileInfo();
		app.gasUsageDataChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.gasUsageDataChanged.disconnect(updateTileInfo);
	}
}
