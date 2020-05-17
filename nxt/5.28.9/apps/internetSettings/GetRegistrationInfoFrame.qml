import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0

WizardFrame {
	id: getRegistrationInfoFrame
	// Page index: 1

	title: qsTr("title-retrieving-your-information")

	nextPage: 2
	previousPage: 0

	// Private properties
	QtObject {
		id: p

		property string activationCode
		property int timeoutInterval: 40000 //msec
	}

	function initWizardFrame(data) {
		p.activationCode = app.activationInfo.activationCode
		if (p.activationCode === undefined || p.activationCode === "") {
			console.log("Error: No activation code passed to GetRegistrationInfoFrame!")
		}

		wizard.selector.visible = true
		wizard.selector.leftArrowVisible = false
		wizard.selector.rightArrowVisible = false

		console.log("Sending request for activation info:", p.activationCode)
		sendGetInfoForActCode()
	}

	function sendGetInfoForActCode() {
		startGetInfoTimeout()
		console.log("Sending request for information associated with activation code:", p.activationCode)
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, app.scsyncUuid, "specific1", "GetInfoForActCode")
		msg.addArgument("activationCode", p.activationCode);
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
		console.log("Destroying GetRegistrationInfoFrame. Stopping timeout timer.")
		stopGetInfoTimeout()
	}

	Text {
		id: verifyActivationText
		anchors.bottom: throbber.top
		anchors.bottomMargin: designElements.vMargin20
		anchors.horizontalCenter: parent.horizontalCenter

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		color: colors.text

		text: qsTr("retrieving-your-information")
	}

	Throbber {
		id: throbber
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: parent.height * 2 / 5
	}

	// Timer stuff for the "GetInfoForActCode" call
	function startGetInfoTimeout() {
		getInfoTimeout.restart()
	}

	function stopGetInfoTimeout() {
		getInfoTimeout.stop()
	}

	Timer {
		id: getInfoTimeout
		interval: p.timeoutInterval
		onTriggered: {
			console.log("Timeout during retrieving registration information.")
			navigateBackWithError(app._AC_TIMEOUT_UNKNOWN_REASON)
		}
	}

/*
  Response has the following components:
   <Success>		true
   <firstName>		roy
   <insert>
   <lastName>		van Putten
   <streetName>		Joan Muyskenweg
   <houseNumber>	22
   <houseNumberExtension>	A
   <zipCode>		1096CJ
   <city>			AMSTERDAM
   <productVariant>	Toon
*/
	BxtResponseHandler {
		response: "GetInfoForActCodeResponse"
		onResponseReceived: {
			var success = message.getArgument("Success") === "true"

			console.log("GetInfoForActCode callback returns message: ", message, message.stringContent)

			if (success === false && typeof activationIgnoreFailure !== 'undefined') {
				console.log("Ignoring activation failure because of environment setting override. (ACTIVATION_IGNORE_FAILURE)")
				success = true
			}

			if (success) {
				var actInfo = app.activationInfo
				actInfo.firstName = message.getArgument("firstName")
				actInfo.insert = message.getArgument("insert")
				actInfo.lastName = message.getArgument("lastName")
				actInfo.streetName = message.getArgument("streetName")
				actInfo.houseNumber = message.getArgument("houseNumber")
				actInfo.houseNumberExtension = message.getArgument("houseNumberExtension")
				actInfo.zipCode = message.getArgument("zipCode")
				actInfo.city = message.getArgument("city")
				actInfo.productVariant = message.getArgument("productVariant")
				app.activationInfo = actInfo

				wizard.selector.navigateBtn(nextPage)
			} else {
				// Invalid activation code, return to previous page
				console.log("Could not retrieve information for activation code: ", p.activationCode)
				var errorCode
				if (message.getArgument("Reason") === "Timeout") {
					errorCode = app._AC_CONNECTION_LOST
				} else {
					errorCode = app._AC_INVALID_CODE
				}
				navigateBackWithError(errorCode)
			}
		}
	}
}
