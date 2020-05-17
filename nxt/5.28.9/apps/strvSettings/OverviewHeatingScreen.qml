import QtQuick 2.1
import qb.components 1.0

import BasicUIControls 1.0;

Screen {
	id: overviewHeatingScreen

	property StrvSettingsApp app

	screenTitle: qsTr("Heating")

	onShown:  {
		screenStateController.screenColorDimmedIsReachable = false;

		app.strvDevicesListChanged.connect(onStrvDevicesListChanged);
		onStrvDevicesListChanged();
	}

	onHidden: {
		app.strvDevicesListChanged.disconnect(onStrvDevicesListChanged);

		screenStateController.screenColorDimmedIsReachable = true;
	}

	QtObject {
		id: p
		property var errorsModel
	}

	function onStrvDevicesListChanged() {
		var newErrors = [];

		for (var i = 0; i < app.strvDevicesList.length; ++i) {
			var curDevice = app.strvDevicesList[i];

			if (curDevice.hasCommunicationError) {
				newErrors.push({
				   'deviceLabel': curDevice.name,
				   'deviceIcon': "image://scaled/apps/strvSettings/drawables/strv-2.svg",
				   'statusText': qsTr("strv-communication-error %1").arg(curDevice.name),
				   'statusIcon': "image://scaled/images/status-error-general.svg"
			   });
			}
		}

		p.errorsModel = newErrors;
	}

	Timer {
		id: pollDevicesTimer
		interval: 10000
		repeat: true
		running: true
		triggeredOnStart: true

		onTriggered: {
			app.getDevices(getDevicesCallback);
		}

		function getDevicesCallback(response) {
			app.handleGetDevicesCallback(response);

			cardView.visible = true;
		}
	}

	ErrorCardsView {
		id: cardView

		visible: false

		anchors.fill: parent
		emptyViewText: qsTr("There are no heating issues anymore.")
		model: p.errorsModel
		delegate: ErrorCard {
			label: modelData.deviceLabel
			icon: Qt.resolvedUrl(modelData.deviceIcon)
			statusIcon: Qt.resolvedUrl(modelData.statusIcon)
			statusText: modelData.statusText
			errorCode: modelData.errorCode ? modelData.errorCode : ""

			onButtonClicked: {
				// The only error we support at the moment
				app.showNoConnectionPopup();
			}
		}
	}

	Throbber {
		id: updateThrobber

		visible: ! cardView.visible

		anchors.centerIn: parent
	}
}
