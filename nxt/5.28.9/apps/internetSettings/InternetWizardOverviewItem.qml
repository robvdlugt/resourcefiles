import QtQuick 2.1

import qb.components 1.0

InstallWizardOverviewItem {
	id: internetWizardOverviewItem

	property InternetSettingsApp myApp: null

	property string kpiPrefix: "InternetWizardOverviewItem."

	mainColor: "#69AAD7"
	secondaryColor: "#82B6DC"
	title: qsTr("Internet")
	extra: qsTr("Connect to WiFi...")
	wizardUrl: app.wifiSettingScreenUrl

	secondary: qsTr("Service Center Activation")
	secondaryWizardUrl: app.activationScreenUrl
	secondaryButtonText: qsTr("Activate")

	primaryIconVisible: primaryCompleted
	secondaryContainerVisible: primaryCompleted
	secondaryIconVisible: secondaryCompleted

	// Still using ST_TUNNEL here, because activation depends on VPN.
	secondaryButtonVisible: myApp !== null && myApp.smStatus >= myApp._ST_TUNNEL && ! secondaryCompleted

	detailsList: []
	primaryFeature: "internet"
	secondaryFeature: "activation"

	Connections {
		target: wizardstate
		onStageCompletedChanged: {
			updateWifiState();
			updateDetailsList();
		}
	}

	onBeforePrimaryWizardOpened: {
		// The WifiSettingScreen should automatically start refreshing the wifi list
		myApp.refreshWifiList = true
	}


	function updateWifiState() {
		if (primaryCompleted !== wizardstate.stageCompleted("internet")) {
			primaryCompleted = wizardstate.stageCompleted("internet");
		}
		if (primaryCompleted && extra !== "") {
			buttonText = qsTr("Change");
			extra = ""
		} else if (! primaryCompleted && extra === "") {
			buttonText = qsTr("Start");
			extra = qsTr("Connect to WiFi...");
		}

		if (secondaryCompleted !== wizardstate.stageCompleted("activation")) {
			secondaryCompleted = wizardstate.stageCompleted("activation")
		}
	}

	Connections {
		target: myApp
		onWifiNetworkNameChanged: {
			updateWifiState();
			updateDetailsList();
		}

		onInternetStatusTextChanged: {
			updateWifiState();
			updateDetailsList();
		}

		onSmStatusChanged: {
			updateWifiState();
			updateDetailsList();
		}
	}

	function updateDetailsList() {
		var newWifiNetworkName;
		if (myApp.smStatus >= myApp._ST_INTERNET && myApp.wifiNetworkName === "") {
			newWifiNetworkName = myApp.activeInterface; // usually "eth0"
		} else if (myApp.wifiNetworkName === ""){
			newWifiNetworkName = qsTr("(not connected)");
		} else {
			newWifiNetworkName = myApp.wifiNetworkName;
		}

		detailsList = [  [qsTr("Wifi network"), newWifiNetworkName]
						,[qsTr("Status"), myApp.internetStatusText]
					  ];
	}

	onAppChanged: {
		console.log("App.objectName:", app.objectName)
		if (app.objectName === "InternetSettingsApp") {
			myApp = app;
			myApp.checkInetStatus();
		}
	}

	Timer {
		running: true
		// Run once to populate initial details. Afterwards, the details will be updated by the Connections to the InternetSettingsApp.
		repeat: false
		interval: 1000 //msec
		onTriggered: {
			updateWifiState();
			updateDetailsList();
		}
	}
}
