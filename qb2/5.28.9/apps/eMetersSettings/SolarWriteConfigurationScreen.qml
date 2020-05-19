import QtQuick 2.1
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: solarWriteConfigurationScreen
	screenTitle: qsTr("Writing Solar configuration")


	hasBackButton: false
	hasHomeButton: false
	hasCancelButton: true
	inNavigationStack: false

	property EMetersSettingsApp app

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
				//
				curDevice = {
					'deviceUuid': app.solarWizardUuid,
					'sensors': ['analogSolar'],
					// If we only have analogSolar,
					'status': app.getMaConfigurationStatusString(4),
					'statusInt': Constants.CONFIG_STATUS.SOLAR
				};
			} else {
				var tmpSensors = curDevice.sensors
				if (tmpSensors.indexOf('analogSolar') === -1) {
					tmpSensors.push('analogSolar');
					curDevice.sensors = tmpSensors;
				}
				curDevice.statusInt = curDevice.statusInt | Constants.CONFIG_STATUS.SOLAR;
				curDevice.status = app.getMaConfigurationStatusString(curDevice.statusInt);
			}

			devices.push(curDevice);

			return devices;
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		disableCancelButton();
		app.activateSolar();
		app.maConfiguration = p.createSensorConfiguration();
		app.sendSensorConfiguration(app.maConfiguration, sendSensorConfigurationCallback);

	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		throbber.visible = false;
	}

	function sendSensorConfigurationCallback(message) {
		if (message.getArgument("success") === "true") {
			if (app.solarWizardDividerType >= 0)
				app.setMeterConfiguration(app.solarWizardUuid, "solar", undefined, app.solarWizardDivider, app.solarWizardDividerType);

			app.setStandardYearTargets(app.solarWizardEstimatedGeneration);
			// wait for 5 seconds so that the meter configuration is send to the module and the status is updated with the correct state
			util.delayedCall(5000, checkSolarStatus);
		} else {
			enableCancelButton()
			throbber.running = false;

			var errorMsg = message.getArgument("reason");
			explanationText.text = qsTr("msg-mm-no-support-solar %1").arg(errorMsg);

// It seems that the meter module you selected does not support Solar. Please select
// the Cancel button and remove the meter module before trying again.\n\nError message details:\n%1
		}
	}

	function checkSolarStatus() {
		var solarSensor = app.getUsageByType("solar");
		if (solarSensor && solarSensor.usage) {
			if (solarSensor.usage.status === Constants.meterStatusValues.ST_OPERATIONAL ||
				solarSensor.usage.status === Constants.meterStatusValues.ST_COMMISSIONING) {
				// TODO: add your solar kit is installed
				hide();
			} else {
				stage.openFullscreenInner(app.checkSolarConnectionScreenUrl, null, false);
			}
		}
	}

	Throbber {
		id: throbber
		width: Math.round(150 * horizontalScaling)
		height: Math.round(150 * verticalScaling)

		smallRadius: 4
		mediumRadius: 5
		largeRadius: 7
		bigRadius: 10

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: parent.height / 5
		}

		Component.onCompleted: {
			changePosition()
		}
	}

	Text {
		id: explanationText
		text: qsTr("msg-applying-solar-configuration")
//Please wait while the solar configuration is applied. This may take up to 1 minute, during
// which the screen may become unresponsive. Please do not restart the device during this time.
		wrapMode: Text.WordWrap
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		horizontalAlignment: Text.AlignHCenter
		anchors {
			top: throbber.bottom
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(100 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(100 * horizontalScaling)
		}
	}
}
