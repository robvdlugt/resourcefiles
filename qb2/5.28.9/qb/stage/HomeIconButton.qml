import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: homeButton
	visible: false

	onClicked: {
		stage.navigateHome();
	}

	Image {
		id: homeButtonIcon
		anchors.centerIn: parent
		source: "image://scaled/images/home.svg"
	}
}
