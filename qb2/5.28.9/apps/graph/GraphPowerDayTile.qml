import QtQuick 2.1

DayTile {
	id: graphPowerDayTile
	dayTileTitleText: qsTr("Power in days")
	unitString: "kWh"
	values: app.dayTilePowerValues
	agreementType: "electricity"
	rectangleColor: dimmableColors.graphElecSingleOrLowTariff
}
