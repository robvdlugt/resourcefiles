import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;

App {
	id: clockApp

	// These are the URL's for the QML resources from which our widgets will be instantiated.
	// By making them a URL type property they will automatically be converted to full paths,
	// preventing problems when passing them around to code that comes from a different path.
	property url tileUrl : "ClockTile.qml"
	property url thumbnailIcon: "drawables/clock.svg"

	property string timeStr
	property string dateStr

	function init() {
		registry.registerWidget("tile", tileUrl, clockApp, null, {thumbLabel: qsTr("Clock"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
	}

	function updateClockTiles() {
		var now = new Date().getTime();
		timeStr = i18n.dateTime(now, i18n.time_yes);
		dateStr = i18n.dateTime(now, i18n.mon_full);
	}

	Timer {
		id: datetimeTimer
		interval: 10000
		triggeredOnStart: true
		running: true
		repeat: true
		onTriggered: updateClockTiles()
	}
}
