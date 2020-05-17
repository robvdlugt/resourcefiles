import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: alarmPopup

	property string curState: ""
	property string smokedetectorName: ""

	onCurStateChanged: {
		if (curState === "alarmTest") {
			bigText.text = qsTr("Testalarm");
			background.color = colors.smokedetectorTestPopupBg;
		} else if (curState === "alarm") {
			bigText.text = qsTr("Smokealarm");
			background.color = colors.smokedetectorAlarmPopupBg;
		}
	}

	onSmokedetectorNameChanged: {
		smallText.text = smokedetectorName;
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: colors.smokedetectorAlarmPopupBg
	}

	Image {
		id: smokeDetectorImg
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(100 * verticalScaling)
		}
		source: "image://scaled/apps/smokeDetector/drawables/smokedetector_alarm.svg"
	}

	Text {
		id: bigText
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(290 * verticalScaling)
		}
		color: colors.white
		font {
			pixelSize: qfont.smokeDetectorAlarmText
			family: qfont.semiBold.name
		}
	}

	Text {
		id: smallText
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bigText.baseline
			topMargin: designElements.vMargin10
		}
		color: colors.white
		font {
			pixelSize: qfont.secondaryImportantBodyText
			family: qfont.regular.name
		}
		textFormat: Text.PlainText // Prevent XSS/HTML injection
	}

	MouseArea {
		id: nonClickableArea
		anchors.fill: parent
	}

	Rectangle {
		id: closeButtonBackground
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			right: parent.right
			rightMargin: anchors.topMargin
		}
		width: Math.round(50 * horizontalScaling)
		height: width
		radius: width / 2
		opacity: 0.1
		color: "white"
	}

	Image {
		id: closeButton
		anchors.centerIn: closeButtonBackground
		source: "image://scaled/apps/smokeDetector/drawables/close-circle-cross.svg"
	}

	MouseArea {
		anchors.centerIn: closeButtonBackground
		width: closeButtonBackground.width + designElements.hMargin20
		height: width
		property string kpiId: curState + ".close"

		onPressed: closeButtonBackground.color = "black"
		onReleased: closeButtonBackground.color = "white"
		onClicked: {
			alarmPopup.hide();
		}
	}
}
