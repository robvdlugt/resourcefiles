import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: maUpdateInProgressPopup

	QtObject {
		id: p

		property int idleTime: 0
		property int maxTime: 600
		property int maUpdatePercentage: 0
	}

	property SystemSettingsApp app
	property string uuid: ""

	function update() {
		if (app.maFwUpdateStatusMsg) {
			// clear idleTime if there is progress
			if (app.maFwUpdatePercentage !== p.maUpdatePercentage)
			{
				p.idleTime = 0;
				p.maUpdatePercentage = app.maFwUpdatePercentage;
			}

			// Check if idle time has expired or firmware update was finished/failed
			if (p.idleTime >= p.maxTime || (app.maFwUpdateStatus === app._FIRMWARE_UPDATE_INACTIVE || app.maFwUpdateStatus > app._FIRMWARE_UPDATE_INPROGRESS)) {
				timer.stop();
				app.maFwUpdatePercentage = 0;
				maUpdateProgressPopup.stopAnimation();
				maUpdateInProgressPopup.hide();
				stage.openFullscreen(app.settingsScreenUrl);

				var popupTitle = "";
				var popupText = "";
				if (app.maFwUpdateStatus === app._FIRMWARE_UPDATE_COMPLETE) {
					popupTitle = qsTr("Update successful");
					popupText = qsTr("ma_firmware_update_success");
				} else {
					popupTitle = qsTr("Update failed");
					popupText = qsTr("ma_firmware_update_failed");
				}

				qdialog.showDialog(qdialog.SizeLarge, popupTitle, popupText);
			} else {
				if (app.maFwUpdateStatusMsg.indexOf("validating") !== -1 || app.maFwUpdatePercentage === 100) {
					maUpdateProgressPopup.progressText = qsTr("Installing");
					maUpdateProgressPopup.subProgressText = qsTr("This can take a few minutes");
				} else {
					maUpdateProgressPopup.progressText = qsTr("Downloading %1%").arg(app.maFwUpdatePercentage);
					maUpdateProgressPopup.subProgressText = "";
				}
			}
			// empty to prevent dialog popup when driver updates automatically / again
			app.maFwUpdateStatusMsg = "";
		}
	}

	onShown: {
		app.maFwUpdateStatusUpdate.connect(update);
		p.idleTime = 0;
		p.maUpdatePercentage = 0;
		app.startMeterAdapterUpdate(uuid);
		timer.restart();
		maUpdateProgressPopup.startAnimation();
	}

	onHidden: {
		app.maFwUpdateStatusUpdate.disconnect(update);
		app.getDeviceInfo();
	}

	UpdateProgressPopupElements{
		id: maUpdateProgressPopup
		headerText: qsTr("Updating meter module")
		footerText: qsTr("Do NOT power off your meter module!")
	}

	Timer {
		id: timer

		interval: 5000
		repeat: true

		onTriggered: {
			p.idleTime += 5;
			app.getMeterAdapterUpdateStatus();
		}
	}


}
