import QtQuick 2.1

import BasicUIControls 1.0;
import qb.components 1.0

Screen {
	id: selectSolarEMeterScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Select energy meter")
	isSaveCancelDialog: true
	synchronousSave: true
	inNavigationStack: false

	property EMetersSettingsApp app

	QtObject {
		id: p
		property string selectDevice
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		// Disable until we have one selected
		if (radioButtonGroup.currentControlId === -1) {
			disableSaveButton();
		}
		if (args && args.selectDevice)
			p.selectDevice = args.selectDevice;
		app.getDeviceInfo();
		app.getSensorConfiguration();
		refreshList();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		maDeviceList.removeAll();
	}

	onSaved: {
		if (radioButtonGroup.currentControlId === -1) {
			return;
		} else {
			showSaveThrobber(true);
			var meterAdapterIndex = radioButtonGroup.currentControlId;
			var meterAdapterUuid = app.maDevices[meterAdapterIndex].uuid;
			app.solarWizardUuid = meterAdapterUuid;
			app.getDividerConfigurable(meterAdapterUuid, "analogSolar", function (msg) {
				showSaveThrobber(false);
				var hasDivider = true;
				if (msg) {
					var success = msg.getArgument("success");
					var configurable = msg.getArgument("configurable");
					if (success === "true" && configurable !== "true")
						hasDivider = false;
				}
				if (hasDivider)
					stage.openFullscreenInner(app.eMeterIndicationScreenUrl, {from: "solarwizard", resource: "solar", uuid: meterAdapterUuid}, false);
				else
					stage.openFullscreenInner(app.estimatedGenerationScreenUrl, {from: "solarwizard"}, false);
			});
		}
	}

	function deviceHasAnalogElectricty(uuid) {
		var hasAnalogElectricty = false;

		for (var idx = 0; idx < app.maConfiguration.length; idx++) {
			if (app.maConfiguration[idx].deviceUuid === uuid) {
				hasAnalogElectricty = (app.maConfiguration[idx].sensors.indexOf("analogElec") !== -1);
				break;
			}
		}

		return hasAnalogElectricty;
	}

	function refreshList() {
		maDeviceList.removeAll();

		var showPage = -1;
		for (var idx = 0; idx < app.maDevices.length; idx++) {
			// If the device already has analog electrity configured, disable its item.
			var itemState = deviceHasAnalogElectricty(app.maDevices[idx].uuid) ? "disabled" : "enabled";
			maDeviceList.addDevice({"index": idx, "device": app.maDevices[idx], "uuid": app.maDevices[idx].uuid, "aState": itemState});
		}

		maDeviceList.refreshView();

		// Jump to the right page
		if (showPage === -1)
			showPage = 0;
		maDeviceList.goToPage(showPage);
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true
		onCurrentControlIdChanged: enableSaveButton();
	}

	Text {
		id: titleText

		text: qsTr("Select an energy meter or add a new one.")

		wrapMode: Text.WordWrap

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(60 * horizontalScaling)
		}
	}

	SmartDeviceList {
		id: maDeviceList
		width: Math.round(576 * horizontalScaling)
		anchors {
			left: titleText.left
			top: titleText.bottom
			topMargin: Math.round(30 * verticalScaling)
			bottom: parent.bottom
			bottomMargin: Math.round(30 * verticalScaling)
		}

		delegate: energyMeterDetailsDelegate
		addDeviceText: qsTr("Add energy meter")

		itemHeight: Math.round(74 * verticalScaling)
		addItem.anchors.leftMargin: Math.round(46 * horizontalScaling)

		onAddDeviceClicked: {
			stage.openFullscreen(app.addDeviceScreenUrl, {state: "meteradapter", from: "solarwizard"});
		}
	}


	Component {
		id: energyMeterDetailsDelegate

		Item {
			id: meterRoot
			width:  childrenRect.width
			height: childrenRect.height

			property int idx: index
			property string uuid: app.maDevices[idx].uuid

			state: aState // Populated from refreshList()
			states: [
				State {
					name: "enabled"
				},
				State {
					name: "disabled"
					PropertyChanges { target: maRadioButton; visible: false}
					PropertyChanges { target: maLabel; leftTextColor: "gray"}
					PropertyChanges { target: maLabel; rightTextColor: "gray"}
				}
			]

			Text {
				id: maNameLabel

				text: qsTr("Energy meter %1").arg(meterRoot.idx + 1)
				font {
					family: qfont.bold.name
					pixelSize: qfont.titleText
				}

				anchors {
					top: parent.top
					left: maLabel.left
				}
			}

			StandardRadioButton {
				id: maRadioButton
				controlGroup: radioButtonGroup

				width: Math.round(40 * horizontalScaling)

				text: ""

				anchors {
					left: parent.left
					verticalCenter: maLabel.verticalCenter
				}

				Component.onCompleted: {
					if (p.selectDevice === parent.uuid)
						selected = true;
				}

			}
			SingleLabel {
				id: maLabel

				width: Math.round(530 * horizontalScaling)

				leftText: app.getDeviceSerialNumber(meterRoot.uuid)
				rightText: app.getInformationSourceStatus(meterRoot.uuid)

				rightTextFont: qfont.light.name
				rightTextSize: qfont.bodyText

				anchors {
					top: maNameLabel.bottom
					topMargin: designElements.vMargin6
					bottomMargin: designElements.vMargin6
					left: maRadioButton.right
					leftMargin: designElements.hMargin6
				}

				MouseArea {
					id: maLabelMA
					anchors.fill: parent
					enabled: maRadioButton.visible
					onClicked: { maRadioButton.selected = true }
				}

			}
		}
	}
}
