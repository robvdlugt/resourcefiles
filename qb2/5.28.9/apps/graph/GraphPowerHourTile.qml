import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Power in hours")
	values: app.hourTilePowerValues
	dataType: "electricity"
	maxValue: app.hourTilePowerMaxValue
	graphColor: dimmableColors.graphElecSingleOrLowTariff
}
