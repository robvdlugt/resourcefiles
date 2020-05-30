import QtQuick 2.1
import BxtClient 1.0
import FileIO 1.0

import qb.components 1.0
import qb.base 1.0

App {
	id: tscSettingsApp

	property url tscFrameUrl: "TscFrame.qml"
	property url guiModScreenUrl: "GuiModScreen.qml"
	property url rotateTilesScreenUrl: "RotateTilesScreen.qml"
	property url toggleNativeFeaturesScreenUrl: "ToggleNativeFeaturesScreen.qml"
	property url firmwareUpdateScreenUrl: "FirmwareUpdate.qml"
	property url credentialsMobileAppScreenUrl: "CredentialsMobileAppScreen.qml"
	property url changeTariffScreenUrl: "ChangeTariffScreen.qml"
        property url softwareUpdateInProgressPopupUrl: "SoftwareUpdateInProgressPopup.qml"
        property Popup softwareUpdateInProgressPopup
	property url hideToonLogoScreenUrl: "HideToonLogoScreen.qml"
	property url hideErrorSystrayScreenUrl: "HideErrorSystrayScreen.qml"
	property url customToonLogoScreenUrl: "CustomToonLogoScreen.qml"
        property url settingsScreenUrl: "qrc:/apps/settings/SettingsScreen.qml"

	property string tscVersion: "2.1.2"

	property real nxtScale: isNxt ? 1.5 : 1 
	property bool rebootNeeded: false

	property bool preheatDisabled: true

        property variant billingInfos: ({})
        property variant agreementDetails: ({})

	property variant localSettings: {
		'locked': false,
		'lockPinCode': "1234"
	}

	FileIO { 
		id: startupFileIO
	}

        FileIO {
                id: downloadStatusFile
                source: "file:///tmp/update.status.vars"
                onError: console.log("Can't open /tmp/update.status.vars")
        }

	function init() {
		registry.registerWidget("settingsFrame", tscFrameUrl, this, "tscFrame", {categoryName: "TSC", categoryWeight: 310});
		registry.registerWidget("screen", guiModScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", rotateTilesScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", toggleNativeFeaturesScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", firmwareUpdateScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", hideToonLogoScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", hideErrorSystrayScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", customToonLogoScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", credentialsMobileAppScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", changeTariffScreenUrl, this, null, {lazyLoadScreen: true});
		registry.registerWidget("popup", softwareUpdateInProgressPopupUrl, this,"softwareUpdateInProgressPopup");
                notifications.registerType("tsc", notifications.prio_HIGHEST, Qt.resolvedUrl("drawables/notification-update.svg"), settingsScreenUrl, {"categoryUrl": tscFrameUrl}, "Meerdere TSC notifications");
		notifications.registerSubtype("tsc", "update", settingsScreenUrl, {"categoryUrl": tscFrameUrl});
		notifications.registerSubtype("tsc", "firmware", firmwareUpdateScreenUrl, {});
	}

        QtObject {
                id: p
                property string pwrUsageUuid
                property string userMsgUuid
                property string configMsgUuid
		property string thermostatUuid
		property string vocDevUuid
	}


        Component.onCompleted: {
                // load the settings on completed is recommended instead of during init
		loadSettings();
		createStartupFile();
        }



        function loadSettings()  {
                var settingsFile = new XMLHttpRequest();
                settingsFile.onreadystatechange = function() {
                        if (settingsFile.readyState == XMLHttpRequest.DONE) {
                                if (settingsFile.responseText.length > 0)  {
					var temp = JSON.parse(settingsFile.responseText);
					var globalTemp = globals.tsc;
					var localTemp = localSettings;
                                        for (var setting in temp) {
						//console.log("TSC settings: ", setting, temp[setting]);
						if (globalTemp[setting] !== undefined)  { globalTemp[setting] = temp[setting]; }
						if (localTemp[setting] !== undefined)  { localTemp[setting] = temp[setting]; }
                                        }
                                        globals.tsc = globalTemp;
                                        localSettings = localTemp;
					if (stage.logo) stage.logo.visible = (globals.tsc["hideToonLogo"] !== 2 );
                                }
                        }
                }
                settingsFile.open("GET", "file:///mnt/data/tsc/tscSettings.userSettings.json", true);
                settingsFile.send();
        }

	function saveSettingsTsc() {
                // save the new settings into the json file
		var saveFile = new XMLHttpRequest();
		var saveSettings = globals.tsc;
		for (var setting in localSettings) {
			saveSettings[setting] = localSettings[setting];
		}
                saveFile.open("PUT", "file:///mnt/data/tsc/tscSettings.userSettings.json");
                saveFile.send(JSON.stringify(saveSettings));
	}

	function createStartupFile() {
		// create a startup file which downloads the TSC control script and installs a inittab routine
  		var startupFileCheck = new XMLHttpRequest();
		//console.log("TSC: checking tsc boot file"); 
                startupFileCheck.onreadystatechange = function() {
                        if (startupFileCheck.readyState == XMLHttpRequest.DONE) {
                                if (startupFileCheck.responseText.length === 0)  {
					console.log("TSC: missing tsc boot startup file, creating it")
	        			var startupFile = new XMLHttpRequest();
					startupFile.open("PUT", "file:///etc/rc5.d/S99tsc.sh");
					startupFile.send("if [ ! -s /usr/bin/tsc ] || grep -q no-check-certificate /usr/bin/tsc ; then /usr/bin/curl -Nks --retry 5 --connect-timeout 2 https://raw.githubusercontent.com/ToonSoftwareCollective/tscSettings/master/tsc -o /usr/bin/tsc ; chmod +x /usr/bin/tsc ; fi ; if ! grep -q tscs /etc/inittab ; then sed -i '/qtqt/a\tscs:245:respawn:/usr/bin/tsc >/var/log/tsc 2>&1' /etc/inittab ; if grep -q tscs /etc/inittab ; then init q ; fi ; fi");
					startupFile.close;
					rebootNeeded = true;
				}
                                if (startupFileCheck.responseText.indexOf("curl") === -1)  {
					console.log("TSC: tsc boot startup file wrong, modifying it")
	        			var startupFile = new XMLHttpRequest();
					startupFile.open("PUT", "file:///etc/rc5.d/S99tsc.sh");
					startupFile.send("if [ ! -s /usr/bin/tsc ] || grep -q no-check-certificate /usr/bin/tsc ; then /usr/bin/curl -Nks --retry 5 --connect-timeout 2 https://raw.githubusercontent.com/ToonSoftwareCollective/tscSettings/master/tsc -o /usr/bin/tsc ; chmod +x /usr/bin/tsc ; fi ; if ! grep -q tscs /etc/inittab ; then sed -i '/qtqt/a\tscs:245:respawn:/usr/bin/tsc >/var/log/tsc 2>&1' /etc/inittab ; if grep -q tscs /etc/inittab ; then init q ; fi ; fi");
					startupFile.close;
					rebootNeeded = true;
				}
			}
		}
                startupFileCheck.open("GET", "file:///etc/rc5.d/S99tsc.sh", true);
                startupFileCheck.send();
	}

        function getSoftwareUpdateStatus() {
                var downloadStatusText = downloadStatusFile.read();
                var keysAndValues = downloadStatusText.split('&');
                var retVal = {'action': '', 'item': 0}
                var keyvaluepair = ''

                for (var i = 0; i < keysAndValues.length; i++) {
                        keyvaluepair = keysAndValues[i].split('=');
                        retVal[keyvaluepair[0]] = keyvaluepair[1];
                }
                return retVal;
        }


        function parseBillingInfo(msg) {
                if (msg) {
                        var newBillingInfos = {};
                        var infoChild = msg.getChild("info", 0);
                        while (infoChild) {
                                var billingInfo = {};
                                var childChild = infoChild.child;
                                while (childChild) {
                                        if (childChild.name === "type" || childChild.name === "error")
                                                billingInfo[childChild.name] = childChild.text;
                                        else
                                                billingInfo[childChild.name] = parseFloat(childChild.text);
                                        childChild = childChild.sibling;
                                }

                                billingInfo.haveSJV = billingInfo.error !== "notSet" && billingInfo.usage !== 0;
                                newBillingInfos[billingInfo.type] = billingInfo;
                                infoChild = infoChild.next;
                        }
                        billingInfos = newBillingInfos;
			//console.log("TSC: ",JSON.stringify(billingInfos));
                }
        }
	
	function setTariff(elec,elecLow,dualTariff,gas) {
                var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.pwrUsageUuid, "specific1", "BaseData");
		if (dualTariff) {
                	msg.addArgumentXmlText("<BaseField><Type>POWER</Type><SeparateBilling>true</SeparateBilling><TariffPeak>%1</TariffPeak><TariffOffPeak>%2</TariffOffPeak></BaseField>".arg(elec).arg(elecLow));
		}
		else {
                	msg.addArgumentXmlText("<BaseField><Type>POWER</Type><SeparateBilling>false</SeparateBilling><TariffPeak>%1</TariffPeak></BaseField>".arg(elec));
		}
                msg.addArgumentXmlText("<BaseField><Type>GAS</Type><SeparateBilling>false</SeparateBilling><TariffPeak>%1</TariffPeak></BaseField>".arg(gas));
                bxtClient.sendMsg(msg);
	}

        function onThermostatInfoChanged(node) {
               var tempNode = node.child;
               while (tempNode) {
			if (globals.tsc["noPreheatWhenAway"] && tempNode.name === "activeState") {
				if ( tempNode.text === "2" || tempNode.text === "3" || tempNode.text === "4" ) {
					if (!preheatDisabled) {
						preheatDisabled=true;
                				var setDHWInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetDhwSettings");
                				setDHWInfoMessage.addArgument("dhwEnabled",  0);
                				bxtClient.sendMsg(setDHWInfoMessage);
					}
				} else {
					if (preheatDisabled) {
						preheatDisabled=false;
                				var setDHWInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetDhwSettings");
                				setDHWInfoMessage.addArgument("dhwEnabled",  1);
                				bxtClient.sendMsg(setDHWInfoMessage);
					}
				}
			}
			tempNode = tempNode.sibling;
                }
 
       }

        function getDHWInfo() {
                var getDHWInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetDhwSettings");
                bxtClient.doAsyncBxtRequest(getDHWInfoMessage,getDHWInfoMessageCallback, 20);
        }


	function getAgreementDetails() {
                //console.log("TSC: getting agreement details")
                var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "ConfigProvider", "GetObjectConfig")
                msg.addArgument("package", "happ_scsync")
                msg.addArgument("internalAddress", "agreementDetail")
                bxtClient.doAsyncBxtRequest(msg, getAgreementDetailsCallback, 30)
	}

        function onThermostatStatesChanged(node) {
		if (globals.tsc["summerMode"]) {
                	var nodeState = node.getChild("state")
	                while (nodeState && globals.tsc["summerMode"]) {
                               	if (nodeState.getChildText("tempValue") != "1000") {
                                        var myTsc = globals.tsc
                                        myTsc["summerMode"] =  false
                                        globals.tsc = myTsc
                                        saveSettingsTsc()
					var sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, "Notification", "CreateNotification")
					sendmsg.addArgument("type",  "tsc");
					sendmsg.addArgument("subType",  "thermostat");
					sendmsg.addArgument("text",  "Summer mode disabled due to manual setpoint change!");
                                	bxtClient.sendMsg(sendmsg);
                        } else {
				}
                        	nodeState = nodeState.next
                	}
		}

	}

	function toggleSummerMode() {
		if (globals.tsc["summerMode"]) {
                	var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "ConfigProvider", "GetObjectConfig")
                	msg.addArgument("package", "happ_thermstat")
                	msg.addArgument("internalAddress", "thermostatStates")
                	bxtClient.doAsyncBxtRequest(msg, toggleSummerModeCallback, 30)
		} else {
	                var thermstatesFile = new XMLHttpRequest()
                	thermstatesFile.open("GET", "file:///mnt/data/tsc/tscSettings.savedThermstates.json", 0) //sync request
                	thermstatesFile.send()
                        if (thermstatesFile.responseText.length > 0)  {
                        	var thermStates = JSON.parse(thermstatesFile.responseText);

                                var sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "ConfigProvider", "SetObjectConfig")
                                sendmsg.addArgument("Config", null)
                                var sendnode = sendmsg.getArgumentXml("Config");
                                sendnode = sendnode.addChild("device", null, 0);
                                sendnode.addChild("package", "happ_thermstat", 0);
                                sendnode.addChild("type", "states", 0);
                                sendnode.addChild("name", "thermostatStates", 0);
                                sendnode.addChild("internalAddress", "thermostatStates", 0);
                                sendnode.addChild("visibility", "0", 0);
                                sendnode = sendnode.addChild("states", null, 0);
                                for (var i = 0; i < 5; i++) {
                                        var stateNode = sendnode.addChild("state", null, 0)
                                        stateNode.addChild("id", i, 0)
                                        stateNode.addChild("tempValue", thermStates[i].tempValue ? thermStates[i].tempValue : 600 , 0)
                                        stateNode.addChild("dhw", thermStates[i].dhw ? thermStates[i].dhw : 0 ,0)
                                }
                                bxtClient.sendMsg(sendmsg);
				sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, "Notification", "CreateNotification")
				sendmsg.addArgument("type",  "tsc");
				sendmsg.addArgument("subType",  "thermostat");
				sendmsg.addArgument("text",  "Summer mode disabled. Setpoints restored.");
                                bxtClient.sendMsg(sendmsg);
                        } else {
				sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, "Notification", "CreateNotification")
				sendmsg.addArgument("type",  "tsc")
				sendmsg.addArgument("subType",  "thermostat")
				sendmsg.addArgument("text",  "Could not restore setpoints after disabling summer mode!")
                                bxtClient.sendMsg(sendmsg);
			}
                 }
	}

        function toggleSolarSubscription() {
                var tmpAgreementDetails = agreementDetails
		if (tmpAgreementDetails["SolarDisplay"] === "1" ) {
                	tmpAgreementDetails["SolarDisplay"] = "0"
		} else {
                	tmpAgreementDetails["SolarDisplay"] = "1"
		}
		if (tmpAgreementDetails["SolarActivated"] === "1" ) {
                	tmpAgreementDetails["SolarActivated"] = "0"
		} else {
                	tmpAgreementDetails["SolarActivated"] = "1"
		}
                agreementDetails = tmpAgreementDetails

                var saveAgreementDetails = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "ConfigProvider", "SetObjectConfig")
                saveAgreementDetails.addArgument("Config", null)
                var configNode = saveAgreementDetails.getArgumentXml("Config")
                var deviceConfigNode = configNode.addChild("device", null, 0)
                for (var prop in tmpAgreementDetails)  {
                        deviceConfigNode.addChild(prop, tmpAgreementDetails[prop], 0)
                }

                bxtClient.sendMsg(saveAgreementDetails)

		// this requires a compleet reboot
		rebootNeeded = true
        }

	function rebootToon() {
		var restartToonMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "specific1", "RequestReboot");
		bxtClient.sendMsg(restartToonMessage);
	}

        BxtDiscoveryHandler {
                id: hdrvSensoryDiscoHandler
                deviceType: "hdrv_sensory"
                onDiscoReceived: {
                        if (isHello) {
                                if (devNode) {
                                        for (var device = devNode.getChild("device"); device; device = device.next) {
                                                var deviceType = device.getAttribute("type");
                                                if (deviceType === undefined)
                                                        continue;

                                                var deviceUuid;
                                                if (~deviceType.indexOf("vocSensor"))
                                                {
                                                        deviceUuid = device.getAttribute("uuid");
                                                        if (deviceUuid)
                                                                p.vocDevUuid = deviceUuid;
                                                }
                                        }
                                }
                        }
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
                        var saveFile = new XMLHttpRequest()
                        if ((value = message.getArgument("eco2")))
                        {
                                saveFile.open("PUT", "file:///tmp/eco2");
                                saveFile.send(value);
                        }
                        else if ((value = message.getArgument("tvoc")))
                        {
                                saveFile.open("PUT", "file:///tmp/tvoc");
                                saveFile.send(value);
                        }

                }
        }



        BxtDiscoveryHandler {
                id: configDiscoHandler
                deviceType: "hcb_config"

		onDiscoReceived: {
                        p.configMsgUuid = deviceUuid;
			if (rebootNeeded) {
				//rebooting the toon to let the startup script do some work
				rebootToon()
			}
			getAgreementDetails()
                }
        }

        BxtDiscoveryHandler {
                id: pwrusageDiscoHandler
                deviceType: "happ_pwrusage"
                onDiscoReceived: {
                        p.pwrUsageUuid = deviceUuid;
                }
        }

        BxtDiscoveryHandler {
                id: userMsgDiscoHandler
                deviceType: "happ_usermsg"
                onDiscoReceived: {
                        p.userMsgUuid = deviceUuid;
                }
        }

        BxtDiscoveryHandler {
                id: thermstatDiscoHandler
                deviceType: "happ_thermstat"
                onDiscoReceived: {
                        p.thermostatUuid = deviceUuid;
			getDHWInfo();

                }
        }

        BxtDatasetHandler {
                id: billingInfoDsHandler
                dataset: "billingInfo"
                discoHandler: pwrusageDiscoHandler
                onDatasetUpdate:  parseBillingInfo(update) 
        }


        BxtDatasetHandler {
                id: thermstatInfoDsHandler
                dataset: "thermostatInfo"
                discoHandler: thermstatDiscoHandler
                onDatasetUpdate: onThermostatInfoChanged(update)
        }

        BxtDatasetHandler {
                id: thermstatStatesDsHandler
                dataset: "thermostatStates"
                discoHandler: thermstatDiscoHandler
                onDatasetUpdate: onThermostatStatesChanged(update)
        }


        BxtRequestCallback {
                id: getDHWInfoMessageCallback
                onMessageReceived: {
	                if (message.getArgument("dhwEnabled") == 0) {
				preheatDisabled=true
			}
			else {
				preheatDisabled=false
			}
                }
        }

        BxtRequestCallback {
                id: getAgreementDetailsCallback

                onMessageReceived: {
                        if (message) {
                                var tmpAgreementDetails = {}
                                var actNode = message.getArgumentXml("Config").getChild("device")
                                var childNode = actNode.child
                                while (childNode) {
                                        tmpAgreementDetails[childNode.name] = childNode.text
                                        childNode = childNode.sibling;
                                }
                                agreementDetails = tmpAgreementDetails
                        }
                }
	}

        BxtRequestCallback {
                id: toggleSummerModeCallback

                onMessageReceived: {
                        if (message) {
                                var tmpThermStates = {}
                                var tmpDHWStates = {}
                                var actNode = message.getArgumentXml("Config").getChild("device").getChild("states")

               		 	var nodeState = actNode.getChild("state")
		                while (nodeState) {
                       			var id = parseInt(nodeState.getChildText("id"))
		                        var tempValue = parseFloat(nodeState.getChildText("tempValue"))
                               		var dhw = parseInt(nodeState.getChildText("dhw")) 
					tmpThermStates[id] = {}
					tmpThermStates[id].tempValue = tempValue
					tmpThermStates[id].dhw = dhw
               		        	nodeState = nodeState.next
                       		}

		                var saveFile = new XMLHttpRequest()
				// save the current therm states
		                saveFile.open("PUT", "file:///mnt/data/tsc/tscSettings.savedThermstates.json",0) // do sync request to wait for the send to complete
		                saveFile.send(JSON.stringify(tmpThermStates))

				// now it is time to lower these setpoints
				var sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "ConfigProvider", "SetObjectConfig")
				sendmsg.addArgument("Config", null)
                		var sendnode = sendmsg.getArgumentXml("Config");
                		sendnode = sendnode.addChild("device", null, 0);
                		sendnode.addChild("package", "happ_thermstat", 0);
                		sendnode.addChild("type", "states", 0);
                		sendnode.addChild("name", "thermostatStates", 0);
                		sendnode.addChild("internalAddress", "thermostatStates", 0);
                		sendnode.addChild("visibility", "0", 0);
                		sendnode = sendnode.addChild("states", null, 0);
                		for (var i = 0; i < 5; i++) {
                        		var stateNode = sendnode.addChild("state", null, 0)
                        		stateNode.addChild("id", i, 0)
                        		stateNode.addChild("tempValue", 1000, 0)  // set the setpoint to 10 degrees for summer mode
                        		stateNode.addChild("dhw", tmpThermStates[i].dhw ? tmpThermStates[i].dhw : 0,0)
                		}
                        	bxtClient.sendMsg(sendmsg);
				// send notification to user
				sendmsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.userMsgUuid, "Notification", "CreateNotification")
				sendmsg.addArgument("type",  "tsc")
				sendmsg.addArgument("subType",  "thermostat")
				sendmsg.addArgument("text",  "Summer mode selected. All setpoints now at 10 degrees.")
                                bxtClient.sendMsg(sendmsg);
                        }
                }
        }


}
