import QtQuick 2.1

import qb.components 1.0

import "Constants.js" as Constants

InstallWizardOverviewItem {
	id: eMeters

	property EMetersSettingsApp app

	property string kpiPrefix: "MetersWizardOverviewItem."

	primaryFeature: "emeters"

	mainColor: "#BACC33"
	secondaryColor: "#C1CC6E"
	title: qsTr("Energy Meters")
	extra: "" // Empty
	wizardUrl: app.eMetersScreenUrl

	primaryButtonVisible: false

	secondary: feature.enabledGasMeterConfiguration() ? qsTr("Check type electricity/gas meter") : qsTr("Check type electricity meter")
	secondaryWizardUrl: app.meterConfigurationInstallScreenUrl
	secondaryContainerVisible: primaryCompleted && needsCValueConfiguration
	secondaryButtonVisible: true

	property bool needsCValueConfiguration: false

	property bool elecSensorProblem: false
	property bool gasSensorProblem: false

	primaryWarningVisible: elecSensorProblem || gasSensorProblem

	onShown: {
		app.getSensorConfiguration();
		app.getAllMeterConfigurations();

		updatePrimaryButton();
		updateDetailsList();
		updateNeedsMeterConfiguration();
	}

	onSecondaryWizardOpened: {
		if (secondaryContainerVisible) {
			secondaryCompleted = true;
		}
	}

	Connections {
		target: app
		onMaConfigurationChanged: updateDetailsList();
		onMeterConfigurationChanged: updateNeedsMeterConfiguration();
		onUsageDevicesInfoChanged: {
			updateDetailsList();
			updateNeedsMeterConfiguration();
		}
	}

	Connections {
		target: wizardstate

		onStageCompletedChanged: {
			updatePrimaryButton();
		}
	}

	function updatePrimaryButton() {
		primaryButtonVisible = wizardstate.stageCompleted("activation");
	}

	function updateDetailsList() {
		var tmpDetailsList = [];

		var hasGasSensor = false;
		var hasElecSensor = false;

		for (var i = 0 ; i < app.maConfiguration.length; ++i) {
			var statusInt = app.maConfiguration[i].statusInt;
			if (statusInt & Constants.CONFIG_STATUS.GAS) {
				hasGasSensor = true;
			}
			if (statusInt & Constants.CONFIG_STATUS.ELEC) {
				hasElecSensor = true;
			}
		}

		if (globals.productOptions["electricity"] === "1") {
			tmpDetailsList.push([qsTr("Electricity"), status2String(hasElecSensor, "elec")]);
		}
		if (globals.productOptions["gas"] === "1") {
			tmpDetailsList.push([qsTr("Gas"), status2String(hasGasSensor, "gas")]);
		}

		detailsList = tmpDetailsList;
	}

	function status2String(hasSensor, type) {
		var retString;
		var sensorProblem;

		if (! hasSensor) {
			// The sensor not being configured (yet) is not a problem that needs to
			// be reported with the warning icon. Therefor: sensorProblem = false.
			sensorProblem = false;
			retString = qsTr("Not configured yet");
		} else {
			var typeUsage = app.getUsageByType(type);

			if (! typeUsage || ! typeUsage.usage) {
				sensorProblem = true;
				retString = qsTr("Problem with sensor");
			} else {
				switch (typeUsage.usage.status) {
				case Constants.meterStatusValues.ST_OPERATIONAL:
				case Constants.meterStatusValues.ST_COMMISSIONING:
					sensorProblem = false;
					retString = qsTr("Ok");
					break;
				default:
					sensorProblem = true;
					retString = qsTr("Problem with sensor");
					break;
				}
			}
		}

		if (type === "elec") elecSensorProblem = sensorProblem;
		else if (type === "gas") gasSensorProblem = sensorProblem;

		return retString;
	}

	function updateNeedsMeterConfiguration() {
		var needsElecMeterConfiguration = false;
		var needsGasMeterConfiguration = false;
		for (var uuid in app.meterConfiguration) {
			for (var resource in app.meterConfiguration[uuid]) {
				if (app.meterConfiguration[uuid][resource].dividerType !== undefined) {
					if (resource === "elec")
						needsElecMeterConfiguration = true;
					else if (resource === "gas")
						needsGasMeterConfiguration = true;
				}
			}
		}
		needsCValueConfiguration = needsElecMeterConfiguration || needsGasMeterConfiguration;
	}
}
