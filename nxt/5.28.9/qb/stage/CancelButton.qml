import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuBarButton {
	id: cancelButton
	visible: false
	label: qsTr("Cancel")

	property string kpiPrefix: stage.currentScreenKpiPrefix

	onClicked: {
		stage.cancelButtonClicked();
	}
}
