import QtQuick 2.1
import qb.components 1.0

/**
 * Component displaying up to fixed number of items scrollable by up/down buttons. Scrolling is page based.
*/

Item {
	id: simpleList

	/// delegate for ListView
	property alias delegate: listView.delegate
	/// data model for all items
	property alias dataModel: listView.model
	/// Number of items per one page - maximum number of items in Repeater.
	property int itemsPerPage: 5
	/// number of items in dataModel
	property int count: dataModel.count
	/// Currently selected item in the ListView.
	property alias currentItem: listView.currentItem
	/// Data model index of currently selected item (zero based) within all items (not only the visible ones)
	property alias dataIndex: listView.currentIndex
	/// Height of the scroll buttons.
	property int buttonsHeight: height - (itemsPerPage * itemHeight) - ((itemsPerPage - 1) * itemSpacing)
	/// Color of scroll buttons icon in down state.
	property alias buttonDownStateColor: butDown.buttonDownColor
	/// Color of background of the buttons in down state.
	property alias buttonDownStateBackground: butDown.backgroundDown
	/// Color of background of the buttons in the up state.
	property alias buttonUpStateBackground: butDown.backgroundUp
	/// Height of single item in ListView (in px).
	property int itemHeight: 0
	/// Color of the scrollbar lane.
	property alias scrollLaneColor: scrollLane.color
	/// visibility of navigation buttons
	property alias buttonsVisible: butDown.visible
	/// scrollbar visibility
	property bool scrollbarVisible: true
	/// spacing between visible items
	property alias itemSpacing: listView.spacing

	QtObject {
		id: p
		///private properties for unit tests
		property ThreeStateButton prvButUp: butUp
		property ThreeStateButton prvButDown: butDown
		property Rectangle prvScrollbar: scrollbar
	}

	/// set item with data index dataIdx as visible and emit a signal about it. Scroll the page if needed
	function selectItem(dataIdx) {
		listView.currentIndex = dataIdx;
	}

	/// Width and height of scrollable list including buttons area.
	width: Math.round(325 * horizontalScaling)
	height: parent.height

	ListView {
		id: listView
		width: parent.width
		anchors {
			top: parent.top
			bottom: butDown.top
		}
		snapMode: ListView.SnapToItem
		clip: true
		highlightFollowsCurrentItem: true
		highlightMoveDuration: 0
		boundsBehavior: Flickable.StopAtBounds
	}

	ThreeStateButton {
		id: butDown
		width: simpleList.width / 2
		height: simpleList.buttonsHeight
		anchors {
			bottom: parent.bottom
			left: parent.left
		}
		backgroundUp: colors.simpleListBtnColorUp
		backgroundDown: colors.simpleListBtnColorDown
		buttonDownColor: colors.simpleListBtnOverlayColorDown
		image: "qrc:/images/arrow-down.svg"
		enabled: !listView.atYEnd && listView.contentHeight
		visible: !(listView.atYBeginning && listView.atYEnd)

		onClicked:{
			var currentIndex = listView.indexAt(10, listView.contentY + 10);
			currentIndex = Math.min(currentIndex + itemsPerPage, listView.count - 1);
			listView.positionViewAtIndex(currentIndex, ListView.Beginning);
		}
	}

	ThreeStateButton {
		id: butUp
		width: simpleList.width / 2
		height: simpleList.buttonsHeight
		anchors {
			bottom: parent.bottom
			left: butDown.right
		}
		backgroundUp: butDown.backgroundUp
		backgroundDown: butDown.backgroundDown
		buttonDownColor: butDown.buttonDownColor
		image: "qrc:/images/arrow-up.svg"
		enabled: !listView.atYBeginning && listView.contentHeight
		visible: butDown.visible

		onClicked:{
			var currentIndex = listView.indexAt(10, listView.contentY + 10);
			currentIndex = Math.max(currentIndex - itemsPerPage, 0);
			listView.positionViewAtIndex(currentIndex, ListView.Beginning);
		}
	}

	Rectangle {
		id: scrollLane
		width: Math.round(4 * horizontalScaling)
		radius: width / 2
		color: colors.simpleListScrollbarBg
		anchors {
			right: parent.right
			top: parent.top
			bottom: listView.bottom
		}
		visible:  scrollbarVisible && !(listView.atYBeginning && listView.atYEnd)
	}

	Rectangle {
		id: scrollbar
		width: scrollLane.width
		height: listView.contentHeight > 0 ? listView.visibleArea.heightRatio * (scrollLane.height) : 0
		radius: width / 2
		color: colors.ibListScrollbar
		anchors {
			left: scrollLane.left
			top: scrollLane.top
			topMargin: listView.visibleArea.yPosition >= 0 ? (listView.visibleArea.yPosition * scrollLane.height) : 0
		}
		visible: scrollLane.visible
	}
}
