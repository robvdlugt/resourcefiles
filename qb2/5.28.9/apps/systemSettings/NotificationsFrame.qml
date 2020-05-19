import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: notificationsFrame
	anchors.fill: parent

	onShown: {
		phoneNumber1.inputText = app.eventUserInfo["phone1"];
		phoneNumber2.inputText = app.eventUserInfo["phone2"];
	}

	onHidden: {
		qtUtils.clearFocus();
	}

	Column {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		Item {
			width: parent.width
			height: childrenRect.height

			Text {
				id: titleText
				anchors {
					left: parent.left
					right: infoButton.left
					rightMargin: designElements.hMargin6
				}
				font {
					pixelSize: qfont.bodyText
					family: qfont.regular.name
				}
				wrapMode: Text.WordWrap
				text: qsTr("notification-intro-no-email")
			}

			IconButton {
				id: infoButton
				anchors {
					top: parent.top
					right: parent.right
				}
				iconSource: "qrc:/images/info.svg"
				onClicked: qdialog.showDialog(qdialog.SizeLarge, qsTr("notication-popup-title"), qsTr("notication-popup-content-no-email"))
			}
		}

		Item {
			id: spacer
			width: parent.width
			height: designElements.vMargin10
		}

		EditTextLabel {
			id: phoneNumber1
			width: parent.width
			labelText: qsTr("Phone 1")
			prefilledText: app.eventUserInfo["phone1"]
			leftTextAvailableWidth: width * 0.6
			inputHints: Qt.ImhDigitsOnly
			showAcceptButton: true
			showValidationIcon: true
			validator: RegExpValidator { regExp: /^$|06\d{8}/ } // TODO: make this based on country

			onInputAccepted: app.saveUserContactInfo(inputText, true)
		}

		EditTextLabel {
			id: phoneNumber2
			width: parent.width
			labelText: qsTr("Phone 2")
			prefilledText: app.eventUserInfo["phone2"]
			leftTextAvailableWidth: width * 0.6
			inputHints: Qt.ImhDigitsOnly
			showAcceptButton: true
			showValidationIcon: true
			validator: RegExpValidator { regExp: /^$|06\d{8}/ } // TODO: make this based on country

			onInputAccepted: app.saveUserContactInfo(inputText, false)
		}

		Item {
			id: spacer2
			width: parent.width
			height: Math.round(18 * verticalScaling)
		}

		WarningBox {
			width: parent.width
			height: Math.round(70 * verticalScaling)
			warningText: qsTr("notification-warning-text")
			warningIcon: ""

		}
	}
}
