import QtQuick 2.1

import BasicUIControls 1.0;
import qb.components 1.0

Screen {
	id: strvOverviewScreen
	screenTitle: qsTr("Smart radiator valves")
	property StrvSettingsApp app

	onShown: {
		app.getDevices();
	}

	QtObject {
		id: p

		property string removedDevUuid

		function openRemoveDeviceScreen(uuid, name) {
			stage.openFullscreen(app.strvRemoveDeviceScreenUrl, {"uuid": uuid, "screenTitle": qsTr("Disconnect %1").arg(name), postSuccessCallbackFcn: util.partialFn(removeSucceededCallbackFcn, uuid)});
		}

		function removeSucceededCallbackFcn(devUuid) {
			// We received the callback that a device has been removed, but for the moment we
			// still have that STRV devices in our list.
			// Let's start a timer to check the status of the device until we notice that it has
			// been removed from the list.
			if (app.getDeviceByUuid(devUuid) !== undefined) {
				removedDevUuid = devUuid;
				postRemoveRefreshTimer.start();
			}
		}
	}

	Timer {
		id: postRemoveRefreshTimer
		interval: 1000
		repeat: true
		triggeredOnStart: true

		property int repeatCount: 0
		property int maxRepeatCount: 10

		onTriggered: {
			if (app.getDeviceByUuid(p.removedDevUuid) === undefined || repeatCount >= maxRepeatCount) {
				postRemoveRefreshTimer.stop();
				repeatCount = 0;
			} else {
				app.getDevices();
				repeatCount += 1;
			}
		}
	}

	Component {
		id: strvDeviceListDelegate
		Row {
			// Typical properties that are populated for each device:
			// uuid
			// name
			// batteryLevel
			// hasCommunicationError
			height: deviceLabel.height
			spacing: ListView.view ? ListView.view.spacing : 0

			SingleLabel {
				id: deviceLabel
				width: deviceList.addDeviceLabelWidth
				leftText: modelData.name
				leftTextFormat: Text.PlainText // Prevent XSS/HTML injection

				onClicked: editButton.clicked()

				Text {
					id: connectionStatus
					anchors {
						right: batteryStatus.left
						rightMargin: designElements.hMargin10
						verticalCenter: parent.verticalCenter
					}
					font.family: qfont.regular.name
					font.pixelSize: qfont.bodyText
					text: !modelData.hasCommunicationError ? qsTr("Connected") : qsTr("Not connected")
				}

				Image {
					id: batteryStatus
					anchors {
						right: parent.right
						rightMargin: designElements.hMargin10
						verticalCenter: parent.verticalCenter
					}
					source: app.getBatteryImage(modelData.hasCommunicationError, modelData.batteryLevel)
				}
			}

			IconButton {
				id: editButton
				iconSource: "qrc:/images/edit.svg"
				onClicked: {
					stage.openFullscreen(app.deviceDetailsScreen, {"uuid": modelData.uuid});
				}
			}

			IconButton {
				id: deleteButton
				iconSource: "qrc:/images/delete.svg"
				onClicked: {
					p.openRemoveDeviceScreen(modelData.uuid, modelData.name);
				}
			}

			IconButton {
				id: infoButton
				iconSource: "qrc:/images/info.svg"
				primary: true
				visible: modelData.hasCommunicationError

				onClicked: app.showNoConnectionPopup()
			}
		}
	}

	DeviceList {
		id: deviceList
		anchors {
			left: parent.left
			right: parent.right
			leftMargin: Math.round(150 * horizontalScaling)
			rightMargin: Math.round(108 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
		}

		visible: ! postRemoveRefreshTimer.running

		itemsPerPage: 6
		maxItems: 10
		addDeviceLabelWidth: Math.round(416 * horizontalScaling)

		model: app.strvDevicesList
		delegate: strvDeviceListDelegate

		addDeviceText: qsTr("Add a smart radiator valve")
		onAddDeviceClicked: stage.openFullscreen(app.addStrvWizardScreenUrl);
	}

	Throbber {
		id: updateThrobber
		anchors {
			top: deviceList.top
			horizontalCenter: deviceList.horizontalCenter
		}
		visible: ! deviceList.visible
	}
}
