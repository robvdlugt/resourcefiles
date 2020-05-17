import QtQuick 2.1

Rectangle {
	id: notEnoughDataProgressBar

	function setProgress(hours) {
		var oneHourStep = Math.round((notEnoughDataProgressBar.width - 2) / 48);
		fillBar.width = (notEnoughDataProgressBar.width - 2) - hours * oneHourStep;
	}

	border {
		width: Math.round(2 * horizontalScaling)
		color: colors.benchmarkProgBarLine
	}

	width: Math.round(672 * horizontalScaling)
	height: Math.round(18 * verticalScaling)
	radius: height / 2
	color: colors.none

	Rectangle {
		id: fillBar

		width: Math.round(670 * horizontalScaling)
		height: Math.round(18 * verticalScaling)
		anchors {
			left: parent.left
			top: parent.top
			bottom: parent.bottom
			margins: 1
		}

		color: colors.benchmarkProgressBar
		radius: notEnoughDataProgressBar.radius
	}
}
