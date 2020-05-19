import QtQuick 2.11
import qb.components 1.0
import Weather 1.0
import DateTracker 1.0

Tile {
	id: weatherTile

	function init() {
		app.tilesInstantiated++;
	}

	onClicked: {
		stage.openFullscreen(app.weatherScreenUrl);
	}

	Component.onDestruction: {
		app.tilesInstantiated--;
	}

	Text {
		id: weatherTileTitleText
		text: Weather.cityName
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.waTileTitleTextColor
	}

	WeatherIcon {
		id: weatherTileIcon
		whiteOverlay: screenStateController.dimmedColors
		nightAndDay: true
		sourceSize.height: Math.round(64 * verticalScaling)
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
	}

	Text {
		id: weatherTileTemperatureText
		text: app.roundToHalf(Weather.temperature) + "°"
		anchors {
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.waTileTextColor
	}
}
