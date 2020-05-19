import QtQuick 2.1

RingTodayTile {
	id: boilerTodayTile

	titleText: qsTr("Heating today")
	valueText: "-"
	usageColor: canvas.dimState ? dimmableColors.dayTileAverageBar : dimmableColors._beauty

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "heatingTime", unitType: "energy", intervalType: "hours"})

	function updateTileInfo() {
		if (!app.boilerUsageDataRead)
			return;

		dayUsage = app.boilerUsageData['dayUsage'];
		valueText = (typeof dayUsage === "undefined" || isNaN(dayUsage)) ? "-" : i18n.duration(dayUsage * 60, true);
		avgDayValue = app.boilerUsageData['avgDayValue'];

		updateTileGraphic();
	}

	function updateTileGraphic() {
		if (dayDataOkay()) {
			var usage = dayUsage;
			if (isPowerTile)
				usage += dayLowUsage;

			if (avgDataOkay()) {
				var percentage = usage / (avgDayValue * 2) * 100;
				usagePercentage = !isNaN(percentage) ? percentage : 0;
			} else {
				// when there is no avg value, make ratio based on entire day: (60 * 24) mins (minutes in 24h)
				usagePercentage = usage / (60 * 24) * 100;
			}
		} else {
			usagePercentage = 0;
		}
	}

	function init() {
		updateTileInfo();
		app.boilerUsageDataChanged.connect(updateTileInfo);
	}

	Component.onDestruction: {
		app.boilerUsageDataChanged.disconnect(updateTileInfo);
	}

	Image {
		id: icon
		anchors.centerIn: parent
		source: "image://scaled/apps/graph/drawables/boilerTime_tileIcon" + (dimState ? "_dim" : "") + ".svg"
	}
}
