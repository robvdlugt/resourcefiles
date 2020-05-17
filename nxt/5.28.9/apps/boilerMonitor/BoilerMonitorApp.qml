import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

import "BoilerMonitorConstants.js" as Constants

App {
	id: boilerMonitorApp

	property url boilerImageUrl: "drawables/app_icon.svg"
	property url boilerMonitorScreenUrl: "BoilerMonitorScreen.qml"
	property url boilerMonitorIntroScreenUrl: "BoilerMonitorIntroScreen.qml"
	property url boilerInfoOverviewScreenUrl: "BoilerInfoOverviewScreen.qml"
	property url boilerDataSelectScreenUrl: "BoilerDataSelectScreen.qml"
	property url boilerProdYearSelectScreen: "BoilerProdYearSelectScreen.qml"
	property url boilerAddMaintenanceScreenUrl: "BoilerAddMaintenanceScreen.qml"
	property url boilerLastMaintenanceScreenUrl: "BoilerLastMaintenanceScreen.qml"
	property url boilerMaintenanceIntervalScreenUrl: "BoilerMaintenanceIntervalScreen.qml"
	property url boilerMaintenanceProviderScreenUrl: "BoilerMaintenanceProviderScreen.qml"
	property url boilerDisableAdvicePopupUrl: "BoilerDisableAdvicePopup.qml"
	property url boilerPhoneNumberScreenUrl: "BoilerPhoneNumberScreen.qml"
	property url boilerWaterPressureScreenUrl: "BoilerWaterPressureScreen.qml"
	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"

	property bool firstUse: true // true means the user has never gone thru the intro screens
	property bool firstUseNotificationSent: false // true means notification has been sent
	property bool waterPressureBoilerInfoRequested: false

	// Undefined until received or not set yet, true if consent given, false if consent withdrawn or declined
	property variant consentSet

	property string boilerMonitorNotificationType: "boilerMonitor"
	property real progress: 0

	// @see Constants.BACKEND_DATA for bit meanings
	property int backendDataReceived: 0
	property bool backendDataComplete: (backendDataReceived === ((1 << Object.keys(Constants.BACKEND_DATA).length) - 1))

	property bool apiError: false

	property string appName: qsTr("boilerMonitor_app_name")

	property MenuItem boilerMonitorMenu

	property variant boilerInfo: Constants.EMPTY_BOILERINFO
	property variant boilerStatus: Constants.EMPTY_BOILERSTATUS
	property variant contactInfo: Constants.EMPTY_CONTACTINFO
	property variant maintenanceProviders: []
	property variant serviceConfiguration: ({
		"enableServiceInterval": true,
		"enableServiceProvider": true,
		"enablePhoneNumbers": true,
		"automaticConsent": false,
		"showIntroduction": true,
	})

	property variant userContactInfo: {
		'phone1': "",
		'phone2': ""
	}

	// for convenience
	property string boilerBrandName
	property string	boilerModelName
	property variant lastMaintenance

	// 0 = displayUuid, 1 = bxtProxy, 2 = appConfig, 3 = phoneNumbers, 4 = consent
	initVarCount: 5

	QtObject {
		id: p

		property string usermsgUuid
		property string hcbConfigUuid
		property string kpiUuid
		property string bxtProxyUuid
		property string displayUuid
		property bool autoConsentSent: false

		// NOTE: the uuids in apiProxies need to be in line with base-packages
		property variant apiProxies: {
			"boilerApi":				{uuid: "38715664-1ec5-4bc4-baea-676985ad09ed"},	// https://boiler-api.mgmt.quby-test.quby.com/boiler-api/v1
			"boilerKnowledgeService":	{uuid: "3a2f53ba-d440-48d8-8a7e-a21d68b769cc"},	// https://boiler-knowledge-service.mgmt.quby-test.quby.com/boilerKnowledgeBaseServiceRest/brands
			"contactApi":				{uuid: "b71faf84-8d29-4649-8919-3a5e191efb1c"}	// https://mc-contact-service.mgmt.quby-test.quby.com/
		}
	}

	onFirstUseChanged: updateMenuItemDestination()
	onConsentSetChanged: {
		updateMenuItemDestination();
		checkForAutoConsent();
	}
	onBackendDataReceivedChanged: {
		updateMenuItemDestination()
		checkForAutoConsent();
	}

	onBoilerInfoChanged: {
		if (typeof boilerInfo === "undefined")
			return;

		if (boilerInfo.services.length) {
			lastMaintenance = qtUtils.stringToDate(boilerInfo.services[boilerInfo.services.length - 1].serviceDate, "yyyy-MM-dd");
		} else {
			lastMaintenance = undefined;
		}

		calculateProgress();
	}

	onContactInfoChanged: calculateProgress()
	onServiceConfigurationChanged: {
		calculateProgress();
		updateMenuItemDestination();
		checkForAutoConsent();
		if (!serviceConfiguration["showIntroduction"])
			notifications.registerSubtype(boilerMonitorNotificationType, "firstUse", boilerMonitorScreenUrl, {});
	}

	onDoneLoadingChanged: {
		fetchDataFromBackend(true);
	}

	Connections {
		target: globals
		onServiceCenterAvailableChanged: {
			apiError = !globals.serviceCenterAvailable;
			// will check variable in function
			fetchDataFromBackend(true);
		}
	}

	Connections {
		target: canvas
		onFirstLoadingDoneChanged: {
			if (!firstUseNotificationSent) {
				// Send the firstUse notification
				sendNotification(true, "firstUse", qsTr("first-use-notification"));
				firstUseNotificationSent = true;
				saveAppConfig();
			}
		}
	}

	function checkForAutoConsent() {
		if (hasBackendData(Constants.BACKEND_DATA.CONSENT) && hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG)) {
			if (consentSet !== true && serviceConfiguration["automaticConsent"] === true && !p.autoConsentSent) {
				p.autoConsentSent = true;
				sendConsent(true);
			}
		}
	}

	function calculateProgress() {
		if (Constants.progressFields && serviceConfiguration) {
			var total = 0, filled = 0;
			Constants.progressFields.forEach(function (field) {
				if (!boilerMonitorApp[field.object])
					return;

				if (field.configEnableField === undefined ||
						(field.configEnableField && serviceConfiguration[field.configEnableField] === true)) {
					total++;
					var fieldToTest = field.field ? boilerMonitorApp[field.object][field.field] : boilerMonitorApp[field.object];
					if (fieldToTest !== undefined && fieldToTest !== null) {
						if (field.testFn instanceof Function) {
							if (field.testFn(fieldToTest))
								filled++;
						} else {
							filled++;
						}
					}
				}
			});
			progress = (filled / total);
		}
	}

	function updateMenuItemDestination() {
		if (boilerMonitorMenu) {
			if (firstUse && serviceConfiguration["showIntroduction"]) {
				boilerMonitorMenu.screenUrl = boilerMonitorIntroScreenUrl;
			} else if (consentSet !== true && hasBackendData(Constants.BACKEND_DATA.CONSENT) && !serviceConfiguration["automaticConsent"]) {
				boilerMonitorMenu.screenUrl = boilerMonitorIntroScreenUrl;
			} else {
				boilerMonitorMenu.screenUrl = boilerMonitorScreenUrl;
			}
		}
	}

	function init() {
		registry.registerWidget("menuItem", null, boilerMonitorApp, "boilerMonitorMenu", {objectName: "boilerMonitorMenuItem", label: appName, image: boilerImageUrl, screenUrl: boilerMonitorIntroScreenUrl, weight: 91});
		registry.registerWidget("screen", boilerMonitorIntroScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerMonitorScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerInfoOverviewScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerDataSelectScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerProdYearSelectScreen, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerAddMaintenanceScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerLastMaintenanceScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerMaintenanceIntervalScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerMaintenanceProviderScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerPhoneNumberScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", boilerWaterPressureScreenUrl, boilerMonitorApp, null, {lazyLoadScreen: true});

		notifications.registerType(boilerMonitorNotificationType, notifications.prio_LOW, boilerImageUrl,
								   boilerMonitorScreenUrl, {"categoryUrl": boilerMonitorScreenUrl}, qsTr("notification-boilerMonitor-grouped") );
		notifications.registerSubtype(boilerMonitorNotificationType, "firstUse", boilerMonitorIntroScreenUrl, {});
		notifications.registerSubtype(boilerMonitorNotificationType, "firstConsent", boilerMonitorIntroScreenUrl, {});
		notifications.registerSubtype(boilerMonitorNotificationType, "mtncProviders", boilerInfoOverviewScreenUrl, {fetch: true, page: 1, highlightField: "maintenanceProviderField"});
		notifications.registerSubtype(boilerMonitorNotificationType, "maintenanceDue", boilerMonitorScreenUrl, {});
		notifications.registerSubtype(boilerMonitorNotificationType, "fault", boilerMonitorScreenUrl, {});
		notifications.registerSubtype(boilerMonitorNotificationType, "waterPressure", boilerMonitorScreenUrl, {"fromWaterPressureNotification": true});
	}

	function confirmFirstUse() {
		if (firstUse) {
			firstUse = false;
			firstUseNotificationSent = true;
			// Store that the user has acknowledged the first-use screen
			saveAppConfig();
			removeFirstUseNotification();
		}
	}

	function getAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "boilerMonitorApp");

		bxtClient.doAsyncBxtRequest(msg, getConfigCallback, 30);
	}

	function saveAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("boilerMonitorApp", null, 0);
		node.addChild("package", "qt-gui", 0);
		node.addChild("internalAddress", "boilerMonitorApp", 0);

		node.addChild("firstUse", firstUse ? 1 : 0, 0);
		node.addChild("firstUseNotificationSent", firstUseNotificationSent ? 1 : 0, 0);
		node.addChild("waterPressureBoilerInfoRequested", waterPressureBoilerInfoRequested ? 1 : 0, 0);

		var userNotificationPreferenceBitfield = 0;
		if (contactInfo["phoneNumber1Selected"]) {
			userNotificationPreferenceBitfield += 1;
		}
		if (contactInfo["phoneNumber2Selected"]) {
			userNotificationPreferenceBitfield += 2;
		}
		node.addChild("userNotificationPreference", userNotificationPreferenceBitfield, 0);

		// If there are more configuration parameters that we need to save, add them here

		bxtClient.sendMsg(msg);
	}

	function sendNotification(unique, subType, text) {
		notifications.send(boilerMonitorNotificationType, subType, unique, text);
	}

	function removeFirstUseNotification() {
		notifications.removeByTypeSubType(boilerMonitorNotificationType, "firstUse");
	}

	function removeMaintenanceNotification() {
		notifications.removeByTypeSubType(boilerMonitorNotificationType, "maintenanceDue");
	}

	function removeFaultNotification() {
		notifications.removeByTypeSubType(boilerMonitorNotificationType, "fault");
	}

	// Set boiler brand id + name and send to API
	function setBoilerBrand(id, name, callbackScreen) {
		setBoilerInfoField("brandId", id, callbackScreen, function () {
			boilerBrandName = name !== undefined ? name : "";
			boilerModelName = "";
		});
	}

	// Set boiler model id + name and send to API
	function setBoilerModel(id, name, callbackScreen) {
		setBoilerInfoField("modelId", id, callbackScreen, function () {
			boilerModelName = name !== undefined ? name : "";
		});
	}

	// Set boiler production year and send to API
	function setBoilerProductionYear(year, callbackScreen) {
		setBoilerInfoField("productionYear", year, callbackScreen);
	}

	// Set boiler last maintenance date and send to API
	function setBoilerLastMaintenance(date, callbackScreen) {
		setBoilerInfoField("lastMaintenance", date, callbackScreen);
	}

	// Set phone number and send to API
	function setBoilerPhoneNumber(phoneNumber1Selected, phoneNumber2Selected, callbackScreen) {
		var tmpContactInfo = {};
		tmpContactInfo["phoneNumber1Selected"] = (phoneNumber1Selected === true);
		tmpContactInfo["phoneNumber2Selected"] = (phoneNumber2Selected === true);

		var cb = function(message) {
			var status = Number(message.getArgument("http_code"));

			if (status === Constants.HTTP_OK || status === Constants.HTTP_CREATED) {
				contactInfo = tmpContactInfo;
				saveAppConfig();
				if (callbackScreen && callbackScreen.saveFinished)
					callbackScreen.saveFinished(true);
			} else if (status === Constants.HTTP_NOT_FOUND) {
				// If the resource was not POSTed yet, create the contacts on the back end
				contactInfo = tmpContactInfo;
				saveAppConfig();
				createContactInfoOnMC(cb);
			} else {
				if (callbackScreen && callbackScreen.saveFinished)
					callbackScreen.saveFinished(false);
			}
		}

		sendContactInfoToMC(tmpContactInfo, cb);
	}

	// Set boiler maintenance interval and send to API
	function setBoilerMaintenanceInterval(interval, callbackScreen) {
		setBoilerInfoField("serviceInterval", interval, callbackScreen);
	}

	// Set boiler maintenance provider option and send to API
	function setBoilerMaintenanceProvider(option, callbackScreen) {
		setBoilerInfoField("maintenanceProviderId", option, callbackScreen);
	}

	// Set boilerInfo field to specified value and send to API
	function setBoilerInfoField(fieldName, fieldValue, callbackScreen, onSuccess) {
		if (typeof fieldName === "undefined")
			return;

		// validate if different
		var changed = false;
		switch (fieldName) {
		case "lastMaintenance":
			var length = boilerInfo["services"].length;
			if (length) {
				if (boilerInfo["services"][length - 1].serviceDate !== fieldValue)
					changed = true;
			} else {
				if (typeof fieldValue === "string")
					changed = true;
			}
			break;
		default:
			changed = (boilerInfo[fieldName] !== fieldValue);
			break;
		}

		if (changed) {
			var tmpBoilerInfo = Object.assign({}, boilerInfo);
			switch (fieldName) {
			case "brandId":
				tmpBoilerInfo[fieldName] = fieldValue;
				tmpBoilerInfo["modelId"] = undefined;
				break;
			case "lastMaintenance":
				// assuming list of service dates is in ascending order (older first)
				tmpBoilerInfo["services"].pop();
				if (typeof fieldValue === "string")
					tmpBoilerInfo["services"].push({"serviceDate" : fieldValue});
				break;
			default:
				tmpBoilerInfo[fieldName] = fieldValue;
				break;
			}

			// fill subscribedSince if unset, since it is mandatory for all PUT requests
			if (tmpBoilerInfo["subscribedSince"] === undefined)
				tmpBoilerInfo["subscribedSince"] = getDateYYYYMMDD();

			var cb = function(message) {
				var status = Number(message.getArgument("http_code"));

				var success = (status === Constants.HTTP_CREATED || status === Constants.HTTP_NO_CONTENT) ? true : false;
				if (success) {
					boilerInfo = tmpBoilerInfo;
					if (onSuccess instanceof Function)
						onSuccess();
				}
				if (callbackScreen && callbackScreen.saveFinished)
					callbackScreen.saveFinished(success);
			}

			sendBoilerInfoToApi(tmpBoilerInfo, cb);
		} else {
			if (callbackScreen && callbackScreen.saveFinished)
				callbackScreen.saveFinished(true);
		}
	}

	// Parse returned boiler brand name from BKS, save to boilerBrandName property
	function getBoilerBrandNameCallback(message) {
		if (!message)
			return;

		if (Number(message.getArgument("http_code")) === Constants.HTTP_OK) {
			try {
				var result = JSON.parse(message.getArgument("data"));
				if (result["id"] === boilerInfo["brandId"]) {
					boilerBrandName = result["name"];
				}
			} catch (error) {
				console.error("BoilerMonitorApp(getBoilerBrandName): error parsing response:", message.getArgument("data"));
			}
		}
	}

	// Parse returned boiler model name from BKS, save to boilerModelName property
	function getBoilerModelNameCallback(message) {
		if (!message)
			return;

		if (Number(message.getArgument("http_code")) === Constants.HTTP_OK) {
			try {
				var result = JSON.parse(message.getArgument("data"));
				if (result["id"] === boilerInfo["modelId"]) {
					boilerModelName = result["name"];
				}
			} catch (error) {
				console.error("BoilerMonitorApp(getBoilerModelName): error parsing response:", message.getArgument("data"));
			}
		}
	}

	// check if boilerBrandName and boilerModelName are set, otherwise request them
	function checkBoilerBrandModelName(changed) {
		var msg;

		if (boilerInfo["brandId"]) {
			if (!boilerBrandName || changed) {
				msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerKnowledgeService"]["uuid"], "specific1", "DoWebRequest");
				msg.addArgument("urlExtension", "/" + boilerInfo["brandId"]);
				bxtClient.doAsyncBxtRequest(msg, getBoilerBrandNameCallback, 15);
			}
		} else {
			boilerBrandName = "";
		}

		if (boilerInfo['modelId']) {
			if (!boilerModelName || changed) {
				msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerKnowledgeService"]["uuid"], "specific1", "DoWebRequest");
				msg.addArgument("urlExtension", "/" + boilerInfo["brandId"] + "/models/" + boilerInfo["modelId"]);
				bxtClient.doAsyncBxtRequest(msg, getBoilerModelNameCallback, 15);
			}
		} else {
			boilerModelName = "";
		}
	}

	function fetchDataFromBackend(all, callback) {
		if (!doneLoading || !globals.serviceCenterAvailable) {
			if (typeof callback === "function")
				callback(false);
			return;
		}

		var fetchFunctions = [
			{id: Constants.BACKEND_DATA.SERVICE_CONFIG,		fn: fetchServiceConfig},
			{id: Constants.BACKEND_DATA.BOILER_PROFILE,		fn: fetchBoilerInfo},
			{id: Constants.BACKEND_DATA.CONSENT,			fn: getConsent},
			{id: Constants.BACKEND_DATA.BOILER_STATUS,		fn: fetchBoilerStatus},
			{id: Constants.BACKEND_DATA.MTNC_PROVIDERS,		fn: fetchMaintenanceProviders}
		];
		var fetchPending = 0;
		var fetchCB = function (id) {
			fetchPending &= ~(id);
			if (fetchPending === 0 && typeof callback === "function")
				callback(true);
		}

		for (var i = 0; i < fetchFunctions.length; i++) {
			var dataId = fetchFunctions[i].id;
			if (!hasBackendData(dataId) || all) {
				fetchPending |= dataId;
				fetchFunctions[i].fn(util.partialFn(function (id) { fetchCB(id) }, dataId));
			}
		}

		if (fetchPending === 0)
			fetchCB(0);
	}

	/**
	  * @brief whether specified type of backend data has been retrieved
	  * @arg type: one of #Constants.BACKEND_DATA.*
	  */
	function hasBackendData(type) {
		return ((backendDataReceived & type) ? true : false);
	}

	// Get boiler info from API
	function fetchBoilerInfo(callback) {
		if (doneLoading && globals.serviceCenterAvailable) {
			if (!p.displayUuid || !p.apiProxies["boilerApi"]["uuid"])
				return;

			var cb = function (message) {
				if (message)
					fetchBoilerInfoCallback(Number(message.getArgument("http_code")), message.getArgument("data"), callback)
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerApi"]["uuid"], "specific1", "DoWebRequest");
			msg.addArgument("urlExtension", "/boilers/" + p.displayUuid);
			bxtClient.doAsyncBxtRequest(msg, cb, 15);
		} else {
			if (typeof callback === "function")
				callback(false);
		}
	}

	// Parse returned boiler info, save to boilerInfo property
	function fetchBoilerInfoCallback(status, text, callback) {
		var success = false;
		if (status === Constants.HTTP_OK) {
			try {
				// parse JSON to boilerInfo
				var resp = JSON.parse(text);
				var boilerChanged = (boilerInfo.brandId !== resp.brandId
									|| boilerInfo.modelId !== resp.modelId);
				boilerInfo = resp;
				checkBoilerBrandModelName(boilerChanged);
				backendDataReceived |= Constants.BACKEND_DATA.BOILER_PROFILE;
				success = true;
			} catch (error) {
				console.error("BoilerMonitorApp(fetchBoilerInfo): error parsing response:", text);
			}
		} else if (status === Constants.HTTP_NOT_FOUND) {
			backendDataReceived |= Constants.BACKEND_DATA.BOILER_PROFILE;
			success = true;
		} else {
			console.error("BoilerMonitorApp(fetchBoilerInfo): failed retrieving boiler profile!");
		}

		if (typeof callback === "function")
			callback(success);
	}

	function fetchBoilerStatus(callback) {
		if (doneLoading && globals.serviceCenterAvailable) {
			if (!p.displayUuid || !p.apiProxies["boilerApi"]["uuid"])
				return;

			var cb = function (message) {
				if (message)
					fetchBoilerStatusCallback(Number(message.getArgument("http_code")), message.getArgument("data"), callback)
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerApi"]["uuid"], "specific1", "DoWebRequest");
			msg.addArgument("urlExtension", "/boilers/" + p.displayUuid + "/status");
			msg.addArgument("httpHeader", "Accept-Language: " + canvas.locale);
			bxtClient.doAsyncBxtRequest(msg, cb, 15);
		} else {
			if (typeof callback === "function")
				callback(false);
		}
	}

	function fetchBoilerStatusCallback(status, text, callback) {
		var success = false;
		if (status === Constants.HTTP_OK) {
			if (text) {
				try {
					var resp = JSON.parse(text);
					// check for valid response and save boilerStatus
					if (resp.state && resp.fault && resp.maintenance) {
						boilerStatus = resp;

						backendDataReceived |= Constants.BACKEND_DATA.BOILER_STATUS;
						success = true;
					}
				} catch (error) {
					console.error("BoilerMonitorApp(fetchBoilerStatus): error parsing response:", text);
				}
			}
		} else if (status === Constants.HTTP_NOT_FOUND) {
			backendDataReceived |= Constants.BACKEND_DATA.BOILER_STATUS;
			success = true;
		} else {
			console.error("BoilerMonitorApp(fetchBoilerStatus): failed retrieving boiler status!");
		}	

		if (typeof callback === "function")
			callback(success);
	}

	function fetchMaintenanceProviders(callback) {
		if (doneLoading && globals.serviceCenterAvailable) {
			if (!p.apiProxies["boilerApi"]["uuid"])
				return;

			var cb = function (message) {
				if (message)
					fetchMaintenanceProvidersCallback(Number(message.getArgument("http_code")), message.getArgument("data"), callback)
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerApi"]["uuid"], "specific1", "DoWebRequest");
			msg.addArgument("urlExtension", "/maintenance-providers/");
			msg.addArgument("httpHeader", "Accept-Language: " + canvas.locale);
			bxtClient.doAsyncBxtRequest(msg, cb, 15);
		} else {
			if (typeof callback === "function")
				callback(false);
		}
	}

	function fetchMaintenanceProvidersCallback(status, response, callback) {
		var success = false;
		if (status === Constants.HTTP_OK) {
			if (response) {
				try {
					var resp = JSON.parse(response);
					if (Array.isArray(resp)) {
						maintenanceProviders = resp;
						backendDataReceived |= Constants.BACKEND_DATA.MTNC_PROVIDERS;
						success = true;
					} else {
						console.error("BoilerMonitorApp(fetchMaintenanceProviders): received non-array response:", response);
					}
				} catch (error) {
					console.error("BoilerMonitorApp(fetchMaintenanceProviders): error parsing response:", response);
				}
			}
		} else {
			console.error("BoilerMonitorApp(fetchMaintenanceProviders): failed retrieving maintenance providers!");
		}

		if (typeof callback === "function")
			callback(success);
	}

	function fetchServiceConfig(callback) {
		if (doneLoading && globals.serviceCenterAvailable) {
			if (!p.apiProxies["boilerApi"]["uuid"])
				return;

			var cb = function (message) {
				if (message)
					fetchServiceConfigCallback(Number(message.getArgument("http_code")), message.getArgument("data"), callback)
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerApi"]["uuid"], "specific1", "DoWebRequest");
			msg.addArgument("urlExtension", "/feature-settings");
			bxtClient.doAsyncBxtRequest(msg, cb, 15);
		} else {
			if (typeof callback === "function")
				callback(false);
		}
	}

	function fetchServiceConfigCallback(status, response, callback) {
		var success = false;
		if (status === Constants.HTTP_OK) {
			if (response) {
				try {
					var jsonResponse = JSON.parse(response);
					if (typeof jsonResponse === "object") {
						var tmpServiceConfiguration = serviceConfiguration;
						for (var field in serviceConfiguration) {
							if (jsonResponse.hasOwnProperty(field))
								tmpServiceConfiguration[field] = jsonResponse[field];
						}
						backendDataReceived |= Constants.BACKEND_DATA.SERVICE_CONFIG;
						serviceConfiguration = tmpServiceConfiguration;
						success = true;
					} else {
						console.error("BoilerMonitorApp(fetchServiceConfig): received non-object response:", response);
					}
				} catch (error) {
					console.error("BoilerMonitorApp(fetchServiceConfig): error parsing response:", response);
				}
			}
		} else {
			console.error("BoilerMonitorApp(fetchServiceConfig): failed retrieving service configuration!");
		}

		if (typeof callback === "function")
			callback(success);
	}

	// Get date in YYYY-MM-DD format
	function getDateYYYYMMDD(date) {
		if (typeof date === "undefined")
			date = new Date();
		else if (!(date instanceof Date))
			return "";
		return qtUtils.dateToString(date, "yyyy-MM-dd");
	}

	// Send boiler info to API
	function sendBoilerInfoToApi(info, callback) {
		var jsonData = JSON.stringify(info);

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["boilerApi"]["uuid"], "specific1", "DoWebRequest");
		msg.addArgument("httpRequestType", "PUT");
		msg.addArgument("urlExtension", "/boilers/" + p.displayUuid);
		msg.addArgument("data", jsonData);

		bxtClient.doAsyncBxtRequest(msg, callback, 10);
	}

	// Send contact info to API
	function sendContactInfoToMC(tmpContactInfo, callback) {

		var contactInfoMsgRaw = {
			"commonName" : bxtClient.getCommonname(),
			"language": canvas.locale,

			"phoneNumber1": tmpContactInfo["phoneNumber1Selected"] ? userContactInfo["phone1"] : "",
			"phoneNumber2": tmpContactInfo["phoneNumber2Selected"] ? userContactInfo["phone2"] : ""
		}

		var contactInfoMsgJSON = JSON.stringify(contactInfoMsgRaw);

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["contactApi"]["uuid"], "specific1", "DoWebRequest");
		msg.addArgument("httpRequestType", "PUT");
		msg.addArgument("data", contactInfoMsgJSON);

		bxtClient.doAsyncBxtRequest(msg, callback, 10);
	}

	function getKpiLoggingUuid() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.kpiUuid, "Logger", "GetUuid");
		msg.addArgument("logServ", "kpi");
		bxtClient.doAsyncBxtRequest(msg, getKpiLoggingUuidCallback, 30);
	}

	function getApiUuid(name) {
		if (p.apiProxies[name] && p.apiProxies[name].uuid)
			return p.apiProxies[name].uuid;
		else
			return "";
	}

	// If the contact data is changed, this should update the stored phone numbers. Also if numbers are removed they should be removed from the backend.
	function parseEventContacts(update) {
		var tempUserContactInfo = userContactInfo;
		var contact = update.getChild("contact");
		for (; contact; contact = contact.next) {
			if (contact.getChildText("contactType") === "user") {
				tempUserContactInfo["phone1"] = contact.getChildText("phone1");
				tempUserContactInfo["phone2"] = contact.getChildText("phone2");
			}
		}
		userContactInfo = tempUserContactInfo;

		// Remove the indexes of any removed phone numbers
		var tmpContactInfo = Object.assign({}, contactInfo);
		var changed = false;

		if (userContactInfo["phone1"] === "" && tmpContactInfo["phoneNumber1Selected"]) {
			tmpContactInfo["phoneNumber1Selected"] = false;
			changed = true;
		}

		if (userContactInfo["phone2"] === "" && tmpContactInfo["phoneNumber2Selected"]) {
			tmpContactInfo["phoneNumber2Selected"] = false;
			changed = true;
		}

		if (changed) {
			contactInfo = tmpContactInfo;

			saveAppConfig();
			sendContactInfoToMC(tmpContactInfo);
		}

		initVarDone(3);
	}

	function deleteContactInfoFromMC() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["contactApi"]["uuid"], "specific1", "DoWebRequest");
		msg.addArgument("httpRequestType", "DELETE");
		msg.addArgument("urlExtension", "/" + bxtClient.getCommonname());

		bxtClient.sendMsg(msg);
	}

	function createContactInfoOnMC(callback) {
		var contactInfoMsgRaw = {
			"commonName" : bxtClient.getCommonname(),
			"language": canvas.locale,

			"phoneNumber1": contactInfo["phoneNumber1Selected"] ? userContactInfo["phone1"] : "",
			"phoneNumber2": contactInfo["phoneNumber2Selected"] ? userContactInfo["phone2"] : ""
		}

		var contactInfoMsgJSON = JSON.stringify(contactInfoMsgRaw);

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.apiProxies["contactApi"]["uuid"], "specific1", "DoWebRequest");
		msg.addArgument("httpRequestType", "POST");
		msg.addArgument("data", contactInfoMsgJSON);

		bxtClient.doAsyncBxtRequest(msg, callback, 10);
	}

	function getConsent(callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.kpiUuid, "DataService", "GetConsent");
		msg.addArgument("name", "BOILER_MONITORING");

		var getConsentCallback = function (message) {
			var success = false;
			if (message) {
				var enabled = message.getArgumentXml("enabled");
				if (enabled && enabled.text) {
					backendDataReceived |= Constants.BACKEND_DATA.CONSENT;
					success = (message.getArgument("success") === "true");
					consentSet = success ? (parseInt(enabled.text) === 1) : undefined;
				} else {
					consentSet = undefined;
				}
			}
			initVarDone(4);

			if (typeof callback === "function")
				callback(success);
		}

		bxtClient.doAsyncBxtRequest(msg, getConsentCallback, 45);
	}

	function setConsent(consent, callbackScreen) {
		if (consent !== consentSet) {
			sendConsent(consent, callbackScreen);
		} else {
			if (callbackScreen && callbackScreen.saveFinished)
				callbackScreen.saveFinished(true);
		}
	}

	function sendConsent(consent, callbackScreen) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.kpiUuid, "DataService", "SetConsent");
		msg.addArgument("name", "BOILER_MONITORING");
		msg.addArgument("enabled", consent ? 1 : 0);

		var sendConsentCallback = function(message) {
			if (message) {
				var success;
				var succcesText = message.getArgumentXml("success").text;

				if (succcesText === "true") {
					success = true;
					consentSet = consent;

					if (consent === false) {
						// If consent is revoked, remove information locally
						boilerInfo = Object.assign({}, Constants.EMPTY_BOILERINFO);
						boilerBrandName = "";
						boilerModelName = "";
						lastMaintenance = undefined;
						// stay aware of Service Config and Consent
						backendDataReceived = (Constants.BACKEND_DATA.SERVICE_CONFIG + Constants.BACKEND_DATA.CONSENT);
						firstUse = true;
						contactInfo = Object.assign({}, Constants.EMPTY_CONTACTINFO);

						saveAppConfig();
						deleteContactInfoFromMC();
						removeMaintenanceNotification();
						removeFaultNotification();
					} else {
						// When consent is first set, create an empty contactInfo entry on the Message Center
						createContactInfoOnMC();
					}
				} else {
					success = false;
					p.autoConsentSent = false;
				}

				if (callbackScreen && callbackScreen.saveFinished) {
					callbackScreen.saveFinished(success);
				}

			} else { // in case of no message a.k.a. timeout
				if (callbackScreen && callbackScreen.saveFinished) {
					callbackScreen.saveFinished(false);
				}
			}
		}

		bxtClient.doAsyncBxtRequest(msg, sendConsentCallback, 11);
	}

	function confirmDisableAdvice(callbackScreen) {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("boiler_noAdvice_title"), boilerDisableAdvicePopupUrl,
								  qsTr("boiler_noAdvice_confirmButton"), function () { setConsent(false, callbackScreen); return false; },
								  qsTr("boiler_noAdvice_backButton"), 0);
	}

	function getPhoneNumberInfoText() {
		// Calculate the infoText for the phoneNumber
		var phoneNumberString = "-";

		if (contactInfo["phoneNumber1Selected"]) {
			phoneNumberString = userContactInfo["phone1"];

			if (contactInfo["phoneNumber2Selected"]) {
				phoneNumberString += ", ";
				phoneNumberString += userContactInfo["phone2"];
			}
		} else if (contactInfo["phoneNumber2Selected"]) {
			phoneNumberString = userContactInfo["phone2"];
		}

		return phoneNumberString;
	}

	function getMaintenanceProviderById(id) {
		for (var i = 0; i < maintenanceProviders.length; i++) {
			if (maintenanceProviders[i].id === id)
				return maintenanceProviders[i];
		}
	}

	function callScreenCallback(screen, callbackName, callbackArgs) {
		if (screen && callbackName && typeof screen[callbackName] === "function") {
			screen[callbackName](callbackArgs);
		}
	}

	BxtRequestCallback {
		id: getConfigCallback

		onMessageReceived: {
			var configNode = message.getArgumentXml("Config").getChild("boilerMonitorApp");

			if (configNode) {
				var userNotificationPreferenceNode = configNode.getChild("userNotificationPreference");
				if(userNotificationPreferenceNode) {
					var phoneNumbersBitfield = parseInt(userNotificationPreferenceNode.text);

					var tmpContactInfo = Object.assign({}, contactInfo);

					tmpContactInfo["phoneNumber1Selected"] = (phoneNumbersBitfield & 1) == 1;
					tmpContactInfo["phoneNumber2Selected"] = (phoneNumbersBitfield & 2) == 2;

					contactInfo = tmpContactInfo;
				}

				var node = configNode.getChild("firstUse");
				firstUse = node ? (parseInt(node.text) === 1) : true;
				node = configNode.getChild("firstUseNotificationSent");
				firstUseNotificationSent = node ? (parseInt(node.text) === 1) : !firstUse;
				waterPressureBoilerInfoRequested = (parseInt(configNode.getChildText("waterPressureBoilerInfoRequested")) === 1);
			} else {
				console.warn("No BoilerMonitorApp configuration available, creating defaults...");
				saveAppConfig();
			}
			initVarDone(2);
			updateMenuItemDestination();
		}
	}

	BxtRequestCallback {
		id: getKpiLoggingUuidCallback

		onMessageReceived: {
			if (message.getArgument("success") === "1") {
				p.displayUuid = message.getArgument("uuid");
			} else {
				console.error("Failed getting UUID: " + message.getArgument("reason"));
			}

			initVarDone(0);
		}
	}

	BxtDiscoveryHandler {
		id: usermsgDiscoHandler
		deviceType: "happ_usermsg"
		onDiscoReceived: {
			p.usermsgUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: hcbconfigDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.hcbConfigUuid = deviceUuid;
			getAppConfig();
		}
	}

	BxtDiscoveryHandler {
		id: kpiDiscoHandler
		deviceType: "happ_kpi"
		onDiscoReceived: {
			p.kpiUuid = deviceUuid;
			getKpiLoggingUuid();
			getConsent();
		}
	}

	BxtDiscoveryHandler {
		id: bxtProxyDiscoHandler
		deviceType: "hcb_bxtproxy"
		onDiscoReceived: {
			p.bxtProxyUuid = deviceUuid;
			initVarDone(1);
		}
	}

	BxtDiscoveryHandler {
		id: eventmgrDiscoHandler
		deviceType: "happ_eventmgr"
	}

	BxtDatasetHandler {
		id: eventContactsDsHandler
		dataset: "eventContacts"
		discoHandler: eventmgrDiscoHandler
		onDatasetUpdate: parseEventContacts(update)
	}
}
