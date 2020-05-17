import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

WizardFrame {
	id: sendActivationCodeFrame
	// Page index: 3

	title: qsTr("title-activating-your-product")
	nextPage: 5
	previousPage: 2

	// Private properties
	QtObject {
		id: p

		property int timeoutInterval: 40000 //msec
	}

	function initWizardFrame(data) {
		outcomeData = data

		wizard.selector.visible = true
		wizard.selector.leftArrowVisible = false
		wizard.selector.rightArrowVisible = false

		console.log("Sending activation request")
		startActivationTimeout()
		sendRegisterQuby()
	}

	function sendRegisterQuby() {
		var activationCode = app.activationInfo.activationCode
		console.log("Sending request to register activation code:", activationCode)
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, app.scsyncUuid, "specific1", "RegisterQuby")
		msg.addArgument("CustomerVerificationCode", activationCode);
		bxtClient.sendMsg(msg)
	}

	function navigateBackWithError(_errorCode, _reason) {
		var actInfo = app.activationInfo
		actInfo.errorCode = _errorCode
		actInfo.errorReason = _reason
		app.activationInfo = actInfo
		wizard.selector.navigateBtn(0)
	}

	Component.onDestruction: {
		console.log("Destroying SendActivationCodeFrame. Stopping timeout timer.")
		stopActivationTimeout()
	}

	Text {
		id: sendActivationText
		anchors.bottom: throbber.top
		anchors.bottomMargin: designElements.vMargin20
		anchors.horizontalCenter: parent.horizontalCenter

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		color: colors.text

		text: qsTr("activating-your-product")
	}

	Throbber {
		id: throbber
		anchors {
			centerIn: parent
		}
	}

	// Timer stuff for the "RegisterQuby" call

	function startActivationTimeout() {
		activationTimeout.restart()
	}

	function stopActivationTimeout() {
		activationTimeout.stop()
	}

	Timer {
		id: activationTimeout
		interval: p.timeoutInterval
		onTriggered: {
			console.log("Timeout during activation.")
			wizard.selector.navigateBtn(previousPage)
		}
	}


	/*
	Response has the following components:
	<Success>			true
	<Reason>			Success
	<ReasonDetails>		Success
	<CustomerName>		van Putten
	*/
	property variant reasonMapping: {
		""           : qsTr("msg-unknown-reason"),
		"dataInvalid": qsTr("msg-code-invalid"),
		"noInternet" : qsTr("msg-connection-lost"),
		"Timeout"    : qsTr("msg-connection-lost"),
		"UNKNOWN_DEVICE": qsTr("msg-unknown-device"),
		"INVALID_STATUS_CHANGE" : qsTr("msg-invalid-status-change")
	}

	BxtResponseHandler {
		response: "RegisterQubyResponse"
		onResponseReceived: {
			var success = message.getArgument("Success") === "true"

			console.log("RegisterQuby callback returns message: ", message, message.stringContent)
			console.log("Reason: ", message.getArgument("Reason"))
			console.log("ReasonDetails: ", message.getArgument("ReasonDetails"))
			console.log("CustomerName: ", message.getArgument("CustomerName"))

			if (message.getArgument("Reason") === "AlreadyActivated") {
				success = true
			}

			if (success === false && typeof activationIgnoreFailure !== 'undefined') {
				console.log("Ignoring activation failure because of environment setting override. (ACTIVATION_IGNORE_FAILURE)")
				success = true
			}

			if (success) {
				var actInfo = app.activationInfo
				actInfo.errorCode = app._AC_NO_ERROR
				app.activationInfo = actInfo

				wizard.selector.navigateBtn(nextPage)
			} else {
				console.log("Could not activate with activation code: ", app.activationInfo.activationCode)
				var reason = message.getArgument("Reason")
				if (!(reason in reasonMapping)) {
					reason = ""
				}
				navigateBackWithError(app._AC_REGISTER_FAILED, reasonMapping[reason])
			}
		}
	}
}
