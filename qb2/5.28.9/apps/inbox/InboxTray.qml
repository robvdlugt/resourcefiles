import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: inboxSystrayIcon
	visible: false
	posIndex: 300
	objectName: "inboxSystrayIcon"
	image: "drawables/inbox-systray.svg"

	onClicked: {
		stage.openFullscreen(app.fullScreenUrl);
	}
}
