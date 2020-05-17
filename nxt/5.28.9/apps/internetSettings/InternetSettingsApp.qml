import QtQuick 2.1
import BxtClient 1.0
import ScreenStateController 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: internetSettingsApp
	objectName: "InternetSettingsApp"
	// Public properties
	property url wifiSettingScreenUrl: "WifiSettingScreen.qml"
	property url localAccessScreenUrl: "LocalAccessScreen.qml"
	property url mobileAccessScreenUrl: "MobileAccessScreen.qml"
	property url researchParticipationScreenUrl: "ResearchParticipationScreen.qml"
	property url dataExportScreenUrl: "DataExportScreen.qml"
	property url overviewInternetScreenUrl: "OverviewInternetScreen.qml"
	property url networkScreenUrl: "NetworkScreen.qml"
	property url securityScreenUrl: "SecurityScreen.qml"

	property url activationScreenUrl: "ActivationScreen.qml"

	property url enterActivationCodeFrameUrl:  "EnterActivationCodeFrame.qml"
	property url getRegistrationInfoFrameUrl:  "GetRegistrationInfoFrame.qml"
	property url confirmActivationFrameUrl:	"ConfirmActivationFrame.qml"
	property url sendActivationCodeFrameUrl:   "SendActivationCodeFrame.qml"
	property url incorrectDataFrameUrl:		"IncorrectDataFrame.qml"
	property url activationCompletedFrameUrl:  "ActivationCompletedFrame.qml"

	property url internetFrameUrl: "InternetFrame.qml"

	property int _ST_NOMEDIA: 1
	property int _ST_CONNECTED: 2
	property int _ST_CONFIGURED: 3
	property int _ST_INTERNET: 4
	property int _ST_TUNNEL: 5

	property int _CS_CONNECTING: 0
	property int _CS_CONNECTED: 1
	property int _CS_FAIL_PASS: 2
	property int _CS_FAIL_TIMEOUT: 3
	property int _CS_UNKNOWN: 4

	property int _AC_NO_ERROR: 0
	property int _AC_INVALID_CODE: 1
	property int _AC_CONNECTION_LOST: 2
	property int _AC_REGISTER_FAILED: 3
	property int _AC_FAILED_UNKNOWN_REASON: 4
	property int _AC_TIMEOUT_UNKNOWN_REASON: 5

	property variant dataExportInfo: ({state: "IDLE"})

	property variant activationInfo: {
		 "activationCode": ""
		,"errorCode": _AC_NO_ERROR
		,"errorReason": ""
		,"firstName": ""
		,"insert": ""
		,"lastName": ""
		,"streetName": ""
		,"houseNumber": ""
		,"houseNumberExtension": ""
		,"zipCode": ""
		,"city": ""
		,"productVariant": ""
	}
	// When opening the ActivationScreen, continue immediately to the specified page.
	property int activationNextPage: 0

	property int smStatus : 0
	property int wifiStatus : _CS_UNKNOWN
	property string wifiState : ""
	property bool upstreamConnectedState : false
	property int errors : 0
	property int systrayErrors: 0

	property string internetStatusText : ""

	// Active interfaceInfoReceived:
	property string activeInterface : ""

	// Wifi info
	property string wifiNetworkName : ""
	property int wifiLinkQuality: 0
	property string wlanIpAddress : ""
	property string wlanMacAddress : ""
	property variant wifiList : []

	property bool refreshWifiList : false
	property string connectingNetworkMac
	property string connectingNetworkAuth

	// Hidden network info
	property string hiddenNetworkEssid: ""
	property int hiddenNetworkAuth: -1
	property variant securityTypes: ['WEP', 'WPA', 'WPA2']

	// Enabled flags
	property bool localAccessEnabled : false
	property bool mobileAccessEnabled : false
	property bool researchParticipationEnabled : false

	// Public signals
	signal wifiNetworkListUpdated();

	property alias scsyncUuid: p.scsyncUuid

	// Private properties
	QtObject {
		id: p

		property url internetSystrayUrl: "InternetSystray.qml"
		property url internetOverviewButtonUrl: "InternetOverviewButton.qml"
		property url internetWizardOverviewItemUrl: "InternetWizardOverviewItem.qml"

		property string scsyncUuid
		property string hcb_netconUuid
		property string configMsgUuid
	}

	function init() {
		// We need to check if there is an update available after activation so subscribe to changes
		if (isWizardMode) {
			if (globals.productOptions.activated === 1) {
				wizardstate.setStageCompleted("activation", 1);
				console.debug("We already were activated! Checking if there is an update available so we can start downloading");
				checkFirmwareUpdateStatus();
			} else {
				globals.productOptionsChanged.connect(productOptionsChangedHandler);
			}
		}

		registry.registerWidget("settingsFrame", internetFrameUrl, internetSettingsApp, "internetFrame", {categoryName: qsTr("Internet"), categoryWeight: 400});
		registry.registerWidget("screen", overviewInternetScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("statusButton", p.internetOverviewButtonUrl, internetSettingsApp, null, {weight: 30});
		registry.registerWidget("screen", wifiSettingScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("systrayIcon", p.internetSystrayUrl, internetSettingsApp);

		registry.registerWidget("screen", localAccessScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", mobileAccessScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", researchParticipationScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", dataExportScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("screen", securityScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", networkScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});

		registry.registerWidget("screen", activationScreenUrl, internetSettingsApp, null, {lazyLoadScreen: true});

		if (isWizardMode)
			registry.registerWidget("installationWizardOverviewItem", p.internetWizardOverviewItemUrl, internetSettingsApp, null, {weight: 10});

		notifications.registerSubtype("error", "network", overviewInternetScreenUrl, {});
		notifications.registerType("data-export", notifications.prio_NORMAL, Qt.resolvedUrl("drawables/notification-data-export.svg"),
								   dataExportScreenUrl, {}, "");
		notifications.registerSubtype("data-export", "ready", dataExportScreenUrl, {});
		notifications.registerSubtype("data-export", "error", dataExportScreenUrl, {});
	}

	function checkInetStatus() {
		// Request the interface details of the eth0 interface
		getIfaceInfo("eth0");

		// Request the interface details of the wlan0 interface
		getIfaceInfo("wlan0");

		// Resend all notifies
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "specific1", "reSendAllNotifies");
		bxtClient.sendMsg(msg);
	}

	function setServiceState(service, newState) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "specific1", newState ? "ServiceEnable" : "ServiceDisable");
		msg.addArgument("name", service);
		bxtClient.sendMsg(msg);
	}

	function setLocalAccessState(newState) {
		if (newState !== localAccessEnabled) {
			setServiceState("http", newState);
			setServiceState("netbios", newState);
			localAccessEnabled = newState;
		}
	 }

	function requestLocalAccessState() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "specific1", "CheckServiceEnable");
		msg.addArgument("name", "http");
		bxtClient.sendMsg(msg);
	}

	function setMobileAccessState(newState) {
		if (newState !== mobileAccessEnabled) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "setMobileAccessState");
			msg.addArgument("mobileAccess", newState);
			bxtClient.sendMsg(msg);
			mobileAccessEnabled = newState;
		}
	 }

	function requestMobileAccessState() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "getMobileAccessState");
		bxtClient.sendMsg(msg);
	}

	function setResearchEnabledState(newState) {
		if (newState !== researchParticipationEnabled) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "setResearchState");
			msg.addArgument("researchEnabled", newState);
			bxtClient.sendMsg(msg);
			researchParticipationEnabled = newState;
		}
	 }

	function requestResearchState() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "getResearchState");
		bxtClient.sendMsg(msg);
	}

	function getWifiNetworkList() {
		// Request the new wifi networks
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "NetworkInformation", "GetWirelessNetworks");
		bxtClient.sendMsg(msg);
	}

	// Function requests the interface details of the the given interface
	function getIfaceInfo(iface) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "NetworkInformation", "GetInterfaceInfo");
		msg.addArgument("iface", iface);
		bxtClient.sendMsg(msg);
	}

	function getWirelessNetworkInformation() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "NetworkInformation", "GetWirelessNetworkInformation");
		bxtClient.sendMsg(msg);
	}

	// Function is called when a GetInterfaceInfoResponse is received
	function interfaceInfoReceived(msg) {
		if ( msg ) {
			var node = msg.getArgumentXml("interfaceInfo")
			if ( node ) {
				var iface = node.getChildText("iface");
				if ( iface === "wlan0" && activeInterface === "wlan0") {
					wlanMacAddress = node.getChildText("macaddress");
					wlanIpAddress = node.getChildText("ipaddress");
					wifiNetworkName = node.getChildText("essid");
					// When the enc node is set to UNUSED the hiddenNetwork is active
					if (node.getChildText("enc") === "UNUSED") {
						hiddenNetworkEssid = wifiNetworkName;
					}
				} else if (iface !== "wlan0" && activeInterface === "eth0") {
					wlanMacAddress = node.getChildText("macaddress");
					wlanIpAddress = node.getChildText("ipaddress");
					// Clear the new wifi info. No wifiNetwork highlighted in the wifiListView
					connectingNetworkAuth = "";
					connectingNetworkMac = "";
					wifiNetworkName = "";
					hiddenNetworkEssid = "";
					wifiStatus = _CS_UNKNOWN;
				}
			}
		}
	}

	// Function translates the received network list in xml to a sorted network list array
	function wifiNetworkListReceived(msg) {
		var messageNode = msg.getArgumentXml("WirelessNetworks").getChild("WirelessNetwork");
		if (messageNode) {
			var networks = [];
			// Store the individual networks in a Array to be able to sort them
			for (; messageNode; messageNode = messageNode.next) {
				var network = {};
				network.Mac = messageNode.getChildText("Address");
				network.Quality = parseInt(messageNode.getChildText("Quality").split("/")[0]);
				network.Essid = messageNode.getChildText("ESSID");
				network.EncryptionKey = messageNode.getChildText("EncryptionKey");
				network.Enc = messageNode.getChildText("Enc");
				network.Auth = messageNode.getChildText("Auth");

				networks.push(network);
			}
			// Sort the individual networks. The strongest signal on top
			networks.sort(function (a, b) {return b.Quality - a.Quality;});

			// Store the  sorted wifiList in the app
			wifiList = networks;

			wifiNetworkListUpdated();
		}
	}

	// Function sets the wifi information to connect to a new wifi network
	function connectToWifi(networkInfo) {
		if (typeof networkInfo !== "object" || (!networkInfo.essid && !networkInfo.enc && !networkInfo.auth))
			return;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcb_netconUuid, "NetworkInformation", "SetWirelessNetworkInformation");
		msg.addArgument("type", "dhcp");
		msg.addArgument("iface", "wlan0");
		msg.addArgument("essid", networkInfo.essid);
		msg.addArgument("enc", networkInfo.enc);
		msg.addArgument("auth", networkInfo.auth);

		if (networkInfo.mac)
			msg.addArgument("bssid", networkInfo.mac);
		if ( networkInfo.auth !== "OPEN" )
			msg.addArgument("key", networkInfo.password);

		bxtClient.sendMsg(msg);

		wifiStatus = _CS_CONNECTING;
		wifiNetworkName = networkInfo.essid;
		connectingNetworkMac = networkInfo.mac ? networkInfo.mac : "";
		connectingNetworkAuth = networkInfo.auth;
		determineInetStatus();

		wifiConnectTimeout.restart();
	}

	function getWifiIconState() {
		if (wifiStatus === _CS_CONNECTING || (smStatus < _ST_INTERNET && wifiStatus < _CS_FAIL_PASS)) {
			return "CONNECTING";
		} else if (wifiStatus === _CS_FAIL_PASS || wifiStatus === _CS_FAIL_TIMEOUT) {
			return "CONNECTION_ERROR";
		} else if (smStatus >= _ST_INTERNET && wifiStatus === _CS_CONNECTED) {
			return"CONNECTED";
		} else {
			return "DEFAULT";
		}
	}

	/**
	 *	@brief	Function is responsible for the determination  of the Internet status text
	 *			Function is called when the netcon statemachine changes of state
	 *			or when the WifiInformation changes in "Configuring", "Authentication failed" or "Connecting"
	 *
	 *			When the Toon is connected with Wifi this states are leading
	 *
	 *	@remark	In the statusNotifyHandler wifiState is also set to connected when the netcon statemachine state
	 *			is greater the _ST_INTERNET. This will indicated that wifi must be connected.
	 *			When this is removed the switching from a wifi network with a faulty pass to a wifi network with a correct pass
	 *			will cause that the wifiState stays in Configuring. Probably a hcb_netcon bug.
	 */
	function determineInetStatus() {
		console.log("[InternetSettingsApp] State change: wifiState = " + wifiState + wifiStatus +				// Very handy for debugging inet stuff
														" smStatus = " + smStatus +
														" activeInterface = " + activeInterface +
														" upstreamConnectedState = " + upstreamConnectedState);

		if ( wifiStatus == _CS_CONNECTING )
			internetStatusText = qsTr("Connecting");
		else if ( wifiStatus == _CS_FAIL_PASS )
			internetStatusText = qsTr("Wifi pass incorrect");
		else if ( wifiStatus == _CS_FAIL_TIMEOUT )
			internetStatusText = qsTr("Not connected");
		else if ( wifiStatus == _CS_CONNECTED && smStatus < _ST_INTERNET )
			internetStatusText = qsTr("Connecting");

		else if ( smStatus < _ST_CONFIGURED )
			internetStatusText = qsTr("Not connected");
		else if ( smStatus < _ST_INTERNET )
			internetStatusText = qsTr("Connecting");
		else if ( ! upstreamConnectedState )
			internetStatusText = qsTr("Connected with internet");
		else
			internetStatusText = qsTr("Connected with service center");

		globals.setServiceCenterAvailable(upstreamConnectedState);
	}

	function productOptionsChangedHandler() {
		if (globals.productOptions.activated === 1) {
			wizardstate.setStageCompleted("activation", 1);
			globals.productOptionsChanged.disconnect(productOptionsChangedHandler);
			console.debug("We just activated! Checking if there is an update available so we can start downloading");
			checkFirmwareUpdateStatus();
		}
	}

	function checkFirmwareUpdateStatus() {
		console.log("Sending request for firmware update status")
		var checkFirmwareUpdateMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "CheckFirmwareUpdate");
		bxtClient.sendMsg(checkFirmwareUpdateMessage);
	}

	function createDataArchive() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "CreateDataArchive");

		function createDataArchiveCB(response) {
			var dataExport = dataExportInfo;
			if (!response) {
				dataExport.state = "ERROR";
				dataExportInfo = dataExport;
				return;
			}

			var success = response.getArgument("success");
			if (success === "true") {
				dataExport.state = "READY";
				dataExport.archiveUrl = response.getArgument("archiveUrl");
				dataExport.archiveAltUrl = response.getArgument("archiveAltUrl");
				var accessTimeoutStr = response.getArgument("accessTimeout");
				if (accessTimeoutStr)
					dataExport.accessTimeoutDate = new Date(parseInt(accessTimeoutStr) * 1000);
			} else {
				dataExport.state = "ERROR";
			}
			dataExportInfo = dataExport;
		}

		// timeout is 5 minutes * 3 drivers currently exporting data + 60 secs slack
		bxtClient.doAsyncBxtRequest(msg, createDataArchiveCB, 960);
		var dataExport = dataExportInfo;
		dataExport.state = "IN_PROGRESS";
		dataExportInfo = dataExport;
	}

	// 0=statemachine
	// 1=upstreamConnectionState
	initVarCount: 2

	BxtDiscoveryHandler {
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		deviceType: "hcb_netcon"
		onDiscoReceived: {
			p.hcb_netconUuid = statusNotifyHandler.sourceUuid = gwifNotifyHandler.sourceUuid = wifiInfoNotifyHandler.sourceUuid = deviceUuid;
			checkInetStatus();
		}
	}

	BxtDiscoveryHandler {
		deviceType: "UpstreamConnection"
		onDiscoReceived: {
			upstreamConnectionHandler.sourceUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		deviceType: "hcb_config"

		onDiscoReceived: {
			p.configMsgUuid = deviceUuid;
		}
	}

	BxtNotifyHandler {
		id: statusNotifyHandler
		serviceId: "status"
		onNotificationReceived : {
			var statemachine = message.getArgument("statemachine");
			if (statemachine) {
				var prevSmStatus = smStatus;
				smStatus = parseInt(statemachine);

				// When the state is bigger than previous state the internet connection is recovering. Stop the timeout timer
				if (smStatus > prevSmStatus && smStatus >= _ST_INTERNET) {
					wifiConnectTimeout.stop();

					// hcb_netcon bug? See, flash "if we have internet but connect state isn't connected set to connected"
					wifiStatus = _CS_CONNECTED;

					// Get the wireless network information
					getWirelessNetworkInformation();
					wifiLinkQualityTimer.restart();
				}

				// Determine the new status text for the InternetFrame
				determineInetStatus();
				initVarDone(0);
			}
		}
	}

	BxtNotifyHandler {
		id: upstreamConnectionHandler
		serviceId: "ConnectedState"
		initialPoll: true
		variables: [ "IsConnected" ]
		onNotificationReceived: {
			var isConnected = message.getArgument("IsConnected");
			if (typeof(isConnected) === "undefined")
				return;
			upstreamConnectedState = (isConnected === "1");

			// Set the internet error that is used by the Internet status button
			if (upstreamConnectedState)
				errors = 0;
			else
				errors = 1;

			// Determine the new status text for the InternetFrame
			determineInetStatus();
			initVarDone(1);
		}
	}

	BxtNotifyHandler {
		id: gwifNotifyHandler
		serviceId: "gwif"
		onNotificationReceived : {
			var newIface = message.getArgument("iface");
			if ( newIface && newIface != activeInterface ) {
				activeInterface = newIface;

				// Request the interface details of the new iface
				getIfaceInfo(activeInterface);
			}
			var newIpAddress = message.getArgument("ipaddress");
			if (newIpAddress && newIpAddress !== wlanIpAddress) {
				wlanIpAddress = newIpAddress;
			}
		}
	}

	BxtNotifyHandler {
		id: wifiInfoNotifyHandler
		serviceId: "WifiInformation"
		onNotificationReceived : {
			var status = message.getArgument("WifiStatus");
			if (status) {
				wifiState = status;

				if ( wifiState == "Configuring" || wifiState == "Authentication failed" || wifiState == "Connected" || wifiState == "Disabled" ) {

					if ( wifiState == "Configuring" ) {
						wifiStatus = _CS_CONNECTING;
					} else if ( wifiState == "Authentication failed" ) {
						wifiStatus = _CS_FAIL_PASS;
						wifiConnectTimeout.stop();
					} else if ( wifiState == "Connected" ) {
						wifiStatus = _CS_CONNECTED;
					} else if ( wifiState == "Disabled" ) {
						wifiStatus = _CS_UNKNOWN;
					}

					// Determine the new status text
					determineInetStatus();
				}
			}
		}
	}

	BxtResponseHandler {
		response: "CheckServiceEnableResponse"
		serviceId: "specific1"
		onResponseReceived: localAccessEnabled = message.getArgument("enabled") === "true" ? true : false;
	}

	BxtResponseHandler {
		response: "getMobileAccessStateResponse"
		serviceId: "specific1"
		onResponseReceived: mobileAccessEnabled = message.getArgument("mobileAccess") === "true" ? true : false;
	}

	BxtResponseHandler {
		response: "getResearchStateResponse"
		serviceId: "specific1"
		onResponseReceived: researchParticipationEnabled = message.getArgument("researchEnabled") === "true" ? true : false;
	}

	BxtResponseHandler {
		response: "GetInterfaceInfoResponse"
		serviceId: "NetworkInformation"
		onResponseReceived: {
			interfaceInfoReceived(message);
		}
	}

	BxtResponseHandler {
		response: "GetWirelessNetworksResponse"
		serviceId: "NetworkInformation"
		onResponseReceived: {
			wifiNetworkListReceived(message);
		}
	}

	BxtResponseHandler {
		response: "GetWirelessNetworkInformationResponse"
		serviceId: "NetworkInformation"
		onResponseReceived: {
			var linkQuality = message.getArgument("Link_Quality");
			if (linkQuality) {
				wifiLinkQuality = parseInt(linkQuality);
			}
		}
	}

	/**
	 *	@brief	The wifiConnectTimeout timer is started when the connect to wifi bxt call is done.
	 *	@remark	Hcb_neton does not output anything when the WEP password is not failed so if the wifiStatus is less than conencted when the
	 *			timeout occurs the wifiStatus will become _CS_FAIL_PASS
	 */
	Timer {
		id: wifiConnectTimeout
		interval: 78000;			// Wifi connect timeout of 1.3 minuts
		onTriggered: {
			if (connectingNetworkAuth === "WEP" && wifiStatus < _CS_CONNECTED) {
				wifiStatus = _CS_FAIL_PASS;
			} else {
				wifiStatus = _CS_FAIL_TIMEOUT;
			}

			// Determine the new status text
			determineInetStatus();
		}
	}

	Timer {
		id: wifiLinkQualityTimer
		interval: 60000				// Check every minute the wifiLinkQuality for the InternetSystray iIconButton
		repeat: true
		onTriggered: {
			// Get the wireless network information
			getWirelessNetworkInformation();
		}
	}

	onSmStatusChanged: {
		if (isWizardMode) {
			if ((! wizardstate.stageCompleted("internet")) && smStatus >= _ST_INTERNET) {
				wizardstate.setStageCompleted("internet", true);
			} else if (wizardstate.stageCompleted("internet") && smStatus < _ST_INTERNET) {
				wizardstate.setStageCompleted("internet", false);
			}
		}
	}
}
