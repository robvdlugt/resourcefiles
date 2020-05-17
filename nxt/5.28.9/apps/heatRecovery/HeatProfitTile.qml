import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Tile {
	id: root

	property real profit: app.hasDevice ? app.heatRecoveryUsageInfo["currentEstimatedSavings"] : NaN

	onClicked: stage.openFullscreen(app.heatRecoveryScreenUrl)

	Text {
		id: titleText
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
		text: qsTr("Heat Profit")
	}

	Image {
		id: icon
		source: "image://scaled/apps/heatRecovery/" + !isNaN(profit) ? (dimState ? "drawables/heatrec_dev_dim.svg" : "drawables/heatrec_device_leaf.svg") : "drawables/heatrec_nodata.svg"
		anchors {
			horizontalCenter: parent.horizontalCenter
			horizontalCenterOffset: !isNaN(profit) ? Math.round(10 * horizontalScaling) : 0
			verticalCenter: parent.verticalCenter
		}
	}

	Text {
		id: tileText
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignRight
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
		color: dimmableColors.tileTextColor
		text: !isNaN(profit) ? "± " + i18n.currency(profit) : qsTr("Data unavailable")
	}
}
