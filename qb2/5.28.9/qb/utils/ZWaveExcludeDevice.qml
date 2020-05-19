import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0

Widget {
	id: zwaveExcludeDevice
	anchors.fill: parent

	QtObject {
		id: p
		property string deviceUuid

		function handleExcludeResponse(status, type, uuid) {
			if (typeof zwaveExcludeDevice !== 'undefined') {
				if (status === "deleted" && uuid === p.deviceUuid) {
					zwaveExcludeDevice.state = "unlinked";
				} else if (status !== "canceled") {
					zwaveExcludeDevice.state = "failed";
				}
			}
		}
	}

	onShown: {
		securityPopup.titleText = qsTr("Disconnect device");
		securityPopup.hideCloseBtn = false;
		if (args && args.uuid) {
			p.deviceUuid = args.uuid;
		}
		zwaveExcludeDevice.state = "unlinking";
		zWaveUtils.excludeDevice("delete", p.handleExcludeResponse);
	}

	onHidden: {
		if (zwaveExcludeDevice.state === "unlinking") {
			zWaveUtils.excludeDevice("stop");
		} else if (zwaveExcludeDevice.state === "unlinked") {
			stage.navigateBack();
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
			rightMargin: designElements.hMargin20
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.titleText
		}
		color: colors.text
		text: qsTr("zwave-exclude-device-steps")
		wrapMode: Text.WordWrap
	}

	RowLayout {
		anchors {
			top: bodyText.bottom
			bottom: button.top
			left: bodyText.left
			right: bodyText.right
		}
		spacing: designElements.hMargin15

		Throbber {
			id: linkThrobber
			visible: false
		}

		Image {
			id: statusIcon
			visible: false
		}

		Text {
			id: statusText
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			visible: statusIcon.visible
			wrapMode: Text.WordWrap
		}
	}

	StandardButton {
		id: button
		anchors {
			left: bodyText.left
			bottom: parent.bottom
			bottomMargin: bodyText.anchors.topMargin
		}
		minWidth: Math.round(100 * horizontalScaling)
		visible: false

		onClicked: {
			if (zwaveExcludeDevice.state === "failed") {
				zwaveExcludeDevice.state = "unlinking";
				zWaveUtils.excludeDevice("delete", p.handleExcludeResponse);
			} else {
				securityPopup.hide();
			}
		}
	}

	Image {
		id: image
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			right: parent.right
			rightMargin: designElements.hMargin20
		}
		source: "image://scaled/qb/utils/drawables/popup-press-button.svg"
	}

	states: [
		State {
			name: "unlinking"
			PropertyChanges { target: linkThrobber; visible: true }
		},
		State {
			name: "unlinked"
			PropertyChanges { target: button; visible: true; text: "OK" }
			PropertyChanges { target: statusIcon; visible: true; source: "image://scaled/images/good.svg" }
			PropertyChanges { target: statusText; color: colors._pocahontas; text: qsTr("zwave-device-excluded") }
		},
		State {
			name: "failed"
			PropertyChanges { target: button; visible: true; text: qsTr("Try again") }
			PropertyChanges { target: statusIcon; visible: true; source: "image://scaled/images/bad.svg" }
			PropertyChanges { target: statusText; color: colors._marypoppins; text: qsTr("zwave-device-exclude-failed") }
		}
	]
}
