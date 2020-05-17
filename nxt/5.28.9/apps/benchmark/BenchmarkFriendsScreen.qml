import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Screen {
	id: benchmarkFriendsScreen

	property Widget currentFrame

	screenTitle: qsTr("Friends list")
	anchors.fill: parent

	function init() {
		registry.registerWidgetContainer("benchmarkFriendsFrame", benchmarkFriendsScreen);
	}

	function onWidgetRegistered(widgetInfo) {
		if (widgetInfo.args) {
			p.addCategory(widgetInfo.url, widgetInfo.args.categoryName, widgetInfo.args.categoryWeight, widgetInfo.args.bulletNumProperty);
			if (lCategory.dataIndex === -1)
				lCategory.selectItem(0);
		}
	}

	QtObject {
		id: p

		function addCategory(url, name, weight, bulletNumProperty) {
			var insertIdx = 0;
			var count = categoryModel.count;

			for (; insertIdx < count; insertIdx++)
				if (categoryModel.get(insertIdx).weight > weight)
					break;

			categoryModel.insert(insertIdx, {"url": url.toString(), "name":name, "weight":weight, "bulletNumProperty": bulletNumProperty ? bulletNumProperty : ""});
		}

		function showCategory(url) {
			if (rightPanel.item)
				rightPanel.item.hidden();
			rightPanel.setSource(url, {app: benchmarkFriendsScreen.app});
			if (rightPanel.item) {
				rightPanel.item.shown(null);
			}
			rightPanel.kpiPrefix = url.split("qml")[0];
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
	}

	onShown: {
		if (args && args.categoryUrl) {
			p.openCategoryByUrl(args.categoryUrl);
		}
	}

	ListModel {
		id: categoryModel
	}

	Component {
		id: categoryDelegate
		CategoryListItem {
			height: lCategory.itemHeight
			selected: ListView.isCurrentItem

			property int bulletNum: 0

			NumberBullet {
				size: designElements.hMargin15
				text: bulletNum
				visible: bulletNum > 0

				anchors {
					right: parent.right
					rightMargin: Math.round(20 * horizontalScaling)
					top: parent.top
					topMargin: designElements.vMargin10
				}
			}

			onClicked: lCategory.selectItem(index)
			onSelectedChanged: {
				if (selected)
					p.showCategory(model.url);
			}

			Component.onCompleted: {
				if (model.bulletNumProperty && typeof app[model.bulletNumProperty] === "number") {
					bulletNum = Qt.binding(function () {
						return benchmarkFriendsScreen.app[model.bulletNumProperty];
					});
				}
			}
		}
	}

	SimpleList {
		id: lCategory
		width: Math.round(198 * horizontalScaling)
		anchors.top: parent.top

		itemsPerPage: 7
		itemHeight: Math.round(53 * verticalScaling)

		dataModel: categoryModel
		delegate: categoryDelegate
	}

	Loader {
		id: rightPanel
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: lCategory.right
			right: parent.right
		}
		property string kpiPrefix
	}
}
