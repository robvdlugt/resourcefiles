import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: productFrame
	anchors.fill: parent

	function update(pageChange) {
		// one page with all 3 products if only one metering device, otherwise 1 page with display/boiler and x more pages to show all metering devices
		selector.pageCount = app.meterAdapterInfo.length > 1 ? 1 + Math.ceil(app.meterAdapterInfo.length / productListView.itemsPerPage) : 1;
		productListModel.clear();
		if (selector.currentPage === 0) {
			productListModel.append({"name" : qsTr("Toon"), "displayCode": bxtClient.getCommonname(), "productNr": app.displayInfo.DeviceModel, "serialNr": app.displayInfo.SerialNumber});
			if (globals.heatingMode === "central") {
				productListModel.append({"name" : qsTr("Boiler module"), "displayCode": "", "productNr": app.boilerAdapterInfo.DeviceModel, "serialNr": app.boilerAdapterInfo.SerialNumber });
			}
		}
		var idx = (selector.currentPage === 0 ? 0 : (selector.currentPage-1) * productListView.itemsPerPage);
		var count = (selector.currentPage === 0 ? (app.meterAdapterInfo.length === 1 ? 1 : 0) : productListView.itemsPerPage);
		for (var i = 0; idx < app.meterAdapterInfo.length && i < count; idx++, i++) {
			var uuid = app.getMeterAdapterInfo(idx, 'deviceUuid');
			var deviceIdentifier = app.getDeviceIdentifier(uuid);
			productListModel.append({"name" : deviceIdentifier, "displayCode": "", "productNr": app.getMeterAdapterInfo(idx, 'DeviceModel'), "serialNr": app.getMeterAdapterInfo(idx, 'SerialNumber')});
		}
		if (!pageChange)
			selector.navigateBtn(0);
	}

	function init() {
		app.systemInfoUpdate.connect(update);
	}

	onShown: {
		app.getDeviceInfo();
	}

	Component.onDestruction: app.systemInfoUpdate.disconnect(update)

	ListModel {
		id: productListModel
	}

	ListView {
		id: productListView
		anchors {
			top: parent.top
			topMargin: Math.round(4 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(69 * horizontalScaling)
			bottom: parent.bottom
		}
		spacing: designElements.vMargin6
		model: productListModel
		interactive: false
		property int itemsPerPage: 3

		delegate: Column {
			width: parent.width
			spacing: productListView.spacing

			Text {
				id: moduleCategory
				text: model.name
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.titleText
				}
				color: colors.productLabel
				textFormat: Text.PlainText // Prevent XSS/HTML injection
			}

			SingleLabel {
				id: commonName
				width: parent.width
				visible: model.displayCode
				leftText: qsTr("Display code")
				rightText: visible ? model.displayCode : ""
			}

			SingleLabel {
				id: modulePn
				width: parent.width
				leftText: qsTr("Product number")
				rightText: model.productNr
			}

			SingleLabel {
				id: moduleSn
				width: parent.width
				leftText: qsTr("Serial number")
				rightText: model.serialNr
			}
		}
	}

	DottedSelector {
		id: selector
		anchors {
			left: productListView.left
			right: productListView.right
			bottom: parent.bottom
			bottomMargin: designElements.vMargin5
		}
		visible: pageCount > 1
		hideArrowsOnBounds: true

		onNavigate: productFrame.update(true)
	}
}
