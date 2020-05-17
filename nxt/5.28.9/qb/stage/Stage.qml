import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import ScreenStateController 1.0
import qb.registry 1.0;

import "Stage.js" as StageJs;

App {
	id: stage

	property bool onRootScreen
	property url homeScreenUrl
	property url menuScreenUrl
	property Widget logo
	property Widget dateTime
	property Widget backButton
	property Widget menuButton
	property Widget homeButton
	property Widget saveButton
	property Widget cancelButton
	property Widget customButton
	property url logoUrl : "qrc:/qb/stage/Logo.qml"
	property url dateTimeUrl : "qrc:/qb/stage/DateTime.qml"
	property url backButtonUrl : "qrc:/qb/stage/BackButton.qml"
	property url menuButtonUrl : "qrc:/qb/stage/MenuButton.qml"
	property url homeButtonUrl : "qrc:/qb/stage/HomeButton.qml"
	// Icon version of home/menuButton
	property url menuIconButtonUrl : "qrc:/qb/stage/MenuIconButton.qml"
	property url homeIconButtonUrl : "qrc:/qb/stage/HomeIconButton.qml"
	property url saveButtonUrl : "qrc:/qb/stage/SaveButton.qml"
	property url cancelButtonUrl : "qrc:/qb/stage/CancelButton.qml"
	property url customButtonUrl : "qrc:/qb/stage/CustomButton.qml"

	property string currentScreenKpiPrefix
	property string currentScreenIdentifier

	property Row systrayContainer
	property Flow popupContainer

	property int previousScreenState: ScreenStateController.ScreenActive
	property variant stateNames: ['invalid', 'screen_active', 'screen_dimmed', 'screen_color_dimmed', 'screen_off']
//	signal registerFullscreen(url url, string id, variant appContext);

	function init(screenParent, screenTitle, screenIcon) {
		StageJs.screenParent = screenParent;
		StageJs.screenTitleComponent = screenTitle;
		StageJs.screenTitleIconComponent = screenIcon;
		registry.registerWidgetContainer("screen", stage);
		registry.registerWidget("topLeft", dateTimeUrl, stage, "dateTime");
		registry.registerWidget("topLeft", logoUrl, stage, "logo");
		registry.registerWidget("topLeft", backButtonUrl, stage, "backButton");
		registry.registerWidget("topLeft", homeIconButtonUrl, stage, "homeButton");
		registry.registerWidget("topLeft", menuIconButtonUrl, stage, "menuButton");
		registry.registerWidget("topRightButton", saveButtonUrl, stage, "saveButton");
		registry.registerWidget("topLeft", cancelButtonUrl, stage, "cancelButton");
		registry.registerWidget("topRightButton", customButtonUrl, stage, "customButton");

		// Use 'toString()' to create copy of original color instead of reference to property.
		// We need the original colors to restore them when navigating back/home.
		StageJs.topBarDefaultColors = {
			"topbar" : colors.topbar.toString(),
			"menuButtonBackground" : colors.menuButtonBackground.toString(),
			"menuLabel" : colors.menuLabel.toString(),
			"menuBarLabel" : colors.menuBarLabel.toString(),
			"fullScreenTitle" : colors.fullScreenTitle.toString()
		};
	}

	QtObject {
		id: p

		function dimStateChanged() {
			if (stage.menuButton) stage.menuButton.visible = isNormalMode && onRootScreen && !dimState;
			if (StageJs.systrayContainer) StageJs.systrayContainer.visible = (onRootScreen || isMenuScreen) && !dimState;
                        if (stage.logo && (globals.tsc["hideToonLogo"] === 1)) stage.logo.visible = !dimState
                        if (stage.dateTime && (globals.tsc["hideToonLogo"] !== 0)) stage.dateTime.visible = dimState
		}

		function dialogShowingChanged() {
			showOnIdle();
		}

		function getScreenIdentifier(screenUrl) {
			if (typeof screenUrl === "string") {
				var matches = screenUrl.match(/apps\/(.+)\.qml/);
				if (Array.isArray(matches) && matches.length > 1)
					return matches[1];
			}
			return "";
		}
	}

	Connections {
		target: screenStateController
		onScreenStateChanged: {
			previousScreenState = screenStateController.screenState;

			if (ScreenStateController.ScreenActive == screenStateController.screenState) {
				showOnIdle();
			} else {
				countly.stopSession();
			}
		}

		onScreenTouched : {
			countly.startSession();
		}
	}

	Component.onCompleted: {
		canvas.dimStateChanged.connect(p.dimStateChanged);
		if (qdialog.context)
			qdialog.context.showingChanged.connect(p.dialogShowingChanged);
		canvas.appsDoneLoading.connect(showOnIdle);
	}

	onHomeScreenUrlChanged: {
		if (StageJs.currentFullScreenComponent == null) {
			openFullscreenInner(homeScreenUrl, null, false);
		}
	}

	onMenuScreenUrlChanged: {
		StageJs.menuScreenComponent = menuScreenUrl;
	}

	onSystrayContainerChanged: StageJs.systrayContainer = systrayContainer;

	onPopupContainerChanged: {
		if (!StageJs.popupContainer)
			StageJs.popupContainer = popupContainer;
	}

	onOnRootScreenChanged: {
		showOnIdle();
	}

	function destroyScreen(id) {
		var screen = StageJs.loadedScreens[id];
		if (screen) {
			console.debug("destroying screen " + id);
			StageJs.loadedScreens[id] = null;
			screen.destroy();
		}
	}

	function loadScreen(widgetInfo) {
		var screen = util.loadComponent(widgetInfo.url, StageJs.screenParent, {visible: false, widgetInfo: widgetInfo, app: widgetInfo.context});
		if (!screen) {
			console.log("failed loading fullScreen " + widgetInfo.url);
			return;
		}
		console.debug("Loaded fullscreen " + widgetInfo.url + " > " + screen);

		screen.identifier = widgetInfo.url;
		screen.initWidget(widgetInfo);
		return screen;
	}

	function instantiateScreen(widgetInfo) {
		console.debug("loading screen " + widgetInfo.url);
		var screen = util.instantiateComponent(StageJs.preLoadedScreens[widgetInfo.url], StageJs.screenParent, {visible: false, widgetInfo: widgetInfo, app: widgetInfo.context});
		if (screen) {
			StageJs.loadedScreens[widgetInfo.url] = screen;
			screen.identifier = widgetInfo.url;
			screen.initWidget(widgetInfo);
		}
		return screen;
	}

	function onWidgetRegistered(widgetInfo) {
		if (widgetInfo.args && widgetInfo.args.lazyLoadScreen && globals.lazyLoadscreensEnabled)
			StageJs.preLoadedScreens[widgetInfo.url] = util.preloadComponent(widgetInfo.url);
		else
			StageJs.loadedScreens[widgetInfo.url] = loadScreen(widgetInfo);
	}

	function setScreenTitle(title, iconUrl) {
		if (title)
			StageJs.screenTitleComponent.text = title;
		if (iconUrl)
			StageJs.screenTitleIconComponent.source = "image://scaled/" + qtUtils.urlPath(iconUrl);
	}

	function openFullscreen(id, args) {
		return openFullscreenInner(id, args, true);
	}

	function openFullscreenInner(id, args, add) {
		if (!id) {
			console.log("Need id for fullscreen to open!");
			return;
		}

		var widgetInfo = registry.getWidgetInfo("screen", id);
		if (!widgetInfo) {
			console.log(id  + " is not a registered screen!");
			return;
		}

		if (StageJs.currentFullScreen) {
			var oldScreen = StageJs.currentFullScreen;
			var oldScreenId = StageJs.currentFullScreenComponent;
			StageJs.currentFullScreen = null;
			oldScreen.visible = false;
			oldScreen.showing = false;
			oldScreen.hidden();
			oldScreen.scale = 0.5;

			var oldArgs = oldScreen.widgetInfo.args;
			if (oldScreenId.toString() !== id.toString()) {
				qtUtils.clearFocus();
				if (oldScreen.inNavigationStack && add &&
						(!args || !StageJs.fullScreenHistory.length || (args && !args.resetNavigation))) {
					StageJs.fullScreenHistory.push(StageJs.currentFullScreenComponent);
				} else if (oldArgs && oldArgs.lazyLoadScreen && globals.lazyLoadscreensEnabled && StageJs.fullScreenHistory.indexOf(StageJs.currentFullScreenComponent) == -1) {
					// If this was lazy loaded and it is not in the history anymore, remove the old screen
					destroyScreen(StageJs.currentFullScreenComponent);
				}
			}
		}

		// keep bottom item in stack (homescreen)
		if (args && args.resetNavigation)
			clearNavigationStack(1);

		var newScreen = StageJs.loadedScreens[id] ? StageJs.loadedScreens[id] : instantiateScreen(widgetInfo);

		if (newScreen.disableAutoPageViewLogging === false) {
			countly.sendPageViewEvent(util.absoluteToRelativePath(newScreen.identifier));
		}

		StageJs.currentFullScreen = newScreen;
		StageJs.currentFullScreenComponent = id;
		currentScreenIdentifier = p.getScreenIdentifier(id.toString());
		currentScreenKpiPrefix = newScreen.kpiPrefix;

		newScreen.visible = true;
		newScreen.scale = 1;
		newScreen.showing = true;
		newScreen.shown(args);
		// If screen sets a property named cancelShow to true during onShown,
		// this will abort the displaying of said screen. It is up to the screen
		// to hide itself before returning from the onShown handler!!!
		if (newScreen.cancelShow === true) {
			return;
		}

		StageJs.screenTitleComponent.text = newScreen.screenTitle;
		if (newScreen.screenTitleIconUrl.toString())
			StageJs.screenTitleIconComponent.source = "image://scaled/" + qtUtils.urlPath(newScreen.screenTitleIconUrl);
		else
			StageJs.screenTitleIconComponent.source = "";

		onRootScreen = StageJs.fullScreenHistory.length == 0;
		var isTopScreen = StageJs.fullScreenHistory.length <= 1;
		var isMenuScreen = StageJs.currentFullScreenComponent === StageJs.menuScreenComponent;
		var isSaveCancelDialog = newScreen.isSaveCancelDialog;
		var hasSaveButton = isSaveCancelDialog || newScreen.hasSaveButton;
		var hasCancelButton = isSaveCancelDialog || newScreen.hasCancelButton;
		var hasHomeButton = newScreen.hasHomeButton;
		var hasBackButton = newScreen.hasBackButton;

		if (stage.homeButton) stage.homeButton.visible = !onRootScreen && !hasCancelButton && hasHomeButton;
		if (stage.menuButton) stage.menuButton.visible = isNormalMode && onRootScreen && !dimState;
		if (stage.backButton) stage.backButton.visible = !isTopScreen && !hasCancelButton && hasBackButton;
		if (stage.saveButton) stage.saveButton.visible = hasSaveButton;
		if (stage.cancelButton) stage.cancelButton.visible = hasCancelButton;
		if (stage.logo) stage.logo.visible = isNormalMode && (onRootScreen || isMenuScreen) && (globals.tsc["hideToonLogo"] !== 2 );
		if (stage.dateTime) stage.dateTime.visible = dimState && globals.tsc["hideToonLogo"] !== 0
		if (StageJs.systrayContainer) StageJs.systrayContainer.visible = (onRootScreen || isMenuScreen) && !dimState;

		return StageJs.currentFullScreenComponent;
	}

	function navigateBack() {
		var previousItem = StageJs.fullScreenHistory.pop();
		if (previousItem) {
			console.debug("back to " + previousItem);
			return openFullscreenInner(previousItem, null, false);
		} else {
			console.debug("no previous item");
			return 0;
		}
	}

	function navigateHome() {
		stage.restoreTopBarColors()
		var firstItem = StageJs.fullScreenHistory.shift();

		clearNavigationStack();

		if (firstItem) {
			console.debug("top to " + firstItem);
			return openFullscreenInner(firstItem, null, false);
		}
		else
			console.debug("no first item");

		return 0;
	}

	function navigateMenu() {
		if (StageJs.currentFullScreenComponent !== StageJs.menuScreenComponent) {
			openFullscreenInner(StageJs.menuScreenComponent, null, true);
		} else {
			navigateBack();
		}
	}

	function clearNavigationStack(keep) {
		var limit = 0;
		if (keep > 0)
			limit = keep;
		// destroy lazyLoaded screens in history
		while (StageJs.fullScreenHistory.length > limit) {
			var screenId = StageJs.fullScreenHistory.pop();
			var screenInfo = registry.getWidgetInfo("screen", screenId);
			var screenArgs = screenInfo.args;
			if (screenArgs && screenArgs.lazyLoadScreen && globals.lazyLoadscreensEnabled && screenInfo.url != StageJs.currentFullScreenComponent && StageJs.fullScreenHistory.indexOf(screenInfo.url) == -1) {
				destroyScreen(screenId);
			}
		}
	}

	function saveButtonClicked() {
		if (StageJs.currentFullScreen) {
			var synchronousSave = StageJs.currentFullScreen.synchronousSave;
			StageJs.currentFullScreen.saved();
			if (!synchronousSave)
				navigateBack();
		} else {
			navigateBack();
		}
	}

	function cancelButtonClicked() {
		if (StageJs.currentFullScreen) {
			StageJs.currentFullScreen.canceled();
		}
		navigateBack();
	}

	function disableCancelButton() {
		stage.cancelButton.state = "disabled";
	}

	function enableCancelButton() {
		stage.cancelButton.state = "up";
	}

	function customButtonClicked() {
		if (StageJs.currentFullScreen) {
			StageJs.currentFullScreen.customButtonClicked();
		}
	}

	function addCustomTopRightButton(label) {
		stage.customButton.label = label;
		stage.customButton.visible = true;
	}

	function clearTopRightButtons() {
		stage.customButton.visible = false;
		stage.customButton.label = "";
		stage.customButton.state = "up";
	}

	function disableCustomTopRightButton() {
		stage.customButton.state = "disabled";
	}

	function enableCustomTopRightButton() {
		stage.customButton.state = "up";
	}

	function enableSaveButton() {
		stage.saveButton.state = "up";
	}

	function disableSaveButton() {
		stage.saveButton.state = "disabled";
	}

	function registerHomescreenPopup(homescreenPopup) {
		var newPopup = { 'priority': 0, 'callback': null, 'uuid': '' }
		for (var key in homescreenPopup) {
			newPopup[key] = homescreenPopup[key];
		}

		var insertAt = -1;
		for (var i = 0; i < StageJs.homescreenPopups.length; i++) {
			if (StageJs.homescreenPopups[i].uuid === newPopup.uuid)
				return;
			if (StageJs.homescreenPopups[i].priority > newPopup.priority) {
				insertAt = Math.max(insertAt, i);
			}
		}

		if (insertAt >= 0) {
			StageJs.homescreenPopups.splice(insertAt, 0, newPopup);
		} else {
			StageJs.homescreenPopups.push(newPopup);
		}
		showOnIdle();
	}

	function unregisterHomescreenPopup(uuid) {
		for (var i = 0; i < StageJs.homescreenPopups.length; i++) {
			if (StageJs.homescreenPopups[i].uuid === uuid) {
				StageJs.homescreenPopups.splice(i, 1);
				break;
			}
		}
	}

	function showOnIdle() {
		if (screenStateController.screenState == ScreenStateController.ScreenActive && StageJs.homescreenPopups.length &&
				onRootScreen && canvas.firstLoadingDone && !qdialog.context.showing) {
			if (StageJs.homescreenPopups[0].callback) {
				qdialog.reset();
				StageJs.homescreenPopups[0].callback();
			}
		}
	}

	function colorizeTopBar(topBarColor, topBarTextColor) {
		if (topBarColor === undefined || topBarTextColor === undefined) {
			restoreTopBarColors();
		} else {
			colors.topbar = topBarColor;
			colors.menuButtonBackground = topBarColor;
			colors.menuLabel = topBarTextColor;
			colors.menuBarLabel = topBarTextColor;
			colors.fullScreenTitle = topBarTextColor;
		}
	}

	function restoreTopBarColors() {
		if (canvas.dimState)
			return;
		colors.topbar = StageJs.topBarDefaultColors["topbar"];
		colors.menuButtonBackground = StageJs.topBarDefaultColors["menuButtonBackground"];
		colors.menuLabel = StageJs.topBarDefaultColors["menuLabel"];
		colors.menuBarLabel = StageJs.topBarDefaultColors["menuBarLabel"];
		colors.fullScreenTitle = StageJs.topBarDefaultColors["fullScreenTitle"];
	}

	/**
	 * @brief It calculates the number of ms until somewhere between 1 and 3 am o'clock next day.
	 */
	function calcHeartbeatInterval() {
		var now = new Date();
		var interval = (24 - now.getHours() + 1/* o'clock - time window start */) * 3600; // [s]
		return (interval + (Math.floor(Math.random() * 7200/* time window interval [s] */))) * 1000; // [ms]
	}

	/**
	 * @brief It sends heartbeat event and current screen state event once a day.
	 */
	Timer {
		id: heartbeat
		interval: calcHeartbeatInterval();
		running: true
		repeat: true

		onTriggered: {
			interval = calcHeartbeatInterval();

			var homescreenApp = canvas.getAppInstance("homescreen");
			try {
				homescreenApp.homeScreen.logTilePlacement();
			} catch(e) {
				console.log("Failed to initiate logging of tile placement!")
			}
		}
	}
}
