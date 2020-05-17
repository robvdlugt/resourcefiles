import QtQuick 2.0

import qb.base 1.0
import qb.components 1.0

Item {
	anchors.fill: parent

	property Screen parentScreen
	property App app
	property alias title: titleText.text
	property url imageSource
	default property alias content: content.data

	signal shown(var args)
	signal hidden()
	signal next()
	signal canceled()

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: anchors.topMargin
			right: image.left
			rightMargin: designElements.hMargin20
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.secondaryImportantBodyText
		}
		color: colors.text
		wrapMode: Text.WordWrap
	}

	Item {
		id: content
		anchors {
			top: titleText.bottom
			topMargin: designElements.vMargin15
			bottom: parent.bottom
			bottomMargin: anchors.topMargin
			left: titleText.left
			right: image.left
			rightMargin: designElements.hMargin20
		}
	}

	Image {
		id: image
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		source: imageSource.toString() ? "image://scaled/" + qtUtils.urlPath(imageSource) : ""
	}
}
