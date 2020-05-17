import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	id: confirmActivationFrame
	// Page index: 2

	title: qsTr("Confirm your details")

	nextPage: 3
	previousPage: 0

	property string nameDetails: ""        //"Q. Uby"
	property string addressDetails1: ""    //"Straatweg 3A"
	property string addressDetails2: ""    //"3030 AZ Rotterdam"

	function initWizardFrame(_data) {
		wizard.selector.visible = true
		wizard.selector.leftArrowVisible = true
		wizard.selector.rightArrowVisible = true

		var data = app.activationInfo

		// Fill in data from response
		nameDetails = [data.firstName, data.insert, data.lastName].join(" ")
		addressDetails1 = data.streetName + " " + data.houseNumber + data.houseNumberExtension
		addressDetails2 = [data.zipCode, data.city].join(" ")
	}

	Text {
		id: titleText
		text: qsTr("your-details")

		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
		color: colors.titleText

		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: parent.width / 4
			right: parent.right
			rightMargin: parent.width / 4
		}
	}

	Text {
		id: nameDetailsTitle
		text: qsTr("name-label")
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		color: colors.text

		anchors {
			top: titleText.bottom
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: parent.width / 4
			right: parent.right
			rightMargin: parent.width / 4
		}
	}

	SingleLabel {
		id: nameLabel

		leftText: nameDetails
		leftTextFormat: Text.PlainText // Prevent XSS/HTML injection

		anchors {
			top: nameDetailsTitle.bottom
			topMargin: designElements.vMargin6
			left: nameDetailsTitle.left
			right: nameDetailsTitle.right
		}
	}

	Image {
		id: personImg
		source: "image://scaled/apps/internetSettings/drawables/person.svg"
		anchors {
			right: nameDetailsTitle.left
			rightMargin: designElements.hMargin10
			bottom: nameLabel.bottom
		}
	}

	Text {
		id: addressDetailsTitle
		text: qsTr("address-label")
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		color: colors.text

		anchors {
			top: nameLabel.bottom
			topMargin: designElements.vMargin20
			left: nameLabel.left
			right: nameLabel.right
		}
	}

	SingleLabel {
		id: addressLabel
		// Height = implicit height of the two lines of text + margin. The margin we derive from the other SingleLabel
		height: leftTextHeight + (nameLabel.height - nameLabel.leftTextHeight)

		leftText: qtUtils.escapeHtml(addressDetails1) + "<br>" + qtUtils.escapeHtml(addressDetails2) // Prevent XSS/HTML injection by using qtUtils.escapeHtml

		anchors {
			top: addressDetailsTitle.bottom
			topMargin: designElements.vMargin6
			left: addressDetailsTitle.left
			right: addressDetailsTitle.right
		}
	}

	Image {
		id: houseImg
		source: "image://scaled/apps/internetSettings/drawables/house.svg"

		anchors {
			right: addressDetailsTitle.left
			rightMargin: designElements.hMargin10
			bottom: addressLabel.bottom
		}
	}

	StandardButton {
		id: confirmBtn
		text: qsTr("Confirm")

		anchors {
			right: addressLabel.right
			top: addressLabel.bottom
			topMargin: designElements.vMargin10
		}

		onClicked: {
			wizard.selector.navigateBtn(nextPage)
		}
	}

	StandardButton {
		id: incorrectBtn
		text: qsTr("Incorrect")

		anchors {
			right: confirmBtn.left
			rightMargin: designElements.hMargin10
			verticalCenter: confirmBtn.verticalCenter
		}

		onClicked: {
			// Navigate to "IncorrectDataFrame"
			wizard.selector.navigateBtn(4)
		}
	}
}
