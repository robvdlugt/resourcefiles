import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: systemSettingsErrorTrayIcon
	visible: (app.systrayErrorCount > 0) && ! globals.tsc["hideErrorSystray"]
	posIndex: 300
	objectName: "errorSystrayIcon"
	image: "drawables/error_systray.svg"

	onClicked: {
		stage.openFullscreen(app.settingsScreenUrl, {categoryUrl: Qt.resolvedUrl(app.overviewFrameUrl)});
	}
}
