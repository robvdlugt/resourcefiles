import QtQuick 2.1
import qb.components 1.0

Tile {
	id: vocNowTile
	property AirQualityApp app

	QtObject {
		id: p
		property int healthy: 150
		property int undesired: 300
	}

	Text {
		id: titleText
		text: qsTr("Air Quality")
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

	function percentageToVocString(percentage) {
		var vocString;
		if (percentage <= p.healthy) {
			vocString =  qsTr("Healthy");
		} else if (percentage < p.undesired) {
			vocString =  qsTr("Undesired");
		} else {
			vocString =  qsTr("Bad");
		}
		return vocString
	}

	function getImageUrl(percentage, dim) {
		var infix;
		if (percentage <= p.healthy) {
			infix =  "healthy";
		} else if (percentage < p.undesired) {
			infix =  "undesired";
		} else {
			infix =  "bad";
		}
		return "image://scaled/apps/airQuality/drawables/voc-%1%2.svg".arg(infix).arg(dim ? "_dim" : "")
	}

	Image {
		id: vocIcon
		anchors.centerIn: parent
		source: getImageUrl(app.tvoc, canvas.dimState)
	}

	Text {
		id: valueText
		text: percentageToVocString(app.tvoc)
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
