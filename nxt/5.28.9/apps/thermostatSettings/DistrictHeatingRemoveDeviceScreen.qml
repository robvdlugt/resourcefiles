import QtQuick 2.0

import qb.components 1.0

ZwaveRemoveDeviceScreen {
	screenTitle: qsTr("Disconnect Smart Heat module")
	title: qsTr("Disconnect the Smart Heat module")
	numberedSteps: [
		qsTr("Press <b>Disconnect</b>."),
		qsTr("Press and hold the button on the Smart Heat module between 2 and 6 seconds.")
	]
	failedNumberedSteps: numberedSteps

	imageStart: "drawables/delete-smart-heat-module.svg"
	imageBusy: imageStart
	imageSuccess: imageStart
	imageFailed: imageStart
	imagePosition: "center"
}
