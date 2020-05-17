import QtQuick 2.1
import qb.components 1.0
import "Constants.js" as Constants

Screen {
	id: overviewEMetersScreen
	screenTitle: qsTr("Energy meters")

	property EMetersSettingsApp app

	QtObject {
		id: p
		property url advicePopupUrl: "qrc:/qb/components/AdvicePopup.qml"
		property variant usageErrors: []
	}

	Component.onCompleted: {
		QT_TR_NOOP("advice_analog_prefix");
		QT_TR_NOOP("advice_analog_suffix");
		QT_TR_NOOP("advice_analog_elec");
		QT_TR_NOOP("advice_analog_gas");
		QT_TR_NOOP("advice_analog_heat");
		QT_TR_NOOP("advice_analog_solar");
		QT_TR_NOOP("advice_analog_water");
		QT_TR_NOOP("advice_laser_elec");
		QT_TR_NOOP("advice_p1");

		QT_TR_NOOP("status_elec_usage");
		QT_TR_NOOP("status_elec_usage_list");
		QT_TR_NOOP("status_gas_usage");
		QT_TR_NOOP("status_gas_usage_list");
		QT_TR_NOOP("status_heat_usage");
		QT_TR_NOOP("status_heat_usage_list");
		QT_TR_NOOP("status_water_usage");
		QT_TR_NOOP("status_water_usage_list");
		QT_TR_NOOP("status_production");

		QT_TR_NOOP("advice_usage_device_not_connected_B04");
	}

	onShown:  {
		screenStateController.screenColorDimmedIsReachable = false;
		app.usageDevicesInfoChanged.connect(update);
		update();
		cardView.positionViewAtBeginning();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		app.usageDevicesInfoChanged.disconnect(update);
	}

	function update() {
		var newUsageErrors = [], statusText;

		for (var i=0; i < app.usageDevicesInfo.length; i++) {
			var deviceStatus = app.usageDevicesInfo[i].deviceStatus
			if (deviceStatus === Constants.USAGEDEVICE_STATUS.CONN_NOT_CONNECTED
					|| !app.usageDevicesInfo[i].usage.length) {

				if (deviceStatus === Constants.USAGEDEVICE_STATUS.CONN_NOT_CONNECTED)
					statusText = qsTr("status_usage_device_not_connected");
				else
					statusText = qsTr("status_usage_device_not_configured");

				newUsageErrors.push({
					'usageDevice': app.usageDevicesInfo[i],
					'usage': undefined,
					'deviceLabel': app.usageDevicesInfo[i].deviceIdentifier,
					'statusText': statusText,
					'errorCode': app.usageDevicesInfo[i].errorCode
				});
				continue;
			}

			for (var j=0; j < app.usageDevicesInfo[i].usage.length; j++) {
				var usage = app.usageDevicesInfo[i].usage[j];
				if (Constants.meterStatusCodes[usage.status] === Constants.STATUS.ERROR) {
					var sensorStatus = "";
					if (usage.type === "solar")
						sensorStatus = qsTr("status_production");
					else
						sensorStatus = qsTr("status_consumption_list").arg(qsTr("status_" + usage.type + "_usage"));
					statusText = qsTr("status_error_template").arg(sensorStatus);
					newUsageErrors.push({
						'usageDevice': app.usageDevicesInfo[i],
						'usage': usage,
						'deviceLabel': app.usageDevicesInfo[i].deviceIdentifier,
						'statusText': statusText,
						'errorCode': usage.errorCode
					});
				}
			}
		}
		p.usageErrors = newUsageErrors;

	}

	function showAdvice(usageDevice, usage) {
		if (!usageDevice && !usage)
			return;

		var adviceText = "", errorCode;

		if (usage) {
			var adviceErrorStringIDs = [];
			var mType = Constants.measureTypeStrings[usage.measureType];
			if (mType === "analog" || mType === "laser") {
				adviceErrorStringIDs.push("analog_prefix");
				adviceErrorStringIDs.push(mType + "_" + usage.type)
			} else if (mType === "p1") {
				adviceErrorStringIDs.push("p1");
			}

			if (adviceErrorStringIDs.indexOf("analog_prefix") >= 0)
				adviceErrorStringIDs.push("analog_suffix");

			adviceErrorStringIDs.forEach(function (id) {
				var string = qsTr("advice_" + id);
				if (string !== " ")
					adviceText += "<p>" + string + "</p>";
			});
			errorCode = usage.errorCode;
		} else if (usageDevice) {
			if (usageDevice.deviceStatus === Constants.USAGEDEVICE_STATUS.CONN_NOT_CONNECTED) {
				var strId = "advice_usage_device_not_connected_"+usageDevice.errorCode;
				var errStr = qsTr(strId);
				adviceText = (strId === errStr) ? qsTr("advice_usage_device_not_connected") : errStr;
			} else if (!usageDevice.usage.length) {
				adviceText = qsTr("advice_usage_device_not_configured").arg(usageDevice.deviceIdentifier);
			}
			errorCode = usageDevice.errorCode;
		}

		if (adviceText && errorCode) {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Solve the problem"), p.advicePopupUrl);
			qdialog.context.dynamicContent.content = adviceText;
			qdialog.context.dynamicContent.errorCode = errorCode;
		}
	}

	ErrorCardsView {
		id: cardView
		anchors.fill: parent
		emptyViewText: qsTr("There are no energy metering issues anymore.")
		model: p.usageErrors
		delegate: ErrorCard {
			label: modelData.deviceLabel
			icon: "image://scaled/apps/eMetersSettings/drawables/display-graphs.svg"
			statusIcon: "image://scaled/"
						+ (modelData.usage ? "apps/eMetersSettings/drawables/status-error-" + modelData.usage.type
										   : "images/status-error-general") + ".svg"
			statusText: modelData.statusText
			errorCode: modelData.errorCode ? modelData.errorCode : ""

			onButtonClicked: showAdvice(modelData.usageDevice, modelData.usage)
		}
	}
}
