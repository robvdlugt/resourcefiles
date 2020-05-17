import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

BenchmarkWizardFrame {
	id: nameFrame

	function initWizardFrame(name) {
		if (name !== undefined) {
			editText.prefilledText = name;
		}
	}

	title: qsTr("Name screen")
	nextPage: 6
	hasDataSelected: editText.acceptableInput
	outcomeData: editText.inputText

	Text {
		id: titleText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			left: editText.left
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.semiBold.name
		}
		color: colors.nameTitle
		text: feature.featBenchmarkFriendsEnabled() ? qsTr("name_title") : qsTr("name_title", "no_friends")
	}

	Text {
		id: bodyText
		anchors {
			baseline: titleText.bottom
			baselineOffset: Math.round(33 * verticalScaling)
			left: titleText.left
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.nameBody
		text: feature.featBenchmarkFriendsEnabled() ? qsTr("name_body") : qsTr("name_body", "no_friends")
	}

	EditTextLabel {
		id: editText
		anchors {
			top: bodyText.bottom
			topMargin: designElements.vMargin15
			horizontalCenter: parent.horizontalCenter
		}
		labelText: qsTr("Name")
		maxLength: 15
		validator: RegExpValidator { regExp: /\S{2,}.*/ } // at least 2 chars
	}

	Text {
		id: infoText
		anchors {
			top: editText.bottom
			topMargin: designElements.vMargin15
			left: editText.left
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.nameBody
		text: qsTr("name_info")
	}
}
