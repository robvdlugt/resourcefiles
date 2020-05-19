import QtQuick 2.1
import qb.components 1.0

Tile {
	id: root
	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "energy", intervalType: "hours"})

	Text {
		id: title
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
		text: qsTr("Lowest power today")
	}

	Image {
		id: image
		anchors.centerIn: parent
		source: "image://scaled/apps/graph/drawables/" + (dimState ? "LowestUsageIconDim.svg" : "LowestUsageIcon.svg")
	}

	Text {
		id: usageText
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
		text: qsTr("%1 Watt").arg(isNaN(app.powerUsageData["lowestDayValue"]) ? "-" : i18n.number(app.powerUsageData["lowestDayValue"], 0))
	}
}
