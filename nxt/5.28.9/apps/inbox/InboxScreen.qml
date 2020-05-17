import QtQuick 2.1
import qb.components 1.0

/// Main screen of Inbox application. Contains scrollable list of messages on the left and message
/// preview on the right side.

Screen {
	id: inboxScreen
	property InboxApp app
	property string appTitle: qsTr("Notifications") + (app.unreadMessageCount ? (" (" + app.unreadMessageCount + " " + qsTr("new", "", app.unreadMessageCount) + ")") : "")
	screenTitleIconUrl: "drawables/inbox-menu.svg"
	anchors.fill: parent

	onShown: {
		if (args) {
			if (args.msgUuid) {
				for (var i=0; i < inboxList.dataModel.count; i++) {
					var msg = inboxList.dataModel.get(i);
					if (msg && msg.uuid === args.msgUuid) {
						app.fullScreenMsgPopup.message = msg;
						if (parseInt(msg.read_t) === 0) {
							timerReadingMsg.messageIndex = i;
							timerReadingMsg.restart();
						}
						app.fullScreenMsgPopup.show();
						break;
					}
				}
			}
		}
		setTitle(appTitle);
	}

	onAppTitleChanged: {
		setTitle(appTitle);
	}

	/// Timer starting everytime when message is selected.
	/// If message is selected for more than 2 seconds it is marked as read.
	/// This timer is used for full screen message preview as well.
	Timer {
		id: timerReadingMsg
		repeat: false
		running: false
		interval: 2000
		property int messageIndex: 0

		onTriggered: {
			app.markMessageRead(messageIndex);
		}
	}

	/// list background
	Rectangle {
		id: listBackground
		color: colors.ibListBg
		radius: designElements.radius
		anchors {
			fill: parent
			topMargin: Math.round(16 * verticalScaling)
			bottomMargin: Math.round(24 * verticalScaling)
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}

		InboxSimpleList {
			id: inboxList
			itemsPerPage: 5
			delegate: msgHeaderDelegate
			dataModel: app.messageList
			itemHeight: Math.round(60 * verticalScaling)
		}
	}

	Component {
		id: msgHeaderDelegate
		InboxMsgHeaderListItem {
			read: (model.read_t > 0)
			subjectText: model.subject
			onClicked:{
				app.fullScreenMsgPopup.message = model;
				if (parseInt(model.read_t) === 0) {
					timerReadingMsg.messageIndex = index;
					timerReadingMsg.restart();
				}
				app.fullScreenMsgPopup.show();
			}
		}
	}

	Connections {
		target: app.fullScreenMsgPopup
		onHidden: { timerReadingMsg.stop() }
	}
}
