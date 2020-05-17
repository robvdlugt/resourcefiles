import QtQuick 2.1
import BxtClient 1.0
import qb.components 1.0


Tile {
    property AirQualityApp app;

    function init() {
		updateTile();
	}

    onClicked: {
        stage.openFullscreen(app.temperatureCorrectionScreenUrl);
	}

	Connections {
		target: app
		onTemperatureInfoChanged: updateTile()
	}

    function updateTile() {
		temperatureValue.text = i18n.number(app.temperatureInfo.currentDisplayTemperature / 100, 1) + "°";
	}

	Text {
		id: header
		text: qsTr("Measured temperature")

		wrapMode: Text.WordWrap
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

	Text {
		id: temperatureValue
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: dimState ? qfont.clockFaceText : qfont.timeAndTemperatureText
		}
		color: dimmableColors.tileTextColor
	}

	Text {
		id: name
		text: qsTr("$(display)")

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
	}
}
