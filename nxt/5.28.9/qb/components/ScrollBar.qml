import QtQuick 2.1
import qb.components 1.0

Item {
	id: scrollBar
	width: butPrev.width
	visible: alwaysShow || !(container.atYBeginning && container.atYEnd)
	property Flickable container
	property alias laneColor: scrollLane.color
	property alias buttonSize: butPrev.height
	property bool alwaysShow: true
	
	signal next();
	signal previous();

	ThreeStateButton {
		id: butPrev
		visible: buttonSize > 0
		height: Math.round(44 * verticalScaling)
		width: height
		imgRotation: 180
		backgroundUp: colors.ibScrollbarBtnUp
		backgroundDown: colors.ibScrollbarBtnDown
		buttonDownColor: colors.ibListScrollbarButtonIconOverlay
		image: butNext.image
		anchors {
			top: parent.top
			right: parent.right
		}
		leftClickMargin: 10
		rightClickMargin: 10
		topClickMargin: 20
		onClicked: previous()
		enabled: !container.atYBeginning && container.contentHeight
	}

	ThreeStateButton {
		id: butNext
		visible: buttonSize > 0
		height: butPrev.height
		width: height
		backgroundUp: colors.ibScrollbarBtnUp
		backgroundDown: colors.ibScrollbarBtnDown
		buttonDownColor: colors.ibListScrollbarButtonIconOverlay
		image: Qt.resolvedUrl("qrc:/images/arrow-down.svg")
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		leftClickMargin: 10
		rightClickMargin: 10
		bottomClickMargin: 20
		onClicked: next()
		enabled: !container.atYEnd && container.contentHeight
	}

	Rectangle {
		id: scrollLane
		width: Math.round(8 * horizontalScaling)
		radius: width / 2
		color: colors.ibListScrollbarBg
		anchors {
			horizontalCenter: butNext.horizontalCenter
			top: butPrev.bottom
			bottom: butNext.top
		}
	}

	Rectangle {
		id: scrollbar
		width: scrollLane.width
		height: container.contentHeight > 0 ? Math.max(1, container.visibleArea.heightRatio * (scrollLane.height)) : 0
		radius: (width/2)
		color: colors.ibListScrollbar
		anchors {
			left: scrollLane.left
			top: scrollLane.top
			topMargin: container.visibleArea.yPosition >= 0 ? (container.visibleArea.yPosition * scrollLane.height) : 0
		}
	}
}
