import QtQuick 2.1

GraphHeatDayTile {
	id: graphEuroHeatDayTile
	displayInEuro: true
	unitString: i18n.currency()
	values: app.dayTileEuroHeatValues
}
