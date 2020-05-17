import QtQuick 2.1

import "ScrollableListItem.js" as ScrollableListItemJS

/**
 * Component displaying up to fixed number of items scrollable by up/down buttons. Scrolling is page based and is always scrolled
 * to have the itemsPerPage-th item at the top of the visible items - might be empty lines at the last page when total count is not itemsPerPage multiple.
 **/

Rectangle {
	/// delegate that hold the custom layout of the ScrollableSimpleList
	property alias delegate: listView.delegate
	property int itemsPerPage: 4
	property int currentPage: 0
	property int numberOfPages: 0

	signal scrolledPage()
	/// Signal emitted when the visibleDataModel was cleared (scrolling page).
	/// Can be used for controlGroups to clear selections. If a controlGroup is
	/// used for the delegate, a segfault may occur if selections weren't cleared.
	signal modelCleared()

	QtObject {
		id: p

		/// data index of the first visible item in Repeater
		property int firstVisibleDataIdx: 0

		/// adapt scrollbar height based on page count and set proper position
		/// also sets numberOfPages
		function updateScrollbar() {
			var count = ScrollableListItemJS.items.length;
			if (count <= itemsPerPage) {
				scrollbar.visible = false;
			} else {
				scrollbar.visible = true;
			}
			numberOfPages = Math.ceil(count / itemsPerPage);
			scrollbar.height = Math.floor(scrollLane.height / numberOfPages);
			scrollbar.anchors.topMargin = currentPage * scrollbar.height;
		}
	}

	/// add a device to list using this method.
	function addDevice(devVar) {
		ScrollableListItemJS.items.push(devVar);
	}

	/// Refresh the visual data model to refresh the visuals list
	function refreshView() {
		visualDataModel.clear();
		modelCleared();
		if (ScrollableListItemJS.items.length > 0) {
			var firstIndexOnCurrentPage = currentPage * itemsPerPage;
			for (var i = firstIndexOnCurrentPage; i < firstIndexOnCurrentPage + itemsPerPage && i < ScrollableListItemJS.items.length; i++) {
				visualDataModel.append({"item": ScrollableListItemJS.items[i]});
			}
		}
		listView.height = visualDataModel.count * (delegate.height + listView.spacing);
		p.updateScrollbar();
	}

	/// Remove all devices from the ScrollableListItemJS.items array and clear the visualDataModel
	function removeAll() {
		ScrollableListItemJS.items = [];
		visualDataModel.clear();
		modelCleared();
	}

	function scrollPage(amount) {
		currentPage += amount;
		if (currentPage == numberOfPages)
			currentPage = numberOfPages - 1;
		else if (currentPage < 0) {
			currentPage = 0;
		} else {
			refreshView();
		}
		scrolledPage();
	}

	function scrollToPage(page) {
		scrollPage(page - currentPage);
	}

	color: colors.background
	radius: designElements.radius

	/// Width and height of scrollable list including buttons area
	width: Math.round(400 * horizontalScaling)
	height: Math.round(400 * verticalScaling)

	ListModel {
		id: visualDataModel
	}

	Rectangle {
		id: markupRect
		color: colors.canvas
		height: parent.height - (designElements.vMargin10 * 2)
		anchors {
			top: parent.top
			topMargin: designElements.vMargin10
			left: parent.left
			leftMargin: designElements.hMargin10
			right: scrollLane.left
			rightMargin: designElements.hMargin6
		}
		radius: designElements.radius

		ListView {
			id: listView
			anchors {
				fill: markupRect
				margins: 4
			}
			model: visualDataModel
			spacing: designElements.hMargin5
			interactive: false
		}
	}

	ThreeStateButton {
		id: butDown
		width: Math.round(44 * horizontalScaling)
		height: markupRect.height / 2
		backgroundUp: colors.background
		backgroundDown: colors.threeStateButtonBckgDown
		buttonDownColor: colors.ibMsgTitleSelected
		iconAlign: "bottom"
		iconMargin: designElements.vMargin6
		image: "qrc:/images/arrow-down.svg"
		anchors {
			bottom: scrollLane.bottom
			right: parent.right
		}
		leftClickMargin: 10
		rightClickMargin: 10
		bottomClickMargin: 10
		onClicked: {
			scrollPage(1);
		}
		enabled: currentPage < (numberOfPages - 1)
	}

	ThreeStateButton {
		id: butUp
		width: Math.round(44 * horizontalScaling)
		height: markupRect.height / 2
		imgRotation: 180
		backgroundUp: colors.background
		backgroundDown: colors.threeStateButtonBckgDown
		buttonDownColor: colors.ibMsgTitleSelected
		iconAlign: "top"
		iconMargin: designElements.vMargin6
		image: butDown.image
		anchors {
			top: scrollLane.top
			right: parent.right
		}
		leftClickMargin: 10
		rightClickMargin: 10
		topClickMargin: 10
		onClicked: {
			scrollPage(-1);
		}
		enabled: currentPage > 0
	}

	Rectangle {
		id: scrollLane
		width: Math.round(6 * horizontalScaling)
		height: markupRect.height
		radius: width / 2
		color: colors.canvas
		anchors {
			right: butUp.left
			top: markupRect.top
		}
	}

	Rectangle {
		id: scrollbar
		width: Math.round(6 * horizontalScaling)
		radius: width / 2
		color: colors.ibListScrollbar
		visible: false
		anchors {
			left: scrollLane.left
			top: scrollLane.top
		}
	}
}
