import QtQuick 2.1

QtObject {
	id: util
	/**
	 * Load and instantiate a QML Component from a file applying the given properties, and attach it under the given parent node.
	 * Only works for local files that can be loaded synchronously.
	 * This function combines preloadComponent and instantiateComponent for easier use but does not offer the flexibility to instantiate the Component multiple times.
	 * @param type:url url Url to load the QML file from.
	 * @param type:Item parent The parent under which the Component should be loaded in the object tree.
	 * @param type:variant props An object, each of whose properties will be applied to the Component during instantiation (such as width, id, any property the Component has)
	 * @return type:QtObject The instantiated Object, or null if instantiation failed.
	 */
	function loadComponent(url, parent, props) {
		var component = Qt.createComponent(url);
		if (component.status === Component.Ready)
		{
			var loadedSprite = component.createObject(parent, props);
			if (loadedSprite === null) {
				console.log("Error creating object from url " + url);
				return;
			}
			return loadedSprite;
		}
		else
		{
			if (component.status === Component.Error) {
				console.log("Error loading " + url + ": " + component.errorString());
			} else {
				console.log("Loading " + url + " did not finish. Status: " + component.status);
			}
		}

	}

	/**
	 * Preload (but do not instantiate) a QML Component from a file.
	 * The loaded Component can then be instantiated multiple times using instantiateComponent. Only works for local files that can be loaded synchronously.
	 * @param type:url url Url to load the QML file from.
	 * @return type:Component The preloaded Component that can be instantiated using instantiateComponent, or null if loading failed.
	 */
	function preloadComponent(url) {
		var component = Qt.createComponent(url);
		if (component.status === Component.Ready) {}
		else {
			if (component.status === Component.Error) {
				console.log("Error loading " + url + ": " + component.errorString());
			} else {
				console.log("Loading " + url + " did not finish. Status: " + component.status);
			}
			return null;
		}
		return component;
	}

	/**
	 * Instantiate a preloaded QML Component from a file applying the given properties, and attach it under the given parent node.
	 * parent can be null if the loaded type does not have a visual representation or is to be parented later on.
	 * @param type:Component component A Component that was previously preloaded using preLoadComponent.
	 * @param type:Item parent The parent under which the Component should be loaded in the object tree.
	 * @param type:variant props An object, each of whose properties will be applied to the Component during instantiation (such as width, id, any property the Component has)
	 * @return type:QtObject The instantiated Object, or null if instantiation failed.
	 */
	function instantiateComponent(component, parent, props) {
		var loadedSprite = component.createObject(parent, props);
		if (loadedSprite === null) {
			console.log("Error creating object from component " + component);
			return;
		}
		return loadedSprite;
	}

	/**
	* Remove object given if found as child in parent
	* @param parent parent from which to remove object
	* @param obj object to remove
	**/
	function removeItem(parent, obj) {
		for (var i = 0; i < parent.children.length; i++) {
			if (parent.children[i] === obj) {
				obj.visible = false;
				obj.parent = null;
				obj.destroy();
			}
		}
	}

	/**
	 * Insert the given item under the given parent, next to the first sibling for which (sibling[sortProp] < item[sortProp]).
	 * Assuming that the siblings were already ordered, this will result in an ordered list of siblings.
	 * @param type:Item item An Item that will be inserted among the children of parent.
	 * @param type:Item parent The parent under which the Item will be placed.
	 * @param type:string sortProp Name of the property that will be used for sorting. Each of parents' children is expected to feature a property with this name.
	 */
	function insertItem(item, parent, sortProp) {
		for (var i = 0; i < parent.children.length; i++) {
			if (parent.children[i][sortProp] !== undefined && item[sortProp] !== undefined) {
				if (item[sortProp] < parent.children[i][sortProp]) {
					insertItemAt(item, parent, i);
					return;
				}
			} else {
				console.log("Error! Did not find " + sortProp + " property!");
				return;
			}
		}
		item.parent = null;
		item.parent = parent;
	}

	/**
	 * Insert the given item under the given parent, as the child at position [index].
	 * @param type:Item item An Item that will be inserted among the children of parent.
	 * @param type:Item parent The parent under which the Item will be placed.
	 * @param type:integer index component will be insterted at position [index]
	 */
	function insertItemAt(item, parent, index) {
		if (!item || item.parent === undefined) {
			console.log("Error! Cannot place undefined item or item has no parent property!");
		} else if( !parent || !parent.children) {
			console.log("Error! Cannot place given item as a child that object");
		} else if( index < 0 || index > parent.children.length) {
			console.log("Error! Cannot place item at index: " + index);
		} else {
			item.parent = null;
			item.parent = parent;
			while(parent.children[index] != item) {
				var obj = parent.children[index];
				obj.parent = null;
				obj.parent = parent;
			}
		}
	}

	property Item crasherItem: Item{}
	function crashMeNow() {
		Qt.createQmlObject("import QtQuick 2.1; import BxtClient 1.0; BxtActionHandler{action:'crash'}", crasherItem, "");
	}

	/**
	 * @brief Calls a function after a specified delay
	 * @param interval The number of miliseconds to wait before calling the function
	 * @param callback The function to be called
	 * @param callbackArgs a parameter to be passed to the function
	 */
	function delayedCall(interval, callback, callbackArg) {
		if (typeof interval !== "number" || interval === 0 || typeof callback !== "function") {
			console.log("util.delayedCall: interval is not a number or callback is not a function")
			return;
		}

		var timer = Qt.createQmlObject( "import QtQuick 2.1; Timer {interval: " +interval + "}", util);
		timer.triggered.connect( function () {
			callback(callbackArg);
			timer.destroy();
		} );
		timer.start();

		return timer;
	}

	/**
	 * @brief Returns the sum of all array elements
	 * @param arr the array to be summed
	 * @return the sum of the array elements or 0 if argument is not an array or is empty
	 */
	function arraySum(arr) {
		if (typeof arr === "number")
			return arr;
		if (!Array.isArray(arr) || arr.length === 0)
			return 0;

		return arr.reduce(function (total, val) {
			return total + val;
		});
	}

	/**
	 * @brief Return the relative path of a absolute url
	 * @param absolutePath the absolute url
	 * @return the relative path
	 */
	function absoluteToRelativePath(absolutePath)
	{
		var absPath = absolutePath.toString();
		var index = absPath.indexOf(":/");
		if (index !== -1)
			return absPath.substring(index + 2);
		else
			return absPath;
	}

	/**
	 * @brief		Does partial function application
	 * @detailed	Takes a function that accepts some number of arguments, binds values to one or more of those arguments,
	 *				and returns a new function that only accepts the remaining, un-bound arguments.
	 * @param		f The function to apply partial to
	 * @param		... Arguments to bind to new partial function
	 * @return		the new partial function
	 */
	function partialFn(f) {
		var args = Array.prototype.slice.call(arguments, 1);
		return function() {
			var remainingArgs = Array.prototype.slice.call(arguments);
			return f.apply(null, args.concat(remainingArgs));
		}
	}

	function minimizeUrl(url) {
		var re = new RegExp('^(?:https?://)?(?:www\.)?(.+)$');
		var matches = url.match(re);
		if (matches) {
			return matches[1]
		}
		return url;
	}

}
