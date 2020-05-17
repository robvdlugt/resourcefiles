import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

SidePanelButton {
	id: strvSidePanelButton

	property string kpiId: "strvSidePanelButton"

	property StrvSettingsApp app
	panelUrl: app.zoneTempSidePanelUrl

	Image {
		id: flameIcon
		source: app.heatingState ? "image://scaled/apps/strvSettings/drawables/ts-active-3.svg" : "image://scaled/apps/strvSettings/drawables/ts-active-off.svg"

		visible: (!canvas.dimState)
		opacity: strvSidePanelButton.state === "active" ? 1 : 0.7

		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter:   parent.verticalCenter
		}
	}
}
