import QtQuick 2.1
import qb.components 1.0

Item {
	id: inboxSimpleList
	anchors.fill: parent
	property int itemsPerPage: 5
	/// delegate for the ListView
	property alias delegate: inboxList.delegate
	/// data model for all items (not only the visible ones)
	property alias dataModel: inboxList.model
	/// Size of the items
	property int itemHeight

	ListView
	{
		id: inboxList
		height: Math.round(itemHeight * itemsPerPage)
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: scrollBar.left
			rightMargin: Math.round(36 * horizontalScaling)
		}
		clip: true
		interactive: false
		onCountChanged: {
			if (count === 0)
				contentHeight = 0;
			positionViewAtIndex(scrollBar.currentIndex, ListView.Beginning);
		}
	}

	ScrollBar
	{
		id: scrollBar
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: parent.right
			rightMargin: Math.round(16 * horizontalScaling)
		}
		container: inboxList
		property int currentIndex: 0
		onNext: {
			currentIndex = Math.min(currentIndex + itemsPerPage, inboxList.count - 1);
			inboxList.positionViewAtIndex(currentIndex, ListView.Beginning);
			if (inboxList.atYEnd)
				currentIndex = inboxList.count - itemsPerPage;
		}
		onPrevious: {
			currentIndex = Math.max(currentIndex - itemsPerPage, 0);
			inboxList.positionViewAtIndex(currentIndex, ListView.Beginning);
			if (inboxList.atYBeginning)
				currentIndex = 0;
		}
	}
}
