import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Water in hours")
	values: app.hourTileWaterValues
	dataType: "water"
	isSmart: false
	maxValue: app.hourTileWaterMaxValue
	graphColor: dimmableColors.graphWater
}
