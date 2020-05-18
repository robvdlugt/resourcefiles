import QtQuick 2.1
import QtQuick.Window 2.0
// TSC mod start
import FileIO 1.0
// TSC mod end
import QtQuick.VirtualKeyboard 2.3
import QtQuick.VirtualKeyboard.Settings 2.2

import BxtClient 1.0
import ScreenStateController 1.0
import QueuedConnection 1.0
import Feedback 1.0

import qb.components 1.0
import qb.registry 1.0
import qb.stage 1.0
import qb.base 1.0
import qb.lang 1.0
import qb.notifications 1.0
import qb.utils 1.0
import qb.energyinsights 1.0 as EnergyInsights

import themes 1.0

import "Canvas.js" as CanvasJS

Window {
	id: canvas
	// Size is determined by the application view

	// if you add instances here, also add on qb/test/QbTestCase.qml
	property BxtClient bxtClient: BxtClient
	property BxtFactory bxtFactory: BxtFactory
	property Registry registry: Registry{}
	property DependencyResolver dependencyResolver: DependencyResolver{}
	property Globals globals: Globals{}
	property Colors dimColors: TenantDimColors{}
	property Colors normalColors: TenantNormalColors{}
	property Colors colors: normalColors
	property Colors dimmableColors: dimState ? dimColors : normalColors
	property variant i18n
	property Fonts qfont: Fonts
	property Stage stage: Stage{}
	property Notifications notifications
	property Util util: Util{}
	property DesignElements designElements: DesignElements{}
	property ZWaveUtils zWaveUtils: ZWaveUtils{} // replace this by singleton in QQ2

//TSC mod start 
    property int customAppsToLoad
	FileIO {
                id: customFileIO
        }
    property alias qkeyboard: utilsApp.alphaNumericKeyboardScreen
    property alias qnumKeyboard: utilsApp.numericKeyboardScreen

//TSC mod end
	property string locale: ""
	property string localeCurrency: ""
	property bool dimState: screenStateController.dimmedColors
	property bool localeLoaded: false
	property bool firstLoadingDone: false
	property bool isNormalMode: true
	property bool isWizardMode: !isNormalMode
        property bool isBalloonMode: false
	property bool isVisibleinDimState: true
	property int animationInterval : 1000
	property string qmlAnimationURL: "qrc:/qb/components/Balloon.qml"
	

	property int appsToLoad
	onAppsToLoadChanged: p.setPsplashProgress()

	signal queuedSignal
	//when all apps are done with loading (mainly useful when loading apps at runtime)
	signal appsDoneLoading
	signal splashScreenRemoved

	width: 800
	height: 480
	visible: false

	QtObject {
		id: p
		property string scsyncUuid
		property string configUuid
		property int appsDoneLoadingCount: 0
		onAppsDoneLoadingCountChanged: p.setPsplashProgress()
		property bool startedLogged: false
		property bool qtConfigLoaded: false
		property bool featuresLoaded: false

		property string storedKeyboardLocale

		function setPsplashProgress() {
			var progress = Math.round(((globals.enabledApps.length - appsToLoad) + p.appsDoneLoadingCount) / (globals.enabledApps.length * 2) * 100);
			qtUtils.psplashProgress(progress);
		}
	}

	Component {
		id: notificationsComponent
		Notifications {}
	}

	Component.onCompleted: {
		VirtualKeyboardSettings.styleName = "toon";

		// The available locales for the Virtual Keyboard are normally based on the standard dialect/country for that language (i.e. nl_NL, but not nl_BE)
		// This makes a list of keyboard locales to enable, based on the language part only
		var availableLocales = ["en_GB", "nl_NL", "fr_FR", "de_DE", "es_ES"]; //VirtualKeyboardSettings.availableLocales doesn't seem to work
		// create array with only the language part of the locales currently enabled for the UI
		var myLocaleLangs = feature.i18nLocales().map(function (element) {
			return element.substr(0,2);
		});
		// filter keyboard locales based on languages we have available
		var filteredLocales = [];
		filteredLocales = availableLocales.filter(function (element) {
			return ~myLocaleLangs.indexOf(element.substr(0,2));
		});
		VirtualKeyboardSettings.activeLocales = filteredLocales;

		dependencyResolver.addDependencyTo("Canvas.loadApps", "Canvas.agreementDetails");
		dependencyResolver.addDependencyTo("Canvas.loadApps", "Canvas.wizardState");
		dependencyResolver.addDependencyTo("Canvas.loadApps", "Canvas.locale");
		dependencyResolver.addDependencyTo("Canvas.loadApps", "Canvas.heatingInstallationType");
		dependencyResolver.addDependencyTo("Canvas.loadApps", "Canvas.features");
		dependencyResolver.getDependantSignals("Canvas.loadApps").resolved.connect(globals.fillAppsToLoad);

		bxtClient.start();
		screenStateController.init();
		// delayed instantiation of 'Notifications' to make sure bxtClient is already initialized
		notifications = notificationsComponent.createObject(canvas);
		notifications.init();
		// initialize EnergyInsights module so it can receive alives
		EnergyInsights.Functions.init();
		globals.enabledAppsChanged.connect(loadApps);
	}

	QueuedConnection {
		target: canvas
		onSignalEmitted: loadNextApp()
	}

	// Used for unit testing
	function getColor(dim, name) {
		return dim ? dimColors[name] : normalColors[name];
	}

	function setDemoFeatures(features) {
		screenStateController.screenColorDimmedIsReachable = true;
		backendlessStartupLoader.source = "";
		setLocale(features.locale);

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_RESPONSE, "vbox-qb-dev00:qt-gui", "specific1", "GetAgreementDetails");
		msg.addArgument("standalone", features.standalone);
		msg.addArgument("activated", features.activated);
		msg.addArgument("productOption", "");
		var node = msg.getArgumentXml("productOption");
		node.addChild("district_heating", features.district_heating, 0);
		node.addChild("solar", features.solar, 0);
		node.addChild("electricity", features.electricity, 0);
		node.addChild("gas", features.gas, 0);
		node.addChild("sw_updates", features.sw_updates, 0);
		node.addChild("content_apps", features.content_apps, 0);
		node.addChild("telmi_enabeld", features.telmi_enabeld, 0);
		var child = node.addChild("boiler_management", features.boiler_management, 0);
		child.setAttribute("activated", features.boiler_management);
		node.addChild("other_provider_elec", features.other_provider_elec, 0);
		node.addChild("other_provider_gas", features.other_provider_gas, 0);
		node.addChild("heatwinner", features.heatwinner, 0);
		node.addChild("SME", features.SME, 0);

		globals.parseAgreementDetails(msg);

		// Prevent loading apps when the dependency 'Canvas.loadApps' is satisfied
		globals.enabledAppsChanged.disconnect(loadApps);
		dependencyResolver.setDependencyDone("Canvas.agreementDetails");
		dependencyResolver.setDependencyDone("Canvas.wizardState");
		dependencyResolver.setDependencyDone("Canvas.features");
		VirtualKeyboardSettings.locale = getKeyboardLocale(features.locale);

		globals.heatingMode = "central";
		dependencyResolver.setDependencyDone("Canvas.heatingInstallationType");

		msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, "vbox-qb-dev00:qt-gui", "specific1", "UpdateDataSet");
		msg.addArgument("features", "");
		node = msg.getArgumentXml("features");
		node.addChild("FF_HeatingBeat_UiElements", features.heatingBeat, 0);
		node.addChild("FF_BoilerControl_reveal", 1, 0);

		globals.setThermostatFeatures(node);

		// additional apps
		var apps = globals.enabledApps;
		if (features.smokeDetector === "1") {
			if (apps.indexOf("smokeDetector") < 0)
				apps.push("smokeDetector");
		}

		// globals.enabledAppsChanged.connect(loadApps); - keep it disabled and load apps manually
		loadApps();
	}

	function setLocale(newLocale, newLocaleCurrency) {
		if (locale !== newLocale || (newLocaleCurrency && localeCurrency !== newLocaleCurrency) ||
									(!newLocaleCurrency && localeCurrency !== '')) {
			if ((locale !== "")) {
				//Locale or currency changed after startup; restart
				console.log("Locale changed after startup; restarting...");
				Qt.quit();
			}

			console.log("Using locale: " + newLocale);
			qlanguage.setLocale(newLocale);
			qlanguage.loadLanguagePackage("qb/lang");
			bxtClient.setLocale(newLocale);
			initLocale(newLocale, newLocaleCurrency);
			initStage();
			FeedbackManager.startFetchCampaigns();

			locale = newLocale;
			if (newLocaleCurrency)
				localeCurrency = newLocaleCurrency;
			dependencyResolver.setDependencyDone("Canvas.locale");
		}
	}

	function initLocale(newLocale, newLocaleCurrency) {
		var newLocaleImpl = util.loadComponent("qrc:/qb/lang/I18n_" + newLocale + ".qml", canvas, {});
		if (typeof newLocaleImpl === "undefined") {
			console.log("Failed to load locale " + newLocale);
			newLocaleImpl = util.loadComponent("qrc:/qb/lang/I18n_nl_NL.qml", canvas, {});
		}
		if (newLocaleCurrency) {
			var currency = util.loadComponent("qrc:/qb/lang/Currency_" + newLocaleCurrency + ".qml", newLocaleImpl, newLocaleImpl.currencyOptions);
			if (typeof currency !== "undefined") {
				if (newLocaleImpl.currencyImpl)
					newLocaleImpl.currencyImpl.destroy();
				newLocaleImpl.currencyImpl = currency;
			}
		} // else: use the language specific one

		if (i18n)
			i18n.destroy();
		i18n = newLocaleImpl;
		localeLoaded = true;
	}

	function getKeyboardLocale(newLocale) {
		if (typeof newLocale !== "string")
			return VirtualKeyboardSettings.locale;

		var newLang = newLocale.substr(0,2);
		var availableLocales = VirtualKeyboardSettings.activeLocales;

		// find a suitable keyboard locale based on the language part of the UI locale
		for (var i=0; i < availableLocales.length; i++) {
			if (availableLocales[i].indexOf(newLang) === 0)
				return availableLocales[i];
		}
		// when not found, return current keyboard locale
		return VirtualKeyboardSettings.locale;
	}

	function initStage() {
		home.initStage();
	}

	function loadNextApp() {
		if (appsToLoad) {
			var appIdx = globals.enabledApps.length - appsToLoad;

			var appUrl = globals.enabledApps[appIdx] + "/" + globals.enabledApps[appIdx].charAt(0).toUpperCase() + globals.enabledApps[appIdx].slice(1) + "App.qml";
			if (!CanvasJS.loadedApps[appUrl]) {
				console.log("Load app " + globals.enabledApps[appIdx]);

				var appLangUrl = "apps/" + globals.enabledApps[appIdx] + "/lang";
				console.log("Loading language from " + appLangUrl);
				qlanguage.loadLanguagePackage(appLangUrl);

				var instance = util.loadComponent("qrc:/apps/" + appUrl, canvas, {});
				if (instance) {
					instance.init();
					CanvasJS.loadedApps[appUrl] = (instance);
					if (!instance.doneLoading)
						instance.doneLoadingChanged.connect(checkLoadingDone);
					else
						p.appsDoneLoadingCount++;
				}
			}

			if (--appsToLoad == 0) {
//TSC mod start
                     console.log("<<<<<<<<<<<<<<<<<<<<<<<<<< LOADING CUSTOM APPS >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
                     var allApps = globals.enabledApps;
                     var customAppsFound = [];
                     customFileIO.source = "file:////qmf/qml/apps/";
                     var presentApps = customFileIO.dirEntries.slice(0);
                     for (var a in presentApps) {
                             var appToCheck = presentApps[a];
                             if (appToCheck.indexOf("-") === -1) {
                                     customFileIO.source="file:////qmf/qml/apps/" + appToCheck + "/"
                                     var checkAppQml =  appToCheck.charAt(0).toUpperCase() + appToCheck.slice(1) + "App.qml";
                                     var checkAppQmlResult =  customFileIO.entryList([checkAppQml]);
                                     if (checkAppQmlResult.length > 0) {
                                             console.log("TSC found this app to be custom installed: " + appToCheck);
                                             customAppsFound.push(appToCheck);
                                     }
                             }
                     }
		     globals.customApps = customAppsFound
                     customAppsToLoad = globals.customApps.length;
                     while (customAppsToLoad) {
                             var appIdx = globals.customApps.length - customAppsToLoad;
                             allApps.push(globals.customApps[appIdx]);

                             var appUrl = globals.customApps[appIdx] + "/" + globals.customApps[appIdx].charAt(0).toUpperCase() + globals.customApps[appIdx].slice(1) + "App.qml";
			     if (!CanvasJS.loadedApps[appUrl]) {

                            	 console.log("==================================Loading " + globals.customApps[appIdx] + " app============================");
                           	 var instance = util.loadComponent("file:////qmf/qml/apps/" + appUrl, canvas, {});
                            	 if (instance) {
					CanvasJS.loadedApps[appUrl] = (instance);
                                	instance.init();
                             	}
			     }
                             customAppsToLoad--;
                      }
                      globals.enabledAppsChanged.disconnect(loadApps);
                      globals.enabledApps = allApps;
                      globals.enabledAppsChanged.connect(loadApps);
  				console.log("<<<<<<<<<<<<<<<<<<<<<<<<<< FINISHED CUSTOM APPS >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
//TSC mod end
				console.log("<<<<<<<<<<<<<<<<<<<<<<<<<< FINISHED LOADING APPS >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
				dependencyResolver.notifyResolvingStarted();
				dependencyResolver.setDependencyDone("Canvas.appsInitialized")
				//Send out new disco message so we get all the disco messages and handlers registered by apps can act.
				bxtClient.sendDiscoMsg();
				checkLoadingDone(true);

				// Output only printed when RUN_QT_PERFORMANCE_TESTS is defined in performancetest.h
				if (typeof performanceTester == 'object')
					console.log("RUN_QT_PERFORMANCE_TESTS : apps startup time = " + performanceTester.getMsCounter() + "ms");
			}

			queuedSignal();
		}
	}

	function loadApps() {
		if (!firstLoadingDone)
			utilsApp.init();

		loadTimer.start();
		console.time("Profile::Canvas::loadTimer");
		console.log("<<<<<<<<<<<<<<<<<<<<<<<<<< STARTED LOADING APPS >>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		appsToLoad = globals.enabledApps.length;
		queuedSignal();
	}

	function requestConfig() {
		var getConfigMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetPackageConfig");
		getConfigMessage.addArgument("PackageName", "qt-gui");
		bxtClient.sendMsg(getConfigMessage);
	}

	function loadFlashConfig() {
		var loadFlashConfigMessage= bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		loadFlashConfigMessage.addArgument("PackageName", "flash_gui");
		loadFlashConfigMessage.addArgument("internalAddress", "flashConfig")
		bxtClient.doAsyncBxtRequest(loadFlashConfigMessage, getFlashConfigCallback, 20);
	}

	function saveScreenConfig() {
		var saveScreenConfigMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "SetObjectConfig");
		saveScreenConfigMessage.addArgument("Config", null);

		var configNode = saveScreenConfigMessage.getArgumentXml("Config");
		var screenConfigNode = configNode.addChild("screenConfig", null, 0);
		screenConfigNode.addChild("package", "qt-gui", 0);
		screenConfigNode.addChild("internalAddress", "screenConfig", 0);

		var screenOffIsProgramBased = screenStateController.screenOffIsProgramBased ? "1" : "0";
		var prominentWidgetLeft = screenStateController.prominentWidgetLeft ? "1"  : "0";

		screenConfigNode.addChild("timeBeforeDimmingInSec", screenStateController.timeBeforeDimmingInSec.toString(), 0);
		screenConfigNode.addChild("timeBeforeScreenOffInMin", screenStateController.timeBeforeScreenOffInMin.toString(), 0);
		screenConfigNode.addChild("screenOffIsProgramBased", screenOffIsProgramBased, 0);
		screenConfigNode.addChild("prominentWidgetLeft", prominentWidgetLeft, 0);
		screenConfigNode.addChild("brightness", screenStateController.backLightValueScreenActive.toString(), 0);
		screenConfigNode.addChild("dimBrightness", screenStateController.backLightValueScreenDimmed.toString(), 0);
		screenConfigNode.addChild("autoBrightness", screenStateController.autoBrightnessControl.toString(), 0);

		bxtClient.sendMsg(saveScreenConfigMessage);
	}

	Connections {
		target: InputContext
		onLocaleChanged: {
			console.log("Keyboard input context locale set to:", InputContext.locale);
			if (InputContext.locale !== p.storedKeyboardLocale) {
				saveKeyboardConfig();
			}
		}
	}

	function saveKeyboardConfig() {
		if (p.configUuid.length === 0) {
			console.log("Skipping storage of keyboard locale because hcb_config has not been discovered() yet.")
			return;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);
		var configNode = msg.getArgumentXml("Config");

		var keyboardConfigNode = configNode.addChild("keyboardConfig", null, 0);
		keyboardConfigNode.addChild("package", "qt-gui", 0);
		keyboardConfigNode.addChild("internalAddress", "keyboardConfig", 0);
		var currentLocale = InputContext.locale;
		keyboardConfigNode.addChild("locale", currentLocale, 0);

		console.log(msg.stringContent);
		bxtClient.sendMsg(msg);

		p.storedKeyboardLocale = currentLocale;
	}

	function loadKeyboardConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "keyboardConfig");

		bxtClient.doAsyncBxtRequest(msg, loadKeyboardConfigCallback, 30);
	}

	function loadKeyboardConfigCallback(message) {
		if (! message) {
			console.log("Keyboard config not available due to timeout.");
			return;
		}
		console.log(message.stringContent);

		var keyboardConfig = message.getArgumentXml("Config").getChild("keyboardConfig");
		if (keyboardConfig) {
			var newLocale = keyboardConfig.getChildText("locale");
			p.storedKeyboardLocale = newLocale;
			VirtualKeyboardSettings.locale = newLocale;
		} else {
			console.log("Keyboard config not available.");
		}
	}

	function removeSplashscreen () {
		console.debug("removing splashScreen!");
		splashScreenBackground.visible = false;
		console.timeEnd("Profile::Canvas::loadtimer");
		loadTimer.stop();

		if (!firstLoadingDone) {
			screenStateController.start();
			firstLoadingDone = true;

			// fetch features again after first loading is done so we can load any apps
			// not loaded initially because the received features were potentially cached
			// also, any features list response received during the first loading will be ignored, hence this call
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "features", "GetFeatures");
			bxtClient.sendMsg(msg);
		}

		console.profileEnd();
		qtUtils.psplashQuit();
		splashScreenRemoved();
	}

	function checkLoadingDone(initial) {
		if (!initial)
			p.appsDoneLoadingCount++;

		// See if all apps are loaded
		if (appsToLoad)
			return;

		var doneLoading = true;
		for (var app in CanvasJS.loadedApps) {
			if (CanvasJS.loadedApps[app].doneLoading !== true) {
				console.warn("App '" + app + "' is still loading! initVars=" + CanvasJS.loadedApps[app].initVars.toString(2));
				doneLoading = false;
				break;
			}
		}

		if (doneLoading) {
			dependencyResolver.notifyResolvingFinished();
			appsDoneLoading();
			removeSplashscreen();
		}
	}

	function getAppInstance(app) {
		var appUrl = app + "/" + app.charAt(0).toUpperCase() + app.slice(1) + "App.qml";
		var appInstance = CanvasJS.loadedApps[appUrl];
		return typeof appInstance !== "undefined" ? appInstance : null;
	}

	Home {
		id: home
	}

	UtilsApp {
		id: utilsApp
	}

	Rectangle {
		id: screenOffOverlay
		color: "black"
		anchors.fill: parent
		visible: screenStateController.screenState === ScreenStateController.ScreenOff
	}

	Rectangle {
		id: underlay

		anchors.fill: parent
		color: colors.dialogMaskedArea
		opacity: 0.35
		visible: false
		signal clicked()

		MouseArea {
			property string kpiId: "Canvas.Underlay"
			anchors.fill: parent
			onClicked: parent.clicked()
		}
	}

	NotificationBar {
		id: notificationBar
		blockConditions: home.fsPopupShowing || isWizardMode
	}

	InputPanel {
		id: inputPanel
		y: canvas.height
		anchors.left: parent.left
		anchors.right: parent.right
		visible: !dimState
		states: State {
			name: "visible"
			when: Qt.inputMethod.visible
			PropertyChanges {
				target: inputPanel
				y: canvas.height - inputPanel.height
			}
		}
		transitions: Transition {
			id: inputPanelTransition
			from: ""
			to: "visible"
			enabled: isNxt
			reversible: true
			ParallelAnimation {
				NumberAnimation {
					properties: "y"
					duration: 250
					easing.type: Easing.InOutQuad
				}
			}
		}
		Binding {
			target: InputContext
			property: "animating"
			value: inputPanelTransition.running
		}
	}

	Component {
		id: parentalControlOverlayComp
		ParentalControlOverlay {}
	}

	Loader {
		id: parentalControlOverlay
		anchors.fill: parent
		sourceComponent: locale && parentalControl.enabled ? parentalControlOverlayComp : undefined
	}

	Rectangle {
		id: splashScreenBackground
		color: colors.splashScreenBackground
		anchors.fill: parent
	}

	function balloonMode(balloonmode, animationtime, animationtype, visibleindimstate) {
		animationInterval = animationtime
		qmlAnimationURL = animationtype
		if (balloonmode == "Start"){isBalloonMode = true}
		if (balloonmode == "Stop"){isBalloonMode = false}
		if (visibleindimstate == "yes"){isVisibleinDimState = true}
		if (visibleindimstate == "no"){isVisibleinDimState = false}
	}

	Rectangle {
        	id: balloonScreen
        	color: "transparent"
        	anchors.fill: parent
		Timer {
			interval : animationInterval
			//interval: 1000
			repeat: true
			//running : true
			running: isBalloonMode
			onTriggered: {
				var component = Qt.createComponent(qmlAnimationURL);
				var balloon = component.createObject(balloonScreen);
				balloon.x = ((Math.random() * parent.width)-60);
				balloon.y = parent.height;
			}
		}
		visible: (isVisibleinDimState || !dimState)
    	}

	Loader {
		id: backendlessStartupLoader
		anchors.fill: parent
		source: isDemoBuild ? "qrc:/qb/base/BackendlessStartup.qml" : ""
	}

	Connections {
		target: screenStateController
		onSettingsChanged: {
			saveScreenConfig();
		}

		onScreenStateChanged: {
			if (screenStateController.screenState === ScreenStateController.ScreenColorDimmed
					|| screenStateController.screenState === ScreenStateController.ScreenOff) {
				stage.navigateHome();
				if (parentalControlOverlay.item)
					parentalControlOverlay.item.hide();
			} else if (screenStateController.previousScreenState !== ScreenStateController.ScreenDimmed
					   && screenStateController.screenState === ScreenStateController.ScreenActive) {
				if (parentalControlOverlay.item && parentalControl.enabled) {
					parentalControlOverlay.item.show();
				}
			}
		}
	}

	BxtResponseHandler {
		id: packageConfigResponseHandler
		serviceId: "ConfigProvider"
		response: "GetPackageConfigResponse"
		onResponseReceived: {
			// This seems to be the only reason to have this handler. The screenConfig is only parsed once and the tiles are parsed seperately
			var sysConfig = message.getArgumentXml("Config").getChild("sysConfig");
			if (sysConfig) {
				var newLocale = sysConfig.getChildText("locale");
				var newLocaleCurrency = sysConfig.getChildText("currency");
				setLocale(newLocale, newLocaleCurrency);
				loadKeyboardConfig();

				var timezone = sysConfig.getChildText("timezone");
				if (timezone)
					bxtClient.setTimezone(timezone);
			} else {
				console.log("System config not avalibale.");
			}

			if(!p.qtConfigLoaded) {
				var screenConfigNode = message.getArgumentXml("Config").getChild("screenConfig");

				if (screenConfigNode) {
					var shouldSaveConfig = false;

					var brightness = parseInt(screenConfigNode.getChildText("brightness"));
					var dimBrightness = parseInt(screenConfigNode.getChildText("dimBrightness"));
					var autoBrightnessControl = parseInt(screenConfigNode.getChildText("autoBrightness"));
					var timeBeforeDimmingInSec = parseInt(screenConfigNode.getChildText("timeBeforeDimmingInSec"));
					var timeBeforeScreenOffInMin = parseInt(screenConfigNode.getChildText("timeBeforeScreenOffInMin"));
					var screenOffIsProgramBased = parseInt(screenConfigNode.getChildText("screenOffIsProgramBased"));
					var prominentWidgetLeft = parseInt(screenConfigNode.getChildText("prominentWidgetLeft"));

					if (p.featuresLoaded && !globals.features["displayAutoBrightness"] && autoBrightnessControl) {
						screenStateController.autoBrightnessControl = 0;
						shouldSaveConfig = true;
					} else {
						screenStateController.autoBrightnessControl = autoBrightnessControl;
					}
					screenStateController.backLightValueScreenActive = brightness;
					screenStateController.backLightValueScreenDimmed = dimBrightness;
					if (screenStateController.backLightValueScreenDimmed > screenStateController.getMaxBackLightValueScreenDimmed()) {
						screenStateController.backLightValueScreenDimmed = screenStateController.getMaxBackLightValueScreenDimmed();
						shouldSaveConfig = true;
					}
					screenStateController.timeBeforeDimmingInSec = timeBeforeDimmingInSec;
					screenStateController.timeBeforeScreenOffInMin = timeBeforeScreenOffInMin;
					screenStateController.screenOffIsProgramBased = (screenOffIsProgramBased === 1 && globals.heatingMode !== "none");
					screenStateController.prominentWidgetLeft = prominentWidgetLeft === 1;

					if (shouldSaveConfig)
						util.delayedCall(5000, saveScreenConfig);
				} else {
					console.log("No QT screen configuration available, checking for presence of old config file...");
					loadFlashConfig();
				}

				p.qtConfigLoaded = true;
			}
		}
	}

	BxtResponseHandler {
		id: registrationInfoResponseHandler
		response: "GetRegistrationInfoResponse"
		serviceId: "specific1"
		onResponseReceived: {
			// Not all qt install wizard versions set the wizardDone flag so also check wizardstate
			isNormalMode = (message.getArgument("wizardDone") === "1") || wizardstate.completed;
			dependencyResolver.setDependencyDone("Canvas.wizardState");
		}
	}

	BxtResponseHandler {
		id: agreementDetailsResponseHandler
		response: "GetAgreementDetailsResponse"
		serviceId: "specific1"
		onResponseReceived: {
			globals.parseAgreementDetails(message);
			dependencyResolver.setDependencyDone("Canvas.agreementDetails");

			// If changed runtime, update the enabledApps
			if (firstLoadingDone && !loadTimer.running)
				globals.fillAppsToLoad();
		}
	}

	BxtResponseHandler {
		id: getFeaturesResponseHandler
		response: "GetFeaturesResponse"
		serviceId: "features"
		onResponseReceived: {
			var jsonText = message.getArgument("json");
			try {
				var jsonObj = JSON.parse(jsonText);
				var featureList = jsonObj.features;

				if (Array.isArray(featureList)) {
					var	tmpFeatures = {};
					featureList.forEach(function (featName) {
						tmpFeatures[featName] = true;
					});
					globals.features = tmpFeatures;
				}
				p.featuresLoaded = true;

				if (featureList.indexOf("zoneControl") > -1)
					globals.heatingMode = "zone";
				else if(featureList.indexOf("noHeating") > -1)
					globals.heatingMode = "none";
				else
					globals.heatingMode = "central";

				var saveConfig = false;
				// disable auto brightness if locally enabled and feature is not there
				if (!globals.features["displayAutoBrightness"] && screenStateController.autoBrightnessControl) {
					screenStateController.autoBrightnessControl = 0;
					saveConfig = true;
				}

				// disable program based screen off if in no heating mode
				if (globals.heatingMode === "none" && screenStateController.screenOffIsProgramBased) {
					screenStateController.screenOffIsProgramBased = false;
					saveConfig = true;
				}

				if (saveConfig)
					util.delayedCall(5000, saveScreenConfig);

				if (firstLoadingDone && !loadTimer.running)
					globals.fillAppsToLoad();
			} catch(e) {
				if (e instanceof SyntaxError)
					console.log("Syntax error parsing JSON returned from GetFeatures call!", e)
				else
					console.log("Exception thrown response parsing from GetFeatures call!", e)

				globals.heatingMode = "central";
			} finally {
				dependencyResolver.setDependencyDone("Canvas.heatingInstallationType");
				dependencyResolver.setDependencyDone("Canvas.features");
				console.log("globals.features:", JSON.stringify(globals.features));
			}
		}
	}

	BxtDiscoveryHandler {
		id: kpiDiscoHandler
		deviceType: "happ_kpi"
		onDiscoReceived: {
			hcblog.kpiUuid = deviceUuid;
			if (!p.startedLogged) {
				hcblog.logMsg(99, "qt-gui starting");
				hcblog.logKpi("driver starting", "qt-gui");
				p.startedLogged = true;
			}
		}
	}

	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.configUuid = deviceUuid;
			// Always request the config to make sure that we will receive updated locale
			// if we do not request it we will no longer get updates after hcb_config crash
			requestConfig();
		}
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			if (p.scsyncUuid !== deviceUuid) {
				var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, deviceUuid, "specific1", "GetAgreementDetails");
				bxtClient.sendMsg(msg);
				msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, deviceUuid, "specific1", "GetRegistrationInfo");
				bxtClient.sendMsg(msg);
				msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, deviceUuid, "features", "GetFeatures");
				bxtClient.sendMsg(msg);
			}
			p.scsyncUuid = deviceUuid;
		}
	}

	BxtRequestCallback {
		id: getFlashConfigCallback

		onMessageReceived: {
			var configNode = message.getArgumentXml("Config");
			var flashConfigNode = configNode ? configNode.getChild("flashConfig") : null;

			if (flashConfigNode) {
				console.log("Previous screen config found , restoring...");
				var brightness = parseInt(flashConfigNode.getChildText("maxBrightness"));
				var dimBrightness = parseInt(flashConfigNode.getChildText("minBrightness"));
				var screensaverTimeout = parseInt(flashConfigNode.getChildText("screensaverTimeout"));
				var screenOffTimeout = parseInt(flashConfigNode.getChildText("screenOffTimeout"));
				var allowSSControl = parseInt(flashConfigNode.getChildText("allowSSControl"));
				var prominentWidgetLeft = parseInt(flashConfigNode.getChildText("prominentWidgetLeft"));

				screenStateController.backLightValueScreenActive = brightness;
				screenStateController.backLightValueScreenDimmed = dimBrightness;
				screenStateController.screenOffIsProgramBased = allowSSControl === 1;
				screenStateController.timeBeforeDimmingInSec = screensaverTimeout;
				screenStateController.timeBeforeScreenOffInMin = screenOffTimeout / 60;
				screenStateController.prominentWidgetLeft = prominentWidgetLeft === 1;
			} else {
				console.log("No flash screen configuration available, creating defaults...");
			}
			// write the config no matter what, so we have it written on the right place from now on
			saveScreenConfig();
		}
	}

	BxtActionHandler {
		action: "setScreenState"
		onActionReceived: {
			var requestedState = message.getArgument("state");
			var state = 0;
			if (requestedState === "Active") state = 1;
			else if (requestedState === "Dimmed") state = 2;
			else if (requestedState === "ColorDimmed") state = 3;
			else if (requestedState === "Off") state = 4;
			console.log("Forcing screen to state " + state);
			screenStateController.forceTestScreenState(state);
		}
	}

	BxtDiscoveryHandler {
		id: happThermstatDiscoHandler
		deviceType: "happ_thermstat"
	}

	BxtDatasetHandler {
		id: happThermstatFeaturesDataset
		dataset: "features"
		discoHandler: happThermstatDiscoHandler
		onDatasetUpdate: {
			globals.setThermostatFeatures(update);
		}
	}

	Timer {
		id: loadTimer

		interval: isNxt ? 90000 : 180000
		onTriggered: {
			console.debug("timeout for loading apps!");
			dependencyResolver.notifyResolvingFinished();
			removeSplashscreen();
		}
	}
}
