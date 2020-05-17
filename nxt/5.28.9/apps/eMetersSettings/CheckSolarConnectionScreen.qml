import QtQuick 2.1
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: checkSolarConnectionScreen

	screenTitle: qsTr("Check solar connection")

	hasCancelButton: false
	hasHomeButton: false
	hasBackButton: false
	inNavigationStack: false

	property EMetersSettingsApp app

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Ready"));
		disableCustomTopRightButton();
		app.usageDevicesInfoChanged.connect(checkSolarStatus);
		backgroundRect.state = "begin";
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		app.usageDevicesInfoChanged.disconnect(checkSolarStatus);
		resetMaTimeout.stop();
		throbber.visible = false;
	}

	onCustomButtonClicked: {
		hide();
	}

	function checkSolarStatus() {
		if (backgroundRect.state === "checking") {
			var solarSensor = app.getUsageByType("solar");
			if (solarSensor && solarSensor.usage) {
				if (solarSensor.usage.status === Constants.meterStatusValues.ST_OPERATIONAL ||
					solarSensor.usage.status === Constants.meterStatusValues.ST_COMMISSIONING) {
					resetMaTimeout.stop();
					backgroundRect.state = "success";
				} else {
					stage.openFullscreen(app.solarConnectionFailedScreenUrl);
				}
			}
		}
	}

	Text {
		id: connectSensorText
		anchors {
			left: parent.left
			leftMargin: Math.round(24 * horizontalScaling)
			bottom: backgroundRect.top
			bottomMargin: Math.round(13 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.addDeviceTitle
		text: qsTr("Connect the electricity sensor")
	}

	Rectangle {
		id: backgroundRect
		height: Math.round(265 * verticalScaling)
		width: Math.round(756 * horizontalScaling)
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(21 * horizontalScaling)
		}
		radius: designElements.radius
		color: colors.addDeviceBackgroundRectangle

		state: "begin"
		states: [
			State {
				name: "begin"
				PropertyChanges { target: throbber; visible: false }
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: oneText; color: colors.addDeviceText; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.addDeviceText; restoreEntryValues: false }
				PropertyChanges { target: checkButton; enabled: true; state: "up" }
			},
			State {
				name: "checking"
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: checkButton; enabled: false; state: "down" }
				PropertyChanges { target: throbber; visible: true }
			},
			State {
				name: "success"
				PropertyChanges { target: throbber; visible: false }
				PropertyChanges { target: greenCheck; visible: true	}
				PropertyChanges { target: oneText; color: colors.addDeviceTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.addDeviceTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: nbOne; state: "disabled" }
				PropertyChanges { target: nbTwo; state: "disabled" }
				PropertyChanges { target: checkButton; enabled: false; state: "disabled" }
			}
		]
		onStateChanged: {
			if (state === "success") {
				enableCustomTopRightButton();
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
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbOne.verticalCenter
			}
			width: Math.round(600 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("nb_1_text")
		}

		NumberBullet {
			id: nbTwo
			anchors {
				left: nbOne.left
				top: nbOne.bottom
				topMargin: Math.round(25 * verticalScaling)
			}
			text: "2"
		}

		Text {
			id: twoText
			anchors {
				left: nbTwo.right
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbTwo.verticalCenter
			}
			width: Math.round(500 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("nb_2_text")
		}

		StandardButton {
			id: checkButton
			anchors {
				top: twoText.bottom
				left: parent.left
				topMargin: Math.round(13 * verticalScaling)
				leftMargin: Math.round(49 * horizontalScaling)
			}
			text: qsTr("Check")
			onClicked: {
				if (backgroundRect.state === "begin") {
					backgroundRect.state = "checking"
					var solarSensor = app.getUsageByType("solar");
					if (solarSensor && solarSensor.usage) {
						if (solarSensor.usage.status === Constants.meterStatusValues.ST_OPERATIONAL ||
							solarSensor.usage.status === Constants.meterStatusValues.ST_COMMISSIONING) {
							backgroundRect.state = "success";
						} else {
							if (solarSensor.usage.status === Constants.meterStatusValues.ST_DISABLED)
								app.sendResetMaSensor(app.solarWizardUuid, "solar");
							resetMaTimeout.restart();
						}
					}
				}
			}
		}

		Throbber {
			id: throbber
			anchors {
				left: checkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
				verticalCenter: checkButton.verticalCenter
			}
			visible: false
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
			id: deviceImage
			anchors {
				right: parent.right
				rightMargin: Math.round(22 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: Math.round(20 * verticalScaling)
			}
			source: "image://scaled/apps/eMetersSettings/drawables/bigdisplaypanels.svg"
		}
	}

	Timer {
		id: resetMaTimeout
		interval: 60000
		onTriggered: {
			console.debug("resetting MA timed out");
			stage.openFullscreen(app.solarConnectionFailedScreenUrl);
		}
	}
}
