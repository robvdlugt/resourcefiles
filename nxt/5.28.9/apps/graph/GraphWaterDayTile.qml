import QtQuick 2.1

DayTile {
	id: graphWaterDayTile
	dayTileTitleText: qsTr("Water in days")
	unitString: "m³"
	values: app.dayTileWaterValues
	agreementType: "water"
	rectangleColor: dimmableColors.graphWater
}
