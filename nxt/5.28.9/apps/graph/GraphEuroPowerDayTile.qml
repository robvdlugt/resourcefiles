import QtQuick 2.1

GraphPowerDayTile {
	id: graphEuroPowerDayTile
	displayInEuro: true
	unitString: i18n.currency()
	values: app.dayTileEuroPowerValues.map(function (val, i) { return val + app.dayTilePowerFixedCostsValues[i] })
}
