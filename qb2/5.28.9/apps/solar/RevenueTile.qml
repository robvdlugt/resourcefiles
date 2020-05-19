import QtQuick 2.1
import qb.components 1.0

Tile {
	property bool displayMoneyWise: false
	property double value: app.totalProduced

	onClicked: {
		stage.openFullscreen(app.solarScreenUrl,{isYield: true, isUsage: !displayMoneyWise, intervalType: 0});
	}

	Text {
		id: tileTitle
		text: qsTr('Production total')
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Image {
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(41 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		source: "image://scaled/apps/solar/drawables/solar-leaf" + (dimState ? "-dim" : "") + ".svg"
	}

	Text {
		id: tileText
		color: dimmableColors.tileTextColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignRight
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
		text: displayMoneyWise ? i18n.currency(value, i18n.curr_round) : i18n.number(value, 0) + ' kWh'
	}
}
