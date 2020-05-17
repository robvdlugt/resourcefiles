import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Rectangle {
	id: root
	anchors.fill: parent
	color: colors.dialogMaskedArea
	opacity: designElements.opacity

	property string progressText: " "
	property string subProgressText: " "
	property string footerText: " "
	property string headerText: qsTr("Updating")

	function startAnimation() {
		timer_progressAnimation.restart()
	}

	function stopAnimation() {
		timer_progressAnimation.stop()
	}

	MouseArea {
		id: nonClickableArea

		anchors.fill: parent
	}

	Text {
		id: bigText_1

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.top
			baselineOffset: Math.round(80 * verticalScaling)
		}

		text: root.headerText + " "
		color: colors.softUpdatePopTextBig
		font.pixelSize: qfont.secondaryImportantBodyText
		font.family: qfont.semiBold.name
	}

	Text {
		id: movingDotsText

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.top
			baselineOffset: Math.round(80 * verticalScaling)
			right: bigText_1.left
		}

		text: "."
		color: colors.softUpdatePopTextBig
		font.pixelSize: qfont.secondaryImportantBodyText
		font.family: qfont.semiBold.name
	}

	Text {
		id: progressText

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: bigText_1.bottom
			baselineOffset: Math.round(160 * verticalScaling)
		}

		text: root.progressText
		color: colors.softUpdatePopTextSmall
		font.pixelSize: qfont.primaryImportantBodyText
		font.family: qfont.bold.name
	}

	Text {
		id: subProgressText

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: progressText.bottom
			baselineOffset: Math.round(20 * verticalScaling)
		}

		text: root.subProgressText
		color: colors.softUpdatePopTextSmall
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.light.name
	}

	Text {
		id: bigText_2

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: progressText.bottom
			baselineOffset: Math.round(160 * verticalScaling)
		}

		text: root.footerText

		color: colors.cleanLoadingText
		font.pixelSize: qfont.secondaryImportantBodyText
		font.family: qfont.semiBold.name
	}

	Timer {
		id: timer_progressAnimation

		interval: 1000
		repeat: true

		onTriggered: {
			if (movingDotsText.text.length > 2)
				movingDotsText.text = "."
			else
				movingDotsText.text = movingDotsText.text + "."
		}
	}
}
