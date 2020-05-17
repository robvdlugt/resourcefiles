import QtQuick 2.1
import BxtClient 1.0

import qb.base 1.0
import qb.components 1.0

App {
	id: heatRecoveryApp

	property url heatRecoveryScreenUrl: "HeatRecoveryScreen.qml"
	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"

	property variant heatRecoveryInfo: {
		'CurrentState': 0,
		'BlockingState': 0,
		'CurrentFaultcode': 0,
		'CurrentDiagnosticCode': 0,
		'IsConnected': 1,
		'TargetVentilationLevel': 1,
		'NominalVentilationValue': 50,
		'deviceCreatedTime': Date.now() / 1000
	}

	property variant heatRecoveryUsageInfo: {
		'CurrentElectricityQuantity': 0,
		'CurrentEnergyQuantity': 0,
		'ActiveElectricityHours': 0,
		'ActiveGasHours': 0,
		'gasEquivalentCurrentEnergyQuantity': 0,
		'currentEstimatedSavings': 0
	}

	property bool hasDevice: false

	// 0 = heatRecoveryInfo, 1 = heatRecoveryUsageInfo
	initVarCount: 2

	function init() {
		registry.registerWidget("screen", heatRecoveryScreenUrl, heatRecoveryApp, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, heatRecoveryApp, null, {objectName: "heatRecoveryMenuItem", label: qsTr("HeatWinner"), image: p.menuIconUrl, screenUrl: heatRecoveryScreenUrl, weight: 105});
		registry.registerWidget("tile", p.heatProfitTileUrl, heatRecoveryApp, null, {thumbLabel: qsTr("Total"), thumbIcon: p.heatProfitThumbnailUrl, thumbCategory: "heatRecovery", thumbWeight: 120, thumbIconVAlignment: "center"});
	}

	function getCurrentEnergyQuantityString() {
		var amount = heatRecoveryUsageInfo["CurrentEnergyQuantity"];
		if (amount < 1000)
			return amount + " MJ";
		else
			return i18n.number(amount / 1000, 3) + " GJ";
	}

	QtObject {
		id: p

		property url menuIconUrl: "drawables/heatrec_device.svg"
		property url heatProfitTileUrl: "HeatProfitTile.qml"
		property url heatProfitThumbnailUrl: "drawables/heatrec_tile.svg"

		property string rrdUuid

		function parseHeatRecoveryDataset(node, dataset) {
			var tempNode = node.child;
			if (tempNode) {
				var tempInfo = heatRecoveryApp[dataset];
				while (tempNode) {
					tempInfo[tempNode.name] = parseFloat(tempNode.text);
					tempNode = tempNode.sibling;
				}
				heatRecoveryApp[dataset] = tempInfo;
				if (dataset === "heatRecoveryInfo")
					hasDevice = true;
			} else {
				if (dataset === "heatRecoveryInfo")
					hasDevice = false;
			}
		}
	}

	BxtDiscoveryHandler {
		id: thermstatDiscoHandler
		deviceType: "happ_thermstat"
	}

	BxtDatasetHandler {
		id: heatRecoveryInfoDataset
		dataset: "heatRecoveryInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: {
			p.parseHeatRecoveryDataset(update, dataset);
			initVarDone(0);
		}
	}

	BxtDatasetHandler {
		id: heatRecoveryUsageInfoDataset
		dataset: "heatRecoveryUsageInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: {
			p.parseHeatRecoveryDataset(update, dataset);
			initVarDone(1);
		}
	}

	BxtDiscoveryHandler {
		id: rrdDiscoHandler
		deviceType: "hcb_rrd"
		onDiscoReceived: {
			p.rrdUuid = deviceUuid;
		}
	}
}
