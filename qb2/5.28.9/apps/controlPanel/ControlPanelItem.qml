import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

Item {
	id: controlPanelItem

	property alias button: button
	property alias iconSource: button.iconSource
	property alias itemText: itemInfoText.text
	property alias buttonOverlayColorUp: button.overlayColorUp

	property ControlPanelApp app
	property variant statusInfo: app.deviceStatusInfo[configInfo.DevUUID]
	property variant configInfo

	implicitWidth: childrenRect.width
	implicitHeight: Math.round(55 * verticalScaling)

	state: !statusInfo || statusInfo.IsConnected === "0" ? "disabled" : (statusInfo.CurrentState === "0" ? "off" : "on")

	IconButton {
		id: button
		width: Math.round(58 * horizontalScaling)
		height: parent.height
		iconSource: "drawables/smartplug-button.svg"
		overlayWhenUp: true
		colorUp: colors.white
		leftClickMargin: 10
		rightClickMargin: 10
		bottomClickMargin: 2
		topClickMargin: 2

		mouseEnabled: !(configInfo.SwitchLocked === "1")
		onClicked: {
			console.log("Going to switch item " + configInfo.DevUUID + " to " + controlPanelItem.state == "on"?"0":"1");
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, configInfo.DevUUID, "SwitchPower", "SetTarget");
			msg.addArgument("NewTargetValue", controlPanelItem.state == "on" ? "0" : "1");
			bxtClient.sendMsg(msg);
		}

		Rectangle {
			id: led
			visible: !locked.visible
			anchors {
				right: parent.right
				rightMargin: Math.round(3 * horizontalScaling)
				top: parent.top
				topMargin: Math.round(4 * verticalScaling)
			}
			width: Math.round(8 * horizontalScaling)
			height: width
			radius: width / 2
		}

		Image {
			id: locked
			anchors {
				top: parent.top
				right: parent.right
				topMargin: Math.round(4 * verticalScaling)
				rightMargin: Math.round(7 * horizontalScaling)
			}
			visible: configInfo.SwitchLocked === "1"
			source: "image://scaled/apps/controlPanel/drawables/lock.svg"
		}
	}

	Rectangle {
		id: labelContainer
		anchors {
			left: button.right
			// to have symetric spacing between button and label AND the item below
			leftMargin: Math.round(6 * verticalScaling)
		}
		width: Math.round(141 * horizontalScaling)
		height: parent.height
		radius: designElements.radius
		color: colors.background

		Text {
			id: itemNameText

			anchors {
				left: parent.left
				leftMargin: Math.round(11 * horizontalScaling)
				right: linked.visible ? linked.left : parent.right
				rightMargin: Math.round((linked.visible ? 2 : 11) * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(23 * verticalScaling)
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			color: colors.controlPanelItemName
			elide: Text.ElideRight
			text: configInfo.Name
			textFormat: Text.PlainText // Prevent XSS/HTML injection
		}

		Text {
			id: itemInfoText

			anchors {
				left: parent.left
				leftMargin: Math.round(11 * horizontalScaling)
				right: parent.right
				rightMargin: Math.round(11 * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(44 * verticalScaling)
			}
			font.family: qfont.italic.name
			font.pixelSize: qfont.bodyText
			color: colors.controlPanelItemInfo
			text: " "
		}

		Image {
			id: linked
			anchors {
				top: parent.top
				topMargin: designElements.vMargin5
				right: parent.right
				rightMargin: anchors.topMargin
			}
			visible: configInfo.InSwitchAll === "1" && !locked.visible
			source: "image://scaled/apps/controlPanel/drawables/group.svg"
		}
	}

	states: [
		State {
			name: "on"
			PropertyChanges { target: led; color: colors.controlPanelLedOn}
			PropertyChanges { target: button; enabled: true}
		},
		State {
			name: "off"
			PropertyChanges { target: led; color: colors.controlPanelLedOff}
			PropertyChanges { target: button; enabled: true}
		},
		State {
			name: "disabled"
			PropertyChanges { target: led; color: colors.controlPanelLedDisabled}
			PropertyChanges { target: button; enabled: false}
		}
	]
}
