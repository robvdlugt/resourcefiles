import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root
	screenTitle: qsTranslate("SecurityTab", "PIN code")
	hasCancelButton: true
	property ControlPanelApp app

	QtObject {
		id: p
		property string currentPin
		property string newPin

		function verifyPinCallback(success, reason) {
			if (success) {
				root.state = "NEW_PIN";
			} else {
				p.currentPin = "";
				if (reason === "max-pin-retries") {
					pinState.state = "ERROR";
					pinKeyboard.wrongPin();
					pinTitleText.text = qsTr("Maximum number of retries reached!")
					util.delayedCall(5000, root.hide);
				} else if (reason === "wrong-pin") {
					pinState.state = "WRONG";
					pinKeyboard.wrongPin();
				} else {
					pinState.state = "ERROR";
				}
			}
		}

		function setPinCallback(success, reason) {
			if (success) {
				pinState.state = "SET";
				app.alarmPinIsSet = true;
			} else {
				if (reason === "max-pin-retries") {
					pinState.state = "WRONG";
					pinKeyboard.wrongPin();
					pinTitleText.text = qsTr("Maximum number of retries reached!")
					util.delayedCall(5000, root.hide);
				} else {
					pinState.state = "ERROR";
					pinTitleText.text = qsTr("Error setting your new PIN!")
				}
			}
		}
	}

	onCustomButtonClicked: hide()

	Component.onCompleted: {
		root.state = app.alarmPinIsSet ? "CURRENT_PIN" : "NEW_PIN";
		addCustomTopRightButton(qsTr("Done"));
		disableCustomTopRightButton();
	}

	Text {
		id: pinTitleText
		anchors {
			bottom: pinKeyboard.top
			bottomMargin: designElements.vMargin10
			horizontalCenter: pinKeyboard.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}
		color: colors.alarmPanelStateText
		text: qsTr("Enter your current PIN code").arg(colors.alarmPanelTextHighlight.toString())
	}

	NumericKeyboard {
		id: pinKeyboard
		anchors.centerIn: parent
		buttonWidth: Math.round(60 * verticalScaling)
		buttonHeight: Math.round(50 * verticalScaling)
		buttonSpace: designElements.vMargin10
		pinMode: true
		maxTextLength: 4

		onPinEntered: {
			switch(root.state) {
			case "CURRENT_PIN":
				pinState.state = "BUSY";
				p.currentPin = pin;
				app.verifyAlarmPinCode(pin, p.verifyPinCallback);
				break;
			case "NEW_PIN":
				p.newPin = pin;
				continueBtn.enabled = true;
				break;
			case "REENTER_NEW_PIN":
				if (pin === p.newPin) {
					pinState.state = "BUSY";
					app.setAlarmPinCode(p.currentPin, p.newPin, p.setPinCallback);
				} else {
					pinState.state = "WRONG";
					pinKeyboard.wrongPin();
				}
				break;
			}
			var doNotRemoveMeQtQuick1Bug = true; // https://bugreports.qt.io/browse/QTBUG-26904
		}
		onDigitEntered: {
			if (pinState.state === "WRONG")
				pinState.state = "";
		}
		onNumberLengthChanged: {
			if (numberLength < maxTextLength)
				continueBtn.enabled = false;
		}
	}

	Throbber {
		id: pinThrobber
		width: height
		height: Math.round(30 * verticalScaling)
		anchors {
			top: pinKeyboard.top
			topMargin: designElements.vMargin10
			left: pinKeyboard.right
			leftMargin: designElements.hMargin10
		}
		visible: false

		smallRadius: 1.5
		mediumRadius: 2
		largeRadius: 2.5
		bigRadius: 3
	}

	Image {
		id: pinIcon
		anchors.centerIn: pinThrobber
		visible: false
		height: Math.round(24 * verticalScaling)
		sourceSize.height: height
	}

	StandardButton {
		id: continueBtn
		anchors {
			top: pinKeyboard.bottom
			topMargin: pinKeyboard.buttonSpace
			left: pinKeyboard.left
			right: pinKeyboard.right
		}
		text: qsTr("Confirm")
		primary: true
		visible: false

		onClicked: {
			if (root.state === "NEW_PIN") {
				root.state = "REENTER_NEW_PIN"
			}
		}
	}

	Item {
		id: pinState
		states: [
			State {
				name: "BUSY"
				PropertyChanges { target: pinKeyboard; enabled: false }
				PropertyChanges { target: pinThrobber; visible: true }
				PropertyChanges { target: pinIcon; visible: false}
			},
			State {
				name: "WRONG"
				PropertyChanges { target: pinKeyboard; enabled: true }
				PropertyChanges { target: pinThrobber; visible: false}
				PropertyChanges { target: pinIcon; visible: true; source: "qrc:/images/bad.svg" }
			},
			State {
				name: "SET"
				PropertyChanges { target: pinKeyboard; enabled: false }
				PropertyChanges { target: pinThrobber; visible: false}
				PropertyChanges { target: pinIcon; visible: true; source: "qrc:/images/good.svg" }
				PropertyChanges { target: pinTitleText; text: qsTr("Your PIN code is all set!") }
				StateChangeScript { script: { enableCustomTopRightButton(); disableCancelButton() } }
			},
			State {
				name: "ERROR"
				PropertyChanges { target: pinKeyboard; enabled: false }
				PropertyChanges { target: pinThrobber; visible: false}
				PropertyChanges { target: pinIcon; visible: true; source: "qrc:/images/bad.svg" }
			}
		]
	}

		states: [
		State {
			name: "CURRENT_PIN"
		},
		State {
			name: "NEW_PIN"
			PropertyChanges { target: pinTitleText; text: qsTr("Enter your new PIN code").arg(colors.alarmPanelTextHighlight.toString()) }
			PropertyChanges { target: continueBtn; enabled: false; visible: true }
			StateChangeScript { script: pinKeyboard.clear() }
			PropertyChanges { target: pinState; state: "" }
		},
		State {
			name: "REENTER_NEW_PIN"
			PropertyChanges { target: pinTitleText; text: qsTr("Enter your new PIN code again").arg(colors.alarmPanelTextHighlight.toString()) }
			PropertyChanges { target: continueBtn; visible: false }
			StateChangeScript { script: pinKeyboard.clear() }
			PropertyChanges { target: pinState; state: "" }
		}
	]
}
