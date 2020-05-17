import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: dhwFrame
	property DomesticHotWaterApp app

	anchors.fill: parent;

	QtObject {
		id: p
		property bool doHeat: (globals.productOptions["district_heating"] === "1")
	}

	onShown: {
		app.getDWHInfo();
	}

	Item {
		id: labelsContainer

		anchors {
			fill: parent
			leftMargin: Math.round(44 * horizontalScaling)
			rightMargin: Math.round(27 * horizontalScaling)
		}

		Item {
			id: hotWaterTankContainer
			visible: globals.thermostatFeatures["FF_Dhw_UiElements_Settings"]

			height: childrenRect.height
			anchors {
				top: parent.top
				topMargin: Math.round(20 * verticalScaling)
				left: parent.left
				right: parent.right
				bottomMargin: Math.round(20 * verticalScaling)
			}

			Text {
				id: hotWaterTankTitle
				text: qsTr("Hot water tank")
				color: colors.dhwTitleText

				font {
					family: qfont.semiBold.name
					pixelSize: qfont.navigationTitle
				}

				anchors {
					top: parent.top
					left: parent.left
					right: parent.right
				}
			}

			SingleLabel {
				id: dhwControlsSingleLabel

				anchors {
					top: hotWaterTankTitle.baseline
					topMargin: Math.round(20 * verticalScaling)
					left: parent.left
					right: dhwControlsButton.left
					rightMargin: designElements.hMargin6
				}

				leftText: qsTr("Hot water controls")
				rightText: globals.thermostatFeatures["FF_Dhw_UiElements"] ? qsTr("Show") : qsTr("Hide")
			}

			IconButton {
				id: dhwControlsButton
				width: designElements.buttonSize
				anchors {
					bottom: dhwControlsSingleLabel.bottom
					right: parent.right
				}
				iconSource: "qrc:/images/edit.svg"
				onClicked: {
					stage.openFullscreen(app.hotWaterControlSwitchScreenUrl);
				}
			}
		}

		Item {
			id: openTermLabels
			height: childrenRect.height
			anchors {
				top: hotWaterTankContainer.visible ? hotWaterTankContainer.bottom : parent.top
				topMargin: Math.round(20 * verticalScaling)
				left: parent.left
				right: parent.right
			}
			visible: globals.thermostatFeatures["FF_Dhw_PreHeat_Settings"]

			SingleLabel {
				id: dhwTempLabel

				leftText: qsTr("DHW temperature")
				rightText: isNaN(parseFloat(app.boilerInfo.dhwTemp)) ? "-" : (i18n.number(parseFloat(app.boilerInfo.dhwTemp), 0) + '°');

				anchors {
					top: parent.top
					left: parent.left
					right: dhwTempButton.left
					rightMargin: designElements.hMargin6
				}
			}

			IconButton {
				id: dhwTempButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: dhwTempLabel.bottom
					right: parent.right
				}
				onClicked: {
					stage.openFullscreen(app.dhwTemperatureSettingScreenUrl);
				}
			}

			SingleLabel {
				id: preheatLabel

				leftText: qsTr("Preheat DHW")

				anchors {
					top: dhwTempLabel.bottom
					topMargin: designElements.vMargin6
					left: dhwTempLabel.left
					right:dhwTempLabel.right
				}

				OnOffToggle {
					id: preheatoggle
					leftTextOff: qsTr("Off")
					rightTextOn: qsTr("On")

					anchors {
						verticalCenter: parent.verticalCenter
						right: parent.right
						rightMargin: 13
					}

					onSelectedChangedByUser: {
						app.setDHWEnabled(isSwitchedOn);
					}

					selected: app.boilerInfo.dhwPreheat
				}
			}
		}
	}
}
