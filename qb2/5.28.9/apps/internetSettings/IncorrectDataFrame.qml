import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0

import "ActivationWizard.js" as ActWizJs;

WizardFrame {
	id: incorrectDataFrame
	// Page index: 4

	title: qsTr("title-incorrect-data")
	nextPage: 1
	previousPage: -1

	function initWizardFrame(data) {
		outcomeData = data

		if (app.activationInfo.activationCode !== "") {
			activationCodeLabel.prefilledText = app.activationInfo.activationCode
		}

		wizard.selector.visible = false
	}

	function saveActivationCode(text) {
		if (text) {
			var actInfo = app.activationInfo
			actInfo.activationCode = text
			app.activationInfo = actInfo

			wizard.selector.rightArrowClicked();
		}
	}

	Column {
		id: column
		spacing: designElements.vMargin10
		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: parent.width / 6
			right: parent.right
			rightMargin: parent.width / 6
		}

		Text {
			id: checkCodeLabel
			text: qsTr("check-code-label")
			anchors {
				left:  parent.left
				right: parent.right
			}
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.titleText
		}

		Text {
			id: checkCode
			text: qsTr("check-code-explanation")
			anchors {
				left:  parent.left
				right: parent.right
			}
			wrapMode: Text.WordWrap
			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name
			color: colors.text
		}


		EditTextLabel {
			id: activationCodeLabel
			width: parent.width
			labelText: qsTr("activation-code")
			showAcceptButton: true
			validator: RegExpValidator { regExp: /^[a-zA-Z0-9]{6,10}$/ }
			inputHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData

			onInputAccepted: saveActivationCode(inputText)
		}

		Rectangle {
			// Spacer pixel so we have double margin between the sections.
			id: spacer
			color: colors.none
			height: 1
			width: 1
		}

		Text {
			id: dataIncorrectLabel
			text: qsTr("data-incorrect-label")
			anchors {
				left:  parent.left
				right: parent.right
			}
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.titleText
		}

		Text {
			id: dataIncorrect
			text: qsTr("data-incorrect-explanation")
			anchors {
				left:  parent.left
				right: parent.right
			}
			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name
			color: colors.text
		}

		WarningBox {
			id: contactInfoBox
			autoHeight: true
			warningText: qsTr("service-center-info")
			warningIcon: "image://scaled/apps/internetSettings/drawables/call.svg"
			anchors {
				left: parent.left
				right: parent.right
			}
		}
	}
}
