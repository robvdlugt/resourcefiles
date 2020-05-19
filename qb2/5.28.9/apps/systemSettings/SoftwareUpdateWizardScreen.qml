import QtQuick 2.1

import qb.components 1.0

Screen {
	id: softwareUpdateWizardScreen

	property SystemSettingsApp app

	hasBackButton: false
	hasCancelButton: false
	hasHomeButton: false

	screenTitle: qsTr("title-software-download-install")
	anchors.fill: parent

	QtObject {
		id: p

		property int rebootCountdown: 0
		property string rebootFeedbackString: ""


		property int firmwareStatusValue: 0
		property bool firmwareStatusAnimate: false
		property bool firmwareUpdateRequired: false
		property bool firmwareUpdateCompleted: false

		property int downloadStatusValue: 0
		property bool downloadStatusAnimate: false
		property bool softwareDownloadRequired: false
		property bool softwareDownloadCompleted: false

		property int installStatusValue: 0
		property bool installStatusAnimate: false
		property bool softwareInstallRequired: false
		property bool softwareInstallCompleted: false

		// Number of meter adapters that require software update
		property int nrMARequiresUpdates: -1
		// Which meter adapter are we installing the software update right now
		property int curMAInstallingUpdate: -1

		function refresh() {
			if (firmwareUpdateRequired && ! firmwareUpdateCompleted) {
				refreshFirmwareUpdateState();
			} else if (softwareDownloadRequired && ! softwareDownloadCompleted) {
				refreshSoftwareDownloadState();
			} else if (softwareInstallRequired && ! softwareInstallCompleted) {
				refreshSoftwareInstallState();
			} else if (softwareInstallRequired && softwareInstallCompleted) {
				// No need to schedule our reboot after the installation reports 100%,
				// the display will reboot automatically.
				refreshTimer.interval = 5000;
			} else {
				startRebootTimer();
			}
		}

		property int _firmwareTimerCounter
		function refreshFirmwareUpdateState() {
			// Reading the firmware update status is returned by a callback, which is
			// handled by the SystemSettingsApp. We receive the app.maFwUpdateStatusUpdate signal
			// and can then read the app.maFwUpdateStatusMsg and app.maFwUpdatePercentage

			// The only issue is that we should reduce our rate of requesting updates to about
			// once every 5 seconds
			_firmwareTimerCounter += refreshTimer.interval;
			if (_firmwareTimerCounter >= 5000) {
				_firmwareTimerCounter = 0;
				app.getMeterAdapterUpdateStatus();
			}
		}

		function handleFirmwareUpdateSignal() {
			var fwUpdateStatus = app.maFwUpdateStatus;
			switch (fwUpdateStatus) {
			case app._FIRMWARE_UPDATE_STARTWAIT:
			case app._FIRMWARE_UPDATE_INPROGRESS:
				firmwareStatusValue = app.maFwUpdatePercentage / nrMARequiresUpdates;
				// If we're updating 2 meter adapters, and we're busy with the second one
				// add the progress of the first one
				if (nrMARequiresUpdates === 2 && curMAInstallingUpdate === 1) {
					firmwareStatusValue += 50;
				}
				break;
			case app._FIRMWARE_UPDATE_COMPLETE:
			case app._FIRMWARE_UPDATE_INACTIVE:
				if (nrMARequiresUpdates === 2 && curMAInstallingUpdate === 0) {
					firmwareStatusValue = 50;
					// Start the next update
					startFirmwareUpdate();
				} else {
					firmwareStatusValue = 100;
					firmwareUpdateCompleted = true;
					firmwareStatusAnimate = false;
					startSoftwareUpdate();
				}
				break;
			case app._FIRMWARE_UPDATE_FAILED:
			default:
				firmwareUpdateCompleted = true;
				firmwareStatusAnimate = false;
				startSoftwareUpdate();
				break;
			}
		}

		function refreshSoftwareDownloadState() {
			var uStatus = app.getSoftwareUpdateStatus();

			// avoid undefined state before download is started
			if (uStatus.action === "") uStatus.action = 'Downloading';

			if (uStatus.action === "Downloading") {
				downloadStatusValue = uStatus.item;
				downloadStatusAnimate = true;
			} else if (uStatus.action === "Installing") {
				softwareDownloadCompleted = true;
				downloadStatusValue = 100;
				downloadStatusAnimate = false;
				refreshSoftwareInstallState();
			}
		}

		function refreshSoftwareInstallState() {
			var uStatus = app.getSoftwareUpdateStatus();

			if (uStatus.action === "Installing") {
				installStatusValue = uStatus.item;
				installStatusAnimate = true;
				if (uStatus.item === "100") {
					overlay.visible = true;
					progressText.text = qsTr("Software update completed. Preparing reboot.<br>Do NOT power down your device. This may take a few minutes.");
					softwareInstallCompleted = true;
					installStatusAnimate = false;
				}
			} else {
				softwareInstallCompleted = true;
				installStatusAnimate = false;
			}
		}

		function startFirmwareUpdate() {
			var uuid = 0;
			if (app.getMeterAdapterUpdateAvailable(0) && curMAInstallingUpdate === -1) {
				uuid = app.getMeterAdapterInfo(0, "deviceUuid");
				curMAInstallingUpdate = 0;
			} else if (app.getMeterAdapterUpdateAvailable(1)) {
				uuid = app.getMeterAdapterInfo(1, "deviceUuid");
				curMAInstallingUpdate = 1;
			}

			if (uuid !== 0) {
				app.startMeterAdapterUpdate(uuid);
				p.firmwareStatusAnimate = true;
			} else {
				console.log("Attempted to start firmware update, but no adapter meter requires updating.");
				firmwareUpdateCompleted = true;
				firmwareStatusAnimate = false;
			}
		}

		function startSoftwareUpdate() {
			app.startSoftwareUpdate(handleDoUpgradeCallback);
		}

		function handleDoUpgradeCallback(response) {
			if (!response || response.getArgument("result") === "error") {
				console.log("Upgrade callback result:", response.stringContent);
				softwareDownloadCompleted = true;
				softwareInstallCompleted = true;
				downloadStatusAnimate = false;
				installStatusAnimate = false;
				startRebootTimer(response);
			}
		}

		function startRebootTimer(response) {
			if (response === undefined || response === null) {
				rebootFeedbackString = qsTr("No software update required.<br>Rebooting in %1 seconds.");
			} else if (response.getArgument("result") === "error") {
				rebootFeedbackString = qsTr("Error during software update.<br>Rebooting in %1 seconds.");
			} else {
				rebootFeedbackString = qsTr("Software update completed.<br>Rebooting in %1 seconds.");
			}
			rebootCountdown = 11;
			rebootTimer.start();
			refreshTimer.stop();
		}

		function updateRebootTimer() {
			p.rebootCountdown--;
			if (p.rebootCountdown <= 0) {
				rebootTimer.stop();
				p.rebootCountdown = 0;
				overlay.visible = true;
				app.restartToon();
			}
			progressText.text = rebootFeedbackString.arg(p.rebootCountdown);
		}

		function checkUpdateAvailable() {
			p.softwareDownloadRequired = app.displayInfo.UpdateAvailable;
			p.softwareInstallRequired  = app.displayInfo.UpdateAvailable;

			if (p.firmwareUpdateRequired) {
				p.startFirmwareUpdate();
			} else if (p.softwareDownloadRequired || p.softwareInstallRequired) {
				p.firmwareUpdateCompleted = true;
				p.startSoftwareUpdate();
			}
			refreshTimer.start();
		}
	}

	Timer {
		id: rebootTimer
		interval: 1000
		triggeredOnStart: true
		repeat: true
		onTriggered: {
			p.updateRebootTimer();
		}
	}

	Connections {
		target: app
		// Signal emitted after requesting the status of the firmware update (app.getMeterAdapterUpdateStatus())
		onMaFwUpdateStatusUpdate: p.handleFirmwareUpdateSignal()

		onCheckFirmwareUpdateResponseReceived: p.checkUpdateAvailable()
	}

	onShown: {
		p.firmwareUpdateRequired =	app.getMeterAdapterUpdateAvailable(0) ||
									app.getMeterAdapterUpdateAvailable(1);
		if (p.firmwareUpdateRequired) {
			if (app.getMeterAdapterUpdateAvailable(0) &&
				app.getMeterAdapterUpdateAvailable(1)) {
				p.nrMARequiresUpdates = 2;
			} else {
				p.nrMARequiresUpdates = 1;
			}
		}

		if (app.displayInfo['UpdateAvailable']) {
			p.checkUpdateAvailable();
		} else {
			// This checks if the display software update is available, despite the misleading name.
			app.checkFirmwareUpdate(); // After receiving the response, the app emits the checkFirmwareUpdateResponseReceived signal, triggering our p.checkUpdateAvailable()
		}
	}

	Row {
		id: throbberRow
		anchors.horizontalCenter: parent.horizontalCenter

		property real throbberHeight: softwareUpdateWizardScreen.height / 2
		property real throbberWidth:  softwareUpdateWizardScreen.width  / 5

		ThrobberContainer {
			id: firmwareUpdateThrobber
			height: parent.throbberHeight
			width:  parent.throbberWidth

			animate: p.firmwareStatusAnimate
			visible: p.firmwareUpdateRequired

			itemText: qsTr("Firmware<br>updating")
			itemPercentage: p.firmwareStatusValue
		}
		ThrobberContainer {
			id: softwareDownloadThrobber
			height: parent.throbberHeight
			width:  parent.throbberWidth

			animate: p.downloadStatusAnimate
			visible: p.softwareDownloadRequired

			itemText: qsTr("Downloading<br>software")
			itemPercentage: p.downloadStatusValue
		}
		ThrobberContainer {
			id: softwareUpdateThrobber
			height: parent.throbberHeight
			width:  parent.throbberWidth

			animate: p.installStatusAnimate
			visible: p.softwareInstallRequired

			itemText: qsTr("Updating<br>software")
			itemPercentage: p.installStatusValue
		}
	}

	Timer {
		id: refreshTimer

		interval: 500
		repeat: true
		triggeredOnStart: true

		onTriggered: p.refresh()
	}

	Text {
		id: progressText
		text: qsTr("Just a moment please.")

		horizontalAlignment: Text.AlignHCenter
		color: colors.softUpdateWzrdBody
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name

		anchors {
			top: throbberRow.bottom
			topMargin: 70 * verticalScaling
			horizontalCenter: parent.horizontalCenter
		}
	}

	StandardButton {
		id: rebootButton

		visible: p.rebootCountdown > 0
		text: qsTr("Reboot now")

		anchors {
			top: progressText.top
			left: progressText.right
			leftMargin: designElements.hMargin20
		}

		onClicked: {
			p.rebootCountdown = 0;
			p.updateRebootTimer()
		}
	}

	Rectangle {
		id: overlay
		x: 0
		y: -1 * designElements.menubarHeight
		width: canvas.width
		height: canvas.height
		color: "#60000000"
		visible: false
	}
}
