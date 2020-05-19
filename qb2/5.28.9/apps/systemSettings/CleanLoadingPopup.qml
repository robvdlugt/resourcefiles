import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: cleanLoadingPopup

	QtObject {
		id: p

		property int counter

		function startTimer() {
			counter = 30;
			timer.start();
		}
	}

	onShown: {
		p.startTimer();
	}

	Rectangle {
		id: maskedArea

		anchors.fill: parent
		color: colors.dialogMaskedArea
		opacity: designElements.opacity
	}

	Text {
		id: bigText

		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.top
			baselineOffset: Math.round(80 * verticalScaling)
		}

		text: qsTr("Now you can clean your screen...")
		color: colors.cleanLoadingText
		font.pixelSize: qfont.secondaryImportantBodyText
		font.family: qfont.semiBold.name
	}

	Throbber {
		id: loadingThrobber

		width: Math.round(90 * horizontalScaling)
		height: Math.round(87 * verticalScaling)

		anchors {
			centerIn: parent
		}

		Component.onCompleted: {
			smallDotColor = colors.cleanLoadingThrobberDot;
			mediumDotColor = colors.cleanLoadingThrobberDot;
			bigDotColor = colors.cleanLoadingThrobberDot;
			largeDotColor = colors.cleanLoadingThrobberDot;
		}

		Text {
			id: counterNumber

			anchors.centerIn: parent
			text: p.counter
			color: colors.cleanLoadingText
			font.pixelSize: qfont.secondaryImportantBodyText
			font.family: qfont.light.name
		}
	}

	MouseArea {
		id: nonClickableArea

		anchors.fill: parent
	}

	Timer {
		id: timer

		interval: 1000
		repeat: true

		onTriggered: {
			p.counter -= 1;
			if (p.counter === 0) {
				parent.hide();
				stop();
			}
		}
	}
}
