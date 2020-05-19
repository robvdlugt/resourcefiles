import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

import "Constants.js" as Constants

Screen {
	id: meterConfigurationInstallScreen

	property EMetersSettingsApp app

	screenTitleIconUrl: ""
	screenTitle: qsTr("Configure metering type")
	isSaveCancelDialog: false

	QtObject {
		id: p

		property bool needsElecMeterConfiguration: false
		property bool needsGasMeterConfiguration: false
		property variant elecUsage
		property string elecUuid
		property variant gasUsage
		property string gasUuid
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		app.getAllMeterConfigurations();
		updateNeedsMeterConfiguration();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	Connections {
		target: app
		onUsageDevicesInfoChanged: {
			updateNeedsMeterConfiguration();
		}
	}

	function updateNeedsMeterConfiguration() {
		var _needsElecMeterConfiguration = false;
		var _needsGasMeterConfiguration = false;
		p.elecUuid = app.getAdapterUuidForMeter("elec");
		p.elecUsage = app.getUsageByType("elec").usage;
		p.gasUuid = app.getAdapterUuidForMeter("gas");
		p.gasUsage = app.getUsageByType("gas").usage;
		if (p.elecUsage && p.elecUsage.dividerType !== undefined)
			_needsElecMeterConfiguration = true;
		if (p.gasUsage && p.gasUsage.dividerType !== undefined)
			_needsGasMeterConfiguration = true;

		if (_needsElecMeterConfiguration) {
			analogElecMeterType.selected = (p.elecUsage.meterType === Constants.ELEC_METER_TYPE.PULSE);
			elecCValueLabel.rightText = app.getDividerString("elec", p.elecUsage.dividerType, p.elecUsage.divider, true);
		}
		if (_needsGasMeterConfiguration) {
			analogGasMeterType.selected = (p.gasUsage.meterType === Constants.GAS_METER_TYPE.PULSE);
			gasCValueLabel.rightText = app.getDividerString("gas", p.gasUsage.dividerType, p.gasUsage.divider, true);
		}
		p.needsElecMeterConfiguration = _needsElecMeterConfiguration;
		p.needsGasMeterConfiguration = _needsGasMeterConfiguration;
	}

	Column {
		id: contentColumn

		anchors {
			fill: parent
			leftMargin: Math.round(100 * horizontalScaling)
			rightMargin: Math.round(100 * horizontalScaling)
			topMargin: Math.round(70 * verticalScaling)
			bottomMargin: Math.round(100 * verticalScaling)
		}

		spacing: designElements.spacing10

		SingleLabel {
			id: elecMeterLabel
			leftText: qsTr("Electricity meter")
			anchors {
				left: parent.left
				right:	parent.right
				rightMargin: designElements.buttonSize + parent.spacing
			}
			visible: p.needsElecMeterConfiguration

			OptionToggle {
				id: analogElecMeterType

				leftText: qsTr("Rotating disc")
				rightText: qsTr("Pulse")

				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
					bottomMargin: designElements.vMargin10
				}

				onSelectedChangedByUser: {
					var newMeterType = positionIsLeft ? Constants.ELEC_METER_TYPE.DISK : Constants.ELEC_METER_TYPE.PULSE;
					if (newMeterType !== p.elecUsage.meterType) {
						app.setDividerMeterType(p.elecUuid, "elec", newMeterType);
					}
				}
			}
		}

		Item {
			id: elecCValueItem
			width: parent.width
			height: childrenRect.height
			visible: p.needsElecMeterConfiguration

			SingleLabel {
				id: elecCValueLabel

				leftText: qsTr("Value")
				rightText: ""

				anchors {
					left: parent.left
					right: elecCValueButton.left
					rightMargin: designElements.hMargin6
				}
			}
			IconButton {
				id: elecCValueButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: elecCValueLabel.bottom
					right: parent.right
				}
				bottomClickMargin: 3
				onClicked: {
					stage.openFullscreen(app.eMeterIndicationScreenUrl, {resource: "elec", uuid: p.elecUuid, meterType: p.elecUsage.meterType, editing: true});
				}
			}
		}

		Rectangle {
			id: spacer

			color: "transparent"
			height: designElements.vMargin10
			width: parent.width

			visible: p.needsElecMeterConfiguration
		}

		SingleLabel {
			id: gasMeterLabel
			leftText: qsTr("Gas meter")
			anchors {
				left: parent.left
				right:	parent.right
				rightMargin: designElements.buttonSize + parent.spacing
			}
			visible: p.needsGasMeterConfiguration

			OptionToggle {
				id: analogGasMeterType

				leftText: qsTr("Mechanical counter")
				rightText: qsTr("Pulse")

				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
					bottomMargin: designElements.vMargin10
				}

				onSelectedChangedByUser: {
					var newMeterType = positionIsLeft ? Constants.GAS_METER_TYPE.DISK : Constants.GAS_METER_TYPE.PULSE;
					if (newMeterType !== p.gasUsage.meterType) {
						app.setDividerMeterType(p.gasUuid, "gas", newMeterType);
					}
				}
			}
		}

		Item {
			id: gasCValueItem
			width: parent.width
			height: childrenRect.height
			visible: p.needsGasMeterConfiguration

			SingleLabel {
				id: gasCValueLabel

				leftText: qsTr("Value")
				rightText: ""

				anchors {
					left: parent.left
					right: gasCValueButton.left
					rightMargin: designElements.hMargin6
				}
			}
			IconButton {
				id: gasCValueButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors {
					bottom: gasCValueLabel.bottom
					right: parent.right
				}
				bottomClickMargin: 3
				onClicked: {
					var gasUuid = app.getAdapterUuidForMeter('gas');
					stage.openFullscreen(app.eMeterIndicationScreenUrl, {resource: "gas", uuid: p.gasUuid, meterType: p.gasUsage.meterType, editing: true});
				}
			}
		}
	}
}
