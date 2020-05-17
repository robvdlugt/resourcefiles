import QtQuick 2.0

import qb.base 1.0
import qb.components 1.0

Screen {
	screenTitle: qsTranslate("AddStrvWizardScreen", "Install smart radiator valves")
	hasHomeButton: false
	hasBackButton: false
	anchors.fill: parent

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Continue"))
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.strvMountDevicesScreenUrl)
	}

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Math.round(35 * verticalScaling)
			left: parent.left
			leftMargin: anchors.topMargin
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
		text: qsTr("Connected smart radiator valves")
	}

	DeviceList {
		id: deviceList
		anchors {
			top: titleText.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
			right: parent.right
			leftMargin: Math.round(111 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		itemsPerPage: 5
		maxItems: 10
		addDeviceLabelWidth: Math.round(537 * horizontalScaling)

		model: app.getMultipleDevicesByUuid(app.strvJustAddedUuids)
		delegate: strvDeviceListDelegate

		addDeviceText: qsTr("Connect another")
		onAddDeviceClicked: stage.openFullscreen(app.addStrvWizardScreenUrl)
	}

	WarningBox {
		id: warningBox
		anchors {
			left: deviceList.left
			bottom: parent.bottom
			bottomMargin: Math.round(45 * verticalScaling)
		}
		width: deviceList.addDeviceLabelWidth
		autoHeight: true

		warningText: qsTr("You can first connect all the valves you have before continuing.")
		warningIcon: "image://scaled/images/info_warningbox.svg"
	}

	Component {
		id: strvDeviceListDelegate
		Row {
			height: deviceLabel.height
			spacing: ListView.view ? ListView.view.spacing : 0

			SingleLabel {
				id: deviceLabel
				width: deviceList.addDeviceLabelWidth
				leftText: modelData.name
				leftTextFormat: Text.PlainText // Prevent XSS/HTML injection

				onClicked: editButton.clicked()

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
					stage.openFullscreen(app.addStrvWizardScreenUrl, {"frameUrl": app.addNameDeviceFrameUrl, "deviceUuid": modelData.uuid})
				}
			}
		}
	}
}
