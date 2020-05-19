import QtQuick 2.1

import qb.components 1.0

StatusButton {
	id: internetOverviewButton
	titleText: qsTranslate("OverviewInternetScreen", "Connectivity")
	domainIconSource: "image://scaled/apps/internetSettings/drawables/internet-overview-btn-icon.svg"
	errorCount: app.errors
	onClicked: {
		if (errorCount > 0)
			stage.openFullscreen(app.overviewInternetScreenUrl);
	}
}
