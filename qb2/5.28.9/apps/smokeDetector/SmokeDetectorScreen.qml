import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Screen {
	id: smokeDetectorScreen

	property Widget currentFrame

	screenTitle: qsTr("Smoke detector")
	screenTitleIconUrl: "drawables/smokedetector.svg"
	hasBackButton: false;
	anchors.fill: parent

	function init() {
		registry.registerWidgetContainer("smokeDetectorFrame", smokeDetectorScreen);
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

	function addCategory(frame, url, name, weight) {
		var insertIdx = 0;
		var count = categoryModel.count;

		for (; insertIdx < count; insertIdx++)
			if (categoryModel.get(insertIdx).weight > weight)
				break;

		categoryModel.insert(insertIdx, {"frame":frame, "url":url.toString(), "name":name, "weight":weight, "kpiPrefix":url.toString().split("qml")[1]});
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
		if (args && args.categoryUrl) {
			for (var i=0; i<lCategory.count; i++) {
				var currentItem = lCategory.dataModel.get(i);
				if (currentItem.url === args.categoryUrl.toString()) {
					lCategory.selectItem(i);
					break;
				}
			}
		} else {
			// Update values in current frame
			if (currentFrame)
				currentFrame.shown(null);
		}
		addCustomTopRightButton(qsTr("Notifications"));
	}

	onCustomButtonClicked: {
		// Reset the uuid and name of the smokedetector that is added
		app.currentSmokedetectorUuid = "";
		app.currentSmokedetectorName = "";

		stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/settings/SettingsScreen.qml"), {categoryUrl: Qt.resolvedUrl("qrc:/apps/systemSettings/NotificationsFrame.qml")});
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

		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.left:  lCategory.right
		anchors.right: parent.right
	}
}
