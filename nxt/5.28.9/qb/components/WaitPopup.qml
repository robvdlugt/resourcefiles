import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

/**
 * This popup is used where throbber cannot be used because system is fully loaded and throbber would not be animated.
 */
Popup {
	id: waitPopup

	property alias title: bigText.text
	property alias text: smallText.text
	property alias actionTimer: actionTimer

	Rectangle {
		id: maskedArea

		anchors.fill: parent
		color: colors.fstMaskedArea
		opacity: designElements.opacity
	}

	MouseArea {
		id: nonClickableArea
		anchors.fill: parent
	}

	Text {
		id: bigText
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: -40
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.secondaryImportantBodyText
		}
		color: colors.white
	}

	Text {
		id: smallText
		horizontalAlignment: Text.AlignHCenter
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: 40
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.white
	}

	/*
	 * This timer was added to execute actions that are processor-intensive and
	 * would normally freeze the UI if executed on a signal handler like onShown,
	 * making the popup show up too late
	 */
	Timer {
		id: actionTimer
		interval: 1
		repeat: false
		triggeredOnStart: false
	}
}
