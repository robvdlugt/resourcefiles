import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Heat in hours")
	values: app.hourTileHeatValues
	dataType: "heat"
	isSmart: true
	maxValue: app.hourTileHeatMaxValue
	graphColor: dimmableColors.graphGasDistrictHeat
}
