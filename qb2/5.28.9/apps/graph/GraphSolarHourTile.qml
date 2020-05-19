import QtQuick 2.1

HourTile {
	id: root
	hourTileTitle: qsTr("Solar panels in hours")
	values: app.hourTileSolarValues
	dataType: "electricity"
	maxValue: app.hourTileSolarMaxValue
	isSolar: true
	startTime: app.hourTileStartTimeSolar
	endTime: app.hourTileEndTimeSolar
	graphColor: dimmableColors.graphSolar
	timeTextsVisible: values.length > 0
}
