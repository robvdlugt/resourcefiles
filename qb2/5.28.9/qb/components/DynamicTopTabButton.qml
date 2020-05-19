import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;

Widget {
	id: rootWidget

	// Set to the url of the corresponding content
	property url contentUrl

	property alias selected: btn.selected
	property alias iconSource: btn.iconSource

	signal showPanel(url contentUrl)

	// Available as convenience function for overloading items
	function sendShowPanel() {
		showPanel(contentUrl);
	}

	width: Math.round(100 * horizontalScaling)
	height: Math.round(40 * verticalScaling)

	TopTabButton {
		id: btn

		width: parent.width
		height: parent.height

		iconOverlayWhenUp: true
		iconOverlayWhenSelected: true

		onClicked: rootWidget.sendShowPanel()
	}
}
