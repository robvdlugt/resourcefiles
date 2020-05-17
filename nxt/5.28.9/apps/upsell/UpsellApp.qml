import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

App {
	id: upsellApp

	property url upsellTileUrl: "UpsellTileA.qml"
	property var upsellScreenUrls : ["UpsellGeneralScreen.qml", "UpsellFeaturesScreen.qml"]
	property url chosenScreenUrl

	QtObject {
		id: p
		property bool tilePlaced: true
		property string configUuid
		property url lockedMenuItem: "qrc:/qb/components/LockedMenuItem.qml"

		property url benchmarkMenuIconUrl: "qrc:/apps/benchmark/drawables/vergelijk_menu.svg"
		property url profileMenuIconUrl: "qrc:/apps/benchmark/drawables/profile_menu.svg"
		property url boilerMonitorMenuIconUrl: "qrc:/apps/boilerMonitor/drawables/app_icon.svg"
		property url controlPanelMenuIconUrl: "qrc:/apps/controlPanel/drawables/controlPanelClosed.svg"
		property url graphsMenuIconUrl: "qrc:/apps/graph/drawables/graphs.svg"
		property url smokeDetectorMenuIconUrl: "qrc:/apps/smokeDetector/drawables/smokedetector.svg"
		property url statusUsageMenuIconUrl: "qrc:/apps/statusUsage/drawables/menuIcon.svg"
		property url weatherMenuIconUrl: "qrc:/apps/weather/drawables/weather.svg"

		property url benchmarkUpsellScreenUrl: "BenchmarkUpsellScreen.qml"
		property url boilerMonitorUpsellScreenUrl: "BoilerMonitorUpsellScreen.qml"
		property url controlPanelUpsellScreenUrl: "ControlPanelUpsellScreen.qml"
		property url graphsUpsellScreenUrl: "GraphsUpsellScreen.qml"
		property url smokeDetectorUpsellScreenUrl: "SmokeDetectorUpsellScreen.qml"
		property url statusUsageUpsellScreenUrl: "StatusUsageUpsellScreen.qml"
		property url weatherUpsellScreenUrl: "WeatherUpsellScreen.qml"
	}

	function init() {
		var chosenScreenIndex = Qt.md5(bxtClient.getCommonname()).charCodeAt(7) % upsellScreenUrls.length;
		chosenScreenUrl = Qt.resolvedUrl(upsellScreenUrls[chosenScreenIndex]);

		registry.registerWidget("tile", upsellTileUrl, upsellApp, null, {thumbLabel: qsTr("Subscription"), thumbIcon: Qt.resolvedUrl("drawables/upsell-tile-thumb.svg"), thumbCategory: "general", thumbWeight: 70, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", chosenScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, upsellApp, null, {objectName: "upsellMenuItem", label: qsTr("Subscription"), image: Qt.resolvedUrl("drawables/upsell-menu.svg"), screenUrl: chosenScreenUrl, weight: 900});

		// Upsell featured apps
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "graphMenuItem", label: qsTr("Graphs"), image: p.graphsMenuIconUrl, screenUrl: p.graphsUpsellScreenUrl, weight: 940});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "statusUsageMenuItem", label: qsTr("Status usage"), image: p.statusUsageMenuIconUrl, weight: 950, screenUrl: p.statusUsageUpsellScreenUrl});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "benchmarkMenuItem", label: qsTr("Benchmark"), image: p.benchmarkMenuIconUrl, screenUrl: p.benchmarkUpsellScreenUrl, weight: 970});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "boilerMonitorMenuItem", label: qsTr("Boiler Monitor"), image: p.boilerMonitorMenuIconUrl, screenUrl: p.boilerMonitorUpsellScreenUrl, weight: 990});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "controlPanelMenuItem", label: qsTr("Control Panel"), image: p.controlPanelMenuIconUrl, screenUrl: p.controlPanelUpsellScreenUrl, weight: 1000});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "weatherMenuItem", label: qsTr("Weather"), image: p.weatherMenuIconUrl, screenUrl: p.weatherUpsellScreenUrl, weight: 1010});
		registry.registerWidget("menuItem", p.lockedMenuItem, upsellApp, null, {objectName: "smokeMenuItem", label: qsTr("Smoke detector"), image: p.smokeDetectorMenuIconUrl, screenUrl: p.smokeDetectorUpsellScreenUrl, weight: 1040});

		registry.registerWidget("screen", p.benchmarkUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.boilerMonitorUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.controlPanelUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.graphsUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.smokeDetectorUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.statusUsageUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.weatherUpsellScreenUrl, upsellApp, null, {lazyLoadScreen: true});

		dependencyResolver.addDependencyTo("UpsellApp.addTile", "Homescreen.loadTiles");
		dependencyResolver.addDependencyTo("UpsellApp.addTile", "UpsellApp.config");
		dependencyResolver.getDependantSignals("UpsellApp.addTile").resolved.connect(addTile);
	}

	function getAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "upsellApp");

		bxtClient.doAsyncBxtRequest(msg, getConfigCallback, 30);
	}

	function saveAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("upsellApp", null, 0);
		node.addChild("package", "qt-gui", 0);
		node.addChild("internalAddress", "upsellApp", 0);

		node.addChild("tilePlaced", (p.tilePlaced ? "true" : "false"), 0);

		// If there are more configuration parameters that we need to save, add them here

		bxtClient.sendMsg(msg);
	}

	function addTile() {
		if (!p.tilePlaced) {
			var homescreenApp = canvas.getAppInstance("homescreen");
			if (homescreenApp) {
				var tileWidgetInfo = registry.getWidgetInfo("tile", upsellTileUrl);
				homescreenApp.homeScreen.insertTileAtPosition(tileWidgetInfo, 0, 1);
				p.tilePlaced = true;
				saveAppConfig();
			}
		}
	}

	// 0: config
	initVarCount: 1

	BxtDiscoveryHandler {
		id: hcbconfigDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.configUuid = deviceUuid;
			getAppConfig();
		}
	}

	BxtRequestCallback {
		id: getConfigCallback
		onMessageReceived: {
			var configNode = message.getArgumentXml("Config").getChild("upsellApp");
			if (configNode) {
				p.tilePlaced = (configNode.getChildText("tilePlaced") === "true");
			} else {
				p.tilePlaced = false;
			}
			dependencyResolver.setDependencyDone("UpsellApp.config");
			initVarDone(0);
		}
	}
}
