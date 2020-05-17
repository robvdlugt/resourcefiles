import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuItem {
	label: qsTr("What is new")
	image: "drawables/watisnieuw.svg"
	weight: 901
	objectName: "winMenuItem"
	onClicked: {
		app.showWhatIsNew();
	}
}
