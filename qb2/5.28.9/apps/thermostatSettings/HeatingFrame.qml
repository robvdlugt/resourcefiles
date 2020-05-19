import QtQuick 2.1

import BasicUIControls 1.0
import qb.base 1.0
import qb.components 1.0

Widget {
	id: heatingFrame

	property ThermostatSettingsApp app

	QtObject {
		id: p
		// This array contains mapping of heating type names (value in array) to bxt values (array index)
		property var heatingTypeMap: [
			qsTranslate("HeatingInstSelectScreen", "Manual"),
			qsTranslate("HeatingInstSelectScreen", "Manual"),
			qsTranslate("HeatingInstSelectScreen", "Manual"),
			qsTranslate("HeatingInstSelectScreen", "Default")
		]

		property bool allowHeatingSourceTypeChange: feature.enabledHeatingSourceConfiguration()

		function getHeatingSourceTypeString() {
			var fuelType = app.heatingSourceType;
			switch (fuelType) {
			case app._HEATINGTYPE_GAS:
				return qsTranslate("HeatingTypeSelectScreen", "heatingType-gas");
			case app._HEATINGTYPE_OIL:
				return qsTranslate("HeatingTypeSelectScreen", "heatingType-oil");
			case app._HEATINGTYPE_ELECTRIC:
				return qsTranslate("HeatingTypeSelectScreen", "heatingType-elec");
			case app._HEATINGTYPE_HEATPUMP:
				return qsTranslate("HeatingTypeSelectScreen", "heatingType-elecHeatPump");
			case app._HEATINGTYPE_COLLECTIVE:
				return qsTranslate("HeatingTypeSelectScreen", "heatingType-collective");
			case app._HEATINGTYPE_UNKNOWN:
			default:
				return qsTr("Unknown");
			}
		}
	}

	onShown: {
		app.getTempDeviationInfo();
		app.getHeatInstInfo();
		app.getDWHInfo();
		zWaveUtils.getDevices();
	}

	anchors.fill: parent

	Column {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		Item {
			width: parent.width
			height: childrenRect.height
			visible: app.doHeat || app.hasHeatRecovery || (p.allowHeatingSourceTypeChange && !app.boilerInfo.otBoiler)

			SingleLabel {
				id: heatingTypeLabel
				anchors {
					left: parent.left
					right: editTypeButton.visible ? editTypeButton.left : parent.right
					rightMargin: editTypeButton.visible ? designElements.hMargin6 : 0
				}
				leftText: qsTr("Heating type")
				rightText: getHeatingTypeString()

				function getHeatingTypeString() {
					if (app.doHeat)
						return (app.hasSmartHeat || app.doSetupSmartHeat) ? qsTr("Smart District Heat") : qsTr("District Heat");
					else if (app.hasHeatRecovery)
						return qsTr("Heat Recovery");
					else if (p.allowHeatingSourceTypeChange)
						return p.getHeatingSourceTypeString();
					else
						return "";
				}
			}

			IconButton {
				id: editTypeButton
				width: designElements.buttonSize
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"
				visible: (app.doHeat && isWizardMode) || (p.allowHeatingSourceTypeChange && !app.boilerInfo.otBoiler && !app.hasHeatRecovery)

				onClicked: {
					if(app.doHeat)
						stage.openFullscreen(app.districtHeatingTypeSelectScreenUrl);
					else
						stage.openFullscreen(app.heatingTypeSelectScreenUrl);
				}
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height
			visible: !app.doHeat

			SingleLabel {
				id: controlingBoilerLabel
				anchors {
					left: parent.left
					right: verifyButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Boiler control")
				rightText: (app.boilerModuleType !== 1) ? qsTr("On/Off") : ""

				OptionToggle {
					id: boilerToggle
					enabled: !app.hasHeatRecovery
					mouseEnabled: false
					visible: (app.boilerModuleType === 1)

					leftText: qsTr("OpenTherm")
					rightText: qsTr("On/Off")
					backgroundColorRight: colors.onOffToggleRight
					shadowColorRight: colors.onOffToggleRightShadow
					backgroundColorLeft: backgroundColorRight
					shadowColorLeft: shadowColorRight

					selected: !app.boilerInfo.otBoiler

					anchors {
						verticalCenter: parent.verticalCenter
						right: parent.right
						rightMargin: designElements.hMargin10
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							if (parent.positionIsLeft)
							{
								app.setBoilerType(false);
							}
						}
					}
				}
			}

			IconButton {
				id: verifyButton
				width: designElements.buttonSize
				anchors {
					bottom: controlingBoilerLabel.bottom
					right: parent.right
				}
				iconSource: "qrc:/images/refresh.svg"
				enabled: (app.boilerModuleType === 1)

				onClicked: {
					app.testBoilerType();
				}
				visible: !app.testingBoilerType
			}

			Throbber {
				id: verifyThrobber

				height: verifyButton.height
				width: verifyButton.height

				anchors.centerIn: verifyButton
				visible: app.testingBoilerType
			}
		}

		Item {
			width: parent.width
			visible: app.doHeat && (app.hasSmartHeat || app.doSetupSmartHeat)
			height: childrenRect.height

			SingleLabel {
				id: districtHeatLabel
				anchors {
					left: parent.left
					right: addSmartHeatButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Smart Heat module")
			}

			StandardButton {
				id: addSmartHeatButton
				visible: false
				height: districtHeatLabel.height
				anchors {
					right: parent.right
					bottom: districtHeatLabel.bottom
				}
				text: qsTr("Install")
				onClicked: stage.openFullscreen(app.addDeviceScreenUrl, {state: "smartHeatModule"})
			}

			IconButton {
				id: deleteSmartHeatButton
				visible: false
				width: designElements.buttonSize
				anchors {
					right: parent.right
					bottom: districtHeatLabel.bottom
				}
				iconSource: "qrc:/images/delete.svg"
				onClicked: stage.openFullscreen(app.districtHeatingRemoveDeviceScreenUrl, {uuid: app.heatingDevices[0].uuid});
			}

			state: app.heatingDevices.length === 0 ? "notInstalled" : "installed"
			states: [
				State {
					name: "notInstalled"
					PropertyChanges { target: districtHeatLabel; rightText: qsTr("Not installed"); onClicked: addSmartHeatButton.clicked() }
					PropertyChanges { target: addSmartHeatButton; visible: true }
				},
				State {
					name: "installed"
					PropertyChanges {
						target: districtHeatLabel
						rightText: app.heatingDevices[0].IsConnected ? qsTr("Connected") : qsTr("Not connected")
						anchors.right: deleteSmartHeatButton.left }
					PropertyChanges { target: deleteSmartHeatButton; visible: true }
				}
			]
		}

		Item {
			id: spacer
			width: parent.width
			height: Math.round(18 * verticalScaling)
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: tempDeviationLabel

				leftText: qsTr("Temperature deviation")
				rightText: isNaN(parseFloat(app.boilerInfo.tempDeviation)) ? "-" : (i18n.number(parseFloat(app.boilerInfo.tempDeviation), 1) + '°');

				anchors {
					left: parent.left
					right:tempDeviationButton.left
					rightMargin: designElements.hMargin6
				}
			}

			IconButton {
				id: tempDeviationButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: tempDeviationLabel.bottom
					right: parent.right
				}
				onClicked: {
					stage.openFullscreen(app.temperatureCorrectionScreenUrl);
				}
			}
		}

		Item {
			id: openTermLabels
			width: parent.width
			height: childrenRect.height
			visible: app.boilerInfo.otBoiler && !app.doHeat

			SingleLabel {
				id: instTypeLabel

				leftText: qsTr("Heating installation")
				rightText: app.heatingInstInfo.type !== "-" ? p.heatingTypeMap[app.heatingInstInfo.type] : "-"

				anchors {
					left: parent.left
					right:instTypeButton.left
					rightMargin: designElements.hMargin6
				}
			}

			IconButton {
				id: instTypeButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: instTypeLabel.bottom
					right: parent.right
				}
				onClicked: {
					stage.openFullscreen(app.heatingInstSelectScreenUrl);
				}
			}
		}
	}
}
