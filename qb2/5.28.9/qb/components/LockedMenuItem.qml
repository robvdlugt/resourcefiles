import QtQuick 2.1

MenuItem {
	id: lockedMenuItem
	locked: true
	property url screenUrl

	onClicked: {
		if (screenUrl.toString()) {
			stage.openFullscreen(screenUrl);
		}
	}
}
