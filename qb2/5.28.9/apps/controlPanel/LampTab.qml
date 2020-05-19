import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Widget {
	id: root
	anchors.fill: parent

	onShown: lampList.goToPage(0)

	function init() {
		app.devLampsChanged.connect(p.refreshList);
		p.refreshList();
	}

	Component.onDestruction: {
		app.devLampsChanged.disconnect(p.refreshList);
	}

	QtObject {
		id: p

		property url addLampPopupUrl: "AddLampPopup.qml"

		function refreshList() {
			lampList.removeAll();
			var lamps = app.devLamps;
			lamps.sort(app.compareDeviceNames);
			for (var idx = 0; idx < lamps.length; idx++) {
				lampList.addDevice({"name": lamps[idx].Name,
									"isLinked": lamps[idx].InSwitchAll === "1",
									"isLocked": lamps[idx].SwitchLocked === "1",
									"device": lamps[idx]});
			}
			lampList.refreshView();
		}

		function editLampItem(device) {
			stage.openFullscreen(app.editLampScreenUrl, {lampUuid: device.DevUUID})
		}

		function addLampPopup() {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Add hue-lamp popup"), p.addLampPopupUrl);
		}
	}

	Item {
		id: lampListTab
		anchors.fill: parent
		visible: app.linkedBridgeUuid ? true : false

		Text {
			id: listPageTitle
			text: qsTr("lamp_list_page_title")
			font {
				pixelSize: qfont.titleText
				family: qfont.semiBold.name
			}
			color: colors.plugTabTitle
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(42 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(56 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
		}

		Text {
			id: listPageInfo
			text: qsTr("lamp_list_page_info")
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.plugTabText
			anchors {
				left: listPageTitle.left
				right: listPageTitle.right
				baseline: listPageTitle.baseline
				baselineOffset: Math.round(34 * verticalScaling)
			}
			wrapMode: Text.WordWrap
		}

		Component {
			id: deviceListDelegate
			DeviceListDelegate {
				onEditDeviceClicked:{
					if (lampList.getDevice(index).device) {
						p.editLampItem(lampList.getDevice(index).device);
					}
				}
			}
		}

		SmartDeviceList {
			id: lampList
			anchors {
				left: listPageInfo.left
				top: listPageInfo.bottom
				topMargin: Math.round(26 * verticalScaling)
				right: listPageInfo.right
				bottom: parent.bottom
			}

			delegate: deviceListDelegate
			addDeviceText: qsTr("Add lamp")

			onAddDeviceClicked: p.addLampPopup()
		}
	}

	Item {
		id: lampWizardTab
		anchors.fill: parent
		visible: !lampListTab.visible

		Text {
			id: lampTabTitle
			anchors {
				top: parent.top
				topMargin: Math.round(40 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(55 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.plugTabTitle
			text: qsTr("lamp_tab_title")
		}

		Text {
			id: lampTabText
			anchors {
				top: lampTabTitle.bottom
				topMargin: designElements.vMargin15
				left: lampTabTitle.left
				right: lampTabTitle.right
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.plugTabText
			text: qsTr("lamp_tab_text")
			wrapMode: Text.WordWrap
		}

		Text {
			id: lampTabTitle2
			anchors {
				baseline: parent.verticalCenter
				left: lampTabTitle.left
				right: lampImage.left
				rightMargin: Math.round(13 * horizontalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.plugTabTitle
			text: qsTr("lamp_tab_title2")
		}

		Text {
			id: lampTabText2
			anchors {
				top: lampTabTitle2.bottom
				topMargin: designElements.vMargin15
				left: lampTabTitle2.left
				right: lampTabTitle2.right
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.plugTabText
			text: qsTr("lamp_tab_text2")
			wrapMode: Text.WordWrap
		}

		StandardButton {
			id: addlampButton
			anchors {
				left: lampTabTitle.left
				top: lampTabText2.bottom
				topMargin: Math.round(30 * verticalScaling)
			}
			text: qsTr("Link bridge")
			onClicked: {
				stage.openFullscreen(app.addBridgeScreenUrl);
			}
		}

		Image {
			id: lampImage
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(60 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(60 * horizontalScaling)
			}
			source: "image://scaled/apps/controlPanel/drawables/hue-lamp.svg"
		}
	}
}
