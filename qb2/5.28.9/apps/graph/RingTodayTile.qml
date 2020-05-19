import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

BaseTodayTile {
	id: ringTodayTile

	property alias usagePercentage: progressRing.progress
	property alias usageColor: progressRing.fillColor

	function updateTileGraphic() {
		if (dayDataOkay() && avgDataOkay()) {
			var usage = dayUsage;
			if (isPowerTile)
				usage += dayLowUsage;

			progressRing.progress = usage / (avgDayValue * 2) * 100;
		} else {
			progressRing.progress = 0;
		}
	}

	StyledProgressRing {
		id: progressRing
		anchors.centerIn: parent

		backgroundColor: dimmableColors.dayTileBackgroundBar
		fillColor: dimmableColors.dayTileAverageBar
		radius: Math.round(40 * verticalScaling)
		thickness: Math.round(8 * verticalScaling)
		gap: Math.round(10 * verticalScaling)

		mouseEnabled: false
	}
}
