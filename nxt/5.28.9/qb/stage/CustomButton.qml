import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: customButton
	visible: false
	label: qsTr("Custom")
	isLeftBarButton: false

	property string kpiPrefix: stage.currentScreenKpiPrefix

	onClicked: {
		stage.customButtonClicked();
	}
}
