import QtQuick 2.1

import qb.components 1.0

FSWizard {
	id: addStrvWizardScreen
	property string newDeviceUuid

	screenTitle: qsTr("Connect a smoke detector")
	nextScreenUrl: app.smokeDetectorScreenUrl
	frameUrls: [
		app.connectSmokeDetectorFrameUrl,
		app.connectionQualityFrameUrl,
		app.qualityAcknowledgeFrameUrl,
		app.nameFrameUrl,
		app.wizardFinishFrame
	]

	function smokedetectorRemoved(byeByeUuid) {
		// Remove the smokedetector also from the happ_eventmgr
		app.removeDeviceFromScenario(byeByeUuid);
		// Show the user that something went wrong
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Smoke detector is disconnected"), qsTr("smokedetector-disconnected-popup"), qsTr("Link"), function() { stage.openFullscreen(app.addSmokeDetectorScreenUrl) }, qsTr("Cancel"));
	}

	onShown: {
		app.currentSmokedetectorRemoved.connect(smokedetectorRemoved);
	}

	onHidden: {
		app.currentSmokedetectorRemoved.disconnect(smokedetectorRemoved);
	}
}
