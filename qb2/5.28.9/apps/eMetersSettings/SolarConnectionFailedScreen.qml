import QtQuick 2.1
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: solarConnectionFailedScreen

	screenTitle: qsTr("Check solar connection")

	hasCancelButton: true
	hasHomeButton: false
	hasBackButton: false

	inNavigationStack: false

	QtObject {
		id: p

		function createSensorConfiguration() {
			// Get original meter adapter configuration
			var devices = app.maConfiguration;
			var curDevice = undefined;
			// Remove the device that we want to (re)configure (if any)
			for(var i = 0; i < devices.length; i++) {
				if(app.solarWizardUuid === devices[i].deviceUuid) {
					// array.splice returns a list of the removed items. Since we only
					// remove 1, we can immediately pull it from that returned list.
					curDevice = devices.splice(i,1)[0];
				}
			}

			if (curDevice === undefined) {
				// Something went wrong, we should have a device configured with solar here...
				console.log("Warning: Could not find device with solar matching", app.solarWizardUuid, "in device configuration.");
			} else {
				var tmpSensors = curDevice.sensors;
				var analogSolarIndex = tmpSensors.indexOf('analogSolar');
				if (analogSolarIndex !== -1) {
					tmpSensors.splice(analogSolarIndex, 1);
					curDevice.sensors = tmpSensors;
				} else {
					console.log("Warning: could not find 'analogSolar' in sensor configuration.");
				}

				curDevice.statusInt = curDevice.statusInt & (~Constants.CONFIG_STATUS.SOLAR);
				curDevice.status = app.getMaConfigurationStatusString(curDevice.statusInt);

				devices.push(curDevice);
			}

			return devices;
		}

		function cancelSolarConfiguration() {
			app.maConfiguration = p.createSensorConfiguration();
			app.sendSensorConfiguration(app.maConfiguration);
			hide();
		}
	}


	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCanceled: {
		p.cancelSolarConfiguration();
	}

	Text {
		anchors {
			left: parent.left
			leftMargin: Math.round(24 * horizontalScaling)
			bottom: backgroundRect.top
			bottomMargin: Math.round(13 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.addDeviceTitle
		text: qsTr("Connection failed")
	}

	Rectangle {
		id: backgroundRect
		height: Math.round(300 * verticalScaling)
		width: Math.round(756 * horizontalScaling)
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(21 * horizontalScaling)
		}
		radius: designElements.radius
		color: colors.addDeviceBackgroundRectangle

		Image {
			id: warningIcon
			source: "qrc:/images/bad.svg"
			anchors {
				top: parent.top
				topMargin: Math.round(25 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(13 * horizontalScaling)
			}
			height: Math.round(24 * verticalScaling)
			sourceSize {
				width: 0
				height: height
			}
		}
		Text {
			id: warningText
			anchors {
				verticalCenter: warningIcon.verticalCenter
				left: warningIcon.right
				leftMargin: Math.round(13 * horizontalScaling)
			}
			color: colors.addDeviceErrorText
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("warning_text")
		}

		NumberBullet {
			id: b1
			anchors {
				left: warningIcon.left
				top: warningIcon.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
		}
		Text {
			id: b1Text
			anchors {
				verticalCenter: b1.verticalCenter
				left: warningText.left
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("b1_text")
		}

		NumberBullet {
			id: b2
			anchors {
				left: warningIcon.left
				top: b1.bottom
				topMargin: Math.round(30 * verticalScaling)
			}
		}
		Text {
			id: b2Text
			anchors {
				verticalCenter: b2.verticalCenter
				left: warningText.left
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("b2_text")
		}

		NumberBullet {
			id: b3
			anchors {
				left: warningIcon.left
				top: b2.bottom
				topMargin: Math.round(30 * verticalScaling)
			}
		}
		Text {
			id: b3Text
			anchors {
				verticalCenter: b3.verticalCenter
				left: warningText.left
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			text: qsTr("b3_text")
		}

		StandardButton {
			id: retryButton
			anchors {
				top: b3Text.bottom
				topMargin: Math.round(13 * verticalScaling)
				left: warningText.left
			}
			text: qsTr("Retry")
			onClicked: {
				stage.openFullscreen(app.checkSolarConnectionScreenUrl);
			}
		}

		StandardButton {
			id: cancelButton
			anchors {
				top: retryButton.top
				left: retryButton.right
				leftMargin: Math.round(13 * horizontalScaling)
			}
			text: qsTr("Cancel")
			onClicked: {
				p.cancelSolarConfiguration()
			}
		}

		Image {
			id: displayPanelIcon
			anchors {
				right: parent.right
				rightMargin: Math.round(22 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: Math.round(20 * verticalScaling)
			}
			source: "image://scaled/apps/eMetersSettings/drawables/bigdisplaypanels.svg"
		}
	}
}
