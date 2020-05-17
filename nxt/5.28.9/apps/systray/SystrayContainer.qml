import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0

Row {
	id: systrayContainer
	height: parent? parent.height : undefined
	layoutDirection : Qt.RightToLeft

	function init() {
		registry.registerWidgetContainer("systrayIcon", systrayContainer);
		stage.systrayContainer = systrayContainer;
	}

	function insertAtPosIndex(container, newItem) {
		// walk through original array len once
		var len = container.children.length;
		var i = 0;

		// Loop until we find the item in front of which the newItem should be placed.
		// Then add it at the end and from there relocate the remaining items to the end.
		while (len--) {
			var item = container.children[i];

			// should this item come after newItem?
			if (item.posIndex > newItem.posIndex) {
				// append it if it has not been added yet
				if (!newItem.parent)
					newItem.parent = container;

				// reparent it to add it to the end
				item.parent = null
				item.parent = container
				i--; // compensate for index changes in children[]
			}
			// otherwise before, so skip it
			i++;
		}

		// edge case: empty list: add it
		if (!newItem.parent)
			newItem.parent = container;
	}

	function onWidgetRegistered(widgetInfo) {
		// create with null parent
		var newItem = util.loadComponent(widgetInfo.url, null, {app: widgetInfo.context});
		if (newItem.objectName === "")
			console.warning("As a reference for Squish, please define widgetInfo.args.objectName on the systray icon");

		if (newItem) {
			console.log("Loading systrayIcon " + widgetInfo.url + ", posIndex: " + newItem.posIndex);
			if (newItem.posIndex === -999) {
				console.log("SystrayIcon " + widgetInfo.url + " has no posIndex, using 999");
				newItem.posIndex = 999;
			}

			insertAtPosIndex(systrayContainer, newItem);
			newItem.initWidget(widgetInfo);
		} else {
			console.error("Error loading systrayIcon " + widgetInfo.url);
		}
	}
}
