//pragma Singleton
import QtQuick 2.1
import BxtClient 1.0

Item {
	id: root
	property var networkHealth: ({})
	property var devices: ({})

	QtObject {
		id: p
		property string zwaveUuid
		property var securityPopup

		function doAdministrationCall(invokeName, event, requestArgs, timeout, callback) {
			if (!invokeName || !timeout || typeof timeout !== "number" || !event || !zwaveUuid )
				return;

			function adminCB (response) {
				var status, type, uuid;
				if (!response) {
					status = "timeout";
				} else {
					try {
						var obj = JSON.parse(response.getArgument("pb"));
						status = obj.status;
					} catch(e) {
						console.warn("ZWaveUtils: failed parsing response from", invokeName, event, e);
					}

					switch (status) {
					case "keyGrant":
						// automatically grant all keys
						var keys = obj.keys;
						var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "Administration", invokeName);
						msg.addArgument("event", "keyGrant");
						msg.addArgument("accept", "1");
						msg.addArgument("keys", JSON.stringify(keys));
						msg.addArgument("csa", "0");
						bxtClient.doAsyncBxtRequest(msg, adminCB, Math.round(timeout * 1.5));
						return;
					case "ssaAuth":
						var dsk = obj.dsk;
						var userInputDigits = obj.userInputDigits;
						var ssaAuthTimeout = obj.timeout;
						showSecurityEnterKeyPopup(dsk, userInputDigits, ssaAuthTimeout, callback);
						return;
					default:
						if (status === "added") {
							if (obj.securityInfo &&
									(obj.securityInfo.showS2InclusionWarningS0 ||
									 obj.securityInfo.showS2InclusionWarningUnsecure)) {
								showInsecureInclusionPopup(obj.uuid);
							} else {
								hideSecurityPopup();
							}
						} else if (securityPopup && securityPopup.contentSource.toString().indexOf("ZWaveExcludeDevice") === -1) {
							// only hide a possibly visible security popup on remaining Z-Wave status responses
							// when not actively showing ZWaveExcludeDevice content
							hideSecurityPopup();
						}
						type = obj.devType;
						uuid = obj.uuid;
						break;
					}
				}

				if (callback instanceof Function)
					callback(status, type, uuid);
			}

			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "Administration", invokeName);
			msg.addArgument("event", event);
			msg.addArgument("eventTimeout", timeout);
			if (typeof requestArgs === "object")
				for (var arg in requestArgs)
					msg.addArgument(arg, requestArgs[arg]);

			if (callback instanceof Function) {
				bxtClient.doAsyncBxtRequest(msg, adminCB, Math.round(timeout * 1.5));
			} else {
				bxtClient.sendMsg(msg);
			}
		}

		function showSecurityPopup(url, args) {
			if (p.securityPopup) {
				p.securityPopup.setContent(url, args);
			} else {
				p.securityPopup = securityPopupCmp.createObject(root, {"container": home});
				p.securityPopup.show({"contentUrl": url, "contentArgs": args});
				p.securityPopup.hidden.connect(function () {
					p.securityPopup.destroy();
				});
			}
		}

		function showSecurityEnterKeyPopup(dsk, inputDigits, timeout, callback) {
			var url = Qt.resolvedUrl("ZWaveSecurityEnterKey.qml");
			var args = {"dsk": dsk, "inputDigits": inputDigits, "timeout": timeout, "callback": callback};
			showSecurityPopup(url, args);
		}

		function hideSecurityPopup() {
			if (p.securityPopup) {
				p.securityPopup.hide();
				p.securityPopup = undefined;
			}
		}
	}

	function includeDevice(event, callback) {
		p.doAdministrationCall("IncludeDevice", event, undefined, 120, callback);
	}

	function excludeDevice(event, callback) {
		p.doAdministrationCall("ExcludeDevice", event, undefined, 30, callback);
	}

	// Forcefully remove device from configuration
	function removeZwaveDevice(uuid) {
		if (!uuid)
			return;
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, null, "RemoveDevice");
		bxtClient.sendMsg(msg);
	}

	function ssaAuthDevice(accept, dsk, callback) {
		var args = {"accept": accept ? "1" : "0", "dskUserInput": dsk};
		p.doAdministrationCall("IncludeDevice", "ssaAuth", args, 60, callback);
	}

	function showInsecureInclusionPopup(uuid) {
		var url = Qt.resolvedUrl("ZWaveInsecureInclusion.qml");
		var args = {"uuid": uuid};
		p.showSecurityPopup(url, args);
	}

	function doNodeHealthTest(uuid, callback) {

		function healthTestCB(response) {
			if (callback) {
				if (response) {
					var deviceNode = response.getArgumentXml("device");
					var success = deviceNode.getChildText("success") === "1" ? true : false;
					var health = parseInt(deviceNode.getChildText("health"));
					callback(success, health);
				} else {
					callback(false, 0);
				}
			}

			// get new nodeHealth for every device
			getDevices();
		}

		if (uuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, uuid, "specific1", "testNodeHealth");
			bxtClient.doAsyncBxtRequest(msg, healthTestCB, 300);
		}
	}

	function getDevices() {
		if (p.zwaveUuid) {
			var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.zwaveUuid, "specific1", "GetDevices");
			bxtClient.sendMsg(msg);
		}
	}

	Component {
		id: securityPopupCmp
		ZWaveSecurityPopup {}
	}

	BxtDiscoveryHandler {
		id: zwaveDiscoHandler
		equivalentDeviceTypes: ["hdrv_zwave", "happ_zware"]
		onDiscoReceived: {
			p.zwaveUuid = deviceUuid;
			getDevices();
		}
	}

	BxtDatasetHandler {
		id: networkHealthDsHandler
		discoHandler: zwaveDiscoHandler
		dataset: "networkHealth"
		onDatasetUpdate: {
			var tmp = {};
			var node = update.child;
			while (node) {
				tmp[node.name] = (node.name === "uuid" ? node.text : parseInt(node.text));
				node = node.sibling;
			}
			networkHealth = tmp;
		}
	}

	BxtResponseHandler {
		serviceId: "specific1"
		response: "GetDevicesResponse"
		onResponseReceived: {
			var devicesNode = message.getArgumentXml("devices");

			var tmp = {};
			for (var device = devicesNode.getChild("device"); device; device = device.next) {
				var newDev = {};
				var uuid = device.getChildText("uuid");
				var node = device.child;
				while (node) {
					switch(node.name) {
					case "securityInfo":
						var nodeChild = node.child;
						newDev[node.name] = {};
						while (nodeChild) {
							newDev[node.name][nodeChild.name] = nodeChild.text;
							nodeChild = nodeChild.sibling;
						}
						break;
					default:
						newDev[node.name] = node.text;
						break;
					}
					node = node.sibling;
				}
				tmp[uuid] = newDev;
			}
			devices = tmp;
		}
	}
}
