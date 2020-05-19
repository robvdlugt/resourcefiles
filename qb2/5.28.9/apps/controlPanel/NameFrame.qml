import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	title: qsTr("Name the plug")
	nextPage: 2
	hasDataSelected: editText.acceptableInput

	function initWizardFrame() {
		editText.prefilledText = plugName;
	}

	Text {
		id: text
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: editText.left
			right: editText.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.plugTabText
		text: qsTr("name_frame_text")
		wrapMode: Text.WordWrap
	}

	EditTextLabel {
		id: editText
		anchors {
			top: text.bottom
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(480 * horizontalScaling)
		labelText: qsTr("Name")
		maxLength: 13
		validator: RegExpValidator { regExp: /.+/ } // empty name is not allowed

		onInputEdited: {
			if (acceptableInput)
				plugName = inputText;
		}

	}
}
