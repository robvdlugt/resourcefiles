import QtQuick 2.1
import qb.components 1.0

Item {
	id: root
	height: butPrev.height
	visible: alwaysShow || !(container.atXBeginning && container.atXEnd)
	property Flickable container
	property alias laneColor: scrollLane.color
	property int laneWidth
	property alias buttonSize: butPrev.height
	property bool alwaysShow: true
	
	signal next();
	signal previous();

	ThreeStateButton {
		id: butPrev
		height: Math.round(44 * verticalScaling)
		width: height
		imgRotation: 90
		backgroundUp: colors.ibScrollbarBtnUp
		backgroundDown: colors.ibScrollbarBtnDown
		buttonDownColor: colors.ibListScrollbarButtonIconOverlay
		image: butNext.image
		anchors {
			top: parent.top
			left: parent.left
		}
		leftClickMargin: 10
		rightClickMargin: 10
		topClickMargin: 10
		bottomClickMargin: 10
		onClicked: previous()
		enabled: !container.atXBeginning && container.contentWidth
	}

	ThreeStateButton {
		id: butNext
		height: butPrev.height
		width: height
		imgRotation: -90
		backgroundUp: colors.ibScrollbarBtnUp
		backgroundDown: colors.ibScrollbarBtnDown
		buttonDownColor: colors.ibListScrollbarButtonIconOverlay
		image: Qt.resolvedUrl("qrc:/images/arrow-down.svg")
		anchors {
			top: parent.top
			right: parent.right
		}
		leftClickMargin: 10
		rightClickMargin: 10
		topClickMargin: 10
		bottomClickMargin: 10
		onClicked: next()
		enabled: !container.atXEnd
				 && (container.visibleArea.xPosition + container.visibleArea.widthRatio).toFixed(5) !== '1.00000' // workaround as atXEnd is not always true
				 && container.contentWidth
	}

	Rectangle {
		id: scrollLane
		width: laneWidth ? laneWidth : undefined
		height: Math.round(8 * verticalScaling)
		anchors.verticalCenter: butNext.verticalCenter
		radius: height / 2
		color: colors.ibListScrollbarBg

		states: [
			State {
				when: laneWidth > 0
				AnchorChanges { target: scrollLane; anchors.horizontalCenter: parent.horizontalCenter }
			},
			State {
				when: !laneWidth
				AnchorChanges { anchors.left: butPrev.right; anchors.right: butNext.left }
			}
		]
	}

	Rectangle {
		id: scrollbar
		width: container.contentWidth > 0 ? container.visibleArea.widthRatio * (scrollLane.width) : 0
		height: scrollLane.height
		radius: (height / 2)
		color: colors.ibListScrollbar
		anchors {
			top: scrollLane.top
			left: scrollLane.left
			leftMargin: container.visibleArea.xPosition >= 0 ? (container.visibleArea.xPosition * scrollLane.width) : 0
		}
	}
}
