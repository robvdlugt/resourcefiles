import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: systemUpdateTrayIcon
	visible: app.displayInfo['UpdateAvailable'] || app.hasUpdateMeterAdapter()
	posIndex: 300
	objectName: "updateSystrayIcon"
	image: "drawables/update.svg"

	onClicked: {
		if (app.displayInfo['UpdateAvailable'])
			stage.openFullscreen(app.settingsScreenUrl, {categoryUrl: app.softwareFrameUrl});
		else if (app.hasUpdateMeterAdapter())
			stage.openFullscreen(app.eMetersScreenUrl, {});
	}
}
