import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: alertFrame
	anchors.fill: parent

	QtObject {
		id: p

		property string phone1: ""
		property string phone2: ""
	}

	onShown: {
		updateContactPreferences();
	}

	function updateContactPreferences() {
		p.phone1 = app.eventUserInfo["phone1"] ? app.eventUserInfo["phone1"] : "";
		p.phone2 = app.eventUserInfo["phone2"] ? app.eventUserInfo["phone2"] : "";

		var enableVoice = app.eventUserContactPref["enableVoice"] ? app.eventUserContactPref["enableVoice"] : false;
		var enableText = app.eventUserContactPref["enableText"] ? app.eventUserContactPref["enableText"] : false;
		var phone1TextEnabled = app.eventUserContactPref["textPhone1"];
		var phone2TextEnabled = app.eventUserContactPref["textPhone2"];
		var phone1VoiceEnabled = app.eventUserContactPref["voicePhone1"];
		var phone2VoiceEnabled = app.eventUserContactPref["voicePhone2"];

		var smsBottomText = qsTr("No number configured");
		var voiceBottomText = qsTr("No number configured");

		// Build sms string
		if (phone1TextEnabled && p.phone1 && phone2TextEnabled && p.phone2)
			smsBottomText = p.phone1 + ", " + p.phone2;
		else if (phone1TextEnabled && p.phone1)
			smsBottomText = p.phone1;
		else if (phone2TextEnabled && p.phone2)
			smsBottomText = p.phone2;

		// Build voice string
		if (phone1VoiceEnabled && p.phone1 && phone2VoiceEnabled && p.phone2)
			voiceBottomText = p.phone1 + ", " + p.phone2;
		else if (phone1VoiceEnabled && p.phone1)
			voiceBottomText = p.phone1;
		else if (phone2VoiceEnabled && p.phone2)
			voiceBottomText = p.phone2;

		alertSMSLabel.bottomText = smsBottomText;
		if ((phone1TextEnabled && p.phone1) || (phone2TextEnabled && p.phone2)) {
			onOffSMSToggle.enabled = true;
			onOffSMSToggle.isSwitchedOn = enableText;
		} else {
			onOffSMSToggle.enabled = false;
			onOffSMSToggle.isSwitchedOn = false;
		}

		alertVoiceCallLabel.bottomText = voiceBottomText;
		if (phone1VoiceEnabled && p.phone1 || phone2VoiceEnabled && p.phone2) {
			onOffVoiceCallToggle.enabled = true;
			onOffVoiceCallToggle.isSwitchedOn = enableVoice;
		} else {
			onOffVoiceCallToggle.enabled = false;
			onOffVoiceCallToggle.isSwitchedOn = false;
		}
	}

	Text {
		id: titleText

		text: qsTr("alert-frame-title")

		color: colors.smokedetectorTitle
		font {
			pixelSize: qfont.titleText
			family: qfont.semiBold.name
		}

		anchors {
			left: alertFrame.left
			leftMargin: Math.round(50 * horizontalScaling)
			right: alertFrame.right
			rightMargin: anchors.leftMargin
			baseline: alertFrame.top
			baselineOffset: Math.round(50 * verticalScaling)
		}
	}

	Text {
		id: contentText
		width: Math.round(450 * horizontalScaling)

		text: qsTr("alert-frame-content")
		wrapMode: Text.WordWrap

		color: colors.smokedetectorBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			left: titleText.left
			right: titleText.right
			top: titleText.bottom
			topMargin: designElements.vMargin10
		}
	}

	DoubleLabel {
		id: alertVoiceCallLabel

		anchors {
			top: contentText.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: titleText.left
			right: editAlertVoicecall.left
			rightMargin: designElements.hMargin6
		}

		topText: qsTr("Alert with Voicecall")

		OnOffToggle {
			id: onOffVoiceCallToggle

			rightTextOn: qsTr('On')
			leftTextOff: qsTr('Off')

			anchors {
				right: parent.right
				rightMargin: designElements.hMargin5
				top: parent.top
				topMargin: designElements.vMargin5
			}

			onIsSwitchedOnChanged: {
				if (isSwitchedOn !== app.eventUserContactPref["enableVoice"]) {
					app.setVoiceTextEnabled(true, isSwitchedOn);
				}
			}
		}
	}

	IconButton {
		id: editAlertVoicecall

		anchors {
			top: alertVoiceCallLabel.top
			right: titleText.right
		}

		iconSource: "qrc:/images/edit.svg"

		onClicked: {
			if (app.checkWarnEmptyPhoneNumbers()) {
				stage.openFullscreen(app.notificationPreferencesScreenUrl, {isVoice: true});
			}
		}
	}

	DoubleLabel {
		id: alertSMSLabel

		anchors {
			top: alertVoiceCallLabel.bottom
			topMargin: designElements.vMargin6
			left: titleText.left
			right: editAlertSMS.left
			rightMargin: designElements.hMargin6
		}

		topText: qsTr("Alert with SMS")

		OnOffToggle {
			id: onOffSMSToggle

			rightTextOn: qsTr('On')
			leftTextOff: qsTr('Off')

			anchors {
				right: parent.right
				rightMargin: designElements.hMargin5
				top: parent.top
				topMargin: designElements.vMargin5
			}

			onIsSwitchedOnChanged: {
				if (isSwitchedOn !== app.eventUserContactPref["enableText"])	{
					app.setVoiceTextEnabled(false, isSwitchedOn);
				}
			}
		}
	}

	IconButton {
		id: editAlertSMS

		anchors {
			top: alertSMSLabel.top
			right: titleText.right
		}

		iconSource: "qrc:/images/edit.svg"

		onClicked: {
			if (app.checkWarnEmptyPhoneNumbers()) {
				stage.openFullscreen(app.notificationPreferencesScreenUrl, {isVoice: false});
			}
		}
	}
}
