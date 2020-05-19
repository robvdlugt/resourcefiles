import QtQuick 2.1

import qb.components 1.0

InstallWizardOverviewItem {
	id: heating

	property string kpiPrefix: "HeatingWizardOverviewItem."

	mainColor: "#F39C12"
	secondaryColor: mainColor
	title: qsTr("Heating")
	secondary: title
	extra: app.doHeat ? qsTr("Select district heating type") : qsTr("Test functioning of the boiler")
	wizardUrl: app.boilerHeatingWizardUrl
	secondaryWizardUrl: app.boilerHeatingWizardUrl

	primaryFeature: "boiler"
	secondaryFeature: primaryFeature

	primaryButtonVisible: false
	secondaryButtonVisible: false

	// ZoneControl is handled by the strvSettings app.
	property bool zoneControlAvailable: globals.enabledApps.indexOf("strvSettings") !== -1
	// If ZoneControl is available, the HeatingTypeWizardOverviewItem from strvSettings
	// will be shown as primary step, meaning this WizardOverviewItem needs to be shown
	// as secondary. Otherwise, this will be shown as the primary thermostat/heating related
	// wizard item.
	primaryContainerVisible: ! zoneControlAvailable
	secondaryContainerVisible: false // handled by updateSecondaryContainerVisible()

	onShown: {
		updatePrimaryButton();
		updateSecondaryContainerVisible();

		globals.heatingModeChanged.connect(updateSecondaryContainerVisible);
	}

	onHidden: {
		globals.heatingModeChanged.disconnect(updateSecondaryContainerVisible);
	}

	Connections {
		target: wizardstate

		onStageCompletedChanged: {
			updatePrimaryButton();
			updateSecondaryContainerVisible();
		}
	}

	function updatePrimaryButton() {
		primaryButtonVisible = wizardstate.stageCompleted("activation");
		secondaryButtonVisible = wizardstate.hasStage("heating") && wizardstate.stageCompleted("activation");
	}

	function updateSecondaryContainerVisible() {
		secondaryContainerVisible = ! primaryContainerVisible &&
				wizardstate.stageCompleted("heating") &&
				globals.heatingMode === "central"
	}
}
