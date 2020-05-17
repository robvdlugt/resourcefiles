import QtQuick 2.1

DayTile {
	id: graphSolarDayTile
	dayTileTitleText: qsTr("Production in days")
	unitString: "kWh"
	values: app.dayTileSolarValues
	agreementType: "electricity"
	rectangleColor: dimmableColors.graphSolar
	production: true
	consumption: false
}
