import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: invitationsFrame
	anchors.fill: parent

	property int bulletNum: app.invitations
	property url popupContentSource: "FriendsPopups.qml"

	function navigatePage(page) {
		var arrOffset = page * 5;
		var invites = app.getFriendlistFriends(true);

		selector.pageCount = Math.ceil(invites.length/5);
		titleLabel.text = invites.length === 0 ? qsTr("invitelistEmpty_title_text") : qsTr("invitelist_title_text");

		for(var i = 0; i < 5; ++i) {
			if (i + arrOffset < invites.length) {
				var friend = invites[i+arrOffset];
				invitelistModel.set(i, { "commonname" : friend.commonname, "name" : friend.name});
			} else {
				invitelistModel.set(i, { "commonname" : "", "name" : ""});
			}
		}
	}

	function newDataAvailableHandler() {
		navigatePage(selector.currentPage);
	}

	onShown: {
		selector.currentPage = 0;
		navigatePage(0);
	}

	Component.onCompleted: { app.newDataAvailable.connect(newDataAvailableHandler); }
	Component.onDestruction: { app.newDataAvailable.disconnect(newDataAvailableHandler); }

	Text {
		id: titleLabel

		width: Math.round(505 * horizontalScaling)
		wrapMode: Text.Wrap
		color: colors.friendListTitle

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(74 * horizontalScaling)
		}

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		text: " "
	}

	ListView {
		id: friendColumn

		width: Math.round(505 * horizontalScaling)
		height: Math.round(240 * verticalScaling)
		anchors {
			top: titleLabel.bottom
			topMargin: Math.round(25 * verticalScaling)
			left: titleLabel.left
		}

		spacing: designElements.spacing8

		model: invitelistModel
		interactive: false

		delegate: Item {
			width: Math.round(448 * horizontalScaling)
			height: Math.round(36 * verticalScaling)
			visible: (model.name !== "")

			property string kpiPrefix: "InvitationsFrame."

			Rectangle {
				height: parent.height
				anchors {
					left: parent.left
					right: plusIcon.left
					rightMargin: designElements.spacing6
				}

				Text {
					id: nameText

					text: model.name
					textFormat: Text.PlainText // Prevent XSS/HTML injection
					color: colors.benchmarkInviteName

					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						leftMargin: designElements.hMargin10
					}

					font {
						family: qfont.semiBold.name
						pixelSize: qfont.bodyText
					}
				}
			}

			IconButton {
				id: plusIcon
				anchors {
					right: infoIcon.left
					rightMargin: designElements.spacing6
				}
				iconSource: "qrc:/images/plus_add.svg"

				onClicked: {
					app.acceptInvite(model.commonname);
				}
			}

			IconButton {
				id: infoIcon
				anchors {
					right: deleteIcon.left
					rightMargin: designElements.spacing6
				}
				iconSource: "qrc:/images/info.svg"

				onClicked: {
					qdialog.showDialog(qdialog.SizeLarge, qsTr("Received invitation"), popupContentSource, qsTr("accept"), function () { app.acceptInvite(model.commonname) }, qsTr("decline"), function () { app.removeFriend(model.commonname) });

					var popup = qdialog.context;
					popup.dynamicContent.state = "invite";
					popup.closeBtnForceShow = true;
					popup.dynamicContent.populate(app.getFriendData(model.commonname));
				}
			}

			IconButton {
				id: deleteIcon
				anchors {
					right: parent.right
				}
				iconSource: "qrc:/images/delete.svg"

				onClicked: {
					qdialog.showDialog(qdialog.SizeLarge, qsTr("Remove invitation"), popupContentSource, qsTr("delete"), (function() { app.removeFriend(model.commonname); }), qsTr("cancel"));
					qdialog.context.dynamicContent.state = "delete";
				}
			}
		}
	}

	ListModel {
		id: invitelistModel
	}

	DottedSelector {
		id: selector
		width: Math.round(450 * horizontalScaling)

		anchors {
			left: titleLabel.left
			bottom: parent.bottom
			bottomMargin: designElements.vMargin5
		}

		onNavigate: navigatePage(page)
	}
}
