import QtQuick 2.1

import qb.components 1.0

Screen {
	id: scrOffSettingScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Screen off")
	isSaveCancelDialog: true

	QtObject {
		id: p
		property string mode
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;

		if (globals.heatingMode !== "none") {
			radioButtonList.addCustomItem({"label": app.enableSME ? qsTr("When closed or away") : qsTr("When sleep or away"),
						  "mode": "programBased"});
		}
		radioButtonList.addCustomItem({"label": qsTr("After 1 hour"), "mode" : "timeBased"});
		radioButtonList.addCustomItem({"label": qsTr("Instead of dim"), "mode": "always"});
		radioButtonList.addCustomItem({"label": qsTr("Never"), "mode" : "never"});
		radioButtonList.forceLayout();

		if (screenStateController.screenOffIsProgramBased) {
			p.mode = "programBased";
		} else if (screenStateController.timeBeforeScreenOffInMin < 0) {
			p.mode = "never";
		} else if (screenStateController.timeBeforeScreenOffInMin > 0) {
			p.mode = "timeBased";
		} else {
			p.mode = "always";
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		var selectedItem = radioButtonList.getModelItem(radioButtonList.currentIndex);
		if (selectedItem) {
			screenStateController.screenOffIsProgramBased = (selectedItem.mode === "programBased");
			screenStateController.timeBeforeScreenOffInMin = (selectedItem.mode === "timeBased") ? 60 : (selectedItem.mode === "never") ? -1 : 0;
			screenStateController.notifyChangeOfSettings();
		}
	}

	RadioButtonList {
		id: radioButtonList
		anchors.centerIn: parent
		title: qsTr("Turn off the screen")

		listDelegate: StandardRadioButton {
			id: radioButton
			controlGroupId: index
			controlGroup: model.controlGroup
			text: model.label
			selected: p.mode === model.mode
		}
	}
}
