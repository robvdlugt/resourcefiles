import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0

EditScreen {
	id: root

	property string noPhoneNumberString: qsTr("boiler_phone_number_no_number")

	screenTitle: qsTr("boiler_phone_number_title")

	onScreenShown: {
		contactOption1Checkbox.selected = (app.userContactInfo["phone1"] !== "" && app.contactInfo["phoneNumber1Selected"]);
		contactOption2Checkbox.selected = (app.userContactInfo["phone2"] !== "" && app.contactInfo["phoneNumber2Selected"]);
	}

	onScreenSaved: {
		app.setBoilerPhoneNumber(contactOption1Checkbox.selected, contactOption2Checkbox.selected, root);
	}

	function openPhoneNumberEditScreen() {
		stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/settings/SettingsScreen.qml"), {categoryUrl: Qt.resolvedUrl("qrc:/apps/systemSettings/NotificationsFrame.qml")});
	}

	Text {
		id: phoneNumberHeader
		anchors {
			top: parent.top
			topMargin: Math.round(43 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}
		width: Math.round(600 * horizontalScaling)
		wrapMode: Text.WordWrap
		text: qsTr("boiler_phone_number_header")
		color: colors._harry
	}

	Text {
		id: phoneNumberSubHeader
		anchors {
			top: phoneNumberHeader.bottom
			topMargin: Math.round(10 * verticalScaling)
			left: phoneNumberHeader.left
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		width: phoneNumberHeader.width
		wrapMode: Text.WordWrap
		text: qsTr("boiler_phone_number_sub_header")
		color: colors._harry
	}

	Column {
		id: contactOptionsColumn
		width: Math.round(555 * horizontalScaling)
		anchors {
			top: phoneNumberSubHeader.bottom
			topMargin: Math.round(20 * verticalScaling)
			left: phoneNumberHeader.left
		}
		spacing: designElements.spacing8

		StandardCheckBox {
			id: contactOption1Checkbox
			width: parent.width
			text: app.userContactInfo["phone1"] !== "" ? app.userContactInfo["phone1"] : noPhoneNumberString
			fontFamilyUnselected: text === noPhoneNumberString ? qfont.italic.name : qfont.regular.name
			leftClickMargin: 0
			onTextChanged: selected = (text !== noPhoneNumberString)

			MouseArea {
				anchors.fill: parent
				enabled: parent.text === noPhoneNumberString

				onClicked: openPhoneNumberEditScreen();
			}

			IconButton {
				width: designElements.buttonSize
				anchors {
					top: parent.top
					left: parent.right
					leftMargin: Math.round(5 * horizontalScaling)
				}
				iconSource: parent.text === noPhoneNumberString ? "qrc:/images/plus_add.svg" : "qrc:/images/edit.svg"

				onClicked: openPhoneNumberEditScreen();
			}
		}

		StandardCheckBox {
			id: contactOption2Checkbox
			width: parent.width
			text: app.userContactInfo["phone2"] !== "" ? app.userContactInfo["phone2"] : noPhoneNumberString
			fontFamilyUnselected: text === noPhoneNumberString ? qfont.italic.name : qfont.regular.name
			onTextChanged: selected = text !== noPhoneNumberString
			// Make invisible when both phone numbers are empty
			visible: text !== noPhoneNumberString || contactOption1Checkbox.text !== noPhoneNumberString
			leftClickMargin: 0
			onVisibleChanged: selected = (visible ? selected : false)

			StyledRectangle {
				anchors.fill: parent
				color: colors.none
				visible: parent.text === noPhoneNumberString
				onClicked: openPhoneNumberEditScreen();
			}

			IconButton {
				width: designElements.buttonSize
				anchors {
					top: parent.top
					left: parent.right
					leftMargin: Math.round(5 * horizontalScaling)
				}
				iconSource: parent.text === noPhoneNumberString ? "qrc:/images/plus_add.svg" : "qrc:/images/edit.svg"

				onClicked: openPhoneNumberEditScreen();
			}
		}
	}

	WarningBox {
		id: infoBox
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(35 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(640 * horizontalScaling)
		height: Math.round(86 * verticalScaling)

		warningText: qsTr("boiler_use_your_number")
		warningIcon: Qt.resolvedUrl("qrc:/images/info_warningbox.svg")
	}
}
