import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: root

	property alias totalYield: totalYieldValue.text
	property alias selfUsageYield: selfUsageYieldValue.text
	property alias returnedYield: returnedYieldValue.text

	Column {
		id: totalContainer
		anchors {
			left: parent.left
			leftMargin: Math.round(30 * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}

		Image {
			id: bigSunLeaf
			anchors.horizontalCenter: parent.horizontalCenter
			source: "image://scaled/apps/solar/drawables/big-sun-leaf.svg"
		}

		Text {
			id: totalYieldText
			anchors.horizontalCenter: parent.horizontalCenter
			font.family: qfont.regular.name
			font.pixelSize: qfont.titleText
			color: colors.solarAppText
			text: qsTr('Total yield')
		}

		Text {
			id: totalYieldValue
			anchors.horizontalCenter: parent.horizontalCenter
			font.family: qfont.regular.name
			font.pixelSize: qfont.secondaryImportantBodyText
			color: colors.solarAppValue
			text: '- kWh'
		}
	}

	DashedLine {
		id: horDashLine
		width: Math.round(50 * horizontalScaling)
		height: 1
		color: colors.solarRevenueDashLine
		anchors {
			left: totalContainer.right
			leftMargin: Math.round(30 * horizontalScaling)
			verticalCenter: totalContainer.verticalCenter
		}
	}

	DashedLine {
		id: verticalLine
		width: 1
		height: Math.round(93 * verticalScaling)
		color: colors.solarRevenueDashLine
		anchors {
			left: horDashLine.right
			verticalCenter: horDashLine.verticalCenter
		}
	}

	DashedLine {
		id: topLine
		width: Math.round(91 * horizontalScaling)
		height: 1
		color: colors.solarRevenueDashLine
		anchors {
			left: verticalLine.right
			top: verticalLine.top
		}
	}

	DashedLine {
		id: bottomLine
		width: Math.round(91 * horizontalScaling)
		height: 1
		color: colors.solarRevenueDashLine
		anchors {
			left: verticalLine.right
			bottom: verticalLine.bottom
		}
	}

	Image {
		id: imgHouse
		source: "image://scaled/apps/solar/drawables/usage-house.svg"
		anchors {
			verticalCenter: topLine.verticalCenter
			left: topLine.right
			leftMargin: Math.round(30 * horizontalScaling)
		}
	}

	Text {
		id: selfUsageYield
		text: qsTr('Self usage')
		anchors {
			right: parent.right
			rightMargin: Math.round(50 * horizontalScaling)
			bottom: imgHouse.verticalCenter
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.titleText
		color: colors.solarAppText
	}

	Text {
		id: selfUsageYieldValue
		text: '- kWh'
		anchors {
			right: selfUsageYield.right
			top: imgHouse.verticalCenter
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.secondaryImportantBodyText
		color: colors.solarAppValue
	}

	Image {
		id: imgMast
		source: "image://scaled/apps/solar/drawables/yellow-mast.svg"
		anchors {
			verticalCenter: bottomLine.verticalCenter
			left: bottomLine.right
			leftMargin: Math.round(30 * horizontalScaling)
		}
	}

	Text {
		id: returnedYield
		text: qsTr('Yield returned')
		anchors {
			right: selfUsageYield.right
			bottom: imgMast.verticalCenter
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.titleText
		color: colors.solarAppText
	}

	Text {
		id: returnedYieldValue
		text: '- kWh'
		anchors {
			right: selfUsageYield.right
			top: imgMast.verticalCenter
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.secondaryImportantBodyText
		color: colors.solarAppValue
	}
}
