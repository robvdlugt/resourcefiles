import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: softwareUpdateInProgressPopup

	QtObject {
		id: p
		property variant actionStrings : {'Downloading': qsTr('Downloading'), 'Installing': qsTr('Installing') }
		property variant upgradeStatus : {'action': actionStrings['Downloading'], 'item': 0}

		function translateAction(action) {
			return actionStrings[action];
		}

		function handleDoUpgradeCallback(response) {
			var failure = (!response || response.getArgument("result") === "error")
			if (failure) {
				timer.stop();
				softwareUpdateProgressPopup.stopAnimation();
				hide();
				stage.openFullscreen(app.settingsScreenUrl);
				qdialog.showDialog(qdialog.SizeLarge, qsTr("Update failed"), qsTr("update_failed_popup_text"));
			}
		}
	}

	onShown: {
		app.startSoftwareUpdate(p.handleDoUpgradeCallback);
		timer.restart();
		softwareUpdateProgressPopup.startAnimation();
	}

	UpdateProgressPopupElements{
		id: softwareUpdateProgressPopup
		headerText: qsTr("Updating $(display)")
		footerText: qsTr("Do NOT power off your Toon!")
		progressText: p.upgradeStatus.action + ": " + p.upgradeStatus.item + "%"
	}

	Timer {
		id: timer

		interval: 100
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			var uStatus = app.getSoftwareUpdateStatus();
			// avoid undefined state before download is started
			if (uStatus.action === "") uStatus.action = 'Downloading';
			uStatus.action = p.translateAction(uStatus.action);
			p.upgradeStatus = uStatus;
		}
	}

}
