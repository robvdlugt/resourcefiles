import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: switchLockScreen

	screenTitle: qsTr("Plug control")
	isSaveCancelDialog: true
	anchors.fill: parent
	property Item context

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args && args.context) {
			context = args.context;
			screenElements.plugName = context.plugName;
			screenElements.radioGroup.currentControlId = args.context.switchLocked;
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		context.switchLocked = screenElements.radioGroup.currentControlId === 1 ? true : false;
	}

	SwitchLockScreenElements {
		id: screenElements	
		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(150 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
	}
}
