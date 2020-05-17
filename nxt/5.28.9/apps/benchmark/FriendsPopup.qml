import QtQuick 2.1
import qb.components 1.0

Rectangle {
	id: root
	anchors.fill: parent

	Image {
		id: comic
		anchors {
			top: parent.top
			topMargin: designElements.vMargin10
			horizontalCenter: parent.horizontalCenter
		}
	}

	Text {
		id: text
		anchors {
			top: comic.bottom
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		wrapMode: Text.WordWrap
	}

	DottedSelector {
		id: selector
		width: parent.width - Math.round(96 * horizontalScaling)
		pageCount: 3
		arrowColorUp: "transparent"
		arrowColorDown: colors._middlegrey
		onNavigate: root.state = "page" + (page + 1)

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
		}
	}

	state: "page1"
	states: [
		State {
			name: "page1"
			PropertyChanges { target: comic; source: "image://scaled/apps/benchmark/drawables/PopupComic01.svg" }
			PropertyChanges { target: text; text: qsTr("friendsPopupPage1") }
		},
		State {
			name: "page2"
			PropertyChanges { target: comic; source: "image://scaled/apps/benchmark/drawables/PopupComic02.svg" }
			PropertyChanges { target: text; text: qsTr("friendsPopupPage2") }
		},
		State {
			name: "page3"
			PropertyChanges { target: comic; source: "image://scaled/apps/benchmark/drawables/PopupComic03.svg" }
			PropertyChanges { target: text; text: qsTr("friendsPopupPage3") }
		}
	]
}
