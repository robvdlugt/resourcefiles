import QtQuick 2.1

import qb.components 1.0

StatusButton {
	id: thermostatOverviewButton
	titleText: qsTr("Heating")
	errorCount: app.errors
	property ThermostatSettingsApp app

	onClicked: {
		if (errorCount > 0)
			stage.openFullscreen(app.overviewHeatingScreenUrl);
	}

	Component.onCompleted: {
		var heatingType = app.getHeatingType();
		if (heatingType === 1) {
			domainIconSource = "image://scaled/apps/thermostatSettings/drawables/heating-cv-overview-btn-icon.svg";
		} else {
			domainIconSource = "image://scaled/apps/thermostatSettings/drawables/heating-overview-btn-icon.svg";
		}
	}
}
