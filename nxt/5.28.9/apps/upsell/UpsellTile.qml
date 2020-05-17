import QtQuick 2.1

import qb.components 1.0

Tile {
	id: upsellTile
	property alias text: text.text
	property string imageFile
	bgColor: colors._robinhood
	opacity: dimState ? 0.0 : 1.0

	function init() {}

	onClicked: stage.openFullscreen(app.chosenScreenUrl)

	Text {
		id: text
		anchors {
			left: parent.left
			leftMargin: designElements.vMargin10
			top: parent.top
			topMargin: anchors.leftMargin
			right: image.left
			bottom: parent.bottom
			bottomMargin: anchors.leftMargin
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.bodyText
		}
		lineHeight: 0.9
		color: colors.white
		wrapMode: Text.WordWrap
		elide: Text.ElideRight
	}

	Image {
		id: image
		anchors {
			right: parent.right
			rightMargin: Math.round(8 * horizontalScaling)
			bottom: parent.bottom
		}
		source: imageFile ? "image://scaled/apps/upsell/drawables/" + imageFile : ""
	}
}
