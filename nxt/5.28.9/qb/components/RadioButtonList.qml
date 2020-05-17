import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

/**
 * A component that represents a radiobutton list
 *
 * In a group of radio buttons, only one radio button can be checked at a time.
 * If the user selects another button, the previously selected button is switched off.
 */

Item {
	id: radioButtonList

	implicitWidth: Math.max(listHeader.implicitWidth, listView.implicitWidth)
	implicitHeight: (listHeader.text ? listHeader.height + listView.anchors.topMargin : 0) +
					count * (count ? listView.contentItem.children[0].height : 0) +
					(count ? (count - 1) * listView.spacing : 0)

	property string title
	property alias currentIndex: radioGroup.currentControlId

	property alias count: listView.count
	property alias listDelegate: listView.delegate
	property alias listSpacing: listView.spacing

	property int radioLabelWidth: 0

	function addItem(text) {
		listModel.append({"itemtext": text,"itemEnabled": true, "controlGroup": radioGroup});
	}

	function addCustomItem(item) {
		item.controlGroup = radioGroup;
		item.itemEnabled = true;
		listModel.append(item);
	}

	function setItemEnabled(index,enabled) {
		if(enabled === false) {
			listModel.setProperty(index, "itemEnabled", false);
		} else {
			listModel.setProperty(index, "itemEnabled", true);
		}
	}

	function getModelItem(index) {
		if (index < 0 || index >= listModel.count) {
			return undefined
		} else {
			return listModel.get(index)
		}
	}

	function forceLayout() {
		listView.forceLayout()
	}

	function clearModel() {
		listModel.clear();
		listView.forceLayout()
	}

	Text {
		id: listHeader
		text: title
		anchors {
			left: parent.left
			right: parent.right
		}
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
		color: colors.rbTitle
		wrapMode: Text.WordWrap
	}

	ListView {
		id: listView
		width: radioButtonList.width
		implicitWidth: radioLabelWidth ? radioLabelWidth : maxWidth
		anchors {
			top: listHeader.text ? listHeader.bottom : parent.top
			topMargin: listHeader.text ? Math.round(10 * verticalScaling) : 0
			bottom: parent.bottom
		}
		delegate: listDelegate
		model: listModel

		spacing: Math.round(8 * verticalScaling)

		highlightRangeMode : ListView.StrictlyEnforceRange
		highlightFollowsCurrentItem : false
		interactive: false

		property int maxWidth: 0
	}

	ControlGroup {
		id: radioGroup
		exclusive: true
	}

	Component {
		id: listDelegate

		StandardRadioButton {
			id: radioButton
			width: radioLabelWidth ? radioLabelWidth : parent.width
			controlGroupId: index
			controlGroup: radioGroup
			text: model.itemtext ? model.itemtext : ""
			enabled: model.itemEnabled
			selected: model.selected ? true : false

			property string kpiId: title + ".radioButton" + index

			ListView.onAdd: ListView.view.maxWidth = Math.max(ListView.view.maxWidth, implicitWidth)
		}
	}

	ListModel {
		id: listModel
	}
}
