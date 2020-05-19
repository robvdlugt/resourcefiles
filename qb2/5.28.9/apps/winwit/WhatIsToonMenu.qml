import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuItem {
	label: qsTr("What is Toon")
	image: "drawables/watistoon.svg"
	weight: 900
	objectName: "wiqMenuItem"
	onClicked: {
		if (app) {
			app.showWhatIsToon();
		}
	}
}
