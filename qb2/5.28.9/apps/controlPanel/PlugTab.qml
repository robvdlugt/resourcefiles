import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Widget {
	id: root
	anchors.fill: parent

	onShown: plugList.goToPage(0)

	function init() {
		app.devPlugsChanged.connect(p.refreshList);
		p.refreshList();
	}

	Component.onDestruction: {
		app.devPlugsChanged.disconnect(p.refreshList);
	}

	QtObject {
		id: p

		function refreshList() {
			plugList.removeAll();
			var plugs = app.devPlugs;
			plugs.sort(app.compareDeviceNames);
			for (var idx = 0; idx < plugs.length; idx++) {
				plugList.addDevice({"name": plugs[idx].Name,
									"isLinked": plugs[idx].InSwitchAll === "1",
									"isLocked": plugs[idx].SwitchLocked === "1",
									"device": plugs[idx]});
			}
			plugList.refreshView();
		}

		function editPlugItem(device) {
			stage.openFullscreen(app.editPlugScreenUrl, {plugUuid: device.DevUUID})
		}
	}

	Item {
		id: plugListPage
		visible: app.devPlugs.length > 0
		anchors.fill: parent

		Text {
			id: listPageTitle
			text: qsTr("Managing Smart Plugs")
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(42 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(56 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.plugTabTitle
		}

		Text {
			id: listPageInfo
			text: qsTr("Here you can add your Smart Plugs, rename, delete or linking to everything on / off button")
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
					if (plugList.getDevice(index).device) {
						p.editPlugItem(plugList.getDevice(index).device);
					}
				}
			}
		}

		SmartDeviceList {
			id: plugList
			anchors {
				left: listPageInfo.left
				top: listPageInfo.bottom
				topMargin: Math.round(26 * verticalScaling)
				right: listPageInfo.right
				bottom: parent.bottom
			}
			delegate: deviceListDelegate
			addDeviceText: qsTr("Add plug")

			onAddDeviceClicked: stage.openFullscreen(app.addPlugScreenUrl);
		}
	}

	Item {
		id: plugWizardTab
		anchors.fill: parent
		visible: !plugListPage.visible

		Text {
			id: plugTabTitle
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
			text: qsTr("plug_tab_title")
		}

		Text {
			id: plugTabText
			anchors {
				left: plugTabTitle.left
				right: plugTabTitle.right
				top: plugTabTitle.bottom
				topMargin: designElements.vMargin15
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.plugTabText
			text: qsTr("plug_tab_text")
			wrapMode: Text.WordWrap
		}

		StandardButton {
			id: addPlugButton
			anchors {
				left: plugTabTitle.left
				top: plugTabText.bottom
				topMargin: Math.round(30 * verticalScaling)
			}
			text: qsTr("Add plug")
			onClicked: stage.openFullscreen(app.addPlugScreenUrl);
		}

		Text {
			id: noPlugsYetTitle
			anchors {
				top: addPlugButton.bottom
				topMargin: Math.round(30 * verticalScaling)
				left: plugTabTitle.left
				right: plugImage.left
				rightMargin: Math.round(13 * horizontalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.plugTabTitle
			text: qsTr("No plugs yet?")
		}

		Text {
			id: noPugsYetLink
			anchors {
				top: noPlugsYetTitle.bottom
				topMargin: designElements.vMargin15
				left: noPlugsYetTitle.left
				right: noPlugsYetTitle.right
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.plugTabText
			text: qsTr("buy them here")
		}

		Image {
			id: plugImage
			anchors {
				right: parent.right
				rightMargin: Math.round(60 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: anchors.rightMargin
			}
			source: visible ? "image://colorized/" + colors.plugIconWelcomeScreen.toString()
							  + "/apps/controlPanel/drawables/smartplug.svg" : ""
		}
	}
}
