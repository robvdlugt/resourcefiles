import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Screen {
	id: settingsScreen
	objectName: "settingsScreen"
	property Widget currentFrame

	screenTitleIconUrl: "drawables/SettingsMenuIcon.svg"
	screenTitle: qsTr("Settings")
	anchors.fill: parent

	function init(app) {
		registry.registerWidgetContainer("settingsFrame", settingsScreen);
	}

	function onWidgetRegistered(widgetInfo) {
		if (widgetInfo.args) {
			var screen = util.loadComponent(widgetInfo.url, rightPanel, {visible: false, width: 602, height: 400, app:widgetInfo.context});
			if (screen) {
				screen.initWidget(widgetInfo);
				addCategory(screen, widgetInfo.url, widgetInfo.args.categoryName, widgetInfo.args.categoryWeight);
				if (lCategory.dataIndex === -1)
					lCategory.selectItem(0);
			}
		}
	}

	function onWidgetDeregistered(widgetInfo) {
		console.log("Remove", widgetInfo.url, widgetInfo.uid);
		// First remove the name from the category model
		for (var j = 0; j < categoryModel.count; j++) {
			var curCategory = categoryModel.get(j);
			if (curCategory.url === widgetInfo.url.toString()) {
				console.log("Found matching category:", curCategory.url, curCategory.name);
				categoryModel.remove(j);
				break;
			}
		}

		// Then remove the actual widget
		for (var i = 0; i < rightPanel.children.length; i++) {
			var curChild = rightPanel.children[i];
			if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
				console.log("Found child with widget.uid", widgetInfo.uid);
				curChild.visible = false;
				curChild.parent = null;
				curChild.destroy();
				break;
			}
		}
	}

	function addCategory(frame, url, name, weight) {
		var insertIdx = 0;
		var count = categoryModel.count;

		for (; insertIdx < count; insertIdx++)
			if (categoryModel.get(insertIdx).weight > weight)
				break;

		categoryModel.insert(insertIdx, {"frame": frame, "url": url.toString(), "name": name, "weight": weight, "kpiPrefix": url.toString().split("qml")[1]});
	}

	function openCategory(indexCategory) {
		if (currentFrame) {
			currentFrame.hide();
			currentFrame.hidden();
		}
		currentFrame = indexCategory.frame;
		currentFrame.show();
		currentFrame.shown(null);
		rightPanel.kpiPrefix = indexCategory.kpiPrefix;
	}

	onShown: {
		if (args) {
			if (args.showDefault) {
				lCategory.selectItem(0);
			} else if (args.categoryUrl) {
				for (var i=0; i<lCategory.count; i++) {
					var item = lCategory.dataModel.get(i);
					if (item.url === Qt.resolvedUrl(args.categoryUrl)) {
						// category already open, update it
						if (lCategory.dataIndex === i && currentFrame)
							currentFrame.shown(null);
						else
							lCategory.selectItem(i);
						break;
					}
				}
			}
		} else {
			// Update values in current frame
			if (currentFrame)
				currentFrame.shown(null);
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
					openCategory(model);
			}
		}
	}

	Item {
		id: rightPanel

		property string kpiPrefix

		height: parent.height
		anchors.left: lCategory.right
		anchors.right: parent.right
	}
}
