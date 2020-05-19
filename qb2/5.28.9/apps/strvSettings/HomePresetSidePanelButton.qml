import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

SidePanelButton {
	id: homePresetSidePanelButton

	property string kpiId: "homePresetSidePanelButton"

	property StrvSettingsApp app
	panelUrl: app.homePresetSidePanelUrl

	Image {
		id: flameIcon
		source: "image://scaled/apps/strvSettings/drawables/presetIcon.svg"

		visible: (!canvas.dimState)
		opacity: homePresetSidePanelButton.state === "active" ? 1 : 0.7

		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter:   parent.verticalCenter
		}
	}

	onDimStateChanged: {
		if (dimState) {
			sendShowPanel();
		}
	}
}
