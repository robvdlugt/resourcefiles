import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

SidePanelButton {
	id: dhwSidePanelButton

	property string kpiPostfix: "dhwSidePanelButton"
	property DomesticHotWaterApp app
	panelUrl: app.sidePanelUrl

	QtObject {
		id: p

		property string flameIconState: "off"

		function updateFlameIconState() {
			switch(app.dhwState) {
			case app._DHW_STATE_OFF:
				flameIconState = "off";
				break;
			case app._DHW_STATE_ON:
				flameIconState = "on";
				break;
			case app._DHW_STATE_UNKNOWN:
			case app._DHW_STATE_ERROR:
				flameIconState = "error";
				break;
			}
		}
	}

	Connections {
		target: app
		onDhwStateChanged: p.updateFlameIconState()
	}

	Component.onCompleted: {
		p.updateFlameIconState();
	}

	Image {
		id: icon
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter:   parent.verticalCenter
			verticalCenterOffset: canvas.dimState ? Math.round(60 * verticalScaling) : 0
		}
		source: "image://scaled/apps/domesticHotWater/drawables/"
				+ "hw-" + (canvas.dimState ? "dim" : dhwSidePanelButton.state) + "-" + p.flameIconState + ".svg"
	}

	Connections {
		target: canvas
		onDimStateChanged: {
			if (canvas.dimState) {
				icon.anchors.horizontalCenter = undefined;
				icon.anchors.left = dhwSidePanelButton.left
			} else {
				icon.anchors.left = undefined;
				icon.anchors.horizontalCenter = dhwSidePanelButton.horizontalCenter;
			}
		}
	}
}
