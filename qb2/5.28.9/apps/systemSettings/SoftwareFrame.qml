import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: softwareFrame
	anchors.fill: parent

	onShown: {
		app.getDeviceInfo();
		app.checkFirmwareUpdate();
	}

	Item {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			bottom:parent.bottom
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}

		SingleLabel {
			id: softwareVersionLabel
			anchors {
				top: parent.top
				left: parent.left
				right: toonUpdateButton.left
				rightMargin: designElements.hMargin6
			}
			leftText: qsTr("Software version")
			rightText: app.displayInfo['SoftwareVersion']
		}

		Throbber {
			id: checkingUpdateThrobber
			anchors {
				top: toonUpdateButton.top
				left: toonUpdateButton.left
			}
			width: height
			height: toonUpdateButton.height
			visible: app.displayInfo['CheckingForUpdate']
		}

		StandardButton {
			id: toonUpdateButton
			width: Math.round(88 * horizontalScaling)
			anchors {
				top: softwareVersionLabel.top
				right: parent.right
			}
			text: qsTr("Update")
			visible: app.displayInfo['UpdateAvailable']

			onClicked: {
				stage.openFullscreen(app.softwareUpdateScreenUrl);
			}
		}

		SingleLabel {
			id: boilerFirmwareLabel
			anchors {
				top: softwareVersionLabel.bottom
				topMargin: designElements.vMargin6
				left: parent.left
				right: boilerUpdateButton.left
				rightMargin: designElements.hMargin6
			}
			leftText: qsTr("Boiler firmware")
			rightText: app.boilerAdapterInfo['SoftwareVersion']
			visible: globals.heatingMode === "central"
		}

		StandardButton {
			id: boilerUpdateButton
			anchors {
				top: boilerFirmwareLabel.top
				left: toonUpdateButton.left
				right: toonUpdateButton.right
			}
			text: qsTr("Update")
			visible: app.boilerAdapterInfo['UpdateAvailable'] && globals.heatingMode === "central"
		}

		DoubleLabel {
			id: factorySettings
			anchors {
				top: boilerFirmwareLabel.bottom
				topMargin: Math.round(50 * verticalScaling)
				left: parent.left
				right: recoverButton.left
				rightMargin: designElements.hMargin6
			}
			visible: !app.disableFactoryReset
			topText: qsTr("Factory settings")
			bottomText: qsTr("All data and settings will be erased")
		}

		StandardButton {
			id: recoverButton
			anchors {
				top: factorySettings.top
				left: toonUpdateButton.left
				right: toonUpdateButton.right
			}
			text: qsTr("Recover")
			visible: !app.disableFactoryReset

			onClicked: {
				stage.openFullscreen(app.factoryResetScreenUrl);
			}
		}

		DoubleLabel {
			id: toonRestart
			anchors {
				top: factorySettings.visible ? factorySettings.bottom : factorySettings.top
				topMargin: factorySettings.visible ? Math.round(6 * verticalScaling) : 0
				left: parent.left
				right: restartButton.left
				rightMargin: designElements.hMargin6
			}
			topText: qsTr("Toon restart")
			bottomText: qsTr("All data and settings will be preserved")

		}

		StandardButton {
			id: restartButton
			anchors {
				top: toonRestart.top
				left: toonUpdateButton.left
				right: toonUpdateButton.right
			}
			text: qsTr("Restart")

			onClicked: {
				stage.openFullscreen(app.restartScreenUrl);
			}
		}
	}
}
