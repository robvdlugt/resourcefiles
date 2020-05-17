import QtQuick 2.1
import qb.components 1.0

import BasicUIControls 1.0;

Screen {
	id: overviewHeatingScreen

	screenTitle: qsTr("Heating")

	onShown:  {
		screenStateController.screenColorDimmedIsReachable = false;
		app.thermostatStateChanged.connect(onThermostatStateChanged);
		onThermostatStateChanged();
	}

	onHidden: {
		app.thermostatStateChanged.disconnect(onThermostatStateChanged);
		screenStateController.screenColorDimmedIsReachable = true;
	}

	QtObject {
		id: p
		property url advicePopupUrl: "qrc:/qb/components/AdvicePopup.qml"
		property bool hasDistrictHeat: app.getHeatingType() === 2
		property variant errorsModel
	}

	function showAdvice(adviceText, errorCode) {
		if (errorCode) {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Solve the problem"), p.advicePopupUrl);
			qdialog.context.dynamicContent.content = adviceText;
			qdialog.context.dynamicContent.errorCode = errorCode;
		} else {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Advice"), adviceText);
		}
	}

	function onThermostatStateChanged() {
		var newErrors = [];
		if (app.thermostatState & app.thermostatStates.CONNECTIVITY_BOILER_MODULE) {
			newErrors.push({
				'deviceLabel': qsTr("Boiler module"),
				'deviceIcon': "image://scaled/images/display.svg",
				'statusText': qsTr("connectivity-boilermodule-title"),
				'statusIcon': "image://scaled/apps/thermostatSettings/drawables/status-error-heating.svg",
				'adviceText': qsTr("connectivity-boilermodule-advice"),
				'errorCode': "A01"
			});
		}
		if (app.thermostatState & app.thermostatStates.CONNECTIVITY_OPENTHERM) {
			newErrors.push({
				'deviceLabel': qsTr("Boiler module"),
				'deviceIcon': "image://scaled/images/display.svg",
				'statusText': app.hasHeatRecovery ? qsTr("connectivity-opentherm-heatrec-title") : qsTr("connectivity-opentherm-title"),
				'statusIcon': "image://scaled/apps/thermostatSettings/drawables/status-error-heating.svg",
				'adviceText': app.hasHeatRecovery ? qsTr("connectivity-opentherm-heatrec-advice") : qsTr("connectivity-opentherm-advice"),
				'errorCode': "A02"
			});
		}
		if (app.thermostatState & app.thermostatStates.CONNECTIVITY_HEAT_RECOVERY) {
			newErrors.push({
				'deviceLabel': qsTr("Heat Recovery"),
				'deviceIcon': "image://scaled/apps/thermostatSettings/drawables/heatrecovery-error-card.svg",
				'statusText': qsTr("connectivity-heatrec-title"),
				'statusIcon': "image://scaled/apps/thermostatSettings/drawables/status-error-heating.svg",
				'adviceText': qsTr("connectivity-heatrec-advice"),
				'errorCode': "A03"
			});
		}
		if (app.thermostatState & app.thermostatStates.HEATREC_ERROR) {
			newErrors.push({
				'deviceLabel': qsTr("Heat Recovery"),
				'deviceIcon': "image://scaled/apps/thermostatSettings/drawables/heatrecovery-error-card.svg",
				'statusText': app.heatRecoveryInfo["CurrentFaultcode"]
							   ? qsTr("heatrec-error-line %1").arg(app.heatRecoveryInfo["CurrentFaultcode"])
							   : qsTr("heatrec-error-generic"),
				'statusIcon': "image://scaled/images/status-error-general.svg",
				'adviceText': qsTr("heatrec-error-advice"),
				'errorCode': ""
			});
		}
		if (app.thermostatState & app.thermostatStates.BOILER_ERROR) {
			newErrors.push({
				'deviceLabel': qsTr("Boiler"),
				'deviceIcon': "image://scaled/apps/thermostatSettings/drawables/boiler-error-card.svg",
				'statusText': qsTr("boiler-error-line %1").arg(app.thermInfo.errorFound),
				'statusIcon': "image://scaled/images/status-error-general.svg",
				'adviceText': qsTr("boiler-error-advice"),
				'errorCode': ""
			});
		}
		p.errorsModel = newErrors;
	}

	ErrorCardsView {
		id: cardView
		anchors.fill: parent
		emptyViewText: qsTr("There are no heating issues anymore.")
		model: p.errorsModel
		delegate: ErrorCard {
			label: modelData.deviceLabel
			icon: Qt.resolvedUrl(modelData.deviceIcon)
			statusIcon: Qt.resolvedUrl(modelData.statusIcon)
			statusText: modelData.statusText
			errorCode: modelData.errorCode ? modelData.errorCode : ""

			onButtonClicked: showAdvice(modelData.adviceText, modelData.errorCode)
		}
	}
}
