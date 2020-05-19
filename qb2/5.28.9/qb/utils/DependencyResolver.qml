import QtQuick 2.1

import "DependencyResolver.js" as DependencyResolverJs

Item {
	id: root
	Component.onDestruction: {
		checkAndCleanDependencies();
	}

	Component {
		id :dependantSignalsComp
		QtObject {
			signal resolved
			signal timedOut
		}
	}

	Component {
		id: dependantTimerComp
		Timer {
			property string dependantName
			onTriggered: onDependantTimedOut(dependantName)
		}
	}
	
	/**
	 * @internal
	 */
	function createDependant(dependantName) {
		var signals = dependantSignalsComp.createObject(root);

		var dependant = {
			name: dependantName,
			signals: signals,
			timer: undefined,
			dependencies: {}
		}

		return dependant;
	}

	/**
	 * @internal
	 */
	function destroyDependant(dependant) {
		if (!dependant) {
			return;
		}

		if (typeof dependant.signals !== 'undefined') {
			dependant.signals.destroy();
			dependant.signals = undefined;
		}
		if (typeof dependant.timer !== 'undefined') {
			dependant.timer.destroy();
			dependant.timer = undefined;
		}
	}

	/**
	 * It adds a dependency to a dependant. A dependant can have multiple
	 * dependencies. The same dependency can be used on multiple dependants.
	 *
	 * @note Should only be called at initialization stage (init method).
	 *
	 * @return type:boolean True if dependency was successfully added.
	 */
	function addDependencyTo(dependantName, dependencyName) {
		var dependantList = DependencyResolverJs.dependants;

		var dependant = dependantList[dependantName];
		if (!dependant) {
			dependant = createDependant(dependantName);
			dependantList[dependantName] = dependant;
		}

		var dependenciesList = dependant.dependencies;
		if (!(dependencyName in dependenciesList)) {
			dependenciesList[dependencyName] = true; // can be anything
			return true;
		}
		return false;
	}

	/**
	 * It sets a dependency to "done". If this is the last dependency of a
	 * dependant, the signal 'resolved' is fired on that dependant.
	 *
	 * @return type:boolean True on sucess.
	 */
	function setDependencyDone(dependencyName) {
		var dependantList = DependencyResolverJs.dependants;

		var dependencyFound = false;
		for(var dependantName in dependantList) {
			if (!dependantList.hasOwnProperty(dependantName))
				continue;

			var dependant = dependantList[dependantName];
			var dependencies = dependant.dependencies;
			if (dependencyName in dependencies) {
				delete dependencies[dependencyName];
				dependencyFound = true;

				if (0 === Object.keys(dependencies).length) {
					if (dependant.signals.resolved) {
						dependant.signals.resolved();
					}
					destroyDependant(dependant);
					delete dependantList[dependantName]; // not needed anymore
				}
			}
		} // for
		return dependencyFound;
	}


	/**
	 * It sets timeout on a dependant. If all of its dependecies are not
	 * resolved within the given interval the signal 'timedOut' is fired.
	 *
	 * @return type:signal A signal that is fired when the internal timer
	 * expires due to unresolved dependency(s).
	 */
	function setDependantTimeout(dependantName, interval) {
		var dependantList = DependencyResolverJs.dependants;

		var dependant = dependantList[dependantName];
		if (!dependant) {
			dependant = createDependant(dependantName);
			dependantList[dependantName] = dependant;
		}

		if (typeof dependant.timer === 'undefined') {
			// Once this is ported to QtQuick 2 the timer object could
			// hold reference to dependant object instead of holding its name.
			var timer = dependantTimerComp.createObject(root, {"dependantName": dependantName});
			if (!timer) {
				return undefined;
			}
			dependant.timer = timer;
		}
		dependant.timer.interval = interval;

		return dependant.signals.timedOut;
	}

	/**
	 * @internal
	 */
	function onDependantTimedOut(dependantName) {
		var dependant = DependencyResolverJs.dependants[dependantName];
		if (!dependant) {
			return undefined;
		}

		var dependencies = dependant.dependencies;
		for (var dependencyName in dependencies) {
			console.log("DependencyResolver: The dependency '" +
						dependencyName + "' of dependant '" + dependantName +
						  "' was not resolved due to timeout.");
		}

		if (dependant.signals.timedOut) {
			console.log("DependencyResolver: Invoking the timeout signal on the dependant '" +
						dependantName + "'.");
			dependant.signals.timedOut();
		}

		delete DependencyResolverJs.dependants[dependant.name];
		destroyDependant(dependant);
	}


	/**
	 * It checks a dependant existence.
	 * @note Exists for unit-testing purposes
	 *
	 * @return type:boolean True ff dependant exists.
	 */
	function isDependantExisting(dependantName) {
		return DependencyResolverJs.dependants[dependantName] ? true : false;
	}

	/**
	 * It returns a dependant signals.
	 *
	 * @return type:QtObject An object of signals supported by dependant.
	 */
	function getDependantSignals(dependantName) {
		var dependant = DependencyResolverJs.dependants[dependantName];
		if (!dependant) {
			return undefined;
		}
		return dependant.signals;
	}


	/**
	 * It starts timers on dependants that have specified timeout
	 * and dependecies.
	 *
	 * @note It should be called immediately after the apps have been
	 * initialized, hence, dependencies registered.
	 */
	function notifyResolvingStarted() {
		var dependantList = DependencyResolverJs.dependants;
		for(var dependantName in dependantList) {
			if (!dependantList.hasOwnProperty(dependantName))
				continue;

			var dependant = dependantList[dependantName];
			if (typeof dependant.timer !== 'undefined' && Object.keys(dependant.dependencies).length > 0) {
				dependant.timer.running = true;
			}
		}
	}

	/**
	 * @see checkAndCleanDependencies
	 * @note It should be called immediately before the splashscreen has been
	 * removed.
	 */
	function notifyResolvingFinished() {
		checkAndCleanDependencies();
	}

	/**
	 * It checks if dependencies are resolved and it removes unresolved ones
	 * from memory. A log message is produced for every unresolved
	 * dependency.
	 */
	function checkAndCleanDependencies() {
		var dependantList = DependencyResolverJs.dependants;
		for(var dependantName in dependantList) {
			if (!dependantList.hasOwnProperty(dependantName))
				continue;

			var dependant = dependantList[dependantName];
			for(var dependency in dependant.dependencies) {
				console.log("DependencyResolver: Unresolved dependency '" +
							dependency + "' for dependant '" + dependantName + "'!");
				if (typeof hcblog !== 'undefined')
					hcblog.logKpi("unresolvedDependency", dependency);
			}

			destroyDependant(dependant);
		}
		DependencyResolverJs.dependants = {};
	}
}
