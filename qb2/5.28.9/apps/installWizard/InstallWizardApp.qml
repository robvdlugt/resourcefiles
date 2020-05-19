import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0;
import qb.base 1.0;

App {
	id: installWizardApp
	property url dimIconUrl : "qrc:/apps/homescreen/DimIcon.qml"
	property url languageScreenUrl: "LanguageScreen.qml"

	property url installWizardScreenUrl : "InstallWizardScreen.qml"
	property url installWizardOverviewScreenUrl : "InstallWizardOverviewScreen.qml"

	property url installWizardMenuUrl: "drawables/InstallWizardIcon.svg"

	property url factoryResetScreenUrl: "qrc:/apps/systemSettings/FactoryResetScreen.qml"

	QtObject {
		id: p

		property string scsyncMsgUuid
		property string configMsgUuid

	}

	property string displaySoftwareVersion: "-/-/-/-"
	property string availableSoftwareVersion: "-"
	property bool versionVisible: false


	function init() {
		registry.registerWidget("systrayIcon", dimIconUrl, installWizardApp, "");

		registry.registerWidget("screen", installWizardScreenUrl, installWizardApp, "");
		registry.registerWidget("screen", installWizardOverviewScreenUrl, installWizardApp, "");
		registry.registerWidget("screen", factoryResetScreenUrl, installWizardApp, null, {lazyLoadScreen: true});

		if (wizardstate.stages().indexOf("language") < 0 || wizardstate.stageCompleted("language")) {
			stage.homeScreenUrl = installWizardScreenUrl;
		} else {
			registry.registerWidget("screen", languageScreenUrl, installWizardApp, "");
			stage.homeScreenUrl = languageScreenUrl;
		}
	}

	function setLocale(locale) {
		console.log("InstallWizardApp - Setting locale to: ", locale)
		var localeMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.configMsgUuid, "DatetimeControl", "SetLocale");
		localeMessage.addArgument("locale", locale);

		bxtClient.sendMsg(localeMessage);
		wizardstate.setStageCompleted("language", true)

		console.log("New locale", locale, ". Canvas.locale", canvas.locale)
		// If the locale didn't change, canvas.setLocale() will not restart the
		// GUI... but we do want it to! So instead of depending on
		// canvas.setLocale(), we're going to restart here explicitely.
		console.log("Restarting after selecting language for the installation wizard")
		Qt.quit()
	}

	function getDeviceInfo() {
		console.log("(InstallWizardApp) Requesting device info from happ_scsync")
		var getDeviceInfoMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncMsgUuid, "specific1", "GetDeviceInfo");
		bxtClient.doAsyncBxtRequest(getDeviceInfoMessage, getDeviceInfoCallback, 20);
	}

	function sendWizardDone() {
		var doneMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncMsgUuid, "specific1", "wizardDone");
		bxtClient.sendMsg(doneMsg);
	}

	BxtRequestCallback {
		id: getDeviceInfoCallback

		onMessageReceived: {
			console.log(message.stringContent);
			var devicesNode = message.getArgumentXml("devices");
			var device = devicesNode.getChild("device");
			var tmpInfo = [];

			for (; device; device = device.next) {
				var deviceType = device.getChild("DeviceType").text;
				if (deviceType !== "Display") {
					continue
				}

				// Software version contains a string like "qb2/ene/2.9.1"
				var SoftwareVersion = device.getChildText("SoftwareVersion");
				//Update available is an option entry in the DeviceInfo message. If it is available use it, otherwise try to decide it ourselfs
				var updateAvailable = device.getChild("UpdateAvailable");
				updateAvailable = false
				var AvailableVersion = device.getChildText("AvailableVersion");

				console.log("(InstallWizardApp) Read display software version:", SoftwareVersion, updateAvailable, AvailableVersion)

				displaySoftwareVersion = SoftwareVersion
			}
		}
	}

	BxtDiscoveryHandler {
		deviceType: "happ_scsync"

		onDiscoReceived: {
			p.scsyncMsgUuid = deviceUuid;
			getDeviceInfo();
		}
	}

	BxtDiscoveryHandler {
		id: configDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.configMsgUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: softwareVersionInfoDsHandler
		discoHandler: configDiscoHandler
		dataset: "softwareVersionInfo"
		onDatasetUpdate: {
			availableSoftwareVersion = update.getChildText("latestVersion");
		}
	}

}
