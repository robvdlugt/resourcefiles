import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: nameFrame
	title: qsTr("Name your smoke detector")
	imageSource: "drawables/sd-name.svg"
	property bool canContinue: editText.acceptableInput

	onNext: app.setDeviceName(editText.inputText)

	Text {
		id: bodyText
		width: parent.width
		anchors.top: parent.top
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("name_smokedetector_1")
	}

	EditTextLabel {
		id: editText
		anchors {
			top: bodyText.bottom
			topMargin: designElements.vMargin10
			left: bodyText.left
			right: bodyText.right
		}
		labelText: qsTr("Name")
		maxLength: 20
		validator: RegExpValidator { regExp: /^\S.*$/ } // empty name is not allowed
	}

	WarningBox {
		anchors {
			top: editText.bottom
			topMargin: designElements.vMargin20
			left: bodyText.left
			right: bodyText.right
		}
		autoHeight: true

		warningText: qsTr("name_smokedetector_tip")
		warningIcon: ""
	}
}
