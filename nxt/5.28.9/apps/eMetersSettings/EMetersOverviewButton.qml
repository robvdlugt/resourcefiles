import QtQuick 2.1

import qb.components 1.0

StatusButton {
	id: eMetersOverviewButton
	titleText: qsTr("Energy meters")
	domainIconSource: "image://scaled/apps/eMetersSettings/drawables/emeters-overview-btn-icon.svg"
	errorCount: app.errors
	statusText: errorCount === -1 ? qsTr("No meter module installed") : ""
	onClicked: {
		if (errorCount === -1)
			stage.openFullscreen(app.eMetersScreenUrl);
		else if (errorCount > 0)
			stage.openFullscreen(app.overviewEMetersScreenUrl);
	}
}
