import QtQuick 2.0

import qb.components 1.0

FSWizard {
	id: addStrvWizardScreen

	property StrvSettingsApp app
	property string newDeviceUuid
	property string editingDeviceUuid

	onShown: {
		if (args && args.deviceUuid)
			editingDeviceUuid = args.deviceUuid;
	}

	screenTitle: qsTr("Install smart radiator valves")
	nextScreenUrl: app.addDeviceOverviewScreenUrl
	finalRightButtonText: qsTr("Save")
	frameUrls: [
		app.addConnectFrameUrl,         // 0
		app.addNameDeviceFrameUrl,      // 1
	]
}
