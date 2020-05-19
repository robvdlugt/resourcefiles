import QtQuick 2.1

DayTile {
	id: graphHeatDayTile
	dayTileTitleText: qsTr("Heat in days")
	unitString: "GJ"
	values: app.dayTileHeatValues
	agreementType: "heat"
	rectangleColor: dimmableColors.graphGasDistrictHeat
}
