import QtQuick 2.1

BarTodayTile {
	id: powerTodayTile
	titleText: qsTr("Power today")
	isPowerTile: true
	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "energy", intervalType: "hours"})

	function updateTileInfo() {
		if (!app.powerUsageDataRead)
			return;

		dayUsage = app.powerUsageData[displayInEuro ? 'dayCost' : 'dayUsage'];
		dayLowUsage = app.powerUsageData[displayInEuro ? 'dayLowCost' : 'dayLowUsage'];
		var totalDayUsage = dayUsage + dayLowUsage;

		if (displayInEuro) {
			// add fixedDayCost if available
			if (feature.featElecFixedDayCostEnabled() && typeof(app.billingInfoElec.fixedDayCost) !== "undefined") {
				fixedDayCost = app.billingInfoElec.fixedDayCost;
				totalDayUsage += fixedDayCost;
			}
			valueText = isNaN(totalDayUsage) ? "-" : i18n.currency(totalDayUsage);
		} else {
			valueText = (isNaN(totalDayUsage) ? "-" : app.usageTileRounding("electricity", "hours", totalDayUsage / 1000, 0) + " kWh");
		}
		avgDayValue = app.powerUsageData[displayInEuro ? 'avgDayValueCost' : 'avgDayValue'];
		updateTileGraphic();
	}

	function init() {
		updateTileInfo();
		app.powerUsageDataChanged.connect(updateTileInfo);
		app.billingInfoElecChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.powerUsageDataChanged.disconnect(updateTileInfo);
		app.billingInfoElecChanged.disconnect(updateTileInfo);
	}
}
