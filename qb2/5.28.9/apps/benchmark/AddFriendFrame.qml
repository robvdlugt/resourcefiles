import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: addFriendsFrame
	anchors.fill: parent
	clip: true

	QtObject {
		id: p

		property url addFriendsPopupSource: "AddFriendsPopup.qml"
		property url invitationPopupSource: "InvitationPopup.qml"
	}

	function showInvitationDialog() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("send_invitation"), p.invitationPopupSource, null, function(){sendInvitation(); return true;});
		sendInvitation();
	}

	function sendInvitation() {
		qdialog.context.title =  qsTr("send_invitation");
		qdialog.context.dynamicContent.state = "BUSY";
		qdialog.context.button1.text = "";
		qdialog.context.button2.text = "";
		qdialog.context.closeBtnForceHide = true;

		app.setFriendInvitation(editDisplayCode.inputText, editZipCode.inputText.toUpperCase());
	}

	function updateInvitationDialog() {
		var popup = qdialog.context;
		qdialog.context.closeBtnForceShow = true;
		if (app.invitationSuccess === 1) {
			qdialog.context.title =  qsTr("send_invitation_ok");
			popup.dynamicContent.state = "SUCCESS";
			editDisplayCode.inputText = "";
			editZipCode.inputText = "";
		} else if (app.invitationSuccess === 0 ) {
			// Set the popup in the correct error state with a title
			qdialog.context.title = qsTr("send_invitation_error");
			popup.dynamicContent.state = "ERROR";

			// Set the error from the driver to the content of the popup
			if (app.invitationFaultCode === "timeout")
				popup.dynamicContent.contentText = qsTr("invitation_popup_timeout");
			else if (app.invitationFaultCode === "unknownCommonNameAndZipcodeCombination")
				popup.dynamicContent.contentText = qsTr("invitation_popup_failed_line");
			else if ( (app.invitationFaultCode === "requestAlreadyExists") || (app.invitationFaultCode === "requestAlreadyExistsMadeByOtherParty") )
				popup.dynamicContent.contentText = qsTr("invitation_popup_failed_line_requestAlreadyExists");
			else if(app.invitationFaultCode === "friendshipAlreadyExists")
				popup.dynamicContent.contentText = qsTr("invitation_popup_failed_line_friendshipAlreadyExists");
			else if (app.invitationFaultCode === "cannotBefriendYourself")
				popup.dynamicContent.contentText = qsTr("invitation_popup_failed_line_cannotBefriendYourself");
			else if (app.invitationFaultCode === "requestHasBeenRevokedByOtherParty")
				popup.dynamicContent.contentText = qsTr("invitation_popup_failed_line_requestHasBeenRevokedByOtherParty");
			else if (app.invitationFaultCode === "maxFriends")
				popup.dynamicContent.contentText = qsTr("invitation_popup_maxfriends_line");

			// Add buttons to allow the user to try it again
			qdialog.context.button1.text = qsTr("Try again");
			qdialog.context.button2.text = qsTr("Cancel");
		}
	}

	onShown: {
		editDisplayCode.inputText = "";
		editZipCode.inputText = "";
	}

	Component.onCompleted: {
		app.invitationResponse.connect(updateInvitationDialog);
	}

	Component.onDestruction: {
		app.invitationResponse.disconnect(updateInvitationDialog);
	}

	Item {
		id: container
		anchors.fill: parent
		anchors.topMargin: Qt.inputMethod.visible ? - Math.round(175 * verticalScaling) : 0

		Text {
			id: titleText
			anchors {
				left: parent.left
				leftMargin: Math.round(74 * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(40 * verticalScaling)
				right: iconButton.left
				rightMargin: designElements.hMargin10
			}
			font {
				pixelSize: qfont.titleText
				family: qfont.semiBold.name
			}
			text: qsTr("add-friend-title")
			wrapMode: Text.WordWrap
		}

		IconButton {
			id: iconButton
			anchors {
				right: contentText.right
				top: titleText.top
			}
			iconSource: "qrc:/images/info.svg"

			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge, qsTr("Add friends"), p.addFriendsPopupSource);
			}
		}

		Text {
			id: contentText
			width: Math.round(450 * horizontalScaling)

			text: qsTr("add-friend-content")
			wrapMode: Text.WordWrap

			color: colors.addFriendBody

			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}

			anchors {
				left: titleText.left
				top: titleText.bottom
				topMargin: designElements.vMargin15
			}
		}

		EditTextLabel {
			id: editDisplayCode
			anchors {
				left: titleText.left
				right: parent.right
				rightMargin: Math.round(74 * horizontalScaling)
				top: contentText.bottom
				topMargin: Math.round(25 * verticalScaling)
			}
			kpiPostfix: "editDisplayCode"
			labelText: qsTr("Displaycode")
			validator: RegExpValidator { regExp: /^[A-Za-z]{2,5}-[A-Za-z0-9]{3,12}-[A-Za-z0-9]{4,10}$/ }
			inputHints: Qt.ImhPreferLowercase
			showValidationIcon: true
			leftTextAvailableWidth: zipCodeExText.width + designElements.hMargin10
									+ Math.max(editDisplayCode.leftTextImplicitWidth, editZipCode.leftTextImplicitWidth)

			onInputAccepted: {
				if (!editZipCode.acceptableInput)
					editZipCode.setFocus(true);
			}
		}

		EditTextLabel {
			id: editZipCode
			kpiPostfix: "editZipCode"
			anchors {
				left: titleText.left
				top: editDisplayCode.bottom
				topMargin: designElements.vMargin10
				right: editDisplayCode.right
			}
			labelText: qsTr("ZIPcode")
			validator: RegExpValidator { regExp: /^[A-Za-z0-9 -]+$/ }
			inputHints: Qt.ImhPreferUppercase | Qt.ImhPreferNumbers
			maxLength: 10
			showValidationIcon: true
			leftTextAvailableWidth: editDisplayCode.leftTextAvailableWidth

			onInputAccepted: {
				if (!editDisplayCode.acceptableInput)
					editDisplayCode.setFocus(true)
			}

			Text {
				id : zipCodeExText
				anchors {
					right: parent.left
					rightMargin: (- editZipCode.leftTextAvailableWidth) - designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}

				font.family: qfont.italic.name
				font.pixelSize: qfont.bodyText
				text: qsTr("(1234 AB)")
			}
		}

		StandardButton {
			id: invitationButton
			anchors {
				top: editZipCode.bottom
				topMargin: designElements.vMargin10
				right: editZipCode.right
			}
			text: qsTr("Send invitation")
			topClickMargin: 7
			enabled: editDisplayCode.acceptableInput && editZipCode.acceptableInput

			onClicked: {
				editDisplayCode.setFocus(false);
				editZipCode.setFocus(false);
				showInvitationDialog();
			}
		}
	}

	Image {
		id: codeImage
		anchors {
			bottom: parent.bottom
			left: parent.left
			leftMargin: Math.round(37 * horizontalScaling)
		}
		source: "image://scaled/apps/benchmark/drawables/CodeDude.svg"
	}
}
