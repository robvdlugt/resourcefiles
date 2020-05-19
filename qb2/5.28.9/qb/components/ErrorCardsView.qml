import QtQuick 2.1
import qb.components 1.0

Item {
	id: root
	property alias model: listView.model
	property alias delegate: listView.delegate
	property int itemsPerPage: 3
	property alias emptyViewText: emptyText.text

	function positionViewAtBeginning() {
		listView.positionViewAtBeginning();
	}

	ListView {
		id: listView
		anchors {
			left: parent.left
			leftMargin: Math.round(35 * horizontalScaling)
			top: parent.top
			topMargin: designElements.vMargin10
			right: parent.right
			rightMargin: anchors.leftMargin
			bottom: scrollbar.top
			bottomMargin: designElements.vMargin10
		}
		orientation: ListView.Horizontal
		snapMode: ListView.SnapToItem
		spacing: designElements.vMargin20
		cacheBuffer: anchors.rightMargin * 2
		interactive: isNxt
		boundsBehavior: ListView.StopAtBounds
		preferredHighlightBegin: 0
		preferredHighlightEnd: currentItem ? currentItem.width : 0
		highlightRangeMode: ListView.ApplyRange
		highlightMoveDuration: 400

		onMovementEnded: {
			var moveDuration = highlightMoveDuration;
			highlightMoveDuration = 0;
			listView.currentIndex = listView.indexAt(contentX, 0);
			highlightMoveDuration = moveDuration;
		}
	}

	Image {
		id: fillImage
		anchors {
			bottom: listView.bottom
			right: parent.right
			rightMargin: Math.round(100 * horizontalScaling)
		}
		visible: listView.count && listView.count < root.itemsPerPage
		source: visible ? "image://scaled/qb/components/drawables/marieke-clipboard.svg" : ""
	}

	Rectangle {
		id: emptyRectangle
		anchors.fill: listView
		radius: designElements.radius
		color: colors.contentBackground
		visible: listView.count === 0
	}

	Text {
		id: emptyText
		anchors {
			top: emptyRectangle.top
			topMargin: Math.round(30 * verticalScaling)
			left: emptyRectangle.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: emptyImage.left
			rightMargin: designElements.hMargin20
		}
		font {
			pixelSize: Math.round(32 * verticalScaling)
			family: qfont.regular.name
		}
		visible: emptyRectangle.visible
		color: colors._harry
		wrapMode: Text.WordWrap
	}

	Image {
		id: emptyImage
		anchors {
			bottom: parent.bottom
			bottomMargin: - Math.round(10 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(90 * horizontalScaling)
		}
		visible: emptyRectangle.visible
		source: visible ? "image://scaled/qb/components/drawables/marieke-pointing-left.svg" : ""
	}

	HorizontalScrollbar {
		id: scrollbar
		width: Math.round(root.width * 0.6)
		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		}
		container: listView
		laneColor: colors.contrastBackground
		laneWidth: Math.round(width / 2)
		alwaysShow: false

		onNext: {
			listView.currentIndex = Math.min(listView.currentIndex + root.itemsPerPage, listView.count - 1);
		}
		onPrevious: {
			listView.currentIndex = Math.max(listView.currentIndex - root.itemsPerPage, 0);
		}
	}
}
