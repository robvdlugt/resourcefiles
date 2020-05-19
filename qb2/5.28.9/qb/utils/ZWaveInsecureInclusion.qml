import QtQuick 2.11

import qb.base 1.0
import qb.components 1.0

Widget {
	id: zwaveInsecureInclusion
	anchors.fill: parent

	QtObject {
		id: p
		property string deviceUuid
	}

	onShown: {
		securityPopup.titleText = qsTr("Connection not secured");
		if (args && args.uuid) {
			p.deviceUuid = args.uuid;
		}
	}

	Text {
		id: bodyText
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: image.left
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.titleText
		}
		color: colors.text
		text: qsTr("zwave-improve-security-text")
		wrapMode: Text.WordWrap
	}

	Image {
		id: image
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			right: parent.right
			rightMargin: designElements.hMargin20
		}
		source: "image://scaled/qb/utils/drawables/popup-no-secure-connection.svg"
	}

	StandardButton {
		id: improveBtn
		anchors {
			left: bodyText.left
			bottom: parent.bottom
			bottomMargin: designElements.vMargin24
		}
		primary: true
		text: qsTr("Improve connection")

		onClicked: securityPopup.setContent(Qt.resolvedUrl("ZWaveExcludeDevice.qml"), {"uuid": p.deviceUuid})
	}

	StandardButton {
		id: continueBtn
		anchors {
			left: improveBtn.right
			leftMargin: designElements.hMargin20
			bottom: improveBtn.bottom
		}
		primary: false
		text: qsTr("Continue (not secured)")

		onClicked: securityPopup.hide()
	}
}
