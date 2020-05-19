import QtQuick 2.1
/**
 * Component extending StandardButton to support rich text formatting (e.g. html tags) in button text.
*/

StandardButton {
	id: root

	property string text
	property string kpiPostfix: text

	Text {
		anchors.centerIn: parent
		text: root.text
		font.family: root.fontFamily
		font.pixelSize: root.fontPixelSize
		color: root.fontColor
	}
}
