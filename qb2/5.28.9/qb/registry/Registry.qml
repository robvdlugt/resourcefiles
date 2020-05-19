import QtQuick 2.1

import "Registry.js" as RegistryJs

QtObject {
	/**
	 * Register a widget
	 * @param type:string typeName Type of widget to be registered
	 * @param type:url widgetUrl Url to load widget from
	 * @param type:App appContext The owner app
	 * @param type:string localName Name of the variable in the app that should automagically be updated point to the latest instantiated widget of this type or null if not used.
	 * @param type:variant args Argument passed along to the widget initialisation
	 * @return type:string the uid of the registred widget, can be used to deregister it later.
	 */
	function registerWidget(typeName, widgetUrl, appContext, localName, args) {
		var containerInfo = RegistryJs.registeredWidgetContainers[typeName];
		if (!containerInfo) {
			console.warn("registerWidget: No container registered yet for type", typeName);
			containerInfo = {widgetList: [], widgets: {}};
			RegistryJs.registeredWidgetContainers[typeName] = containerInfo;
		}

		var uid = "" + new Date().getTime() + ":" + Math.round(Math.random() * 0xFFFFFFFF);

		var widgetInfo = {
			url: widgetUrl,
			localName: localName,
			context: appContext,
			args: args,
			containerInfo: containerInfo,
			uid: uid
		};

		RegistryJs.registeredWidgetsByUid[uid] = widgetInfo;

		containerInfo.widgets[widgetUrl] = widgetInfo;
		containerInfo.widgetList.push(widgetInfo);
		if (containerInfo.container) {
			if (typeof containerInfo.container.onWidgetRegistered === "function") {
				containerInfo.container.onWidgetRegistered(widgetInfo);
			} else { 
				console.warn("registerWidget: The container associated with container type", typeName, "does not have an onWidgetRegistered function!");
			}
		} else {
			console.warn("registerWidget: The container instance for type", typeName, "has not been initialized yet!");
		}
		return uid;
	}

	/**
	 * Deregister a widget by it's handle. Will call onWidgetDeregistered on the widgets' container.
	 * @param type:Object handle The handle of the registred widget, as returned from registerWidget
	 */
	function deregisterWidget(handle) {
		//Find the widgetInfo
		var widgetInfo = RegistryJs.registeredWidgetsByUid[handle];
		if (!widgetInfo) return;
		var containerInfo = widgetInfo.containerInfo;
		if (!containerInfo) return;
		//Remove it from the containers' list of widgets
		RegistryJs.registeredWidgetsByUid[handle] = undefined;
		var idx = containerInfo.widgetList.indexOf(widgetInfo);
		containerInfo.widgetList.splice(idx, 1);
		if (containerInfo.widgets[widgetInfo.url] === widgetInfo)
			containerInfo.widgets[widgetInfo.url] = undefined;
		//Inform the container that this widget was deregistered
		if (widgetInfo.containerInfo.container)
			widgetInfo.containerInfo.container.onWidgetDeregistered(widgetInfo);
	}

	/**
	 * Register a container for a type of widget.
	 * The container should have a onWidgetRegistered method through which it shall be notified when new widgets of it's type are registered.
	 * This method will also be called for any widget of it's type already registered before the container is being registered.
	 * @param type:string typeName Type of widget for which this will be the container
	 * @param type:WidgetContainer container The container object
	 */
	function registerWidgetContainer(typeName, container) {
		if (!container) {
			console.warn("registerWidgetContainer: invalid container instance");
			return;
		}
		
		var containerInfo = RegistryJs.registeredWidgetContainers[typeName];
		if (!containerInfo) {
			containerInfo = {widgetList: [], widgets: {}, container: container};
			RegistryJs.registeredWidgetContainers[typeName] = containerInfo;
		} else {
			containerInfo.container = container;
			for (var i in containerInfo.widgetList) {
				if (typeof container.onWidgetRegistered === "function") {
					container.onWidgetRegistered(containerInfo.widgetList[i]);
				} else {
					console.warn("registerWidgetContainer: The container associated with container type", typeName, "does not have an onWidgetRegistered function");
				}
			}
		}
	}

	/**
	 * Deregister a container for a type of widget.
	 * Note: this function has only been used for Unit testing. If you intend
	 * to use this in production, ensure this is tested.
	 */
	function deregisterWidgetContainer(typeName, container) {
		var containerInfo = RegistryJs.registeredWidgetContainers[typeName];
		if (!containerInfo) {
			return;
		} else {
			containerInfo.container = container;
			for (var i in containerInfo.widgetList) {
				deregisterWidget(containerInfo.widgetList[i].uid);
			}
			delete RegistryJs.registeredWidgetContainers[typeName];
		}
	}

	/**
	 * Get an array with registered widgets of the specified type
	 * @param type:string typeName Type of widgets requested
	 * @return type:Array<WidgetInfo> An array containing all registered widgets of the requested type
	 */
	function getRegisteredWidgets(typeName) {
		var container = RegistryJs.registeredWidgetContainers[typeName];
		if (!container) {
			return [];
		}
		return container.widgetList;
	}

	/**
	 * Returns widgetInfo of the specifed widget type and url. Note: Do not use if more widgets are registered from the same url.
	 * @param type:string widgetType Type of requested widget
	 * @param type:string widgetUrl Url of requested widget
	 * @return type:WidgetInfo object which contains widget info data
	 */
	function getWidgetInfo(widgetType, widgetUrl) {
		var widgetList = RegistryJs.registeredWidgetContainers[widgetType];
		if (widgetList.widgets[widgetUrl]) {
			return widgetList.widgets[widgetUrl];
		} else {
			return undefined;
		}
	}
}
