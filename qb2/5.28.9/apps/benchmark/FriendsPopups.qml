import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

Item
{
	id: rootPopup

	function populate(friend) {
		var date = "";
		if (typeof friend.requestT !== "undefined" && friend.requestT !== "0")
			date = i18n.dateTime(parseInt(friend.requestT*1000), i18n.time_no | i18n.mon_full | i18n.year_yes);

		switch (state) {
		case "invite":
			nameText.text = friend.name;
			inviteDate.text = qsTr("Sent you an invitation on: %1").arg(date);
			// fallthrough
		case "info":
			houseType.source = "image://scaled/" + qtUtils.urlPath(Qt.resolvedUrl(friend.homeImage));
			familyType.source = "image://scaled/" + qtUtils.urlPath(Qt.resolvedUrl(friend.familyImage));
			houseSizeValue.text = friend.homeSize + "m2";
			buildPeriodValue.text = friend.buildPeriodText;

			if (state == "info")
				friendsSinceLabel.text = qsTr("friend_info_popup_friends_since %1").arg(date);
			else
				friendsSinceLabel.text = qsTr("Do you want to compare your usage with %1?").arg(friend.name);
			break;
		case "notAccepted":
			commonnameLabel.text = friend.commonname;
			invitedDateLabel.text = qsTr("friend_notAccepted_popup_invitation_date %1").arg(date);
			break;
		}
	}
	Item {
		anchors {
			left: parent.left
			right: inviteContext.left
			top: inviteContext.top
		}
		Image {
			id: inviteImage
			visible: false
			source: "image://scaled/apps/benchmark/drawables/TileProfileBalloon.svg"
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}

	Item {
		id: inviteContext
		anchors {
			left: parent.left
			leftMargin: Math.round(100 * horizontalScaling)
			top: parent.top
			topMargin: designElements.vMargin10
		}
		visible: false
		height: childrenRect.height

		Text {
			id: nameText

			textFormat: Text.PlainText // Prevent XSS/HTML injection
			color: colors.friendListInfoPopupTitles
			font {
				family: qfont.regular.name
				pixelSize: qfont.navigationTitle
			}
		}

		Text {
			id: inviteDate
			color: colors.friendListInfoPopupTitles
			anchors {
				baseline: nameText.baseline
				baselineOffset: designElements.vMargin15 + font.pixelSize
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}
	}

	Item {
		id: infoContext

		width: childrenRect.width
		height: childrenRect.height
		visible: false
		anchors {
			left: inviteContext.left
			top: inviteContext.bottom
			topMargin: designElements.vMargin15
		}

		Row {
			id: infoRow
			spacing: Math.round(30 * horizontalScaling)

			Image {
				id: houseType
				anchors.bottom: parent.bottom
			}

			Image {
				id: familyType
				anchors.bottom: parent.bottom
			}

			Item {
				id: houseSize
				width: childrenRect.width
				Component.onCompleted: { height = houseSizeValue.y - houseSizeTitle.y + houseSizeValue.height }

				Text {
					id: houseSizeTitle
					anchors {
						baseline: houseSizeValue.baseline
						baselineOffset: Math.round(-32 * verticalScaling)
					}
					text: qsTr("friend_info_popup_house_size")
					color: colors.friendListInfoPopupTitles
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.titleText
					}
				}

				Text {
					id: houseSizeValue
					anchors {
						baseline: parent.bottom
					}
					color: colors.friendListInfoPopupValues
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
					}
					text: " "
				}
			}

			Item {
				id: buildPeriod
				width: childrenRect.width
				Component.onCompleted: { height = buildPeriodValue.y - buildPeriodTitle.y + buildPeriodValue.height }

				Text {
					id: buildPeriodTitle
					anchors {
						baseline: buildPeriodValue.baseline
						baselineOffset: Math.round(-32 * horizontalScaling)
					}
					text: qsTr("friend_info_popup_build_period")
					color: colors.friendListInfoPopupTitles
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.titleText
					}
				}

				Text {
					id: buildPeriodValue
					anchors {
						baseline: parent.bottom
					}
					color: colors.friendListInfoPopupValues
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
					}
					text: " "
				}
			}
		}

		Text {
			id: friendsSinceLabel
			anchors {
				baseline: infoRow.bottom
				baselineOffset: Math.round(30 * verticalScaling) + font.pixelSize
			}
			color: colors.friendListInfoPopupTitles
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			textFormat: Text.PlainText // Prevent XSS/HTML injection
		}
	}

	Item {
		id: notAcceptedContext

		visible: false

		anchors {
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
		}

		Image {
			id: mailmanIcon

			anchors {
				left: parent.left
				top: parent.top
			}

			source: "image://scaled/apps/benchmark/drawables/TheMailman.svg"
		}

		Text {
			id: commonnameLabel
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(35 * verticalScaling)
				left: mailmanIcon.right
				leftMargin: Math.round(35 * horizontalScaling)
			}
			color: colors.friendListInfoPopupTitles
			font {
				family: qfont.regular.name
				pixelSize: qfont.titleText
			}
		}

		Text {
			id: invitedDateLabel
			anchors {
				baseline: commonnameLabel.baseline
				baselineOffset: Math.round(30 * verticalScaling)
				left: commonnameLabel.left
			}
			color: colors.friendListInfoPopupTitles
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		Text {
			id: notAcceptedLabel
			anchors {
				baseline: invitedDateLabel.baseline
				baselineOffset: Math.round(55 * verticalScaling)
				left: invitedDateLabel.left
			}
			color: colors.friendListInfoPopupValues
			text: qsTr("friend_notAccepted_popup_not_acccepted")
			font {
				family: qfont.regular.name
				pixelSize: qfont.titleText
			}
		}
	}

	Row {
		id: friendDeleteContext

		anchors.centerIn: parent

		spacing: designElements.spacing8
		visible: false

		Image {
			id: hoboIcon
			source: "image://scaled/apps/benchmark/drawables/TheHobo.svg"
		}

		Text {
			id: deleteFriendLabel
			anchors {
				top: hoboIcon.verticalCenter
			}
			text: qsTr("friend_delete_popup_body");
			color: colors.friendListInfoPopupTitles
			font {
				family: qfont.regular.name
				pixelSize: qfont.titleText
			}
		}
	}

	state: "info"

	states: [
		State {
			name: "invite"
			PropertyChanges { target: infoContext; visible: true; }
			PropertyChanges { target: inviteContext; visible: true; }
			PropertyChanges { target: inviteImage; visible: true; }
		},
		State {
			name: "info"
			PropertyChanges { target: infoContext; visible: true; }
		},
		State {
			name: "notAccepted"
			PropertyChanges { target: notAcceptedContext; visible: true; }
		},
		State {
			name: "delete"
			PropertyChanges { target: friendDeleteContext; visible: true; }
		}
	]
}
