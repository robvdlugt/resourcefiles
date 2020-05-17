import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: smokeDetectorSystrayIcon
	visible: false
	posIndex: 300
	objectName: "smokeSystrayIcon"
	image: "drawables/smokedetector-systray.svg"

	onClicked: {
		stage.openFullscreen(Qt.resolvedUrl("SmokeDetectorScreen.qml"));
	}
}
