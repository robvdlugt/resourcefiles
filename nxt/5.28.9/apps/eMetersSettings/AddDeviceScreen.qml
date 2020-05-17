import QtQuick 2.1
import qb.components 1.0

Screen {
	id: addDeviceScreen

	property bool customButtonEnabled: true
	property int failureCount: 0
	property string newDeviceUuid: ""

	hasCancelButton: true
	inNavigationStack: false

	property EMetersSettingsApp app

	QtObject {
		id :p
		property string from
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onShown: {
		if (args && args.state) {
			state = args.state;
		}
		if (args && args.from !== undefined) {
			p.from = args.from;
		}
		
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"));
		disableCustomTopRightButton();
		backgroundRect.state = "notlinked";
	}

	onCustomButtonClicked: {
		if (state === "strv") {
			stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/strvSettings/StrvDeviceDetailsScreen.qml"), {"uuid": newDeviceUuid});
		} else if (app.maDevices.length) {
			stage.openFullscreen(app.connectionQualityScreenUrl, {state: state, uuid: newDeviceUuid, from: p.from});
		} else {
			hide();
		}
	}

	onCanceled: {
		if (backgroundRect.state === "linking") {
			zWaveUtils.includeDevice("stop");
		}
	}

	function handleIncludeResponse(status, type, uuid) {
		// check if addDeviceScreen exists (lazy loaded screen)
		if (typeof addDeviceScreen !== 'undefined') {
			var recognizedMeteringDevice = (type !== undefined && (
											type.indexOf("HAE_METER") !== -1 ||
											type.indexOf("HOME_ENERGY_METER") !== -1 ||
											type.indexOf("ZMNHTD1") !== -1 ||
											type.indexOf("ZMNHXD1") !== -1));
			if (status === "added" && (state === "repeater" || state === "strv" || recognizedMeteringDevice) ) {
				newDeviceUuid = uuid;
				failureCount = 0;
				backgroundRect.state = "linked";
			} else if (status !== "canceled") {
				failureCount++;

				if (state === "strv") {
					if (failureCount % 2 === 1) {
						errorText.text = qsTr("The distance between the radiator valve and $(display) is probably too large. Keep the radiator valve within 2 meters of $(display) while trying to link.");
					} else {
						errorText.text = qsTr("The radiator valve may be linked to another display or controller. In that case, return the radiator valve to factory settings before trying again.");
					}
				} else {
					var deviceArg =  (state === "meteradapter") ? qsTr("meter adapter") : qsTr("repeater");
					errorText.text = (failureCount % 2 === 0) ? qsTr("add_failure_2").arg(deviceArg) : qsTr("add_failure_1").arg(deviceArg);
				}
				backgroundRect.state = "failed";
			}
		}
	}

	Text {
		id: linkDeviceText
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
		height: Math.round(265 * verticalScaling)
		width: Math.round(756 * horizontalScaling)
		anchors {
			top: addDeviceScreen.top
			left: addDeviceScreen.left
			topMargin: Math.round(114 * verticalScaling)
			leftMargin: Math.round(21 * horizontalScaling)
		}
		radius: designElements.radius
		color: colors.addDeviceBackgroundRectangle

		state: "notlinked"
		states: [
			State {
				name: "notlinked"
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: oneText; color: colors.addDeviceText; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.addDeviceText; restoreEntryValues: false }
				PropertyChanges { target: errorText; visible: false; restoreEntryValues: false }
				PropertyChanges { target: errorIcon; visible: false; restoreEntryValues: false }
				PropertyChanges { target: linkButton; enabled: true; state: "up" }
			},
			State {
				name: "linking"
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: linkButton; enabled: false; state: "down" }
				PropertyChanges { target: linkThrobber; visible: true }
			},
			State {
				name: "linked"
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: greenCheck; visible: true	}
				PropertyChanges { target: oneText; color: colors.addDeviceTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.addDeviceTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: nbOne; state: "disabled" }
				PropertyChanges { target: nbTwo; state: "disabled" }
				PropertyChanges { target: linkButton; enabled: false; state: "disabled" }
			},
			State {
				name: "failed"
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: errorText; visible: true }
				PropertyChanges { target: errorIcon; visible: true }
				PropertyChanges { target: linkButton; enabled: true; state: "up" }
			}

		]
		onStateChanged: {
			if (state === "linked") {
				enableCustomTopRightButton();
				disableCancelButton();
			} else if (state === "notlinked") {
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
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbOne.verticalCenter
			}
			width: Math.round(500 * horizontalScaling)
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

		Text {
			id: twoText
			anchors {
				left: nbTwo.right
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbTwo.verticalCenter
			}
			width: Math.round(500 * horizontalScaling)
			wrapMode: Text.WordWrap
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: linkButton
			anchors {
				top: twoText.bottom
				left: parent.left
				topMargin: Math.round(13 * verticalScaling)
				leftMargin: Math.round(49 * horizontalScaling)
			}
			text: qsTr("Link")
			onClicked: {
				if (backgroundRect.state === "notlinked" || backgroundRect.state === "failed") {
					backgroundRect.state = "linking";
					zWaveUtils.includeDevice("add", handleIncludeResponse);
				} else if (backgroundRect.state === "linking") {
					state = "down";
				} else if (backgroundRect.state === "linked") {
					state = "disabled";
				}
			}
		}

		Throbber {
			id: linkThrobber
			anchors {
				left: linkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
				verticalCenter: linkButton.verticalCenter
			}
			visible: false
		}

		Image {
			id: greenCheck
			anchors {
				verticalCenter: linkButton.verticalCenter
				left: linkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
			}
			visible: false
			source: "qrc:/images/good.svg"
		}

		Image {
			id: errorIcon
			anchors {
				left: backgroundRect.left
				top: linkButton.bottom
				leftMargin: Math.round(12 * horizontalScaling)
				topMargin: Math.round(12 * verticalScaling)
			}
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
				top: linkButton.bottom
				leftMargin: Math.round(10 * horizontalScaling)
				topMargin: Math.round(12 * verticalScaling)
				right: deviceImage.left
			}
			wrapMode: Text.WordWrap
			color: colors.addDeviceErrorText
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		Image {
			id: deviceImage
			visible: feature.featShowEnergyMeterImages()

			anchors {
				right: backgroundRect.right
				bottom: backgroundRect.bottom
			}
			states: [
				State {
					name: "meteradapter"
					PropertyChanges {
						target: deviceImage
						source: "drawables/meteradapter_image.png"
					}
					PropertyChanges {
						target: deviceImage
						anchors.rightMargin: Math.round(25 * horizontalScaling)
						anchors.bottomMargin: Math.round(14 * verticalScaling)
					}
				},
				State {
					name: "repeater"
					PropertyChanges {
						target: deviceImage
						source: "drawables/repeater_image.png"
					}
					PropertyChanges {
						target: deviceImage
						anchors.rightMargin: Math.round(34 * horizontalScaling)
						anchors.bottomMargin: Math.round(20 * verticalScaling)
					}
				},
				State {
					name: "strv"
					PropertyChanges {
						target: deviceImage
						visible: false
					}
				}
			]
		}
	}

	states: [
		State {
			name: "meteradapter"
			StateChangeScript { script: {setTitle(qsTr("Add meter adapter"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Link the meter adapter") }
			PropertyChanges { target: oneText; text: qsTr("Plug the meter adapter into an electrical outlet.") }
			PropertyChanges { target: twoText; text: qsTr("First press \"Link\" and then press the button on the meter adapter a few times.") }
			PropertyChanges { target: deviceImage; state: "meteradapter" }
		},
		State {
			name: "repeater"
			StateChangeScript { script: {setTitle(qsTr("Add repeater"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Link the repeater") }
			PropertyChanges { target: oneText; text: qsTr("Plug the repeater into an electrical outlet within 2 meters of the display.") }
			PropertyChanges { target: twoText; text: qsTr("First press \"Link\" and then press the button on the repeater a few times.") }
			PropertyChanges { target: deviceImage; state: "repeater" }
		},
		State {
			name: "strv"
			StateChangeScript { script: {setTitle(qsTr("Add radiator valve"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Link the radiator valve") }
			PropertyChanges { target: oneText; text: qsTr("Put the batteries in the radiator valve and make sure it's ready to be linked.") }
			PropertyChanges { target: twoText; text: qsTr("First press \"Link\" and then shortly press the bottom button on the valve so it starts blinking.") }
			PropertyChanges { target: deviceImage; state: "strv" }
		}
	]
}
