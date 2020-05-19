import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: menuButton

	onClicked: {
		stage.navigateMenu();
	}

	Image {
		id: homeButtonIcon
		anchors.centerIn: parent
		source: "image://scaled/images/menu.svg"
	}
}
