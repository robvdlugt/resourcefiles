import QtQuick 2.1
import FileIO 1.0

Item {
	property int timezone: 1
        property variant tsc: ({"rotateTiles":0,"rotateTilesDim":false,"rotateTilesSeconds":5,"hideToonLogo":0, "customToonLogo":0, "customToonLogoURL":"","hideErrorSystray":false,"showTime":false,"showDate":false,"noPreheatWhenAway":false,"summerMode":false})
	property int screenTransitionEnabled: 0
	property int screenTransitionDuration: 200
	property bool lazyLoadscreensEnabled: true
	property int standbyTransitionEnabled: 1
	property int standbyTransitionDuration: 200
	property bool slideTransitionEnabled: false
	property int slideTransitionDuration: 100
	property bool notificationAnimationsEnabled: false // disabled for now, not fully implemented
	property variant productOptions: ({})
	property variant features: ({})
	property variant thermostatFeatures: ({})
	property bool appsToLoadFilled: false
	property int solarInHcbConfig: 0
	property string tenant: qtUtils.getTenant()

	property bool serviceCenterAvailable: false

	property string heatingMode: "central"

	property variant enabledApps: []
	property variant customApps: [] // mod TSC

	// adding a locale / language here? Please also update
	// BackendlessStartup.qml property variant translations
	property variant languageList : {
			'nl_NL' : 'Nederlands',
			'en_GB' : 'English',
			'nl_BE' : 'Nederlands',
			'fr_BE' : 'Français',
			'fr_FR' : 'Français',
			'es_ES' : 'Español',
			'de_DE' : 'Deutsch'
	}

	property bool activationProcedureActive: false

	QtObject {
		id: p

		property bool agreementDetailsProviderLoyal: false
		property bool agreementDetailsStandalone: true
		property bool agreementDetailsHeatWinner: false
	}

	FileIO {
		id: qmlDir
		source: "qrc:/apps/"
	}

	signal startWhatIsNew()
	signal startWhatIsToon()

	/// Check whether all configured applications actually exist
	function filterEnabledApps(appsToLoad) {
		appsToLoad = appsToLoad.concat(customApps) // mod TSC
		console.log("filterEnabledApps", appsToLoad);
		var presentApps = qmlDir.dirEntries;
		for (var a in appsToLoad) {
			var appToCheck = appsToLoad[a];
			if ((presentApps.indexOf(appToCheck) === -1) && (customApps.indexOf(appToCheck) === -1) ) { // mod TSC
				appsToLoad.splice(appsToLoad.indexOf(appToCheck), 1);
			}
		}

		// only update enabledApps if it contains new apps, assume same order
		var newAppsToLoad = false;
		console.log("enabledApps", enabledApps.length, "appsToLoad", appsToLoad.length)
		if (enabledApps.length !== appsToLoad.length) {
			if (enabledApps.length > appsToLoad.length) {
				// apps need to be unloaded, restart UI
				Qt.quit();
				return;
			} else {
				// new apps to load;
				newAppsToLoad = true;
			}
		} else {
			appsToLoad.forEach(function (value, index) {
				if (enabledApps[index] !== value) {
					// apps need to be unloaded, restart UI
					Qt.quit();
					return;
				}
			});
		}

		if (newAppsToLoad) {
			enabledApps = appsToLoad;
		}
	}

	function parseAgreementDetails(msg) {
		if (msg) {
			var actNode = msg.getArgumentXml("productOption");
			var standalone = msg.getArgument("standalone");
			var activated = msg.getArgument("activated");

			var tmpProductOptions = {};

			if (actNode && standalone && activated) {
				// Check whether the message contains all arguments, but do NOT check whether
				// what the arguments are yet. We'll check whether we're actually standalone
				// lower down.

				// Store standalone
				tmpProductOptions["activated"] = parseInt(activated);
				tmpProductOptions["standalone"] = parseInt(standalone);

				// Store product options
				var childNode = actNode.child
				while (childNode) {
					tmpProductOptions[childNode.name] = childNode.text;
					var attrCount = childNode.getAttributeCount();
					if (attrCount) {
						tmpProductOptions[childNode.name] = {};
						for (var i = 0; i < attrCount; i++)
							tmpProductOptions[childNode.name][childNode.getAttributeName(i)] = childNode.getAttributeValue(i);
						if (tmpProductOptions[childNode.name].hasOwnProperty("value"))
							tmpProductOptions[childNode.name]["value_attribute"] = tmpProductOptions[childNode.name]["value"];
						tmpProductOptions[childNode.name]["value"] = childNode.text;
					}
					childNode = childNode.sibling;
				}
				productOptions = tmpProductOptions;
			}
		}
	}

	function setThermostatFeatures(msg) {
		if (!msg) {
			return;
		}

		var features = {};

		var feature = msg.child;
		while(feature) {
			features[feature.name] = feature.text === "1" ? true : false;
			feature = feature.sibling;
		}

		console.log("thermostatFeatures:", JSON.stringify(features));
		thermostatFeatures = features;
	}

	function setServiceCenterAvailable(available) {
		serviceCenterAvailable = available;
	}

	function fillAppsToLoad() {
		// Check whether the installation wizard has been completed
		var appsToLoad = [];
		if (isWizardMode) {
			if (wizardstate.hasStage("language") && !wizardstate.stageCompleted("language")) {
				// We don't need the other apps when we're only selecting the language.
				appsToLoad = ["installWizard"]
			} else {
				appsToLoad = ["installWizard",
							  "systray",
							  "thermostat",
							  "systemSettings"]

				if (wizardstate.hasStage("heating") && ((feature.appStrvFeatureEnabled() && isNxt) || feature.enabledHeatingModeNoHeating())) {
					// The strvSettings app contains the HeatingModeSelectionScreen used for choosing between
					// the different heating modes.
					appsToLoad.push("strvSettings");
				} else if (wizardstate.hasStage("heating")) {
					// If the configuration does support the heating step but we have it enabled,
					// then mark the heating step as completed.
					wizardstate.setStageCompleted("heating", true);
				}

				if (wizardstate.hasStage("heating") || wizardstate.hasStage("boiler")) {
					appsToLoad.push("thermostatSettings");
				}
				if (wizardstate.hasStage("internet") || wizardstate.hasStage("activation")) {
					appsToLoad.push("internetSettings");
				}
				if (wizardstate.hasStage("emeters")) {
					appsToLoad.push("eMetersSettings");
				}
			}
		} else {
			// Check if the product options are changed that need a reboot, but only when we're not busy with the activation wizard.
			if (appsToLoadFilled && !activationProcedureActive) {
				if ((productOptions["standalone"] ? true : false) !== p.agreementDetailsStandalone) {
					Qt.quit();
				} else if (!productOptions["standalone"]) {
					var newProviderLoyalValue = parseInt(productOptions["other_provider_elec"]) !== 1 && parseInt(productOptions["other_provider_gas"]) !== 1;
					if (newProviderLoyalValue !== p.agreementDetailsProviderLoyal) {
						Qt.quit();
					} else if ((productOptions["heatwinner"] === "0") && p.agreementDetailsHeatWinner) {
						// Heatwinner agreement is off but was on before, reboot UI to remove the app
						Qt.quit();
					}
				}
			}

			// Base set of apps that is available on all displays
			appsToLoad = [
						"homescreen",
						"systray",
						"thermostat",
						"clock",
						"settings",
						"systemSettings",
						"thermostatSettings",
						"internetSettings",
						"tscSettings",
						"eMetersSettings",
						"graph"]

			if (feature.appInboxEnabled()) {
				appsToLoad.push("inbox");
			}

			if (feature.appCustomerServiceEnabled()) {
				appsToLoad.push("customerService");
			}

			if (feature.appImageViewerEnabled()) {
				appsToLoad.push("imageViewer");
			}

			// Air quality (currently) depends on sensors that are only available on the QB3.
			if (isNxt || isDemoBuild || globals.heatingMode === "none") {
				appsToLoad.push("airQuality");
			}

			if (feature.appStrvFeatureEnabled() && globals.heatingMode === "zone") {
				appsToLoad.push("strvSettings");
			}

			// Load status of these apps is determined in the init() function in the xxxApp.qml
			appsToLoad.push("domesticHotWater");
			appsToLoad.push("winwit");

			// Determine if standalone is active
			p.agreementDetailsStandalone = productOptions["standalone"];
			p.agreementDetailsProviderLoyal = !p.agreementDetailsStandalone;

			// These apps are added for non-standalone customers
			if (p.agreementDetailsProviderLoyal) {

				p.agreementDetailsProviderLoyal = parseInt(productOptions["other_provider_elec"]) !== 1 && parseInt(productOptions["other_provider_gas"]) !== 1;

				// boilerMonitor is allowed for other_provider variants, but not with district heating
				if (features["boilerMonitoring"] && productOptions['district_heating'] === "0") {
					appsToLoad.push("boilerMonitor");
				}

				if (feature.appBenchmarkEnabled()) {
					appsToLoad.push("benchmark");
				}
				appsToLoad.push("controlPanel");
                              //TSC disabled: appsToLoad.push("weather");

				if (feature.appStatusUsageEnabled()) {
					// Status usage is only enabled with provider loyal customers
					if (p.agreementDetailsProviderLoyal) {
						appsToLoad.push("statusUsage");
					}
				}

				solarInHcbConfig = feature.appSolarEnabled() ? 1 : 0;

				if (productOptions["solar"] === "1" && solarInHcbConfig === 1) {
					appsToLoad.push("solar");
				}

				if (feature.appHeatRecoveryEnabled() && productOptions["heatwinner"] === "1") {
					appsToLoad.push("heatRecovery");
					p.agreementDetailsHeatWinner = true;
				}

				// Enable various GUI components.
				// When debugging in the virtual box add the qt-gui/config/hcb_project.xml with the correct options
				// to file to the qt-gui folder
				if (feature.appSmokeDetectorEnabled()) {
					appsToLoad.push("smokeDetector");
				}
			} else {
				if (feature.appUpsellEnabled())
					appsToLoad.push("upsell");
			}
		}

		if (isNormalMode) {
			if (globals.heatingMode === "none") {
				console.log("No heating mode selected - Removing all heating related apps");
				var heatingRelatedApps = ["thermostatSettings", "thermostat", "domesticHotWater", "boilerMonitor", "heatRecovery", "strvSettings"];
				appsToLoad = removeAppsFromList(heatingRelatedApps, appsToLoad);
			} else if (globals.heatingMode === "zone") {
				console.log("STRV mode selected - Removing all boiler related apps");
				// The following apps are related explicitely to boilers, and need to be disabled if we don't have a *controlled* boiler.
				var boilerRelatedApps = ["thermostatSettings", "thermostat", "domesticHotWater", "boilerMonitor", "heatRecovery"];
				appsToLoad = removeAppsFromList(boilerRelatedApps, appsToLoad);
			}
		}

		filterEnabledApps(appsToLoad);
		appsToLoadFilled = true;
	}

	function removeAppsFromList(appsToRemove, appList) {
		for (var i in appsToRemove) {
			var tmpApp = appsToRemove[i];
			var tmpIndex = appList.indexOf(tmpApp);
			if (tmpIndex > -1) {
				var removedList = appList.splice(tmpIndex, 1);
				console.log("Removing", JSON.stringify(removedList), "from apps to load");
			}
		}
		return appList;
	}
}
