import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

MenuItem {
	property url screenUrl
	property string screen
	property variant args

	onClicked: {
		if (screenUrl != "") {
			stage.openFullscreen(screenUrl, args);
		} else if (app[screen]) {
			app[screen].show(args);
		}
	}
}
