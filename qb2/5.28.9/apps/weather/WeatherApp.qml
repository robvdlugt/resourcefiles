import QtQuick 2.1

import BxtClient 1.0
import qb.base 1.0
import Weather 1.0
import ScreenStateController 1.0

/// Weather Application.

App {
	id: weatherApp

	property url weatherScreenUrl : "WeatherScreen.qml"
	property url weatherSelectLocationScreenUrl : "WeatherSelectLocationScreen.qml"
    property url weatherDetailsScreenUrl : "WeatherDetailsScreen.qml"
	property url tileUrl: "WeatherTile.qml"
	property url thumbnailIcon: "drawables/weather-thumb.svg"
	property int tilesInstantiated: 0

	initVarCount: 2
	property bool firstUseNotificationSent: false

	property variant weatherDescriptions: {
		"Blizzard": qsTr("Blizzard"),
		"ClearSky": qsTr("Clear Sky"),
		"Clouds": qsTr("Clouds"),
		"FewClouds": qsTr("Few Clouds"),
		"Fog": qsTr("Fog"),
		"Hail": qsTr("Hail"),
		"Mist": qsTr("Mist"),
		"Rain": qsTr("Rain"),
		"ShowerRain": qsTr("Shower Rain"),
		"Sleet": qsTr("Sleet"),
		"Snow": qsTr("Snow"),
		"Thunderstorm": qsTr("Thunderstorm")
	}

	property variant windDirectionAbbreviations: {
		"N": qsTr("N"), "NNE": qsTr("NNE"), "NE": qsTr("NE"), "ENE": qsTr("ENE"),
		"E": qsTr("E"), "ESE": qsTr("ESE"), "SE": qsTr("SE"), "SSE": qsTr("SSE"),
		"S": qsTr("S"), "SSW": qsTr("SSW"), "SW": qsTr("SW"), "WSW": qsTr("WSW"),
		"W": qsTr("W"), "WNW": qsTr("WNW"), "NW": qsTr("NW"), "NNW": qsTr("NNW")
	}

	QtObject {
		id: p
		property string configUuid
		property string userMsgUuid
		property url menuImageUrl: "drawables/weather.svg"
	}

	function init() {
		registry.registerWidget("screen", weatherScreenUrl, weatherApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", weatherSelectLocationScreenUrl, weatherApp, "weatherSelectLocationScreen", {lazyLoadScreen: true});
        registry.registerWidget("screen", weatherDetailsScreenUrl, weatherApp, "weatherDetailsScreen", {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, weatherApp, null, {objectName: "weatherMenuItem", label: qsTr("Weather"), image: p.menuImageUrl, screenUrl: weatherScreenUrl, weight: 110});
		registry.registerWidget("tile", tileUrl, weatherApp, "weatherTile", {thumbLabel: qsTr("Weather"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 10, baseTileWeight: 20, thumbIconVAlignment: "center"});
    }

	function roundToHalf(n) {
		return i18n.number(Math.round(2.0 * n) / 2.0, 1);
	}

	Binding {
		target: Weather
		property: "fetchActive"
		value: tilesInstantiated > 0 && screenStateController.screenState !== ScreenStateController.ScreenOff
	}

	function saveWeatherConfig() {
		if (p.configUuid.length === 0)
			return console.log("Skipping storage of weather location because hcb_config has not been discovered() yet.");

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);
		var configNode = msg.getArgumentXml("Config");

		var weatherConfigNode = configNode.addChild("weatherConfig", null, 0);
		weatherConfigNode.addChild("package", "qt-gui", 0);
		weatherConfigNode.addChild("internalAddress", "weatherConfig", 0);

		var currentCityName = Weather.cityName;
		var currentCityId = Weather.cityId;
		weatherConfigNode.addChild("cityName", currentCityName, 0);
		weatherConfigNode.addChild("cityId", currentCityId, 0);

		weatherConfigNode.addChild("firstUseNotificationSent", firstUseNotificationSent ? 1 : 0, 0);

		console.log(msg.stringContent);
		bxtClient.sendMsg(msg);
	}

	// Will load the weather config, falling back to happ_weather config if empty
	function loadWeatherConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "weatherConfig");

		bxtClient.doAsyncBxtRequest(msg, loadWeatherConfigCallback, 30);
	}

	function loadWeatherConfigCallback(message) {
		if (!message){
			initVarDone(0);
			return console.log("Weather config not available due to timeout.");
		}

		var weatherConfig = message.getArgumentXml("Config").getChild("weatherConfig");
		if (weatherConfig) {
			Weather.cityName = weatherConfig.getChildText("cityName");
			Weather.cityId = weatherConfig.getChildText("cityId");

			var firstUseNotificationSentString = weatherConfig.getChildText("firstUseNotificationSent");
			firstUseNotificationSent = (parseInt(firstUseNotificationSentString) === 1);

			initVarDone(0);
			return;
		}

		console.log("Weather config not available.");
		migrateWeatherConfig();
	}

	function migrateWeatherConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "happ_weather");
		msg.addArgument("internalAddress", "locationDev");

		bxtClient.doAsyncBxtRequest(msg, migrateWeatherConfigCallback, 30);
	}

	function migrateWeatherConfigCallback(message) {
		if (!message){
			initVarDone(0);
			return console.log("Old weather config not available due to timeout.");
		}

		var weatherConfig = message.getArgumentXml("Config").getChild("device");
		if (weatherConfig) {
			Weather.cityName = weatherConfig.getChildText("name");
			Weather.resolveCityId();
			if (Weather.cityId.length > 0){
				initVarDone(0);
				return console.log("Imported weather location from happ_weather config: " + Weather.cityName);
			}
		}

		console.log("Old weather config not available.");
		migrateInternationalWeatherConfig();
	}

	function migrateInternationalWeatherConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "happ_weather");
		msg.addArgument("internalAddress", "locationSettingsDev");

		bxtClient.doAsyncBxtRequest(msg, migrateInternationalWeatherConfigCallback, 30);
	}

	function migrateInternationalWeatherConfigCallback(message) {
		if (!message){
			initVarDone(0);
			return console.log("Old international weather config not available due to timeout.");
		}

		var weatherConfig = message.getArgumentXml("Config").getChild("device");
		if (weatherConfig) {
			Weather.cityName = weatherConfig.getChildText("cityName");
			Weather.resolveCityId();
			if (Weather.cityId.length > 0){
				initVarDone(0);
				return console.log("Imported international weather location from happ_weather config: " + Weather.cityName);
			}
		}

		console.log("Old international weather config not available.");
		Weather.cityName = qtUtils.getWeatherDefaultCityName();
		Weather.cityId = qtUtils.getWeatherDefaultCityId();
		initVarDone(0);
	}

	BxtDiscoveryHandler {
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.configUuid = deviceUuid;
			loadWeatherConfig();
		}
	}

	BxtDiscoveryHandler {
		deviceType: "happ_usermsg"
		onDiscoReceived: {
			p.userMsgUuid = deviceUuid;
			initVarDone(1);
		}
	}

	function sendFirstUseMessage() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, null, "sendMessage");
		msg.addArgument("subject", qsTr("first-use-notification"));
		msg.addArgument("subtitle", qsTr("first-use-notification"));
		msg.addArgument("content", qsTr("first-use-content"));
		msg.addArgumentInt("messageType", 2);
		msg.addArgumentXmlText("\"<actions><action><type>button</type><btnLabel>" + qsTr("first-use-button") + "</btnLabel><btnPos>left</btnPos><cmdName>maximize</cmdName><returnAfterPress>true</returnAfterPress><cmdTarget>weather/WeatherScreen</cmdTarget></action></actions>");
		bxtClient.sendMsg(msg);
	}

	Connections {
		target: canvas
		onFirstLoadingDoneChanged: {
			if (!firstUseNotificationSent && p.userMsgUuid.length !== 0) {
				sendFirstUseMessage();
				firstUseNotificationSent = true;
				saveWeatherConfig();
			}
		}
	}
}
