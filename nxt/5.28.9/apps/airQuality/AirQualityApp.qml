import QtQuick 2.1
import BxtClient 1.0
import ScreenStateController 1.0

import qb.components 1.0
import qb.base 1.0;

/// Application to manage air quality

App {
	id: airQualityApp

	property url humidityPercentageNowTileUrl: "HumidityPercentageNowTile.qml"
	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"
	property url eco2NowTileUrl: "CO2NowTile.qml"
	property url vocNowTileUrl: "VOCNowTile.qml"
	property url temperatureTileUrl: "TemperatureTile.qml"
	property url temperatureCorrectionScreenUrl: "TemperatureCorrectionScreen.qml"

	property double humidity: 0.0
	property double eco2: 0.0
	property int tvoc: 0.0

	property variant temperatureInfo: {
		'currentDisplayTemperature' : -1,
		'tempDeviation' : "-",
		'tempMeasured' : "-",
	}

	QtObject {
		id: p

		property string primaryHumidityDevUuid
		property string humidityTileRegistrationUuid
		property string vocDevUuid
		property string vocNowTileRegistrationUuid
		property string eco2NowTileRegistrationUuid
		property string thermostatUuid
		property string temperatureTileRegistrationUuid
	}

	function init() {
		registry.registerWidget("screen", temperatureCorrectionScreenUrl, airQualityApp, null, {lazyLoadScreen: true});
	}

	function showHumidityPopup() {
		qdialog.showDialog(qdialog.SizeLarge, "", airQualityApp.tipsPopupUrl);
		qdialog.context.titleFontPixelSize = qfont.navigationTitle;
		var tips = [];

		if (humidity < 40) {
			tips.push({
						  title: qsTr("humidityPopup-Low-Title-Overview"),
						  text:  qsTr("humidityPopup-Low-Content-Overview %1").arg(i18n.number(humidity)),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-overview-low.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-Low-Title1"),
						  text:  qsTr("humidityPopup-Low-Content1"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-low1.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-Low-Title2"),
						  text:  qsTr("humidityPopup-Low-Content2"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-low2.svg")
					  });
		} else if (humidity <= 60) {
			tips.push({
						  title: qsTr("humidityPopup-Good-Title-Overview"),
						  text:  qsTr("humidityPopup-Good-Content-Overview %1").arg(i18n.number(humidity)),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-overview-good.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-Good-Title1"),
						  text:  qsTr("humidityPopup-Good-Content1"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-good1.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-Good-Title2"),
						  text:  qsTr("humidityPopup-Good-Content2"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-good2.svg")
					  });
		} else {
			tips.push({
						  title: qsTr("humidityPopup-High-Title-Overview"),
						  text:  qsTr("humidityPopup-High-Content-Overview %1").arg(i18n.number(humidity)),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-overview-high.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-High-Title1"),
						  text:  qsTr("humidityPopup-High-Content1"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-high1.svg")
					  });
			tips.push({
						  title: qsTr("humidityPopup-High-Title2"),
						  text:  qsTr("humidityPopup-High-Content2"),
						  textFormat: Text.PlainText,
						  image: Qt.resolvedUrl("image://scaled/apps/airQuality/drawables/humidity-tip-high2.svg")
					  });
		}

		qdialog.context.dynamicContent.showSeparator = false;
		qdialog.context.dynamicContent.carousel = false;
		qdialog.context.dynamicContent.countlyLoggingInfix = "humidityExplanationPopup";
		qdialog.context.dynamicContent.tips = tips;
		qdialog.context.blockDimState = false;
	}

	BxtDiscoveryHandler {
		id: hdrvSensoryDiscoHandler
		deviceType: "hdrv_sensory"
		onDiscoReceived: {
			var featureHumidity = feature.featHumidityEnabled();
			var featureAirQuality = globals.features["airQuality"];

			if (isHello) {
				if (featureHumidity && !p.humidityTileRegistrationUuid) {
					p.humidityTileRegistrationUuid = registry.registerWidget("tile", humidityPercentageNowTileUrl, airQualityApp, null, {thumbLabel: qsTr("Humidity"), thumbIcon: Qt.resolvedUrl("drawables/humidityThumbIcon.svg"), thumbCategory: "ventilation", thumbIconVAlignment: "center"});
				}

				if(featureAirQuality && !p.vocNowTileRegistrationUuid && !p.eco2NowTileRegistrationUuid) {
					p.vocNowTileRegistrationUuid = registry.registerWidget("tile", vocNowTileUrl, airQualityApp, null, {thumbLabel: qsTr("Air Quality"), thumbIcon: Qt.resolvedUrl("drawables/vocThumbIcon.svg"), thumbCategory: "ventilation", thumbIconVAlignment: "center"});
					p.eco2NowTileRegistrationUuid = registry.registerWidget("tile", eco2NowTileUrl, airQualityApp, null, {thumbLabel: "CO₂", thumbIcon: Qt.resolvedUrl("drawables/co2ThumbIcon.svg"), thumbCategory: "ventilation", thumbIconVAlignment: "center"});
				}

				if (devNode) {
					for (var device = devNode.getChild("device"); device; device = device.next) {
						var deviceType = device.getAttribute("type");
						if (deviceType === undefined)
							continue;

						var deviceUuid;
						if (featureHumidity && ~deviceType.indexOf("temperatureHumidityPrimary"))
						{
							deviceUuid = device.getAttribute("uuid");
							if (deviceUuid)
								p.primaryHumidityDevUuid = deviceUuid;
						}
						else if (featureAirQuality && ~deviceType.indexOf("vocSensor"))
						{
							deviceUuid = device.getAttribute("uuid");
							if (deviceUuid)
								p.vocDevUuid = deviceUuid;
						}
					}
				}
			} else {
				if (featureHumidity && p.humidityTileRegistrationUuid) {
					registry.deregisterWidget(p.humidityTileRegistrationUuid);
					p.humidityTileRegistrationUuid = "";
					p.primaryHumidityDevUuid = "";
				}

				if(featureAirQuality && p.vocNowTileRegistrationUuid && p.eco2NowTileRegistrationUuid) {
					registry.deregisterWidget(p.vocNowTileRegistrationUuid);
					p.vocNowTileRegistrationUuid = "";
					registry.deregisterWidget(p.eco2NowTileRegistrationUuid);
					p.eco2NowTileRegistrationUuid = "";
					p.vocDevUuid = "";
				}
			}
		}
	}

	BxtNotifyHandler {
		id: humidityInfoNotifyHandler
		sourceUuid: p.primaryHumidityDevUuid
		serviceId: "HumiditySensor"
		initialPoll: true
		variables: ["CurrentHumidity"]
		onNotificationReceived : {
			var value;
			if ((value = message.getArgument("CurrentHumidity")))
				humidity = value;
		}
	}

	BxtNotifyHandler {
		id: vocInfoNotifyHandler
		sourceUuid: p.vocDevUuid
		serviceId: "vocSensor"
		initialPoll: true
		variables: ["eco2", "tvoc"]
		onNotificationReceived : {
			var value;
			if ((value = message.getArgument("eco2")))
				eco2 = value;
			else if ((value = message.getArgument("tvoc")))
				tvoc = value;
		}
	}

	function onThermostatInfoChanged(update) {
		var newTemperatureInfo = temperatureInfo;
		newTemperatureInfo.currentDisplayTemperature = parseInt(update.getChildText("currentDisplayTemp"));
		temperatureInfo = newTemperatureInfo;
	}

	function getTempDeviationInfo() {
		var getTempDeviationMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetTempOffset");
		bxtClient.doAsyncBxtRequest(getTempDeviationMessage, getTempDeviationInfoCallback, 5000);
	}

	function setTempCorrection(tempCorrection) {
		var newtemperatureInfo = temperatureInfo;
		newtemperatureInfo.tempDeviation = tempCorrection;
		temperatureInfo = newtemperatureInfo;

		var adjustTempOffsetMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "AdjustTempOffset");
		adjustTempOffsetMessage.addArgument("offset", tempCorrection);
		bxtClient.sendMsg(adjustTempOffsetMessage);
	}

	BxtDiscoveryHandler {
		id: thermostatDiscoHandler
		deviceType: "happ_thermstat"
		onDiscoReceived: {
			var featureTemperature = globals.heatingMode === "zone" || globals.heatingMode === "none";
			if (!featureTemperature)
				return;

			if (isHello && !p.temperatureTileRegistrationUuid) {
				p.temperatureTileRegistrationUuid = registry.registerWidget("tile", temperatureTileUrl, airQualityApp, null, {thumbLabel: qsTr("$(display)"), thumbIcon: Qt.resolvedUrl("drawables/temperature-thumb.svg"), thumbCategory: "temperature", thumbIconVAlignment: "center"});
				p.thermostatUuid = deviceUuid;
			} else if (!isHello && p.temperatureTileRegistrationUuid) {
				registry.deregisterWidget(p.temperatureTileRegistrationUuid);
				p.temperatureTileRegistrationUuid = "";
				p.thermostatUuid = "";
			}
		}
	}

	BxtDatasetHandler {
		id: thermstatInfoDsHandler
		dataset: "thermostatInfo"
		discoHandler: thermostatDiscoHandler
		onDatasetUpdate: onThermostatInfoChanged(update)
	}

	BxtRequestCallback {
		id: getTempDeviationInfoCallback
		onMessageReceived: {
			var newTemperatureInfo = temperatureInfo;
			newTemperatureInfo.tempDeviation = message.getArgument("offset");
			newTemperatureInfo.tempMeasured = message.getArgument("measuredTemp");
			temperatureInfo = newTemperatureInfo;
		}
	}
}
