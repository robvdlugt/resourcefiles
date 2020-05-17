import QtQuick 2.1

Column {
	id: powerBar
	width: childrenRect.width
	spacing: Math.round(3 * verticalScaling)
	property int filledBars: 0
	property int barWidth: 0
	rotation: 180

	Repeater {
		id: repeater
		model: 10

		Rectangle {
			width: barWidth > 0 ? barWidth : Math.round(32 * horizontalScaling)
			height: Math.round(5 * verticalScaling)
			color: filledBars > index ? dimmableColors["powerTileBar" + index] : dimmableColors.powerTileBarEmpty
			radius: height / 2
		}
	}
}
