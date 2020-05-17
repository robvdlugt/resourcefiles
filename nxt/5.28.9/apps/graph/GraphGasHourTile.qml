import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Gas in hours")
	values: app.hourTileGasValues
	dataType: "gas"
	isSmart: app.connectedInfo.gas_smartMeter === 1
	maxValue: app.hourTileGasMaxValue
	graphColor: dimmableColors.graphGasDistrictHeat
}
