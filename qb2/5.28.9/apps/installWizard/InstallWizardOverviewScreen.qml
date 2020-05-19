import BxtClient 1.0;
import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0

/// Overview screen for the Installation wizardstate: http://pdy5jt.axshare.com/#p=overzicht_-_start
Screen {
	id: installWizardOverviewScreen
	screenTitle: qsTr("Welcome")
	kpiPrefix: "installWizardOverviewScreen"


	function init(context) {
		registry.registerWidgetContainer("installationWizardOverviewItem", installWizardOverviewScreen);
	}

	function onWidgetRegistered(widgetInfo) {
		console.log("Registering overviewItem widget", widgetInfo.url, widgetInfo.args.weight);
		var overviewItem = util.loadComponent(widgetInfo.url,
											  null,
											  {app: widgetInfo.context,
												  weight: widgetInfo.args.weight});
		util.insertItem(overviewItem, overviewItems, "weight");
		overviewItem.initWidget(widgetInfo);
	}


	property InstallWizardApp app

	property string configMsgUuid
	property string scsyncUuid
	property string hcb_netconUuid

	function allRequiredStagesCompleted() {
		var ready = true;
		for(var i = 0; i < wizardstate.stages().length; ++i) {
			var stage = wizardstate.stages()[i];
			if (wizardstate.stageMandatory(stage) && !wizardstate.stageCompleted(stage)) {
				ready = false;
			}
		}
		return ready;
	}

	function updateState() {
		var ready = allRequiredStagesCompleted();
		if (wizardstate.stageCompleted("activation")) {
			enableCustomTopRightButton();
		} else {
			disableCustomTopRightButton();
		}

		if (ready) {
			stage.customButton.label = qsTr("Ready");
		} else {
			stage.customButton.label = qsTr("Update");
		}
	}

	Connections {
		target: wizardstate
		onStageCompletedChanged: {
			// Only update (button) state if this screen is actually on the foreground.
			if (stage.currentScreenKpiPrefix === kpiPrefix) {
				updateState();
			}
		}
	}

	onShown: {
		addCustomTopRightButton(qsTr("Ready"));
		// Read the wizard state
		updateState();
		screenStateController.screenColorDimmedIsReachable = false;
		stage.restoreTopBarColors();

		for (var i = 0; i < overviewItems.children.length; ++i) {
			overviewItems.children[i].shown(null);
		}
	}

	anchors.verticalCenter: parent.verticalCenter
	anchors.horizontalCenter: parent.horizontalCenter


	onCustomButtonClicked: {
		if (allRequiredStagesCompleted()) {
			var stages = wizardstate.stages()
			for (var i = 0; i < stages.length; i++) {
				var curStage = stages[i]
				wizardstate.setStageCompleted(curStage, true)
			}
			app.sendWizardDone();
		} else {
			wizardstate.setStageCompleted("language", false);
		}

		stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/systemSettings/SoftwareUpdateWizardScreen.qml"));
	}

	Column {

		id: overviewItems

		spacing: designElements.vMargin5

		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter

	}

	Text {
		id: versionText
		text: "cur: %1 | av: %2".arg(app.displaySoftwareVersion).arg(app.availableSoftwareVersion)

		visible: app.versionVisible

		font {
			family: qfont.light.name
			pixelSize: qfont.metaText
		}
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
	}
}
