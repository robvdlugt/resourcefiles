import QtQuick 2.1

/**
 * Object that can be registered as a widget container.
 * Note: This is only to convinientely describe the type and for documentation purposes. It's not actually used.
 */

QtObject {
	/**
	 * Called for each registered widget of the type we are the container for.
	 * When the widget gets instantiated it's init() method should be called with the widgetInfo passed here.
	 * @param type:WidgetInfo widgetInfo Description of the registered widget.
	 */
	function onWidgetRegistered(widgetInfo) {}
}
