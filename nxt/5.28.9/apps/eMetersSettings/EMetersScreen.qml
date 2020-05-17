import QtQuick 2.1

import BasicUIControls 1.0
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: eMetersScreen
	anchors.fill: parent

	screenTitle: qsTr("Meter modules")

	onShown: {
		app.getDeviceInfo()
		if (!feature.appEMetersSettingsAdvancedDisabled())
			addCustomTopRightButton(qsTr("Advanced"))
	}

	onCustomButtonClicked: stage.openFullscreen(app.eMeterAdvancedScreenUrl);

	ListView {
		id: list
		anchors {
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		height: (itemHeight * itemsPerPage) + (spacing * (itemsPerPage-1)) +
				(!count || (count % itemsPerPage === 0 && pageSelector.currentPage === pageSelector.pageCount-1) ? (itemHeight + spacing) : 0)
		spacing: designElements.vMargin6
		interactive: false
		clip: true
		preferredHighlightBegin: 0
		highlightRangeMode: ListView.StrictlyEnforceRange
		highlightMoveVelocity: -1
		property int itemHeight: designElements.rowItemHeight
		property int itemsPerPage: 6

		model: app.usageDevicesInfo
		delegate: Row {
			id: deviceItem
			height: childrenRect.height
			spacing: designElements.hMargin6
			property variant deviceData: modelData

			SingleLabel {
				id: deviceLabel
				width: Math.round(514 * horizontalScaling)
				height: list.itemHeight
				rightTextColor: colors._gandalf
				rightTextSize: qfont.metaText
				leftText: modelData.deviceIdentifier
				leftTextFormat: Text.PlainText // Prevent XSS/HTML injection
				rightText: modelData.statusString
				rightTextMargin: statusRow.width

				onClicked: editButton.clicked()

				Row {
					id: statusRow
					anchors {
						right: parent.right
						rightMargin: designElements.hMargin5
						verticalCenter: parent.verticalCenter
					}
					spacing: Math.round(4 * horizontalScaling)

					Repeater {
						id: statusRepeater
						model: app.enabledUtilities

						Image {
							source: "image://scaled/apps/eMetersSettings/drawables/status-" + modelData + "-" +
									(app.hasUsageOfType(deviceItem.deviceData, modelData) ? "on" : "off") + ".svg"
						}
					}
				}
			}

			IconButton {
				id: editButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				bottomClickMargin: 3
				onClicked: stage.openFullscreen(app.eMeterChangeScreenUrl, {"uuid": modelData.deviceUuid});
			}

			IconButton {
				id: deleteButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/delete.svg"
				bottomClickMargin: 3
				onClicked: stage.openFullscreen(app.removeDeviceScreenUrl, {state: "meteradapter", uuid: modelData.deviceUuid});
			}

			IconButton {
				id: updateButton
				width: designElements.buttonSize
				primary: true
				iconSource: "qrc:/images/update.svg"
				bottomClickMargin: 3
				visible: app.deviceInfo[modelData.deviceUuid] ? app.deviceInfo[modelData.deviceUuid].UpdateAvailable : false
				onClicked: stage.openFullscreen(app.maUpdateScreenUrl, {uuid: modelData.deviceUuid})
			}
		}
		footer: Item {
			width: parent.width
			height: list.itemHeight + list.spacing

			StyledRectangle {
				id: addDeviceLabel
				anchors.bottom: parent.bottom
				width: Math.round(514 * horizontalScaling)
				height: list.itemHeight
				radius: designElements.radius
				color: colors.addDeviceItemBg
				borderColor: colors.addDeviceItemBorder
				borderStyle: "DashLine"
				borderWidth: borderColor !== colors.none ? 2 : 0
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
					text: qsTr("Add meter module")
				}
			}

			IconButton {
				id: addButton
				iconSource: "qrc:/images/plus_add.svg"
				anchors {
					bottom: parent.bottom
					left: addDeviceLabel.right
					leftMargin: designElements.hMargin6
				}
				topClickMargin: 3
				height: addDeviceLabel.height
				width: height
				onClicked: stage.openFullscreen(app.addDeviceScreenUrl, {state: "meteradapter"})
			}
		}
		onCurrentIndexChanged: pageSelector.navigateBtn(Math.floor(list.currentIndex / list.itemsPerPage))
	}

	DottedSelector {
		id: pageSelector
		anchors {
			left: list.left
			right: list.right
			bottom: parent.bottom
			bottomMargin: Math.round(12 * verticalScaling)
		}
		visible: pageCount > 1
		pageCount: Math.ceil(list.count / list.itemsPerPage)

		onNavigate: list.currentIndex = (page * list.itemsPerPage)
	}
}
