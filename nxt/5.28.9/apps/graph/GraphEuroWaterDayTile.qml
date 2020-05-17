import QtQuick 2.1

GraphWaterDayTile {
	id: graphEuroWaterDayTile
	displayInEuro: true
	unitString: i18n.currency()
	values: app.dayTileEuroWaterValues
}
