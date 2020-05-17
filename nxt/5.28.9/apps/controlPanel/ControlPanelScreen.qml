import QtQuick 2.1

import qb.components 1.0

Screen {
	id: controlPanelScreen

	screenTitleIconUrl: "drawables/controlPanelClosed.svg"
	screenTitle: qsTr("Control Panel")

	onShown: {
		if (args && typeof args.tab !== "undefined") {
			if (args.tab === "first")
				lCategory.selectItem(0);
			else
				p.openCategoryByUrl(args.tab);
		}
	}

	Component.onDestruction: {
		app.linkedBridgeUuidChanged.disconnect(p.checkBridgeLinked);
	}

	function init() {
		p.addCategory(qsTr("Plugs"), app.plugTabUrl);
		p.addCategory(qsTr("Lamps"), app.lampTabUrl);
		if (feature.featAlarmControlEnabled()) {
			p.addCategory(qsTranslate("AlarmPanel", "Security"), app.securityTabUrl);
		}

		app.linkedBridgeUuidChanged.connect(p.checkBridgeLinked);
		p.checkBridgeLinked();
	}

	QtObject {
		id: p
		property bool scenesAndBridgeTabVisible: false

		function addCategory(name, tabUrl) {
			if (name && tabUrl) {
				categoryModel.append({"name": name, "url": tabUrl.toString()});
				if (lCategory.dataIndex === -1)
					lCategory.selectItem(0);
			}
		}

		function removeCategory(tabUrl) {
			for (var j = 0; j < categoryModel.count; j++) {
				var curCategory = categoryModel.get(j);
				if (curCategory.url === tabUrl.toString()) {
					categoryModel.remove(j);
					return true;
				}
			}
			return false;
		}

		function showCategory(url) {
			if (rightPanel.item)
				rightPanel.item.hidden();
			rightPanel.setSource(url, {"app": controlPanelScreen.app, "widgetInfo": {"container": controlPanelScreen}});
			if (rightPanel.item) {
				rightPanel.item.init();
				rightPanel.item.shown(null);
			}
		}

		function openCategoryByUrl(url) {
			for (var i = 0; i < categoryModel.count; i++) {
				var curCategory = categoryModel.get(i);
				if (curCategory.url === url.toString()) {
					lCategory.selectItem(i)
					return true;
				}
			}
			return false;
		}

		function enableScenesAndBridge() {
			var selectedIdx = lCategory.dataIndex;
			p.addCategory(qsTr("Scenes"), app.sceneTabUrl);
			p.addCategory(qsTr("Bridge"), app.bridgeTabUrl);
			lCategory.selectItem(selectedIdx);
			p.scenesAndBridgeTabVisible = true;
		}

		function disableScenesAndBridge() {
			p.removeCategory(app.sceneTabUrl);
			p.removeCategory(app.bridgeTabUrl);
			p.scenesAndBridgeTabVisible = false;
		}

		function checkBridgeLinked() {
			if (app.linkedBridgeUuid && !p.scenesAndBridgeTabVisible) {
				p.enableScenesAndBridge();
			} else if (!app.linkedBridgeUuid && p.scenesAndBridgeTabVisible) {
				p.disableScenesAndBridge();
			}
		}
	}

	ListModel {
		id: categoryModel
	}

	SimpleList {
		id: lCategory
		width: Math.round(198 * horizontalScaling)
		anchors.top: parent.top


		itemsPerPage: 7
		itemHeight: Math.round(53 * verticalScaling)

		dataModel: categoryModel
		delegate: CategoryListItem {
			height: lCategory.itemHeight
			selected: ListView.isCurrentItem

			onClicked: lCategory.selectItem(index)
			onSelectedChanged: {
				if (selected)
					p.showCategory(model.url);
			}
		}
	}

	Loader {
		id: rightPanel
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: lCategory.right
			right: parent.right
		}
	}
}
