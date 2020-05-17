import QtQuick 2.1
import qb.components 1.0

Tile {
	id: humidityNowTile

	property AirQualityApp app

	onClicked: {
		app.showHumidityPopup();
		countly.sendPageViewEvent(util.absoluteToRelativePath(widgetInfo.url) + ":humidityExplanationPopup");
	}

	Text {
		id: titleText
		text: qsTr("Humidity")
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Image {
		id: humidityIcon
		anchors.centerIn: parent
		source: getImageUrl(app.humidity, canvas.dimState)

		function getImageUrl(percentage, dim) {
			var infix;
			if (percentage < 20) {
				infix = "toolow";
			} else if (percentage < 40) {
				infix =  "low";
			} else if (percentage <= 60) {
				infix =  "healthy";
			} else if (percentage < 80) {
				infix =  "high";
			} else {
				infix =  "toohigh";
			}
			return "image://scaled/apps/airQuality/drawables/humidity-%1%2.svg".arg(infix).arg(dim ? "_dim" : "")
		}
	}

	Text {
		id: valueText
		text: Math.round(app.humidity) + "%"
		anchors {
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
	}
}
