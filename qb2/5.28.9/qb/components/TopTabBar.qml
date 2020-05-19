import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Item {

	property alias currentIndex: tabButtonGroup.currentControlId

	property alias count: tabs.count

	function addItem(text) {
		listModel.append({ "itemtext": text });
		width = tabButtonList.width;
	}

	function setSelectedItem(index) {
		currentIndex = index;
	}

	height: Math.round(48 * verticalScaling)

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
	}

	Component {
		id: listDelegate

		TopTabButton {
			id: tabButton
			text: model.itemtext
			controlGroup: tabButtonGroup
		}
	}

	ListModel {
		id: listModel
	}
}

