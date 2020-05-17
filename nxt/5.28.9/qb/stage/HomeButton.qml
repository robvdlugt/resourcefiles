import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: homeButton
	visible: false
	label: qsTr("Home")
	labelFont : qfont.bold.name

	onClicked: {
		stage.navigateHome();
	}
}
