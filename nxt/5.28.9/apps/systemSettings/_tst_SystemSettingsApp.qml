import QtQuick 2.0
import QtTest 1.0
import FileIO 1.0

import BxtClient 1.0
import BxtTestbench 1.0

import apps.systemSettings 1.0
import qb.test 1.0

QbTestCase {
	name: "systemSettingsApp";

	SystemSettingsApp {
		id: testSystemSettingsApp
	}

	BxtTestBench {
		id: bxtBench;
		property BxtMessage receivedMessage;

		onMessage: {
			receivedMessage = message;
		}
	}

	FileIO {
		id: getDeviceInfoReponseMessage
		source: "tst_deviceInfoResponse.xml"
		onError: console.log(msg.stringContent)
	}

	FileIO {
		id: hdrv_zwaveDiscoMessage
		source: "tst_zwave_disco.xml"
		onError: console.log(msg.stringContent)
	}

	FileIO {
		id: hdrv_zwaveFirmwareUpdateNotifyMessage
		source: "tst_zwave_notify_fwupdate.xml"
		onError: console.log(msg.stringContent)
	}

	function test_a_getDeviceInfo() {
		//get DeviceInfoRepsonse message
		testSystemSettingsApp.getDeviceInfo();

		var receivedMessage = bxtBench.receivedMessage;
		var resp = receivedMessage.createResponse();
		resp.addArgumentXmlText(getDeviceInfoReponseMessage.read());
		bxtBench.injectMessage(resp);

		compare(testSystemSettingsApp.displayInfo['SoftwareVersion'], "2.9.1");
		compare(testSystemSettingsApp.displayInfo['SerialNumber'], "12-03-007-492");
		compare(testSystemSettingsApp.displayInfo['DeviceModel'], "6500-1102-0300");

		compare(testSystemSettingsApp.meterAdapterInfo[0]['SoftwareVersion'], "34/38");
		compare(testSystemSettingsApp.meterAdapterInfo[0]['UpdateAvailable'], true);
		compare(testSystemSettingsApp.meterAdapterInfo[0]['SerialNumber'], "14-11-007-770");
		compare(testSystemSettingsApp.meterAdapterInfo[0]['DeviceModel'], "6500-1300-7200");

		compare(testSystemSettingsApp.boilerAdapterInfo['SoftwareVersion'], "35");
		compare(testSystemSettingsApp.boilerAdapterInfo['UpdateAvailable'], true);
		compare(testSystemSettingsApp.boilerAdapterInfo['SerialNumber'], "12-35-033-862");
		compare(testSystemSettingsApp.boilerAdapterInfo['DeviceModel'], "6500-1200-2000");
	}

	function test_b_checkFirmwareUpdate() {
		testSystemSettingsApp.checkFirmwareUpdate();

		var receivedMessage = bxtBench.receivedMessage;
		compare(receivedMessage.name, "CheckFirmwareUpdate");
		compare(receivedMessage.serviceId, "specific1")
	}

	function test_c_startMeterAdapterUpdate() {
		var uuid = testSystemSettingsApp.getMeterAdapterInfo(0, "deviceUuid");
		testSystemSettingsApp.startMeterAdapterUpdate(uuid);

		var receivedMessage = bxtBench.receivedMessage;
		compare(receivedMessage.name, "ForceEnableUpgrade");
		compare(receivedMessage.serviceId, "specific1")
	}

	function test_d_getMeterAdapterUpdateStatus() {
		testSystemSettingsApp.getMeterAdapterUpdateStatus();

		var receivedMessage = bxtBench.receivedMessage;
		compare(receivedMessage.name, "GetFirmwareUpdateStatus");
		compare(receivedMessage.serviceId, "specific1")
	}

	function test_e_GetFirmwareUpdateStatusResponse() {
		testSystemSettingsApp.getMeterAdapterUpdateStatus();

		var msg = bxtBench.receivedMessage;

		var resp = msg.createResponse();
		resp.addArgument("status", testSystemSettingsApp._FIRMWARE_UPDATE_COMPLETE);
		resp.addArgument("statusMsg", "Meter adapter update done.");
		bxtBench.injectMessage(resp);
		compare(testSystemSettingsApp.maFwUpdateStatus, testSystemSettingsApp._FIRMWARE_UPDATE_COMPLETE);
		compare(testSystemSettingsApp.maFwUpdateStatusMsg, "Meter adapter update done.")
	}

	function test_f_TestDiscoAndFwUpdateNotify() {
		// Send disco so the notify handler has a sourceUuid assigned
		bxtBench.injectMessageText(hdrv_zwaveDiscoMessage.read());

		// Send notify
		bxtBench.injectMessageText(hdrv_zwaveFirmwareUpdateNotifyMessage.read());
		compare(testSystemSettingsApp.maFwUpdatePercentage, 50);
	}

	function test_g_isUpdate() {
		// Display
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.0.29", "3.0.30"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.0.29", "3.1.0"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.1.29", "4.0.0"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.0.0", "3.0.0"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.0.0", "2.0.0"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("3.0.0", "2.9.28"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("2.9.28", "2.8.27"), false)
		compare(testSystemSettingsApp.privs.isReleaseUpdate("2.9.28", "2.9.27"), false);

		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ene/3.0.29", "qb2/ene/3.0.30"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ebl/2.10.0", "qb2/ene/2.10.1"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ebl/2.10.0", "qb2/ebl/2.10.1"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ebl/3.0.29", "qb2/ene/3.0.29"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ene/3.0.29", "qb2/ene/3.0.29"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("qb2/ene/2.9.26", "qb2/ene/2.10.3"), true);

		// Boiler
		compare(testSystemSettingsApp.privs.isReleaseUpdate("34", "35"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("22", "30"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("22", "22"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("22", "10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("1", "0"), false);
		// MA old
		compare(testSystemSettingsApp.privs.isReleaseUpdate("34/36", "35/36"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("38/32", "38/33"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("38/32", "38/32"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("34/36", "33/36"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("34/36", "34/35"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("34/36", "33/35"), false);
		// MA new
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.17/0.11"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.16/0.12"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.17/0.12"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.16/0.11"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.15/0.11"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.16/0.10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11", "0.15/0.10"), false);
		// MA new + Laser
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.17/0.11/0.10"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.16/0.12/0.10"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.17/0.12/0.10"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.16/0.11/0.11"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.17/0.12/0.11"), true);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.16/0.11/0.10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.15/0.11/0.10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.16/0.10/0.10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.16/0.11/0.09"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.15/0.10/0.10"), false);
		compare(testSystemSettingsApp.privs.isReleaseUpdate("0.16/0.11/0.10", "0.15/0.10/0.09"), false);
	}
}
