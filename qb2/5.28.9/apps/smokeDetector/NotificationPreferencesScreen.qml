import QtQuick 2.1
import BasicUIControls 1.0;

import qb.base 1.0
import qb.components 1.0

Screen {
	id: notificationPreferencesScreen

	property SmokeDetectorApp app

	QtObject {
		id: p
		property bool isVoice
		property string option1: ""
		property string option2: ""
	}

	screenTitle: qsTr("Select phonenumbers")
	anchors.fill: parent
	isSaveCancelDialog: true

	onShown: {
		if (args) {
			p.isVoice = (args.isVoice === true);
		}

		p.option1 = app.eventUserInfo["phone1"];
		p.option2 = app.eventUserInfo["phone2"];

		if (p.isVoice) {
			notificationOption1Checkbox.selected = app.eventUserContactPref["voicePhone1"] && app.eventUserInfo["phone1"];
			notificationOption2Checkbox.selected = app.eventUserContactPref["voicePhone2"] && app.eventUserInfo["phone2"];
		} else {
			notificationOption1Checkbox.selected = app.eventUserContactPref["textPhone1"] && app.eventUserInfo["phone1"];
			notificationOption2Checkbox.selected = app.eventUserContactPref["textPhone2"] && app.eventUserInfo["phone2"];
		}
	}

	onSaved: {
		var phone1 = (notificationOption1Checkbox.visible && notificationOption1Checkbox.selected);
		var phone2 = (notificationOption2Checkbox.visible && notificationOption2Checkbox.selected);
		app.setVoiceTextPref(p.isVoice, phone1, phone2);
	}

	Text {
		id: titleText

		text: qsTr("notification-preferences-screen-title")

		color: colors.smokedetectorTitle
		font {
			pixelSize: qfont.titleText
			family: qfont.semiBold.name
		}

		anchors {
			left: parent.left
			leftMargin: Math.round(160 * horizontalScaling)
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
		}
	}

	Text {
		id: contentText
		width: Math.round(450 * horizontalScaling)

		text: qsTr("notification-preferences-screen-content")
		wrapMode: Text.WordWrap

		color: colors.smokedetectorBody
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

	ControlGroup {
		id: notificationOptionsGroup
		exclusive: false
	}

	Column {
		id: notificationOptionsColumn

		width: Math.round(445 * horizontalScaling)
		anchors {
			top: contentText.baseline
			topMargin: Math.round(40 * verticalScaling)
			left: titleText.left
		}
		spacing: designElements.spacing8

		StandardCheckBox {
			id: notificationOption1Checkbox
			width: parent.width
			controlGroupId: 0
			controlGroup: notificationOptionsGroup
			text: p.option1
			visible: p.option1 !== ""
		}

		StandardCheckBox {
			id: notificationOption2Checkbox
			width: parent.width
			controlGroupId: 1
			controlGroup: notificationOptionsGroup
			text: p.option2
			visible: p.option2 !== ""
		}
	}

	Text {
		id: bottomText
		width: contentText.width

		text: qsTr("notification-preferences-screen-bottom")
		wrapMode: Text.WordWrap

		color: colors.smokedetectorBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			left: titleText.left
			top: notificationOptionsColumn.bottom
			topMargin: Math.round(50 * verticalScaling)
		}
	}
}
