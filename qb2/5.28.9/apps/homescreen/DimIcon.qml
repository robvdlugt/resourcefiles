import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: dimSystrayIcon
	posIndex: 100
	objectName: "dimSystrayIcon"
	image: "drawables/dim-systray-icon.svg"

	onClicked: {
		screenStateController.manualDim = true;
	}
}
