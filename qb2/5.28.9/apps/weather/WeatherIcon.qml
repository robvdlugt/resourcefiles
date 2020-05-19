import QtQuick 2.0
import Weather 1.0
import DateTracker 1.0

Image {
	id: weatherIcon

	property string iconName: Weather.icon
	property bool whiteOverlay: false
	property bool nightAndDay: false
	property bool card: false

	source: updateIcon()
	cache: false

	Connections {
		target: Weather
		onForecastChanged: updateIcon()
	}

	function updateIcon() {
		var filePrefix = "image://" + (whiteOverlay ? "colorized/white" : "scaled") + "/apps/weather/drawables/" + (card ? "Card" : "Weather") + "-";
		var now = DateTracker.timestamp;
		var icon = nightAndDay && (now < Weather.sunrise || now > Weather.sunset) ? "Night" : "Day";
		return filePrefix + (iconName.length > 0 ? iconName : "ClearSky") + icon;
	}
}
