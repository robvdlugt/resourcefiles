import QtQuick 2.1
import BasicUIControls 1.0;

import qb.components 1.0

Screen {
	id: strvDeviceDetailsScreen

	property StrvSettingsApp app

	property string devUuid
	property var device: ({"uuid": "", "name": "", "hasCommunicationError": true, "batteryLevel": null})

	screenTitleIconUrl: ""
	screenTitle: qtUtils.escapeHtml(device.name)
	isSaveCancelDialog: false

	onShown: {
		if (args && args.uuid) {
			devUuid = args.uuid;
			app.getDevices();
			refresh();
		}
	}

	Connections {
		target: app
		onStrvDevicesListChanged: refresh();
	}

	function refresh() {
		var myDevice = app.getDeviceByUuid(devUuid);
		if (myDevice)
			device = myDevice;
	}

	function setName(text) {
		var tmpDevice = device;
		tmpDevice.name = text;
		device = tmpDevice;
		app.setDeviceName(device.uuid, text);
	}

	function getBatteryLevelText(hasCommunicationError, batteryLevel) {
		if (app.isInvalidBatteryLevel(hasCommunicationError, batteryLevel) || batteryLevel === 0) {
			return "";
		}
		else {
			return batteryLevel + "%";
		}
	}

	Column {
		id: contentColumn
		anchors {
			left: parent.left
			right: parent.right
			leftMargin: Math.round(150 * horizontalScaling)
			rightMargin: anchors.leftMargin
			top: parent.top
			topMargin: Math.round(100 * verticalScaling)
		}
		spacing: designElements.vMargin6

		EditTextLabel {
			id: nameLabel
			width: parent.width
			labelText: qsTr("Name")
			prefilledText: device.name
			maxLength: app._STRV_NAME_MAX_LENGTH
			showAcceptButton: true
			validator: RegExpValidator { regExp: /[^&<>"']+/ } // & and empty name are not allowed

			onInputAccepted: setName(inputText)
		}

		SingleLabel {
			id: statusLabel
			width: parent.width
			leftText: qsTr("Status")
			rightText: !device.hasCommunicationError ? qsTr("Connected") : qsTr("Not connected")
		}

		SingleLabel {
			id: batteryLabel
			width: parent.width
			leftText: qsTr("Battery")

			Image {
				id: batteryStatus
				anchors {
					right: parent.right
					rightMargin: designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}
				source: app.getBatteryImage(device.hasCommunicationError, device.batteryLevel);
			}

			Text {
				id: batteryValue
				anchors {
					right: batteryStatus.left
					rightMargin: designElements.hMargin6
					verticalCenter: parent.verticalCenter
				}
				font.family: qfont.regular.name
				font.pixelSize: qfont.bodyText
				text: getBatteryLevelText(device.hasCommunicationError, device.batteryLevel)
			}
		}
	}

	IconButton {
		id: infoButton
		anchors {
			left: contentColumn.right
			leftMargin: contentColumn.spacing
			bottom: contentColumn.bottom
		}
		iconSource: "qrc:/images/info.svg"
		primary: true
		visible: device.hasCommunicationError

		onClicked: app.showNoConnectionPopup()
	}

	WarningBox {
		anchors {
			left: contentColumn.left
			right: contentColumn.right
			top: contentColumn.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		autoHeight: true
		warningText: qsTr("strv-low-battery-warning")
		visible: device.batteryLevel !== null && device.batteryLevel <= app._STRV_LOW_BATTERY_THRESHOLD
	}

	StandardButton {
		id: identifyButton

		visible: false // TODO: disabled while we investigate if this functionality is available on our selected STRV type

		text: qsTr("Identify")
		primary: true
		enabled: !device.hasCommunicationError
		onClicked: {
			console.log("identifyButton.onClicked()");
		}

		minWidth: Math.round(120 * horizontalScaling)

		anchors {
			top: contentColumn.bottom
			topMargin: designElements.vMargin20
			left: contentColumn.left
		}
	}
}
