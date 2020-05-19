import QtQuick 2.0

import BasicUIControls 1.0
import qb.components 1.0

Column {
	id: root
	width:  Math.round(300 * horizontalScaling)
	spacing: designElements.vMargin6
	property int itemsPerPage: 6
	property int maxItems: -1
	property alias model: list.model
	property alias delegate: list.delegate
	property string addDeviceText
	property int addDeviceLabelWidth: width * 0.8
	signal addDeviceClicked()

	ListView {
		id: list
		width: parent.width
		height: (itemHeight ? ((itemHeight * root.itemsPerPage) + (spacing * (root.itemsPerPage-1))) : 0) + addLabelHeightOffset
		spacing: parent.spacing
		property int itemHeight: currentItem ? currentItem.height : 0
		property int addLabelHeightOffset: (!count || (count % root.itemsPerPage === 0 && pageSelector.currentPage === pageSelector.pageCount-1) ? footerItem.height : 0)
		currentIndex: 0
		onCurrentIndexChanged: pageSelector.navigate(Math.floor(list.currentIndex / root.itemsPerPage))

		interactive: false
		clip: true
		preferredHighlightBegin: 0
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveVelocity: -1

		footer: count < maxItems || maxItems === -1 ? addRowComponent : null
	}

	Component {
		id: addRowComponent
		Item {
			width: list.width
			height: addDeviceLabel.height + (list.count ? list.spacing : 0)

			StyledRectangle {
				id: addDeviceLabel
				width: root.addDeviceLabelWidth
				anchors {
					bottom: parent.bottom
					left: parent.left
				}
				height: addButton.height
				radius: designElements.radius
				color: colors.addDeviceItemBg
				property string kpiPostfix: "addDevice"
				onClicked: addButton.clicked()

				Text {
					id: addDeviceText
					anchors {
						left: parent.left
						leftMargin: Math.round(13 * horizontalScaling)
						verticalCenter: parent.verticalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
					}
					color: colors._gandalf
					text: root.addDeviceText
				}
			}

			IconButton {
				id: addButton
				iconSource: "qrc:/images/plus_add.svg"
				anchors {
					bottom: parent.bottom
					left: addDeviceLabel.right
					leftMargin: list.spacing
				}
				topClickMargin: 3

				onClicked: root.addDeviceClicked()
			}
		}
	}

	Item {
		id: spacer
		width: 1
		height: list.itemHeight
		visible: list.addLabelHeightOffset === 0
	}

	DottedSelector {
		id: pageSelector
		width: parent.width
		visible: pageCount > 1
		pageCount: Math.ceil(list.count / root.itemsPerPage)
		hideArrowsOnBounds: true

		onCurrentPageChanged: list.currentIndex = (currentPage * root.itemsPerPage)
	}
}
