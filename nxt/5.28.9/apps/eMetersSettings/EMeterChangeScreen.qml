import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0
import qb.utils 1.0

import "Constants.js" as Constants

Screen {
	id: eMeterChangeScreen
	anchors.fill: parent
	screenTitle: qsTr("%1 details").arg(p.usageDevice ? qtUtils.escapeHtml(p.usageDevice.deviceIdentifier) : qsTr("Meter module"))

	QtObject {
		id: p
		property string uuid
		property variant usageDevice
		property int starCount: zWaveUtils.devices[uuid] ? Math.floor(parseInt(zWaveUtils.devices[uuid].HealthValue) / 2) : 0

		function getMeasureTypeString(usage) {
			// if usage/resource has a defined meterType, we don't show a string on the Type label,
			// as another controller is shown to allow the user to select a "meter type" (disk/pulse for now)
			if (usage.meterType !== undefined)
				return "";

			switch (usage.measureType) {
			case Constants.MEASURE_TYPE.ANALOG:
				return qsTr("Analog");
			case Constants.MEASURE_TYPE.SMART_METER:
				return qsTr("Smart meter");
			case Constants.MEASURE_TYPE.LASER:
				return qsTr("Laser");
			default:
				return "";
			}
		}
	}

	onShown: {
		if (args && args.uuid) {
			p.uuid = args.uuid;
			update();
		}
	}

	function update() {
		p.usageDevice = app.getUsageDeviceByUuid(p.uuid);
	}

	function init() {
		app.maDevicesChanged.connect(update);
		app.usageDevicesInfoChanged.connect(update);
	}

	Component.onDestruction: {
		app.maDevicesChanged.disconnect(update);
		app.usageDevicesInfoChanged.disconnect(update);
	}

	GridLayout {
		id: labelsColumn
		anchors {
			top: parent.top
			left: parent.left
			topMargin: Math.round(45 * verticalScaling)
			leftMargin: Math.round(40 * horizontalScaling)
		}
		rowSpacing: designElements.vMargin6
		columnSpacing: rowSpacing
		property int labelWidth: Math.round(388 * horizontalScaling)

		EditTextLabel {
			id: nameLabel
			Layout.columnSpan: 2
			Layout.row: 0
			Layout.fillWidth: true
			labelText: qsTr("Name")
			prefilledText: p.usageDevice ? p.usageDevice.deviceIdentifier : ""
			maxLength: 25
			showAcceptButton: true
			validator: RegExpValidator { regExp: /.+/ } // empty name is not allowed

			onInputAccepted: app.setDeviceName(p.uuid, inputText)
		}

		SingleLabel {
			id: statusLabel
			Layout.preferredWidth: labelsColumn.labelWidth
			Layout.row: 1
			leftText: qsTr("Status")
			rightText: p.usageDevice ? p.usageDevice.statusString : ""
			rightTextSize: qfont.bodyText
		}

		ZWaveSecurityInfoButton {
			id: infoSecurityButton
			Layout.preferredWidth: width
			deviceUuid: p.uuid
		}

		SingleLabel {
			id: softwareLabel
			Layout.preferredWidth: labelsColumn.labelWidth
			Layout.row: 2
			leftText: qsTr("Software version")
			rightText: app.deviceInfo[p.uuid] ? app.deviceInfo[p.uuid].SoftwareVersion : "-"
			rightTextSize: qfont.bodyText
		}

		IconButton {
			id: updateButton
			Layout.preferredWidth: width
			primary: true
			iconSource: "qrc:/images/update.svg"
			topClickMargin: 3
			bottomClickMargin: topClickMargin
			visible: app.deviceInfo[p.uuid] ? app.deviceInfo[p.uuid].UpdateAvailable : false

			onClicked: stage.openFullscreen(app.maUpdateScreenUrl, {uuid: p.uuid})
		}

		SingleLabel {
			id: signalStrengthLabel
			Layout.preferredWidth: labelsColumn.labelWidth
			Layout.row: 3
			leftText: qsTr("Signal strength")
			rightTextSize: qfont.bodyText

			Row {
				id: signalStrengthRow
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(5 * horizontalScaling)
				}

				Repeater {
					id: signalStrengthStars
					model: 5

					Image {
						source: "image://scaled/images/star-" + (index < p.starCount ? "on" : "off") + ".svg"
					}
				}
			}

			states: [
				State {
					name: "HEALTHTEST_IDLE"
					when: !zWaveUtils.networkHealth.active
					PropertyChanges {target: signalStrengthRow; visible: true}
				},
				State {
					name: "HEALTHTEST_BUSY"
					when: (zWaveUtils.networkHealth.active && (zWaveUtils.networkHealth.uuid === p.uuid))
					PropertyChanges {target: signalStrengthLabel; rightText: zWaveUtils.networkHealth.progress + "%"}
					PropertyChanges {target: signalStrengthRow; visible: false}
					PropertyChanges {target: signalStrengthThrobber; visible: true}
					PropertyChanges {target: signalStrengthButton; visible: false}
				},
				State {
					when: (zWaveUtils.networkHealth.active && (zWaveUtils.networkHealth.uuid !== p.uuid))
					name: "HEALTHTEST_DISABLED"
					PropertyChanges {target: signalStrengthLabel; rightText: ""}
					PropertyChanges {target: signalStrengthRow; visible: true}
					PropertyChanges {target: signalStrengthThrobber; visible: false}
					PropertyChanges {target: signalStrengthButton; enabled: false}
				}
			]
		}

		Throbber {
			id: signalStrengthThrobber
			width: designElements.buttonSize
			height: signalStrengthLabel.height
			visible: false
		}

		IconButton {
			id: signalStrengthButton
			Layout.preferredWidth: width
			iconSource: "qrc:/images/refresh.svg"
			topClickMargin: 3
			bottomClickMargin: topClickMargin

			onClicked: zWaveUtils.doNodeHealthTest(p.uuid)
		}

		SingleLabel {
			id: energySourcesEditLabel
			Layout.preferredWidth: labelsColumn.labelWidth
			Layout.row: 4
			leftText: qsTr("Energy sources")

			Row {
				id: energySourcesIconsRow
				anchors {
					right: parent.right
					rightMargin: designElements.hMargin5
					verticalCenter: parent.verticalCenter
				}
				spacing: Math.round(4 * horizontalScaling)

				Repeater {
					id: energySourcesIconsRepeater
					model: app.enabledUtilities

					Image {
						source: "image://scaled/apps/eMetersSettings/drawables/status-" + modelData + "-" +
								(app.hasUsageOfType(p.usageDevice, modelData) ? "on" : "off") + ".svg"
					}
				}
			}
		}

		IconButton {
			id: energySourcesEditButton
			Layout.preferredWidth: width
			iconSource: "qrc:/images/edit.svg"
			topClickMargin: 3
			bottomClickMargin: topClickMargin

			onClicked: stage.openFullscreen(app.manualConfigurationScreenUrl, {uuid: p.uuid})
		}
	}

	Rectangle {
		id: detailsBg
		anchors {
			left: labelsColumn.right
			leftMargin: Math.round(20 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		visible: p.usageDevice ? p.usageDevice.usage.length : false
		color: colors.contrastBackground
		radius: designElements.radius
		height: detailsColumn.height + (detailsColumn.anchors.topMargin * 2)
		onHeightChanged: {
			if (height + labelsColumn.anchors.topMargin <= parent.height) {
				anchors.verticalCenter = undefined;
				anchors.top = labelsColumn.top;
			} else {
				anchors.top = undefined;
				anchors.verticalCenter = parent.verticalCenter;
			}
		}

		Column {
			id: detailsColumn
			anchors {
				top: parent.top
				topMargin: designElements.vMargin10
				left: parent.left
				leftMargin: designElements.vMargin10
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			spacing: designElements.vMargin10

			Repeater {
				id: utilitiesRepeater
				model: p.usageDevice ? p.usageDevice.usage : undefined

				Column {
					id: utilityColumn
					width: parent ? parent.width : undefined
					spacing: designElements.vMargin6

					Rectangle {
						width: height
						height: Math.round(30 * verticalScaling)
						radius: height / 2
						color: colors.white

						Image {
							source: "image://scaled/apps/eMetersSettings/drawables/status-" + modelData.type + "-on.svg"
							anchors.centerIn: parent
						}
					}

					SingleLabel {
						id: meterTypeLabel
						width: parent.width
						leftText: qsTr("Type")
						rightText: p.getMeasureTypeString(modelData) // ew
						rightTextSize: qfont.bodyText

						OptionToggle {
							id: analogMeterType
							anchors {
								verticalCenter: parent.verticalCenter
								right: parent.right
								rightMargin: designElements.hMargin6
							}
							visible: modelData.meterType !== undefined  && Constants.cValueUnits[modelData.type].length === 2
							sliderWidth: Math.round(32 * verticalScaling)
							sliderHeight: Math.round(20 * verticalScaling)
							knobWidth: sliderHeight - 4
							leftSpacing: designElements.hMargin6
							rightSpacing: leftSpacing
							fontPixelSize: qfont.programText

							onSelectedChangedByUser: {
								var newMeterType = positionIsLeft ? Constants.ELEC_METER_TYPE.DISK : Constants.ELEC_METER_TYPE.PULSE;
								if (newMeterType !== modelData.meterType) {
									app.setDividerMeterType(p.uuid, modelData.type, newMeterType);
								}
							}
							Component.onCompleted: {
								if (visible) {
									selected = (modelData.meterType === Constants.ELEC_METER_TYPE.PULSE);
									rightText = Constants.cValueUnits[modelData.type][0].name;
									leftText = Constants.cValueUnits[modelData.type][1].name;
								}
							}
						}
					}

					Item {
						id: cValueItem
						width: parent.width
						height: childrenRect.height
						visible: modelData.dividerType !== undefined

						SingleLabel {
							id: cValueLabel
							anchors {
								left: parent.left
								right: cValueButton.left
								rightMargin: designElements.hMargin6
							}
							leftText: qsTr("Value")
							rightText: parent.visible ? app.getDividerString(modelData.type, modelData.dividerType, modelData.divider, true) : ""
							rightTextSize: qfont.bodyText
						}

						IconButton {
							id: cValueButton
							iconSource: "qrc:/images/edit.svg"
							anchors.right: parent.right
							bottomClickMargin: 3
							onClicked: stage.openFullscreen(app.eMeterIndicationScreenUrl, {resource: modelData.type, meterType: modelData.meterType, uuid: p.uuid, editing: true})
						}
					}
				}
			}
		}
	}

	Image {
		id: senhorPerguntaImg
		anchors {
			right: parent.right
			rightMargin: Math.round(90 * horizontalScaling)
			bottom: parent.bottom
			bottomMargin: Math.round(40 * verticalScaling)
		}
		visible: !detailsBg.visible
		source: "image://scaled/apps/eMetersSettings/drawables/senorpergunta.svg"
	}
}
