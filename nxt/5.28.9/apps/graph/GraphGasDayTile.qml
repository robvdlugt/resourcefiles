import QtQuick 2.1

DayTile {
	id: graphGasDayTile
	dayTileTitleText: qsTr("Gas in days")
	unitString: "m³"
	values: app.dayTileGasValues
	agreementType: "gas"
	rectangleColor: dimmableColors.graphGasDistrictHeat
}
