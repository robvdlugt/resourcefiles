import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: saveButton
	visible: false
	label: !showThrobber ? qsTr("Save") : ""
	isLeftBarButton: false
	property alias showThrobber: throbber.visible

	property string kpiPrefix: stage.currentScreenKpiPrefix

	Throbber {
		id: throbber
		width: height
		height: parent.height * 0.7
		anchors.centerIn: parent
	}

	onClicked: {
		stage.saveButtonClicked();
	}
}
