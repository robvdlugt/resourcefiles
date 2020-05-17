import QtQuick 2.1

import qb.components 1.0

InstallWizardOverviewItem {
	id: heating

	property string kpiPrefix: "HeatingModeWizardOverviewItem."

	mainColor: "#F39C12"
	title: qsTr("Heating control")
	extra: ""
	wizardUrl: app.heatingModeSelectionScreenUrl

	primaryFeature: "heating"
	primaryButtonVisible: false

	secondaryContainerVisible: false

	onShown: {
		updatePrimaryButton();
		updateDetails();
	}

	Connections {
		target: wizardstate
		onStageCompletedChanged: {
			updatePrimaryButton();
			updateDetails();
		}
	}

	Connections {
		target: globals
		onHeatingModeChanged: updateDetails()
	}

	function updatePrimaryButton() {
		primaryButtonVisible = wizardstate.stageCompleted("activation");
	}

	function updateDetails() {
		if (! wizardstate.stageCompleted("heating")) {
			extra = qsTr("Select which device controls your heating");
			detailsList = [];
		} else {
			var currentMode;
			if (globals.heatingMode === "none")
				currentMode = qsTranslate("HeatingModeSelectionScreen", "No heating via Toon")
			else if (globals.heatingMode === "zone")
				currentMode = qsTranslate("HeatingModeSelectionScreen", "Smart radiator valves")
			else
				currentMode = qsTranslate("HeatingModeSelectionScreen", "Central heating")

			extra = "";
			detailsList = [[qsTr("Device"), currentMode]];
		}
	}
}
