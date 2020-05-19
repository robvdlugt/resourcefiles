import QtQuick 2.1
import BxtClient 1.0

import qb.components 1.0
import qb.base 1.0;

App {
	id: root

	property bool supportEnabled

	QtObject {
		id: p

		property url imprintMenuUrl: "drawables/imprint.svg"
		property url imprintScreenUrl: "ImprintScreen.qml"
		property url customerServiceScreenUrl : "CustomerServiceScreen.qml"
		property url customerServiceMenuUrl: "drawables/CustomerServiceIcon.svg"
		property string scsyncUuid

		function handleGetSupportStateResponse(message) {
			supportEnabled = (message.getArgument("supportEnabled") === "true");
		}
	}

	function init() {
		registry.registerWidget("screen", p.customerServiceScreenUrl, root, null, {lazyLoadScreen: true});
		registry.registerWidget("menuItem", null, root, null, {label: qsTr("Toon support"), image: p.customerServiceMenuUrl, screenUrl: p.customerServiceScreenUrl, weight: 135});
		if (feature.appImprintEnabled()) {
			registry.registerWidget("menuItem", null, root, null, {label: qsTr("Imprint"), image: p.imprintMenuUrl, screenUrl: p.imprintScreenUrl, weight: 137});
			registry.registerWidget("screen", p.imprintScreenUrl, root, null, {lazyLoadScreen: true});
		}
	}

	function setSupportState(enabled) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "setSupportState");
		msg.addArgument("supportEnabled", enabled);
		bxtClient.sendMsg(msg);

		supportEnabled = enabled;
	}

	function requestSupportState() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "getSupportState");
		bxtClient.sendMsg(msg);
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
		}
	}

	BxtResponseHandler {
		id: getSupportStateResponseHandler
		response: "getSupportStateResponse"
		onResponseReceived: p.handleGetSupportStateResponse(message)
	}
}
