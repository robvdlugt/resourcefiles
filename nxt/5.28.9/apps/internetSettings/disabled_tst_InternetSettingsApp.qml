import QtQuick 2.0
import QtTest 1.0

import BxtClient 1.0
import BxtTestbench 1.0

import QtTest 1.0
import FileIO 1.0

import apps.internetSettings 1.0
import qb.test 1.0

QbTestCase {
	name: "InternetSettingsApp"

	InternetSettingsApp {
		id: tst_internetSettingApp

		property url urlCategory: internetFrameUrl
	}

	BxtTestBench {
		id: benchInternetSettings
		property BxtMessage receivedMessage;
		onMessage: {
			receivedMessage = message;
		}
	}

	FileIO {
		id: discoMessage
		source: "tst_disco_netcon.xml"
		onError: console.log(msg)
	}

	FileIO {
		id: file_wirelessNetworksResponse
		source: "tst_wirelessNetworksResponse.xml"
		onError: console.log(msg.stringContent)
	}

	function notifyInetStatemachine(val) {
		benchInternetSettings.injectMessageText("<notify uuid=\"parent-UUID\" serviceid=\"status\"><statemachine>" + val + "</statemachine></notify>");
	}


	function notifyWifi(val) {
		benchInternetSettings.injectMessageText("<notify uuid=\"parent-UUID\" serviceid=\"WifiInformation\"><WifiStatus>" + val + "</WifiStatus></notify>");
	}

	function test_a_TestGeneralFunctions() {
		benchInternetSettings.injectMessageText(discoMessage.read());

		compare (tst_internetSettingApp.privs.hcb_netconUuid, "parent-UUID");

		notifyInetStatemachine(1);
		compare (tst_internetSettingApp.smStatus, 1);
		notifyInetStatemachine(5);
		compare (tst_internetSettingApp.smStatus, 5);


		// Test the wifiState
		notifyWifi("Searching");
		compare (tst_internetSettingApp.wifiState, "Searching");
		notifyWifi("Connecting");
		compare (tst_internetSettingApp.wifiState, "Connecting");
		notifyWifi("Authenticating");
		compare (tst_internetSettingApp.wifiState, "Authenticating");
		notifyWifi("Connected");
		compare (tst_internetSettingApp.wifiState, "Connected");
		notifyWifi("Configuring");
		compare (tst_internetSettingApp.wifiState, "Configuring");

		// Set the netcon statemachines to default
		notifyInetStatemachine(1);
		notifyWifi("Disabled");
	}

	function test_b_connectToWifiSucces() {
		// Simulate connect to wifi
		notifyWifi("Configuring");
		compare (tst_internetSettingApp.internetStatusText, "Connecting");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_CONNECTING);
		notifyWifi("Connected");
		notifyInetStatemachine(4);
		compare (tst_internetSettingApp.internetStatusText, "Connected with internet");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_CONNECTED);
		notifyInetStatemachine(5);
		compare (tst_internetSettingApp.internetStatusText, "Connected with service center");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_CONNECTED);

		// Simulate connect to eth0
		notifyInetStatemachine(1);
		notifyWifi("Disabled");
		compare (tst_internetSettingApp.internetStatusText, "Not connected");
		notifyInetStatemachine(5);
		compare (tst_internetSettingApp.internetStatusText, "Connected with service center");
	}

	function test_c_connectToWifiFail() {
		// Simulate connect to wifi
		notifyWifi("Configuring");
		compare (tst_internetSettingApp.internetStatusText, "Connecting");
		notifyWifi("Authentication failed");
		notifyInetStatemachine(3);
		compare (tst_internetSettingApp.internetStatusText, "Wifi pass incorrect");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_FAIL_PASS);
		notifyInetStatemachine(2);
		compare (tst_internetSettingApp.internetStatusText, "Wifi pass incorrect");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_FAIL_PASS);
		notifyInetStatemachine(1);
		compare (tst_internetSettingApp.internetStatusText, "Wifi pass incorrect");
		compare (tst_internetSettingApp.wifiStatus, tst_internetSettingApp._CS_FAIL_PASS);
	}

	function test_d_setLocalAccess() {
		tst_internetSettingApp.setLocalAccessState(true);
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.getArgument("name"), "netbios");
		compare(msg.destination, "parent-UUID");
		compare(msg.name, "ServiceEnable");
	}

	function test_e_setMobileAccessState() {
		discoMessage.source = "tst_disco_scsync.xml";
		benchInternetSettings.injectMessageText(discoMessage.read());
		tst_internetSettingApp.setMobileAccessState(true);
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.getArgument("mobileAccess"), "true");
		compare(msg.destination, "scsync-UUID");
		compare(msg.name, "setMobileAccessState");
	}

	function test_f_setResearchEnabledState() {
		tst_internetSettingApp.setResearchEnabledState(true);
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.getArgument("researchEnabled"), "true");
		compare(msg.destination, "scsync-UUID");
		compare(msg.name, "setResearchState");
	}

	function test_g_getLocalAccess() {
		tst_internetSettingApp.requestLocalAccessState();
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.getArgument("name"), "http");
		compare(msg.destination, "parent-UUID");
		compare(msg.name, "CheckServiceEnable");

		tst_internetSettingApp.localAccessEnabled = true;
		var resp = msg.createResponse();
		resp.addArgument("enabled", "false");
		benchInternetSettings.injectMessage(resp);
		compare(tst_internetSettingApp.localAccessEnabled, false);
	}

	function test_h_requestMobileAccessState() {
		tst_internetSettingApp.requestMobileAccessState();
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.destination, "scsync-UUID");
		compare(msg.name, "getMobileAccessState");

		tst_internetSettingApp.mobileAccessEnabled = true;
		var resp = msg.createResponse();
		resp.addArgument("mobileAccess", "false");
		benchInternetSettings.injectMessage(resp);
		compare(tst_internetSettingApp.mobileAccessEnabled, false);
	}

	function test_i_requestResearchState() {
		tst_internetSettingApp.requestResearchState();
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.destination, "scsync-UUID");
		compare(msg.name, "getResearchState");

		tst_internetSettingApp.researchParticipationEnabled = true;
		var resp = msg.createResponse();
		resp.addArgument("researchEnabled", "false");
		benchInternetSettings.injectMessage(resp);
		compare(tst_internetSettingApp.researchParticipationEnabled, false);
	}

	function test_j_fillWifiList() {
		tst_internetSettingApp.getWifiNetworkList();
		var msg = benchInternetSettings.receivedMessage;

		compare(msg.destination, "parent-UUID");
		compare(msg.name, "GetWirelessNetworks");

		benchInternetSettings.injectMessageText(file_wirelessNetworksResponse.read());

		//Check if the wifiList is stored and sorted
		compare(tst_internetSettingApp.wifiList[0].Essid, "QubyLabsDemo");
		compare(tst_internetSettingApp.wifiList[1].Essid, "Quby network high signal");
		compare(tst_internetSettingApp.wifiList[2].Essid, "Quby network 6");
		compare(tst_internetSettingApp.wifiList[3].Essid, "Quby");
		compare(tst_internetSettingApp.wifiList[4].Essid, "Quby test network");
		compare(tst_internetSettingApp.wifiList[5].Essid, "Quby network low signal");

		// Check the rest of the stored parameters of an wifi network
		compare(tst_internetSettingApp.wifiList[4].Mac, "02:04:6F:CD:BF:9C");
		compare(tst_internetSettingApp.wifiList[4].Quality, 26);
		compare(tst_internetSettingApp.wifiList[4].Essid, "Quby test network");
		compare(tst_internetSettingApp.wifiList[4].EncryptionKey, "on");
		compare(tst_internetSettingApp.wifiList[4].Enc, "autodetect");
		compare(tst_internetSettingApp.wifiList[4].Auth, "WPA2-PSK");
	}
}
