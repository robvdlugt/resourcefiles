import QtQuick 2.1
import BasicUIControls 1.0

Item {
	id: root
	width: errorButton.width
	height: errorButton.height
	property bool error: false
	property bool unknown: false
	property string errorCode
	signal clicked();

	IconButton {
		id: errorButton
		// On the NXT, the physical pixels are square, but on QB2 the physical pixels have a 93% aspect ratio.
		// So, we adjust the width in pixels, in order to appear as a circle on the screen.
		width: height * designElements.pixelAspectRatio
		height: Math.round(55 * verticalScaling)
		radius: height / 2

		colorUp: colors.errorBtnUp
		colorDown: colors.errorBtnDown
		colorDisabled: colors.errorBtnUp

		enabled: root.enabled
		visible: error
		onClicked: root.clicked()

		property string kpiPostfix: "ErrorButton_" + root.errorCode

		Image {
			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: Math.round(7 * verticalScaling)
			}
			source: "image://scaled/images/bad_white.svg"
		}

		Text {
			id: errorCodeText
			anchors {
				horizontalCenter: parent.horizontalCenter
				baseline: parent.bottom
				baselineOffset: Math.round(-11 * verticalScaling)
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.semiBold.name
			}
			color: colors.errorBtnCode
			text: errorCode
		}
	}

	Image {
		anchors.centerIn: parent
		source: "image://scaled/images/" + (unknown ? "statusUnknown.svg" : "good.svg")
		visible: !error
	}
}
