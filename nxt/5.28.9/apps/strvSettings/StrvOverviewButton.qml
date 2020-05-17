import QtQuick 2.1

import qb.components 1.0

StatusButton {
	id: strvOverviewButton
	titleText: qsTr("Heating")
	property StrvSettingsApp app

	errorCount: app.strvDevicesList.length > 0 ? app.errors : -1
	statusText: app.strvDevicesList.length > 0 ? " " : qsTr("strv-none-connected")

	domainIconSource: "image://scaled/apps/strvSettings/drawables/strv.svg";

	onClicked: {
		if (errorCount > 0)
			stage.openFullscreen(app.overviewHeatingScreenUrl);
	}
}
