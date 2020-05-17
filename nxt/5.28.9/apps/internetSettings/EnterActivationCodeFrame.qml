import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0

import "ActivationWizard.js" as ActWizJs;

WizardFrame {
	id: enterActivationCodeFrame
	// Page index: 0
	title: qsTr("title-enter-activation-code")
	nextPage: 1
	previousPage: -1
	hasDataSelected: activationCodeLabel.acceptableInput
	clip: true

	QtObject {
		id: p

		// See _AC_* codes in InternetSettingsApp. Cannot set it
		// directly here through the 'app' reference, because this
		// reference is not initialized immediately when dynamically created.
		// This is now initialized in the onAppChanged handler.
		property int errorCode
		property string errorReason
	}

	onAppChanged: {
		p.errorCode = app._AC_NO_ERROR
		p.errorReason = ""
	}

	function initWizardFrame(data) {
		if (app.activationInfo.activationCode !== "") {
			activationCodeLabel.prefilledText = app.activationInfo.activationCode;
		}
		wizard.selector.visible = true;
		wizard.selector.leftArrowVisible = false;
		wizard.selector.rightArrowVisible = true;
		wizard.selector.rightArrowEnabled = Qt.binding(function () {
			return currentFrame.hasDataSelected;
		});

		p.errorCode   = (app.activationInfo.errorCode   !== undefined) ? app.activationInfo.errorCode   : app._AC_NO_ERROR;
		p.errorReason = (app.activationInfo.errorReason !== undefined) ? app.activationInfo.errorReason : "";
	}

	function saveActivationCode(text) {
		if (text) {
			var actInfo = app.activationInfo;
			actInfo.activationCode = text;
			app.activationInfo = actInfo;

			// activationScreen is in one of the ancestors for this frame, so
			// we can access it directly through its name.
			activationScreen.navigateToPage(nextPage);
		}
	}

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Qt.inputMethod.visible ? Math.round(-70 * verticalScaling) : Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			pixelSize: qfont.largeTitle
			family: qfont.semiBold.name
		}
		text: qsTr("activation-title")
		wrapMode: Text.WordWrap
		color: colors.text
	}

	Text {
		id: bodyText
		anchors {
			left: titleText.left
			right: titleText.right
			top: titleText.bottom
			topMargin: Math.round(40 * verticalScaling)
		}
		font{
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.text
		text: qsTr("activation-body")
		wrapMode: Text.WordWrap
	}

	EditTextLabel {
		id: activationCodeLabel
		anchors {
			left: bodyText.left
			right: bodyText.right
			top: bodyText.bottom
			topMargin: Math.round(40 * verticalScaling)
		}
		leftTextAvailableWidth: width * 0.3
		labelText: qsTr("activation-code")
		inputHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
		validator: RegExpValidator { regExp: /^[a-zA-Z0-9]{6,10}$/ }

		onInputAccepted: saveActivationCode(inputText)
	}

	Image {
		id: errorIcon
		anchors {
			top: activationCodeLabel.bottom
			topMargin: designElements.vMargin10
			left: activationCodeLabel.left
		}
		source: "qrc:/images/bad.svg"
	}

	Text {
		id: errorText
		anchors {
			left: errorIcon.right
			leftMargin: designElements.hMargin10
			right: activationCodeLabel.right
			baseline: errorIcon.verticalCenter
			baselineOffset: Math.round(5 * verticalScaling)
		}
		font{
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors._marypoppins
		wrapMode: Text.WordWrap
	}

	Text {
		id: helpText
		anchors {
			left: activationCodeLabel.left
			right: activationCodeLabel.right
			top: activationCodeLabel.bottom
			topMargin: Math.round(60 * verticalScaling)
		}
		font{
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.text
		text: qsTr("activation-help")
		wrapMode: Text.WordWrap
	}

	state: "default"
	states: [
		State {
			name: "default"
			when: (p.errorCode === app._AC_NO_ERROR)
			PropertyChanges { target: errorText; text: ""}
			PropertyChanges { target: errorIcon; visible: false}
		},
		State {
			name: "warningGetInfoInvalidCode"
			when: (p.errorCode === app._AC_INVALID_CODE)
			PropertyChanges { target: errorText; text: qsTr("explanation-get-info-invalid-code")}
		},
		State {
			name: "warningConnectionLost"
			when: (p.errorCode === app._AC_CONNECTION_LOST)
			PropertyChanges { target: errorText; text: qsTr("explanation-connection-lost")}
		},
		State {
			name: "warningRegisterFailed"
			when: (p.errorCode === app._AC_REGISTER_FAILED)
			PropertyChanges { target: errorText; text: qsTr("explanation-register-failed %1").arg(p.errorReason)}
		},
		State {
			name: "warningFailedUnknownReason"
			when: (p.errorCode === app._AC_FAILED_UNKNOWN_REASON)
			PropertyChanges { target: errorText; text: qsTr("explanation-failed-unknown-reason")}
		},
		State {
			name: "warningTimeoutUnknownReason"
			when: (p.errorCode === app._AC_TIMEOUT_UNKNOWN_REASON)
			PropertyChanges { target: errorText; text: qsTr("explanation-timeout-unknown-reason")}
		}
	]
}
