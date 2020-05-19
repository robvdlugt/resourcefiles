import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Item {
	id: bottomTabBar
	implicitWidth: tabButtonList.width
	height: Math.round(48 * verticalScaling)

	property alias currentIndex: tabButtonGroup.currentControlId
	property alias controlGroup: tabButtonGroup
	property alias count: tabs.count

	signal currentControlIdChangedByUser();

	function addItem(text, kpiId) {
		listModel.append({ "itemtext": text, "kpiId": kpiId });
	}

	function setSelectedItem(index) {
		currentIndex = index;
	}

	/// Sets item at index visibility. Select next visible item when hiding currently selected item. Set currentIndex to -1 when hiding last visible item.
	function setItemVisible(index, visible) {
		if (count <= 0 || index >= count)
			return;

		var item = tabs.itemAt(index);
		if (item.visible === visible)
			return;
		item.visible = visible;

		//hiding currently selected item - find next visible item
		if (!visible && index === currentIndex) {
			var i = (index + 1) % count;
			while (i !== index && !tabs.itemAt(i).visible) {
				i = (i + 1) % count;
			}
			currentIndex = tabs.itemAt(i).visible ? i : -1;
		}

		//showing an item after hiding all of them, make it selected
		if (visible && currentIndex < 0) {
			currentIndex = index;
		}
	}

	/// Enables or disables item at specified index
	function setItemEnabled(index, enabled) {
		if (count <= 0 || index >= count)
			return;

		var item = tabs.itemAt(index);
		if (item.enabled === enabled)
			return;
		item.enabled = enabled;
	}

	Row {
		id: tabButtonList

		spacing: Math.round(4 * horizontalScaling)

		Repeater {
			id: tabs
			model: listModel
			delegate: listDelegate
		}
	}

	ControlGroup {
		id: tabButtonGroup
		exclusive: true
		onCurrentControlIdChangedByUser: bottomTabBar.currentControlIdChangedByUser()
	}

	Component {
		id: listDelegate

		BottomTabButton {
			id: tabButton
			text: model.itemtext
			controlGroupId: index
			controlGroup: tabButtonGroup
			kpiId: model.kpiId
		}
	}

	ListModel {
		id: listModel
	}
}

