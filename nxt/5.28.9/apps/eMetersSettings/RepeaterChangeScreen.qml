import QtQuick 2.1

import qb.components 1.0

Screen {
	id: repeaterChangeScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Modify repeaters")
	isSaveCancelDialog: false
	anchors.fill: parent

	function update() {
		// Repeater
		var repeaters = app.repeaterDevices;
		// Set repeater model to correct length and set last to non configured if <2 repeaters
		repeaterRepeater.model = ((repeaters.length + 1) > 2) ? 2 : (repeaters.length + 1);
		if (repeaters.length < 2) {
			var lastRepeater = repeaterRepeater.itemAt((repeaterRepeater.model - 1));
			lastRepeater.state = "REPEATER_NOT_CONFIGURED";
			lastRepeater.connectionStatus = qsTr("Not installed");
		}

		// Set uuid, connection status and health value
		for (var i = 0; i < repeaters.length; i++) {
			var repeater = repeaterRepeater.itemAt(i);

			repeater.uuid = repeaters[i].uuid;
			repeater.connectionStatus = parseInt(repeaters[i].IsConnected) ? qsTr("Connected") : qsTr("Not connected");

			if (zWaveUtils.networkHealth.active) {
				repeater.state = (zWaveUtils.networkHealth.uuid === repeater.uuid) ? "HEALTHTEST_BUSY" : "HEALTHTEST_DISABLED";
			} else {
				var numStars = 0;

				if (parseInt(repeaters[i].IsConnected)) {
					numStars = Math.floor(parseInt(zWaveUtils.devices[repeater.uuid].HealthValue) / 2);
					repeater.state = "NORMAL";
				} else {
					repeater.state = "REPEATER_NOT_CONNECTED";
				}

				// Draw stars
				for (var j = 0; j < 5; j++)
					repeater.stars.itemAt(j).source = "qrc:/images/star-" + (j < numStars ? "on" : "off") + ".svg";
			}
		}
	}

	function init() {
		app.zwaveDevicesUpdated.connect(update);
		zWaveUtils.networkHealthChanged.connect(update);
	}

	Component.onDestruction: {
		app.zwaveDevicesUpdated.disconnect(update);
		zWaveUtils.networkHealthChanged.disconnect(update);
	}

	onShown: {
		update();
	}

	// Main container
	Item {
		id: centerContainer
		anchors {
			top: parent.top
			left: parent.left
			topMargin: Math.round(20 * verticalScaling)
			leftMargin: Math.round(133 * horizontalScaling)
		}
		width: Math.round(537 * horizontalScaling)

		// Repeater part
		Text {
			id: repeaterSectionTitle
			anchors {
				top: parent.top
				left: parent.left
			}
			text: qsTr("Add or remove repeaters (max. 2)")
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.rbTitle
		}

		Column {
			id: repeaterColumn

			anchors {
				top: repeaterSectionTitle.bottom
				left: parent.left
				right: parent.right
				topMargin: Math.round(12 * verticalScaling)
			}
			spacing: Math.round(30 * verticalScaling)

			Repeater {
				id: repeaterRepeater
				model: 2

				// Repeater
				Item {
					id: repeaterSection
					width: Math.round(537 * horizontalScaling)
					height: childrenRect.height

					property string uuid: ""
					property alias connectionStatus: repeaterLabel.rightText
					property alias stars: repeaterSignalStrengthStars

					SingleLabel {
						id: repeaterLabel
						anchors {
							left: parent.left
							right: repeaterButton.left
							top: parent.top
							rightMargin: designElements.hMargin6
						}

						leftText: qsTr("Repeater")
						rightText: ""
						rightTextFont: qfont.lightItalic.name
						rightTextSize: qfont.bodyText
					}

					IconButton {
						id: repeaterButton

						width: designElements.buttonSize

						anchors {
							bottom: repeaterLabel.bottom
							right: parent.right
						}

						onClicked: {
							if (repeaterSection.state == "REPEATER_NOT_CONFIGURED") {
								stage.openFullscreen(app.addDeviceScreenUrl, {state: "repeater"});
							}
							else {
								stage.openFullscreen(app.removeDeviceScreenUrl, {state: "repeater", uuid: repeaterSection.uuid});
							}
						}
					}

					SingleLabel {
						id: repeaterSignalStrengthLabel

						leftText: qsTr("Signal strength")
						rightText: ""

						anchors {
							top: repeaterLabel.bottom
							left: parent.left
							right: repeaterSignalStrengthButton.left
							topMargin: designElements.vMargin6
							rightMargin: designElements.hMargin6
						}

						Row {
							id: repeaterSignalStrengthRow

							spacing: Math.round(2 * horizontalScaling)
							anchors {
								verticalCenter: parent.verticalCenter
								right: parent.right
								rightMargin: Math.round(12 * horizontalScaling)
							}

							Repeater {
								id: repeaterSignalStrengthStars
								model: 5

								Image {
								}
							}
						}
					}

					Throbber {
						id: repeaterSignalStrengthThrobber
						width: designElements.buttonSize
						height: Math.round(40 * verticalScaling)

						anchors {
							bottom: repeaterSignalStrengthLabel.bottom
							right: parent.right
						}
					}

					IconButton {
						id: repeaterSignalStrengthButton

						width: designElements.buttonSize
						iconSource: "qrc:/images/refresh.svg"

						anchors {
							bottom: repeaterSignalStrengthLabel.bottom
							right: parent.right
						}

						onClicked: {
							zWaveUtils.doNodeHealthTest(repeaterSection.uuid);
						}
					}

					state: "NORMAL"
					states: [
						State {
							name: "NORMAL"
							PropertyChanges {target: repeaterButton; iconSource: "qrc:/images/delete.svg"; enabled: true}
							PropertyChanges {target: repeaterSignalStrengthLabel; rightText: ""; visible: true}
							PropertyChanges {target: repeaterSignalStrengthRow; visible: true}
							PropertyChanges {target: repeaterSignalStrengthThrobber; visible: false}
							PropertyChanges {target: repeaterSignalStrengthButton; visible: true}
						},
						State {
							name: "HEALTHTEST_BUSY"
							PropertyChanges {target: repeaterButton; iconSource: "qrc:/images/delete.svg"; enabled: false}
							PropertyChanges {target: repeaterSignalStrengthLabel; rightText: qsTr("Busy"); visible: true}
							PropertyChanges {target: repeaterSignalStrengthRow; visible: false}
							PropertyChanges {target: repeaterSignalStrengthThrobber; visible: true}
							PropertyChanges {target: repeaterSignalStrengthButton; visible: false}
						},
						State {
							name: "HEALTHTEST_DISABLED"
							PropertyChanges {target: repeaterButton; iconSource: "qrc:/images/delete.svg"; enabled: true}
							PropertyChanges {target: repeaterSignalStrengthLabel; rightText: ""; visible: true}
							PropertyChanges {target: repeaterSignalStrengthRow; visible: true}
							PropertyChanges {target: repeaterSignalStrengthThrobber; visible: false}
							PropertyChanges {target: repeaterSignalStrengthButton; visible: false}
						},
						State {
							name: "REPEATER_NOT_CONFIGURED"
							PropertyChanges {target: repeaterButton; iconSource: "qrc:/images/edit.svg"; enabled: true}
							PropertyChanges {target: repeaterSignalStrengthLabel; rightText: ""; visible: false}
							PropertyChanges {target: repeaterSignalStrengthRow; visible: false}
							PropertyChanges {target: repeaterSignalStrengthThrobber; visible: false}
							PropertyChanges {target: repeaterSignalStrengthButton; visible: false}
						},
						State {
							name: "REPEATER_NOT_CONNECTED"
							PropertyChanges {target: repeaterButton; iconSource: "qrc:/images/delete.svg"; enabled: true}
							PropertyChanges {target: repeaterSignalStrengthLabel; rightText: ""; visible: true}
							PropertyChanges {target: repeaterSignalStrengthRow; visible: true}
							PropertyChanges {target: repeaterSignalStrengthThrobber; visible: false}
							PropertyChanges {target: repeaterSignalStrengthButton; visible: true}
						}
					]
				}
			}
		}
	}

	StandardButton {
		id: advancedBtn
		anchors {
			right: parent.right
			bottom: parent.bottom
			rightMargin: designElements.hMargin6
			bottomMargin: designElements.vMargin6
		}

		text: qsTr("Advanced")
		visible: !feature.appEMetersSettingsAdvancedDisabled()

		onClicked: {
			stage.openFullscreen(app.eMeterAdvancedScreenUrl);
		}
	}
}

