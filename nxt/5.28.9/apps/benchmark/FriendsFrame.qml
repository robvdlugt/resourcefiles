import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: friendsFrame
	anchors.fill: parent

	property url popupContentSource: "FriendsPopups.qml"

	function navigatePage(page) {
		var arrOffset = page*5;
		var friends = app.getFriendlistFriends(false);

		selector.pageCount = Math.ceil(friends.length/5);
		titleLabel.text = friends.length === 0 ? qsTr("friendlistEmpty_title_text") : qsTr("friendlist_title_text");

		for(var i=0; i < 5; ++i) {
			if (i + arrOffset < friends.length) {
				var auxText = "";
				var selected = false;
				var accepted = true;
				var friend = friends[i+arrOffset];

				if (parseInt(friend.friendState) !== app._FS_ACCEPTED) {
					auxText = qsTr("friendsFrame_not_accepted_aux");
					accepted = false;
				} else if (!app.hasValidCompareData(friend)) {
					auxText = qsTr("friendsFrame_not_enough_data_aux");
				} else {
					selected = (friend.compareActive === "1");
				}

				friendlistModel.set(i, { "commonname" : friend.commonname,
										 "name" : friend.name,
										 "auxText" : auxText,
										 "accepted" : accepted,
										 "selected" : selected });
			} else {
				friendlistModel.set(i, { "commonname" : "",
										 "name" : "",
										 "auxText" : "",
										 "accepted" : false,
										 "selected" : false });
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

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(74 * horizontalScaling)
		}

		wrapMode: Text.Wrap

		color: colors.friendListTitle

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
			top: titleLabel.baseline
			topMargin: Math.round(65 * verticalScaling)
			left: titleLabel.left
		}

		spacing: designElements.spacing8

		model: friendlistModel
		interactive: false

		delegate: FriendCheckbox {
			text: model.name
			auxText: model.auxText

			selected: model.selected
			boxEnabled: (model.auxText === "")
			visible: (model.name !== "")

			onBoxClicked: {
				if (selected === model.selected)
					return;

				if ( selected ) {
					if( app.comparableFriendsCount < 4) {
						app.setFriendCompareActive(model.commonname, "1");
					} else {
						qdialog.showDialog(qdialog.SizeLarge,
										   qsTr("friendsFrame_too_many_friends_selected_popup_title"),
										   qsTr("friendsFrame_too_many_friends_selected_popup_body"));
						selected = false;
					}
				} else {
					app.setFriendCompareActive(model.commonname, "0");
				}
			}

			onDeleteClicked: {
				// Prevent XSS/HTML injection by using qtUtils.escapeHtml
				qdialog.showDialog(qdialog.SizeLarge, qsTr("Remove %1").arg(qtUtils.escapeHtml(model.name)), popupContentSource, qsTr("delete"), (function() { app.removeFriend(model.commonname); }), qsTr("cancel"));
				qdialog.context.dynamicContent.state = "delete";
			}

			onInfoClicked: {
				if (model.accepted) {
					// Prevent XSS/HTML injection by using qtUtils.escapeHtml
					qdialog.showDialog(qdialog.SizeLarge, qtUtils.escapeHtml(model.name), popupContentSource);
				} else {
					qdialog.showDialog(qdialog.SizeLarge, qsTr("friend_notAccepted_popup_title"), popupContentSource, qsTr("friend_notAccepted_popup_delete_friend"), (function() { app.removeFriend(model.commonname) }));
				}

				var popup = qdialog.context;
				if (model.accepted) {
					popup.dynamicContent.state = "info";
				} else {
					popup.dynamicContent.state = "notAccepted";
				}

				popup.closeBtnForceShow = true;
				popup.dynamicContent.populate(app.getFriendData(model.commonname));
			}
		}
	}

	ListModel {
		id: friendlistModel
	}

	DottedSelector {
		id: selector
		width: Math.round(450 * horizontalScaling)

		anchors {
			left: titleLabel.left
			bottom: parent.bottom
			bottomMargin: designElements.vMargin5
		}

		visible: pageCount>1
		onNavigate: navigatePage(page)
	}
}
