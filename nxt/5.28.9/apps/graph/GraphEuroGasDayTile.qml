import QtQuick 2.1


GraphGasDayTile {
	id: graphEuroGasDayTile
	displayInEuro: true
	unitString: i18n.currency()
	values: app.dayTileEuroGasValues
}
