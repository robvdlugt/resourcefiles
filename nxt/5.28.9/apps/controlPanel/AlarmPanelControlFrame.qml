import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: alarmPanelControlFrame

	property variant _ALARM_STATE: {
		"ARMED": 0,
		"PARTIAL": 1,
		"DISARMED": 2
	}

	QtObject {
		id: p
		property url iconHouseUrl: "image://scaled/apps/controlPanel/drawables/alarmPanel_disarmed.svg"
		property url iconArmedUrl: "image://scaled/apps/controlPanel/drawables/alarmPanel_armed.svg"
		property url iconDisarmedUrl: "image://scaled/apps/controlPanel/drawables/alarmPanel_disarmed.svg"
		property url iconNightUrl: "image://scaled/apps/controlPanel/drawables/alarmPanel_night.svg"
		property url iconErrorUrl: "image://scaled/apps/controlPanel/drawables/alarmPanel_error.svg"
		property string pinStatusText

		function setStateText(text) {
			stateText.text = text.arg(colors.alarmPanelTextHighlight.toString());
		}

		function cancelPinEntry(noUpdate) {
			if (!noUpdate)
				update();
			container.showPage(0);
			pinPage.state = "";
			pinKeyboard.clear();
			qtUtils.disconnectAllReceivers(pinKeyboard, "pinEntered(QString)");
		}

		function onShowingChanged() {
			if (!showing)
				p.cancelPinEntry();
		}
	}

	Component.onCompleted: {
		QT_TR_NOOP("enter_pin_armed");
		QT_TR_NOOP("enter_pin_partial");
		QT_TR_NOOP("enter_pin_disarmed");
		app.alarmInfoChanged.connect(update);
		app.internetStateChanged.connect(update);
		showingChanged.connect(p.onShowingChanged);
		update();
	}

	Component.onDestruction: {
		app.alarmInfoChanged.disconnect(update);
		app.internetStateChanged.disconnect(update);
	}

	function update() {
		// alarm state
		var alarmState = app.alarmInfo.alarmState;
		switch(alarmState) {
		case "armed":
			tabButtonObj.imageSource = p.iconArmedUrl;
			if (!activateTimer.running)
				p.setStateText(qsTr("Alarm is ON"));
			break;
		case "disarmed":
			tabButtonObj.imageSource = p.iconDisarmedUrl;
			p.setStateText(qsTr("Alarm is OFF"));
			break;
		case "partial":
			tabButtonObj.imageSource = p.iconNightUrl;
			p.setStateText(qsTr("Night mode is ON"));
			break;
		default:
			tabButtonObj.imageSource = p.iconHouseUrl;
			p.setStateText(qsTr("Unknown status"));
			break;
		}
		var alarmStateEnum = alarmState ? alarmState.toUpperCase() : "";
		if (_ALARM_STATE.hasOwnProperty(alarmStateEnum))
			alarmStateGroup.currentControlId = _ALARM_STATE[alarmStateEnum];
		else
			alarmStateGroup.currentControlId = -1;

		if (activateTimer.running) {
			if (alarmState !== "armed" && alarmState !== "partial")
				activateTimer.stop();
			else
				// dont update diag. status when activate timer is running
				return;
		}

		statusText.error = false;
		// diagnosis status
		switch(app.alarmInfo.diagnosisStatus) {
		case "ok":
			statusText.text = qsTr("Everything is ok");
			break;
		case "device-offline":
			statusText.text = qsTr("System is not reachable");
			statusText.error = true;
			break;
		case "device-warning":
			statusText.text = qsTr("Warning");
			statusText.error = true;
			break;
		default:
			statusText.text = " ";
			break;
		}

		if (app.alarmInfo.connected === false) {
			statusText.text = qsTr("Auth. failed! Please relogin");
			statusText.error = true;
		}

		if (!app.internetState) {
			statusText.text = qsTr("System is not reachable");
			statusText.error = true;
		}

		if (statusText.error)
			tabButtonObj.imageSource = p.iconErrorUrl;
	}

	function setArmedState(state) {
		var pinEnteredCb = function (pin) {
			pinPage.state = "BUSY";
			app.setArmedState(state, pin, setArmedStateCallback);
		}

		requestPin(state, pinEnteredCb);
	}

	function setArmedStateCallback(success, reason, newState) {
		if (success) {
			var noUpdate = false;
			if (newState === "armed" || newState === "partial") {
				p.setStateText(qsTr("Activating"));
				activateTimer.startCountdown();
				noUpdate = true;
			}
			p.cancelPinEntry(noUpdate);
		} else {
			pinPage.state = "WRONG";
			pinKeyboard.wrongPin();
			if (reason === "wrong-pin") {
				// nothing else
			} else if (reason === "max-pin-retries") {
				pinTitleText.text = qsTranslate("AlarmEditPinScreen", "Maximum number of retries reached!")
				pinKeyboard.enabled = false;
				util.delayedCall(3000, p.cancelPinEntry);
			} else {
				pinTitleText.text = qsTr("Error setting alarm mode!");
				console.log("AlarmPanel: error setting security level!", reason);
			}
		}
	}

	function requestPin(state, callback) {
		pinKeyboard.clear();
		p.pinStatusText = qsTr("enter_pin_" + state).arg(colors.alarmPanelTextHighlight.toString());
		pinPage.state = "";
		container.showPage(1);
		pinKeyboard.pinEntered.connect(callback);
	}

	ControlGroup {
		id: alarmStateGroup
		exclusive: true
		onCurrentControlIdChangedByUser: {
			if (currentControlId >= 0) {
				for(state in _ALARM_STATE) {
					if (_ALARM_STATE[state] === currentControlId) {
						setArmedState(state.toLowerCase());
						break;
					}
				}
			}
		}
	}

	Flickable {
		id: container
		anchors {
			fill: parent
			leftMargin: Math.round(20 * verticalScaling)
			rightMargin: anchors.leftMargin
		}
		contentWidth: containerRow.width
		clip: true
		interactive: false
		property int pageCount: Math.ceil(contentWidth / width)

		Behavior on contentX {
			enabled: isNxt
			SmoothedAnimation { duration: 200 }
		}

		function showPage(page) {
			if (page < 0 || page >= pageCount)
				return;

			container.contentX = container.width * page;
		}

		Row {
			id: containerRow
			height: parent.height

			Item {
				id: statePage
				width: container.width
				height: container.height

				Text {
					id: stateText
					anchors {
						top: parent.top
						topMargin: designElements.vMargin15
						left: buttonsContainer.left
						right: buttonsContainer.right
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.alarmPanelStateText
					text: " "
					wrapMode: Text.WordWrap
				}

				Text {
					id: statusText
					anchors {
						bottom: buttonsContainer.top
						bottomMargin: designElements.vMargin10
						left: buttonsContainer.left
						right: buttonsContainer.right
					}
					height: Math.round(60 * verticalScaling)
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: error ? colors.alarmPanelTextError : colors.alarmPanelText
					text: " "
					wrapMode: Text.WordWrap
					verticalAlignment: Text.AlignVCenter

					property bool error: false
				}

				Column {
					id: buttonsContainer
					height: childrenRect.height
					anchors {
						bottom: parent.bottom
						bottomMargin: container.anchors.leftMargin * 2
						left: parent.left
						leftMargin: container.anchors.leftMargin
						right: parent.right
						rightMargin: container.anchors.leftMargin
					}
					spacing: designElements.vMargin5

					TwoStateIconButton {
						id: armButton
						width:  parent.width
						height: Math.round(65 * verticalScaling)

						controlGroupId: 0
						controlGroup: alarmStateGroup
						selectionTrigger: "OnClick"
						iconSourceUnselected: "drawables/alarmButton_arm.svg"
						iconSourceSelected: "drawables/alarmButton_arm_active.svg"
						btnColorSelected: colors.alarmPanelSelectedBtn

						bottomLeftRadiusRatio: 0
						bottomRightRadiusRatio: 0
					}

					TwoStateIconButton {
						id: nightButton
						width: parent.width
						height: Math.round(65 * verticalScaling)

						controlGroupId: 1
						controlGroup: alarmStateGroup
						selectionTrigger: "OnClick"
						iconSourceUnselected: "drawables/alarmButton_night.svg"
						iconSourceSelected: "drawables/alarmButton_night_active.svg"
						btnColorSelected: colors.alarmPanelSelectedBtn

						topLeftRadiusRatio: 0
						topRightRadiusRatio: 0
						bottomLeftRadiusRatio: 0
						bottomRightRadiusRatio: 0
					}

					TwoStateIconButton {
						id: disarmButton
						width: parent.width
						height: Math.round(65 * verticalScaling)

						controlGroupId: 2
						controlGroup: alarmStateGroup
						selectionTrigger: "OnClick"
						iconSourceUnselected: "drawables/alarmButton_disarm.svg"
						iconSourceSelected: "drawables/alarmButton_disarm_active.svg"
						btnColorSelected: colors.alarmPanelSelectedBtn

						topLeftRadiusRatio: 0
						topRightRadiusRatio: 0
					}
				}
			}

			Item {
				id: pinPage
				width: container.width
				height: container.height
				states: [
					State {
						name: "BUSY"
						PropertyChanges { target: pinKeyboard; enabled: false }
						PropertyChanges { target: pinThrobber; visible: true }
						PropertyChanges { target: wrongPinIcon; visible: false}
						PropertyChanges { target: cancelPinBtn; enabled: false }
					},
					State {
						name: "WRONG"
						PropertyChanges { target: pinKeyboard; enabled: true }
						PropertyChanges { target: pinThrobber; visible: false}
						PropertyChanges { target: wrongPinIcon; visible: true}
						PropertyChanges { target: cancelPinBtn; enabled: true }
						PropertyChanges { target: pinTitleText; text: p.pinStatusText }
					}
				]

				Text {
					id: pinTitleText
					anchors {
						top: parent.top
						left: parent.left
						right: parent.right
					}
					font {
						family: qfont.bold.name
						pixelSize: qfont.titleText
					}
					color: colors.alarmPanelStateText
					text: p.pinStatusText
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
				}

				NumericKeyboard {
					id: pinKeyboard
					anchors {
						bottom: cancelPinBtn.top
						bottomMargin: pinKeyboard.buttonSpace
						horizontalCenter: parent.horizontalCenter
					}
					buttonWidth: Math.round(60 * verticalScaling)
					buttonHeight: Math.round(50 * verticalScaling)
					buttonSpace: designElements.vMargin10
					pinMode: true
					maxTextLength: 4

					onDigitEntered: pinPage.state = ""
				}

				Throbber {
					id: pinThrobber
					width: height
					height: Math.round(30 * verticalScaling)
					anchors {
						top: pinKeyboard.top
						topMargin: designElements.vMargin10
						left: pinKeyboard.right
						leftMargin: designElements.hMargin5
					}
					visible: false

					smallRadius: 1.5
					mediumRadius: 2
					largeRadius: 2.5
					bigRadius: 3
				}

				Image {
					id: wrongPinIcon
					anchors.centerIn: pinThrobber
					source: "image://scaled/apps/systemSettings/drawables/notification-error.svg"
					visible: false
				}

				StandardButton {
					id: cancelPinBtn
					anchors {
						bottom: parent.bottom
						bottomMargin: Math.round(32 * verticalScaling)
						left: pinKeyboard.left
						right: pinKeyboard.right
					}
					text: qsTr("Cancel")
					onClicked: p.cancelPinEntry()
				}
			}
		}
	}

	Timer {
		id: activateTimer
		interval: 1000
		repeat: true
		running: false
		property int count: 30

		function setCountdownText() {
			statusText.error = false;
			statusText.text = qsTr("The alarm will be active in %n second(s)", "", count).arg(colors.alarmPanelTextHighlight.toString());
		}

		function startCountdown() {
			count = 30;
			setCountdownText();
			restart();
		}

		onTriggered: {
			count--;
			if (count > 0) {
				setCountdownText();
			} else {
				stop();
				alarmPanelControlFrame.update();
			}
		}
	}
}
