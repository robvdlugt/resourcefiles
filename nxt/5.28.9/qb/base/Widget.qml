import QtQuick 2.1

import qb.base 1.0

/**
 * Provides the base functionality for any widget.
 * Sets references from Widget to owner App and back. When everythin is set-up init() will be invoked.
 */
Item {
	id: root
	/// The widget is shown, args is an object holding arguments
	signal shown(variant args)
	/// The widget is hidden
	signal hidden()
	///
	signal doInit()
	/// The widget dim state
	property bool dimState: typeof canvas !== "undefined" ? canvas.dimState : false

	/// Is the widget currently being displayed? visible or apacity should not be used to check this since they may or may not be used by the framework to show/hide the widget.
	property bool showing: false
	/// Handle to the app that owns this Widget. Can be overridden by a more specific App subtype
	property App app
	/// The args specified when registering the widget type
	property variant widgetArgs
	property variant widgetInfo

	/**
	 * Should be called by the WidgetContainer upon widget instantiation.
	 * Handles setting up the references and innitializeing the widget
	 * @param type:WidgetInfo widgetInfo widgetInfo for the instantiated Widget.
	 */
	function initWidget(widgetInfo) {
		root.widgetInfo = widgetInfo;
		root.widgetArgs = widgetInfo.args;

		root.app = widgetInfo.context;
		app.widgetInstantiated(widgetInfo, root);
		doInit();
		init(widgetInfo.context);
	}

	/**
	 * Should be overridden by the Widget implementation. Is invoked when initialisation of the Widget is done (so for example the App reference is set).
	 * @param type:App context The app owning the widget
	 */
	function init(context) {
		console.log("stub Widget init for " + widgetInfo.url);
	}

	/**
	 * Show the widget
	 * Should be overridden by the Widget implementation
	 */
	function show() {
		visible = true;
		showing = true;
	}

	/**
	 * Hide the widget
	 * Should be overridden by the Widget implementation
	 */
	function hide() {
		visible = false;
		showing = false;
	}
}
