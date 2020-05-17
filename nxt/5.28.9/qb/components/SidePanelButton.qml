import QtQuick 2.1

import qb.base 1.0
import BasicUIControls 1.0;

Widget {
	id: sidePanelButton
	width: parent ? (nrTabButtons > 0 ? parent.width / nrTabButtons : parent.width) : 0
	height: parent ? parent.height : 0

	property int nrTabButtons: -1
	property url panelUrl: undefined

	signal showPanel(url panelUrl)

	function sendShowPanel() {
		showPanel(panelUrl);
	}

	StyledRectangle {
		id: background
		anchors.fill: parent
		color: colors.contrastBackground
		radius: designElements.radius
		bottomLeftRadiusRatio: 0
		bottomRightRadiusRatio: 0
		visible: !canvas.dimState

		onClicked: sendShowPanel()
	}

	state: "active"
	states: [
		State {
			name: "inactive"
			PropertyChanges {target: background; color: "transparent" }
		},
		State {
			name: "active"
		}
	]
}
