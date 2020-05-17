import QtQuick 2.1

import "App.js" as AppJs;

/**
 * Base functionality for any App
 * Handles setting of automagic references to instantiated widgets.
 */
Item {
	id: root;

	property int initVars
	property int initVarCount: 0
	property bool doneLoading: true

	/**
	 * Called automatically when a new Widget has been instantiated.
	 * Performs setting of automagic references to instantiated widgets.
	 * @param type:WidgetInfo widgetInfo
	 * @param type:Widget widget The newly instantiated Widget object
	 */
	function widgetInstantiated(widgetInfo, widget) {
		var list = AppJs.instantiatedWidgets;
		var category = list[widgetInfo.url];
		if (!category) {
			list[widgetInfo.url] = [];
		}
		list[widgetInfo.url].push(widget);
		if ((widgetInfo.localName !== null) && (widgetInfo.localName !== "") && (root[widgetInfo.localName] !== undefined)) {
			root[widgetInfo.localName] = widget;
		}
	}

	/**
	 * Called when an instance of a Widget is discarded. Will remove references from the App to the Widget.
	 * @param type:Widget widget The removed Widget instance
	 */
	function widgetUninstantiated(widget) {
		var list = AppJs.instantiatedWidgets;
		var category = list[widget.widgetInfo.url];
		if (!category) {
			return;
		}

		var localName = widget.widgetInfo.localName;
		if ((localName !== null) && (localName !== "") && (root[localName] === widget))
			root[localName] = null;

		var index = category.indexOf(widget);
		category.splice(index, 1);
	}

	/**
	 * Get an array of widgets instantiated from the given Url
	 * @param type:url type
	 * @return type:Array<Widget> the Read-only array containing the instantiated widgets.
	 */
	function getInstantiatedWidgets(type) {
		return AppJs.instantiatedWidgets[type];
	}

	function initVarDone(initVar) {
		if (!initVars)
			return;

		initVars = initVars & (~(1 << initVar));

		if (!initVars)
			doneLoading = true;
	}

	onInitVarCountChanged: {
		doneLoading = false;
		initVars = (1 << initVarCount) - 1;
	}
}
