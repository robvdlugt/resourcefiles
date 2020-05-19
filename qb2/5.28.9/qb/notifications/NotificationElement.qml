import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: notificationElement
	width: parent ? parent.width : 0
	height: itemHeight
	clip: true

	property string uuid
	property url iconSource
	property alias title: title.text
	property url actionUrl
	property variant actionArgs: ({})
	property alias actionButtonIconRotation: actionButton.imgRotation
	property alias actionButtonRotationAnim: actionButtonRotationAnim
	property bool header: false
	property bool showClose: false
	property alias itemHeight: notificationBg.height
	property alias bgColor: notificationBg.color
	property bool activeInDim: false

	signal close();
	signal action();

	StyledRectangle {
		id: notificationBg
		color: colors.notificationsElement
		radius: designElements.radius
		anchors {
			left: parent.left
			right: closeButton.visible && header ? closeButton.left : parent.right
			rightMargin: closeButton.visible && header ? Math.round(16 * verticalScaling) : 0
		}
		height: Math.round(60 * verticalScaling)
		property string kpiId: "Notification.ActionBody"
		mouseIsActiveInDimState: activeInDim

		onClicked: actionButton.clicked()
	}

	Item {
		id: iconContainer
		width: height
		height: Math.round(24 * verticalScaling)
		anchors {
			left: parent.left
			leftMargin: Math.round(16 * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}

		Image {
			id: icon
			anchors.centerIn: parent
			source: iconSource.toString() ? "image://scaled" + qtUtils.urlPath(canvas.dimState ? iconSource.toString().replace(/(\.[^\.]+)$/i, '_dim$1') : iconSource) : ""
		}
	}

	Text {
		id: title
		anchors {
			left: iconContainer.right
			leftMargin: Math.round(10 * horizontalScaling)
			right: actionButton.left
			rightMargin: iconContainer.anchors.leftMargin
			verticalCenter: parent.verticalCenter
		}
		font {
			pixelSize: qfont.tileTitle
			family: qfont.bold.name
		}
		color: dimmableColors.notificationsText
		elide: Text.ElideRight
		text: " "
	}

	ThreeStateButton {
		id: actionButton
		width: height
		height: Math.round(44 * verticalScaling)
		anchors {
			right: closeButton.visible ? closeButton.left : parent.right
			rightMargin: Math.round((header && closeButton.visible ? 24 : 8) * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}
		property string kpiPrefix: "Notification"
		property string kpiPostfix: "ActionButton"

		image: "drawables/" + (header ? "arrow-down" : actionUrl.toString().length > 0 ? "arrow-right" : "delete") + ".svg"
		backgroundUp: "transparent"
		backgroundDown: colors.notificationsBtnDown
		buttonDownColor: colors.ibOverlayColorDown

		visible: !(actionUrl.toString().length === 0 && canvas.dimState) || header

		mouseIsActiveInDimState: activeInDim
		onClicked: {
			action();
			// go to action
			if (actionUrl.toString().length > 0) {
				console.log("Notification: performing action ", actionUrl, "with arguments", JSON.stringify(actionArgs))
				stage.openFullscreen(actionUrl, actionArgs);
			}
		}

		Behavior on imgRotation {
			enabled: globals.notificationAnimationsEnabled
			SequentialAnimation {
				PropertyAction { target: actionButton; property: "iconSmooth"; value: true }
				RotationAnimation {
					id: actionButtonRotationAnim
					target: actionButton
					property: "imgRotation"
					duration: 300
					direction: RotationAnimation.Counterclockwise
					easing.type: direction === RotationAnimation.Clockwise ? Easing.OutQuad : Easing.InQuad
				}
				PropertyAction { target: actionButton; property: "iconSmooth"; value: false }
			}
		}
	}

	IconButton {
		id: closeButton
		width: height
		height: Math.round(44 * verticalScaling)
		anchors {
			right: parent.right
			rightMargin: Math.round(8 * verticalScaling)
			verticalCenter: parent.verticalCenter
		}
		property string kpiPrefix: "Notification"
		property string kpiPostfix: "CloseButton"

		iconSource: "drawables/close.svg"
		colorUp: "transparent"
		colorDown: colors.notificationsBtnDown

		visible: !canvas.dimState && (header || showClose)

		onClicked: {
			close();
		}
	}
}
