import QtQuick 2.1

GraphSolarDayTile {
	id: graphEuroSolarDayTile
	displayInEuro: true
	unitString: i18n.currency()
	values: app.dayTileEuroSolarValues
}
