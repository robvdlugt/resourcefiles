import QtQuick 2.1
import qb.components 1.0

Screen {
	id: removeDeviceScreen

	QtObject {
		id: p

		property var postSuccessCallbackFcn
		property string deviceUuid
	}

	function handleExcludeResponse(status, type, uuid) {
		// check if backgroundRect exists (lazy loaded screen)
		if (typeof backgroundRect !== 'undefined') {
			if (status === "deleted") {
				backgroundRect.state = "unlinked";
				enableCustomTopRightButton();
				disableCancelButton();
				if (p.postSuccessCallbackFcn) {
					p.postSuccessCallbackFcn();
				}
			} else if (status !== "canceled") {
				backgroundRect.state = "failed";
			}
		}
	}

	hasCancelButton: true
	onCustomButtonClicked: hide()

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onShown: {
		if (args) {
			if (args.state) {
				state = args.state;
			}
			if (args.postSuccessCallbackFcn) {
				p.postSuccessCallbackFcn = args.postSuccessCallbackFcn;
			} else {
				p.postSuccessCallbackFcn = undefined;
			}
			p.deviceUuid = args.uuid ? args.uuid : "";
		}

		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"));
		disableCustomTopRightButton();
		backgroundRect.state = "linked";
	}

	onCanceled: {
		if (backgroundRect.state === "unlinking") {
			zWaveUtils.excludeDevice("stop");
		}
	}

	Text {
		id: linkDeviceText

		color: colors.addDeviceTitle

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
	}

	Rectangle {
		id: backgroundRect

		radius: designElements.radius
		width: Math.round(756 * horizontalScaling)
		height: Math.round(265 * verticalScaling)
		color: colors.addDeviceBackgroundRectangle

		anchors {
			top: removeDeviceScreen.top
			left: removeDeviceScreen.left
			topMargin: Math.round(114 * verticalScaling)
			leftMargin: Math.round(21 * horizontalScaling)
		}

		NumberBullet {
			id: nbOne

			text: "1"

			anchors {
				left: parent.left
				top: parent.top
				leftMargin: Math.round(13 * horizontalScaling)
				topMargin: Math.round(35 * verticalScaling)
			}
		}

		Text {
			id: oneText

			width: Math.round(500 * horizontalScaling)
			wrapMode: Text.WordWrap

			anchors {
				left: nbOne.right
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbOne.verticalCenter
			}

			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		NumberBullet {
			id: nbTwo

			text: "2"

			anchors {
				left: nbOne.left
				top: nbOne.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
		}

		Text {
			id: twoText

			width: Math.round(500 * horizontalScaling)
			wrapMode: Text.WordWrap

			anchors {
				left: nbTwo.right
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbTwo.verticalCenter
			}

			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		NumberBullet {
			id: nbThree

			text: "3"

			anchors {
				left: nbOne.left
				top: nbTwo.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
		}

		Text {
			id: threeText

			width: Math.round(500 * horizontalScaling)
			wrapMode: Text.WordWrap

			anchors {
				left: nbThree.right
				right: deviceImage.left
				leftMargin: Math.round(11 * horizontalScaling)
				verticalCenter: nbThree.verticalCenter
			}

			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		Row {
			id: unlinkRow
			anchors {
				top: threeText.bottom
				left: parent.left
				topMargin: Math.round(13 * verticalScaling)
				leftMargin: Math.round(49 * horizontalScaling)
			}
			spacing: designElements.hMargin10

			StandardButton {
				id: unlinkButton
				text: qsTr("Remove")

				onClicked: {
					backgroundRect.state = "unlinking";
					zWaveUtils.excludeDevice("delete", handleExcludeResponse);
				}
			}

			StandardButton {
				id: forceRemoveButton
				text: qsTr("Force remove")
				enabled: false
				visible: enabled && p.deviceUuid

				onClicked: {
					qdialog.showDialog(qdialog.SizeMedium, qsTr("force-remove-popup-title"), qsTr("force-remove-popup-content"), qsTr("Yes"), function() {
						app.removeZwaveDevice(p.deviceUuid);
						if (p.postSuccessCallbackFcn) {
							p.postSuccessCallbackFcn();
						}

						removeDeviceScreen.hide();
						return false;
					}, qsTr("No"));
				}
			}

			Throbber {
				id: linkThrobber
				visible: false
				width: height
				height: designElements.buttonSize
				anchors.verticalCenter: parent.verticalCenter
			}

			Image {
				id: greenCheck
				anchors.verticalCenter: parent.verticalCenter
				visible: false
				source: "qrc:/images/good.svg"
			}

			Image {
				id: errorIcon
				visible: false
				source: "qrc:/images/bad.svg"
				anchors.verticalCenter: parent.verticalCenter
				height: Math.round(24 * verticalScaling)
				sourceSize {
					width: 0
					height: height
				}
			}

			Text {
				id: errorText
				anchors.verticalCenter: parent.verticalCenter
				visible: false
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.addDeviceErrorText
				text: qsTr("Removing failed.")
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
						anchors.rightMargin: Math.round(25 * horizontalScaling)
						anchors.bottomMargin: Math.round(14 * verticalScaling)
					}
				},
				State {
					name: "repeater"
					PropertyChanges {
						target: deviceImage
						source: "drawables/repeater_image.png"
						anchors.rightMargin: Math.round(34 * horizontalScaling)
						anchors.bottomMargin: Math.round(20 * verticalScaling)
					}
				}
			]
		}

		states: [
			State {
				name: "linked"
			},
			State {
				name: "unlinking"
				PropertyChanges { target: unlinkButton; enabled: false; state: "down"; }
				PropertyChanges { target: linkThrobber; visible: true; }
			},
			State {
				name: "unlinked"
				PropertyChanges { target: greenCheck; visible: true;	}
				PropertyChanges { target: oneText; color: colors.addDeviceTextDisabled; }
				PropertyChanges { target: twoText; color: colors.addDeviceTextDisabled; }
				PropertyChanges { target: threeText; color: colors.addDeviceTextDisabled; }
				PropertyChanges { target: nbOne; state: "disabled"; }
				PropertyChanges { target: nbTwo; state: "disabled"; }
				PropertyChanges { target: nbThree; state: "disabled"; }
				PropertyChanges { target: unlinkButton; enabled: false; state: "disabled"; }
			},
			State {
				name: "failed"
				PropertyChanges { target: errorText; visible: true; }
				PropertyChanges { target: errorIcon; visible: true; }
				PropertyChanges { target: unlinkButton; enabled: true; state: "up"; text: qsTr("Try again")}
				PropertyChanges { target: forceRemoveButton; enabled: true }
			}
		]
	}

	states: [
		State {
			name: "meteradapter"
			StateChangeScript { script: {setTitle(qsTr("Remove meter adapter"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Unlink the meter adapter") }
			PropertyChanges { target: oneText; text: qsTr("Unplug the meter adapter from the electrical outlet.") }
			PropertyChanges { target: twoText; text: qsTr("Plug the meteradapter in an electrical outlet within 2 meters of the screen") }
			PropertyChanges { target: threeText; text: qsTr("First press \"remove\" and then press the button on the meter adapter a few times.") }
			PropertyChanges { target: deviceImage; state: "meteradapter" }
		},
		State {
			name: "repeater"
			StateChangeScript { script: {setTitle(qsTr("Remove repeater"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Unlink the repeater") }
			PropertyChanges { target: oneText; text: qsTr("Plug the repeater into an electrical outlet within 2 meters of the display.") }
			PropertyChanges { target: twoText; text: qsTr("First press \"Remove\" and then press the button on the repeater a few times.") }
			PropertyChanges { target: nbThree; visible: false }
			AnchorChanges   { target: unlinkRow; anchors.top: twoText.bottom }
			PropertyChanges { target: deviceImage; state: "repeater" }
		},
		State {
			name: "wirelessBoilerModule"
			StateChangeScript { script: {setTitle(qsTr("Remove wireless boiler module"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Unlink the wireless boiler module") }
			PropertyChanges { target: oneText; text: qsTr("Press \"Remove\" to start the unlinking process") }
			PropertyChanges { target: twoText; text: qsTr("Then follow the instructions that were provided to you specific for your wireless boiler module.") }
			PropertyChanges { target: nbThree; visible: false }
			AnchorChanges   { target: unlinkRow; anchors.top: twoText.bottom }
			PropertyChanges { target: deviceImage; state: "repeater" }
		},

		State {
			name: "meteradapter_recover"
			StateChangeScript { script: {setTitle(qsTr("Recover meter adapter"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Recover the meter adapter") }
			PropertyChanges { target: oneText; text: qsTr("Unplug the meter adapter from the electrical outlet.") }
			PropertyChanges { target: twoText; text: qsTr("Plug the meteradapter in an electrical outlet within 2 meters of the screen") }
			PropertyChanges { target: threeText; text: qsTr("First press \"Recover\" and then press the button on the meter adapter a few times.") }
			PropertyChanges { target: errorText; text: qsTr("Recovering failed.") }
			PropertyChanges { target: unlinkButton; text:qsTr("Recover")}
			PropertyChanges { target: deviceImage; state: "meteradapter" }
		},
		State {
			name: "repeater_recover"
			StateChangeScript { script: {setTitle(qsTr("Recover repeater"))} }
			PropertyChanges { target: linkDeviceText; text: qsTr("Recover the repeater") }
			PropertyChanges { target: oneText; text: qsTr("Plug the repeater into an electrical outlet within 2 meters of the display.") }
			PropertyChanges { target: twoText; text: qsTr("First press \"Recover\" and then press the button on the repeater a few times.") }
			PropertyChanges { target: nbThree; visible: false }
			PropertyChanges { target: errorText; text: qsTr("Recovering failed.") }
			PropertyChanges { target: unlinkButton; text:qsTr("Recover") }
			AnchorChanges   { target: unlinkRow; anchors.top: twoText.bottom }
			PropertyChanges { target: deviceImage; state: "repeater" }
		}
	]
}
