import QtQuick 2.1
import qb.components 1.0

Tile {
	id: co2NowTile

	property AirQualityApp app

	Text {
		id: titleText
		text: qsTr("Estimated CO<sub>2</sub>")
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
		textFormat: Text.RichText
	}

	function getImageUrl(percentage, dim) {
		var infix;
		if (percentage <= 1000) {
			infix =  "healthy";
		} else if (percentage < 2500) {
			infix =  "undesired";
		} else {
			infix =  "bad";
		}

		return "image://scaled/apps/airQuality/drawables/co2-%1%2.svg".arg(infix).arg(dim ? "_dim" : "");
	}

	Image {
		id: co2Icon
		anchors.centerIn: parent
		source: getImageUrl(app.eco2, canvas.dimState)
	}

	Text {
		id: valueText
		text: Math.round(app.eco2) + " ppm"
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
