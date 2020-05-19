import QtQuick 2.1

import qb.base 1.0

Rectangle {
	id: root

	anchors.fill: parent

	Text {
		id: textTop
		width: parent.width - Math.round(60 * horizontalScaling);

		text: qsTr("addFriendsPopup-top-text")
		wrapMode: Text.WordWrap

		color: colors.addFriendBody

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			horizontalCenter: parent.horizontalCenter
		}
	}

	Image {
		id: comic

		source: "image://scaled/apps/benchmark/drawables/CodeComic.svg"

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: textTop.bottom
			topMargin: designElements.vMargin15
		}
	}

	Text {
		id: textBottom
		width: parent.width - Math.round(60 * horizontalScaling);

		text: qsTr("addFriendsPopup-bottom-text")
		wrapMode: Text.WordWrap

		color: colors.addFriendBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: comic.bottom
			topMargin: designElements.vMargin15
			horizontalCenter: parent.horizontalCenter
		}
	}
}
