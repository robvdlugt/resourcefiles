import QtQuick 2.1

import qb.components 1.0;
import qb.base 1.0;

Screen {
	id: menuScreen
	inNavigationStack: true

	property int itemsPerPage: 15

	property url defaultMenuItemUrl: "DefaultMenuItem.qml"
	property Component defaultMenuItem

	property int maxMenuItemWeight: 100000

	//for unit tests
	property alias utestItemContainer: itemContainer
	property alias utestNavBar: widgetNavBar

	function init(app) {
		defaultMenuItem = util.preloadComponent(defaultMenuItemUrl);
		registry.registerWidgetContainer("menuItem", menuScreen);
	}

	function createMenuItem(widgetInfo) {
		var item;
		var itemWeight = maxMenuItemWeight;
		if (widgetInfo.args)
			if (widgetInfo.args.weight) {
				itemWeight = widgetInfo.args.weight;
			}
		if (widgetInfo.url) {
			item = util.loadComponent(widgetInfo.url, itemContainer, Object.assign({app: widgetInfo.context, weight: itemWeight}, widgetInfo.args));
		} else {
			widgetInfo.url = defaultMenuItemUrl;
			item = util.instantiateComponent(defaultMenuItem, itemContainer, {screenUrl:widgetInfo.args.screenUrl, screen: widgetInfo.args.screen, args:widgetInfo.args.args, label: widgetInfo.args.label, image: widgetInfo.args.image, weight: itemWeight, app: widgetInfo.context, objectName: widgetInfo.args.objectName});
		}

		// Initialize item
		if (item) {
			item.initWidget(widgetInfo);
		} else {
			console.debug("Failed to create menuItem!");
			return;
		}
		item.visibleChanged.connect(recountPages);
		util.insertItem(item, itemContainer, "weight");
		recountPages();
	}

	function onWidgetRegistered(widgetInfo) {
		createMenuItem(widgetInfo);
	}

	function navigatePage(page) {
		itemContainerParent.contentY = page * itemContainerParent.height;
	}

	function recountPages() {
		var count = 0;
		var item;
		if(itemContainer) {
			for (var i=0; i < itemContainer.children.length; i++) {
				item = itemContainer.children[i];
				if (typeof item.visible !== "undefined" && item.visible === true)
					count++;
			}
			widgetNavBar.pageCount = Math.ceil(count / itemsPerPage);
		}
	}

	onShown: widgetNavBar.navigateBtn(0);

	UnFlickable {
		id: itemContainerParent
		width: Math.round(672 * horizontalScaling)
		// 104 is the height for MenuItem, plus 8 for the spacing
		height: Math.round((104 + 8) * 3 * verticalScaling)
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Math.round(22 * verticalScaling)
		clip: true

		Flow {
			id: itemContainer
			spacing: designElements.spacing8
			width: parent.width
			height: parent.height
		}
	}

	DottedSelector {
		id: widgetNavBar
		width: Math.round(488 * horizontalScaling)
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 0
		pageCount: 0
		onNavigate: navigatePage(page);
	}
}
