import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

/**
 * Full screen preview of the message in Inbox application.
 * Allows to delete currently selected message.
 * Unread message is marked as read if message is displayed for
 * more than 2 seconds in full screen view.
 */

Popup {
	id: fullScreenMsgPopup

	property variant message
	property InboxApp app

	onMessageChanged: {
		if (message && message.actions) {
			var buttons = [actionButtonLeft, actionButtonMiddle, actionButtonRight];
			var buttonPositions = ["left", "middle", "right"];

			// loop through the three buttons...
			for (var b = 0; b < buttons.length; ++b) {
				var button = buttons[b];
				button.visible = false;
				button.action = null;
				var action = message.actions[buttonPositions[b]];
				// ...and see if we have an action for it
				if (action) {
					console.log(" action" + action.btnPos + ", " + action.cmdTarget + ", " + action.btnLabel);
					button.text = action.btnLabel;
					button.visible = true;
					button.action = action;
				}
			}
		}
		if (message.subject) {
			countly.sendPageViewEvent(util.absoluteToRelativePath(app.fullScreenMsgUrl) + ":" + message.subject);
		}
	}

	QtObject {
		id: p

		property alias tst_msgSubjectText: txtSubject.text
		property alias tst_msgContentText: txtMessage.text

		function executeAction(action) {
			if (action.cmdTarget === "popup") {
				qdialog.showDialog(action.cmdArg.size, action.cmdArg.title, action.cmdArg.text);
			} else {
				// turn it into a QUrl (which uses import paths)
				var actionUrl = Qt.resolvedUrl("qrc:/apps/" + action.cmdTarget + ".qml");
				// tries to parse the cmdArg as JSON
				// if it fails, use arg as string
				var cmdArg;
				try {
					cmdArg = JSON.parse(action.cmdArg);
				} catch(e) {
					cmdArg = action.cmdArg;
				}
				stage.openFullscreen(actionUrl, cmdArg);
			}
			fullScreenMsgPopup.hide();
		}
	}

	StyledRectangle {
		id: popUpContainer
		color: colors.canvas
		anchors.fill: parent
	}

	Rectangle {
		id: messageContainer
		color: colors.ibFullscreenMsgBackground
		radius: designElements.radius
		anchors {
			fill: popUpContainer
			topMargin: Math.round(25 * verticalScaling)
			bottomMargin: anchors.topMargin
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}

		Item {
			id: imgMsgWrap
			height: Math.round(24 * verticalScaling)
			width: height
			visible: message ? (message.read_t === 0) : true
			anchors {
				top: parent.top
				topMargin: Math.round(25 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(40 * horizontalScaling)
			}
			Rectangle {
				id: readIcon
				height: Math.round(8 * verticalScaling)
				width: height
				radius: (width*0.5)
				color: colors.ibMsgDotUnread
				anchors.centerIn: parent
			}
		}

		IconButton {
			id: closeButton
			width: designElements.buttonSize
			height: designElements.buttonSize
			anchors {
				top: parent.top
				right: parent.right
				topMargin: Math.round(16 * verticalScaling)
				rightMargin: Math.round(16 * horizontalScaling)
			}
			iconSource: "qrc:/images/DialogCross.svg"
			colorUp: colors.igpTransparentBackgrnd

			onClicked: {
				fullScreenMsgPopup.hide();
			}
		}

		Text {
			id: txtSubject
			elide: Text.ElideRight
			text: message ? message.subject : ""
			anchors {
				verticalCenter: imgMsgWrap.verticalCenter
				left: imgMsgWrap.right
			}
			color: colors.ibMsgTitleInbox
			verticalAlignment: Text.AlignVCenter
			font {
				pixelSize: qfont.titleText
				family: qfont.bold.name
			}
		}

		Text {
			id: txtDate
			elide: Text.ElideRight
			text: message ? message.receivedLong : ""
			anchors {
				top: txtSubject.bottom
				topMargin: Math.round(4 * verticalScaling)
				left: txtSubject.left
			}
			color: colors.ibMsgDate
			verticalAlignment: Text.AlignVCenter
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
		}

		Rectangle {
			id: line
			height: Math.round(2 * verticalScaling)
			color: colors.ibListViewSeparator1
			anchors {
				top: txtDate.bottom
				topMargin: Math.round(14 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
				left: parent.left
				leftMargin: anchors.rightMargin
			}
		}

		Text
		{
			id: txtMessage
			text: message ? message.content : ""
			width: parent.width
			anchors {
				left: txtSubject.left
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
				top: line.bottom
				topMargin: Math.round(16 * verticalScaling)
				bottom: actionButtonLeft.bottom
				bottomMargin: anchors.topMargin
			}
			wrapMode: Text.WordWrap
			lineHeight: 1.25
			color: colors.ibMsgText
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: actionButtonLeft
			property variant action
			visible: false
			anchors {
				bottom: deleteButton.bottom
				left: txtSubject.left
			}
			onClicked: {
				p.executeAction(action);
			}
		}

		StandardButton {
			id: actionButtonMiddle
			property variant action
			visible: false
			anchors {
				bottom: deleteButton.bottom
				horizontalCenter: parent.horizontalCenter
			}
			onClicked: {
				p.executeAction(action);
			}
		}

		StandardButton {
			id: actionButtonRight
			property variant action
			visible: false
			anchors {
				bottom: deleteButton.bottom
				right: deleteButton.left
				rightMargin: Math.round(10 * horizontalScaling)
			}
			onClicked: {
				p.executeAction(action);
			}
		}

		IconButton {
			id: deleteButton
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(40 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
			}
			iconSource: "qrc:/images/delete.svg"

			onClicked: {
				app.deleteMessage(message.index);
				fullScreenMsgPopup.hide();
			}
		}
	}
}
