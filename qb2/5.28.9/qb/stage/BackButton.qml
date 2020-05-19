import QtQuick 2.1

import qb.base 1.0;
import qb.components 1.0;

MenuBarButton {
	id: backButton
	visible: false
	label: qsTr("Back")
	image: "image://scaled/images/arrow-left-menubutton.svg"
	labelFont : qfont.semiBold.name

	onClicked: {
		stage.navigateBack();
	}
}
