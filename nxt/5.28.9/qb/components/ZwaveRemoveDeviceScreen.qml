import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0

ContentScreen {
	id: root
	screenTitle: qsTr("Disconnect device")
	hasHomeButton: false
	hasCancelButton: true
	imageSource: imageStart

	property alias stepsText: bodyText.text
	property alias numberedSteps: stepsRepeater.model
	property alias tipText: tipBox.warningText
	property string failedText
	property var failedNumberedSteps
	property string forceRemoveTitle: qsTr("force-remove-popup-title")
	property string forceRemoveText: qsTr("force-remove-popup-content")
	property url imageStart
	property url imageBusy
	property url imageSuccess
	property url imageFailed

	QtObject {
		id: p

		property var postSuccessCallbackFcn
		property string deviceUuid
	}

	function handleExcludeResponse(status, type, uuid) {
		// check if root exists (lazy loaded screen)
		if (typeof root !== 'undefined') {
			if (status === "deleted") {
				root.state = "success";
				enableCustomTopRightButton();
				disableCancelButton();
				if (p.postSuccessCallbackFcn) {
					p.postSuccessCallbackFcn();
				}
			} else if (status !== "canceled") {
				root.state = "failed";
			}
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"));
		disableCustomTopRightButton();

		if (args) {
			p.postSuccessCallbackFcn = args.postSuccessCallbackFcn;
			p.deviceUuid = args.uuid ? args.uuid : "";
			if (typeof args.screenTitle === "string")
				setTitle(args.screenTitle);
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		if (root.state === "busy") {
			zWaveUtils.excludeDevice("stop");
		}
	}

	onCustomButtonClicked: {
		hide();
	}

	Text {
		id: bodyText
		anchors {
			left: parent.left
			right: parent.right
			rightMargin: Math.round(60 * horizontalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
	}

	Column {
		id: stepsList
		anchors {
			top: parent.top
			topMargin: bodyText.text ? designElements.vMargin10 : 0
			left: parent.left
			right: parent.right
		}
		spacing: designElements.vMargin15

		Repeater {
			id: stepsRepeater

			RowLayout {
				width: parent.width
				spacing: designElements.hMargin15

				NumberBullet {
					id: stepNumber
					Layout.preferredWidth: width
					text: index + 1
					color: colors.black
				}

				Text {
					id: stepText
					Layout.fillWidth: true
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.text
					wrapMode: Text.WordWrap
					text: modelData
				}
			}
		}
	}

	Row {
		anchors {
			top: numberedSteps && numberedSteps.length ? stepsList.bottom : bodyText.bottom
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: numberedSteps && numberedSteps.length ? Math.round(40 * horizontalScaling) : 0
		}
		spacing: designElements.hMargin15

		StandardButton {
			id: disconnectBtn
			minWidth: Math.round(100 * horizontalScaling)
			primary: true
			text: qsTr("Disconnect")

			onClicked: {
				root.state = "busy";
				zWaveUtils.excludeDevice("delete", handleExcludeResponse);
			}
		}

		StandardButton {
			id: forceRemoveBtn
			minWidth: Math.round(100 * horizontalScaling)
			enabled: false
			visible: enabled && p.deviceUuid
			text: qsTr("Force remove")

			onClicked: {
				qdialog.showDialog(qdialog.SizeMedium, root.forceRemoveTitle, root.forceRemoveText, qsTr("No"), null, qsTr("Yes"), function() {
					zWaveUtils.removeZwaveDevice(p.deviceUuid);
					if (p.postSuccessCallbackFcn) {
						p.postSuccessCallbackFcn();
					}
					root.hide();
					return false;
				});
				qdialog.context.highlightPrimaryBtn = true;
			}
		}

		Throbber {
			id: throbber
			anchors.verticalCenter: parent.verticalCenter
			height: disconnectBtn.height
			visible: false
		}

		Image {
			id: icon
			anchors.verticalCenter: parent.verticalCenter
			source: "image://scaled/images/good.svg"
			visible: false
		}
	}

	WarningBox {
		id: tipBox
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		autoHeight: true
		warningIcon: ""
		visible: warningText.length > 0
	}

	states: [
		State {
			name: "busy"
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: disconnectBtn; enabled: false }
			PropertyChanges { target: root; imageSource: imageBusy }
			PropertyChanges { target: tipBox; visible: false }
		},
		State {
			name: "success"
			PropertyChanges { target: disconnectBtn; enabled: false; text: qsTr("Disconnected") }
			PropertyChanges { target: icon; visible: true }
			PropertyChanges { target: root; imageSource: imageSuccess }
			PropertyChanges { target: tipBox; visible: false }
		},
		State {
			name: "failed"
			PropertyChanges { target: disconnectBtn; text: qsTr("Try again") }
			PropertyChanges { target: forceRemoveBtn; enabled: true }
			PropertyChanges { target: bodyText; text: failedText; restoreEntryValues: false }
			PropertyChanges { target: stepsRepeater; model: failedNumberedSteps; restoreEntryValues: false }
			PropertyChanges { target: icon; visible: true; source: "image://scaled/images/bad.svg" }
			PropertyChanges { target: root; imageSource: imageFailed }
			PropertyChanges { target: tipBox; visible: false }
		}
	]
}
