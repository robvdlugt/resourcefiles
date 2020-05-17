import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

import "SmartDeviceList.js" as SmartDeviceListJS

/**
 * Component displaying list of smart devices - smokeDetectors, plugs or lamps.
 * Component is build around two list models, one that contains the data and one that containts the visible items
 * At the end of the list a dash bordered item is added to "Add" a device.
 * Scrolling is page based using goToPage() method. To add/remove device use addDevice()/removeDevice methods.
*/

Item {
	id: root

	/// how much items are visible in one page, default 4
	property int itemsPerPage: 4
	/// height of each item in pixels, default 36
    property int itemHeight: designElements.rowItemHeight
	/// text for add a device item
	property alias addDeviceText: addDeviceText.text
	/// max number of items, when the maximum number of items is exceeded the add new item button is not visible any more. Default 0 means not used.
	property int maxItems: 0
	/// delegate that hold the custom layout of the SmartDeviceList
	property alias delegate: listView.delegate
	/// when add device button is clicked
	signal addDeviceClicked()
	/// The root item for the 'add device' entry below the list of items
	property alias addItem: addDeviceItem
	/// The number of items currently in the model
	property alias itemCount: visualDataModel.count

	// Used for internal storage of the data. Cannot be private in this case because they need to be accessable from the external delegate
	property int currentIndex: 0

	/// add a device to list using this method.
	function addDevice(devVar) {
		SmartDeviceListJS.devices.push(devVar);
		listPageSelector.pageCount = Math.ceil(SmartDeviceListJS.devices.length / itemsPerPage);
	}

	/// return a specific device from the SmartDeviceListJS.devices array
	function getDevice(index) {
		return SmartDeviceListJS.devices[index+currentIndex];
	}

	/// remove device from specific index
	function removeDevice(index) {
		SmartDeviceListJS.devices.splice(index)
		listPageSelector.pageCount = Math.ceil(SmartDeviceListJS.devices.length / itemsPerPage);
		refreshView();
	}

	/// navigate to specific page (0-based)
	function goToPage(page) {
		if (page >= 0 && page < listPageSelector.pageCount) {
			while (listPageSelector.currentPage !== page) {
				listPageSelector.navigateLeft();
			}
		}
	}

	/// Remove all devices from the SmartDeviceListJS.devices array and the visualModel
	function removeAll() {
		SmartDeviceListJS.devices = [];
		visualDataModel.clear();
	}

	/// Refresh the visual data model to refresh the visuals list
	function refreshView() {
		visualDataModel.clear();
		for (var i = currentIndex; i < currentIndex + itemsPerPage && i < SmartDeviceListJS.devices.length; i++) {
			visualDataModel.append(SmartDeviceListJS.devices[i]);
		}
		listView.height = visualDataModel.count * (itemHeight+listView.spacing);

		// Workaround to make sure that addDeviceItem.visible is recalculated.
		var tmpMaxItems = maxItems;
		maxItems = 0;
		maxItems = tmpMaxItems;
	}

	function getPageForDataIdx(dataIdx) {
		return SmartDeviceListJS.devices.length > 0 ? Math.floor(dataIdx / itemsPerPage) : -1;
	}

	function getFirstVisibleDataIdxOnPage(pageIdx) {
		return SmartDeviceListJS.devices.length > 0 ? pageIdx * itemsPerPage : -1;
	}

	ListModel {
		id: visualDataModel
	}

	ListView{
		id: listView
		width: root.width
		model: visualDataModel
		spacing: Math.round(6 * horizontalScaling)
		interactive: false
	}

	Item {
		id: addDeviceItem
		property bool onLastPage: listPageSelector.currentPage + 1 === listPageSelector.pageCount
		anchors {
			top: listView.bottom
			left: root.left
			right: root.right
		}
		visible: maxItems ? (SmartDeviceListJS.devices.length < maxItems ? onLastPage : false) : onLastPage

		StyledRectangle {
			id: addDeviceLabel
			anchors {
				left: addDeviceItem.left
				right: addButton.left
				rightMargin: designElements.hMargin6
			}
			height: designElements.rowItemHeight

			radius: designElements.radius
			color: colors.addDeviceItemBg
			borderColor: colors.addDeviceItemBorder
			borderStyle: "DashLine"
			borderWidth: borderColor !== colors.none ? 2 : 0

			topClickMargin: 3
			bottomClickMargin: 3
			leftClickMargin: 10
			property string kpiPostfix: "addDevice"

			onClicked: addDeviceClicked()

			Text {
				id: addDeviceText
				font.family: qfont.regular.name
				font.pixelSize: qfont.titleText
				color: colors.singleLabelLeftText

				anchors {
					left: addDeviceLabel.left
					leftMargin: Math.round(13 * horizontalScaling)
					verticalCenter: addDeviceLabel.verticalCenter
				}
				text: "Add device"
			}
		}

		IconButton {
			id: addButton
			iconSource: "qrc:/images/plus_add.svg"
			anchors {
				top: addDeviceItem.top
				right: addDeviceItem.right
			}
			topClickMargin: 3
			height: addDeviceLabel.height
			width: height
			onClicked: addDeviceClicked()
		}
	}

	DottedSelector {
		id: listPageSelector
		width: Math.round(488 * horizontalScaling)

		anchors {
			left: root.left
			bottom: root.bottom
			bottomMargin: Math.round(21 * verticalScaling)
		}

		visible: pageCount > 1

		onNavigate: {
			var currentPage = getPageForDataIdx(currentIndex);
			if (currentPage !== page) {
				var lastPage = getPageForDataIdx(SmartDeviceListJS.devices.length - 1);
				if (page >= 0 && page <= lastPage) {
					currentIndex = getFirstVisibleDataIdxOnPage(page);
					refreshView();
				}
			}
		}
	}
}
