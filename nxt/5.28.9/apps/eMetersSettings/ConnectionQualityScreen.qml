import QtQuick 2.1
import qb.components 1.0

Screen {
	id: connQualityScreen
	hasCancelButton: true
	inNavigationStack: false
	property EMetersSettingsApp app

	QtObject {
		id: p
		property string from
		property string deviceUuid: ""
	}

	onCustomButtonClicked: {
		// Populate device/sensor information, to ensure following wizard steps have the correct information
		// TODO: check if this is needed here
		app.getSensorConfiguration();

		if (p.from === "solarwizard") {
			app.solarWizardUuid = p.deviceUuid;
			stage.openFullscreen(app.selectSolarEMeterScreenUrl, {selectDevice: p.deviceUuid});
		} else if (state == "meteradapter") {
			stage.openFullscreen(app.manualConfigurationScreenUrl, {uuid: p.deviceUuid});
		} else {
			hide();
		}
	}

	onShown: {
		if (args) {
			if (args.state)
				state = args.state;
			p.deviceUuid = args.uuid ? args.uuid : "";
			p.from = args.from;
		}

		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"));
		disableCustomTopRightButton();
		backgroundRect.state = "begin";
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	function checkHealthResponse(success, health) {
		if (success && health >= 3) {
			backgroundRect.state = "success";
		} else {
			state = "meteradapter";
			backgroundRect.state = "failed";
		}
	}

	Text {
		id: checkQualityText
		anchors {
			left: parent.left
			leftMargin: Math.round(24 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(79 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.addDeviceTitle
	}

	Rectangle {
		id: backgroundRect

		radius: designElements.radius
		width: Math.round(756 * horizontalScaling)
		height: Math.round(265 * verticalScaling)
		color: colors.addDeviceBackgroundRectangle

		anchors {
			top: connQualityScreen.top
			left: connQualityScreen.left
			topMargin: Math.round(114 * verticalScaling)
			leftMargin: Math.round(21 * horizontalScaling)
		}

		onStateChanged: {
			if (state === "success") {
				enableCustomTopRightButton();
				disableCancelButton();
			} else if (state === "begin") {
				disableCustomTopRightButton();
				enableCancelButton();
			}
		}

		NumberBullet {
			id: nbOne
			anchors {
				left: parent.left
				top: parent.top
				leftMargin: Math.round(13 * horizontalScaling)
				topMargin: Math.round(35 * verticalScaling)
			}
			text: "1"
		}

		Text {
			id: oneText
			anchors {
				left: nbOne.right
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbOne.verticalCenter
			}
			width: Math.round(700 * horizontalScaling)
			wrapMode: Text.WordWrap
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		NumberBullet {
			id: nbTwo
			anchors {
				left: nbOne.left
				top: nbOne.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
			text: "2"
		}

		StandardButton {
			id: checkButton
			anchors {
				verticalCenter: nbTwo.verticalCenter
				left: nbTwo.right
				leftMargin: Math.round(10 * horizontalScaling)
			}
			onClicked: {
				backgroundRect.state = "checkingSearching";
				zWaveUtils.doNodeHealthTest(p.deviceUuid, checkHealthResponse);
			}
		}

		NumberBullet {
			id: nbThree
			anchors {
				left: nbOne.left
				top: nbTwo.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
			text: "3"
			visible: false
		}

		StandardButton {
			id: linkRepeaterButton
			visible: false
			anchors {
				verticalCenter: nbThree.verticalCenter
				left: nbThree.right
				leftMargin: Math.round(10 * horizontalScaling)
			}
			onClicked: {
				stage.openFullscreen(app.addDeviceScreenUrl, {state: "repeater"});
			}
			text: qsTr("Link repeater")
		}

		Throbber {
			id: linkThrobber
			anchors {
				left: checkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
				verticalCenter: checkButton.verticalCenter
			}
			visible: false
		}

		Text {
			id: linkProgressText
			anchors {
				left: linkThrobber.right
				verticalCenter: linkThrobber.verticalCenter
				leftMargin: Math.round(10 * horizontalScaling)
			}
			visible: linkThrobber.visible
			color: colors.addDeviceText
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: zWaveUtils.networkHealth.progress !== undefined ? zWaveUtils.networkHealth.progress + "%" : "0%"
		}

		Image {
			id: greenCheck
			anchors {
				verticalCenter: checkButton.verticalCenter
				left: checkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
			}
			visible: false
			source: "qrc:/images/good.svg"
		}

		Image {
			id: errorIcon
			anchors {
				left: checkButton.right
				verticalCenter: checkButton.verticalCenter
				leftMargin: Math.round(12 * horizontalScaling)
			}
			visible: false
			source: "qrc:/images/bad.svg"
			height: Math.round(24 * verticalScaling)
			sourceSize {
				width: 0
				height: height
			}
		}

		Text {
			id: errorText
			anchors {
				left: errorIcon.right
				verticalCenter: errorIcon.verticalCenter
				leftMargin: Math.round(10 * horizontalScaling)
			}
			visible: errorIcon.visible
			width: Math.round(350 * horizontalScaling)
			wrapMode: Text.WordWrap
			color: colors.addDeviceErrorText
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("check_MA_connection_quality_error_text")
		}

		state: "begin"
		states: [
			State {
				name: "begin"
				PropertyChanges { target: oneText; color: colors.addDeviceText; restoreEntryValues: false }
				PropertyChanges { target: checkButton; enabled: true; state: "up" }
			},
			State {
				name: "checkingSearching"
				PropertyChanges { target: checkButton; enabled: false; state: "down" }
				PropertyChanges { target: linkThrobber; visible: true }
			},
			State {
				name: "success"
				PropertyChanges { target: greenCheck; visible: true	}
				PropertyChanges { target: oneText; color: colors.addDeviceTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: nbOne; state: "disabled" }
				PropertyChanges { target: nbTwo; state: "disabled" }
				PropertyChanges { target: checkButton; enabled: false; state: "disabled" }
			},
			State {
				name: "failed"
				PropertyChanges { target: errorIcon; visible: true }
				PropertyChanges { target: nbThree; visible: true }
				PropertyChanges { target: checkButton; enabled: true; state: "up" }
				PropertyChanges { target: linkRepeaterButton; visible: true; state: "up" }
			}

		]
	}

	state: "meteradapter"
	states: [
		State {
			name: "meteradapter"
			PropertyChanges { target: connQualityScreen; screenTitle: qsTr("Install meter adapter") }
			PropertyChanges { target: checkQualityText; text: qsTr("Check connection quality") }
			PropertyChanges { target: oneText; text: qsTr("check_MA_quality_one_text") }
			PropertyChanges { target: checkButton; text: qsTr("Check") }
		},
		State {
			name: "repeater"
			PropertyChanges { target: connQualityScreen; screenTitle: qsTr("Install repeater") }
			PropertyChanges { target: checkQualityText; text: qsTr("Place the repeater") }
			PropertyChanges { target: oneText; text: qsTr("Plug the repeater into an electrical outlet within 2 meters of the display.") }
			PropertyChanges { target: checkButton; text: qsTr("Search") }
		}
	]
}
