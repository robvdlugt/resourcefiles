import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: root
	anchors.fill: parent

	QtObject {
		id: p
		property variant linkedBridge: app.linkedBridgeUuid ? app.hueBridges[app.linkedBridgeUuid] : {"IsConnected": "0", "intAddr": "00000000", "friendlyName": " "}

		function disconnectBridge() {
			app.sendBridgeUnlinkMsg(app.linkedBridgeUuid);
		}
	}

	function init() {}

	function disconnectBridge() {
		console.log('Disconnect bridge ', p.linkedBridge.friendlyName);
		qdialog.showDialog(qdialog.SizeLarge, qsTr('Disconnect bridge'),
						   qsTr('disconnect_bridge_dlgcontent %1').arg("%1 (%2)".arg(p.linkedBridge.friendlyName).arg(app.formatMAC(p.linkedBridge.intAddr))),
						   qsTr('Disconnect'), p.disconnectBridge);
		qdialog.context.closeBtnForceShow = true;
	}

	DoubleLabel {
		id: bridgeLabel
		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(56 * horizontalScaling)
			right: btnDisconnect.left
			rightMargin: designElements.vMargin6
		}
		topText: p.linkedBridge.friendlyName
		topTextFormat: Text.PlainText // Prevent XSS/HTML injection
		bottomText: app.formatMAC(p.linkedBridge.intAddr)
		bottomTextFormat: Text.PlainText // Prevent XSS/HTML injection

		Image {
			id: statusIcon
			source: p.linkedBridge.IsConnected === "1" ? "qrc:/images/good.svg" : "qrc:/images/bad.svg"
			anchors {
				top: parent.top
				topMargin: designElements.vMargin10
				right: parent.right
				rightMargin: designElements.hMargin10
			}
			height: Math.round(24 * verticalScaling)
			sourceSize {
				width: 0
				height: height
			}
		}
	}

	IconButton {
		id: btnDisconnect
		width: designElements.buttonSize
		anchors {
			top: bridgeLabel.top
			right: parent.right
			rightMargin: bridgeLabel.anchors.leftMargin
		}
		iconSource: "qrc:/images/delete.svg"
		onClicked: {
			if (feature.appControlPanelPinProtectRemoveBridge()) {
				pinEntry.show();
			} else {
				disconnectBridge();
			}
		}
	}

	PinEntryOverlay {
		id: pinEntry
		parent: widgetInfo.container
		visible: false
		titleText: qsTr("Please enter pincode to remove bridge")
		titleFontSize: qfont.bodyText

		onClosed: hide()
		onPinEntered: {
			if (pin === feature.featPinProtectNumber()) {
				hide();
				disconnectBridge();
			} else {
				wrongPin();
			}
		}
	}
}
