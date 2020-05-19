import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Screen {
	id: root
	property BoilerMonitorApp app

	isSaveCancelDialog: true
	synchronousSave: true

	signal screenShown(variant args)
	signal screenHidden()
	signal screenSaved()
	signal saveFinished(variant success)

	Component.onCompleted: {
		qtUtils.queuedConnect(root, "saveFinished(QVariant)", root, "saveCallback(QVariant)");
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		screenShown(args);
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		screenHidden();
	}

	onSaved: {
		disableSaveButton();
		screenSaved();
		showSaveThrobber(true);
	}

	function saveCallback(success) {
		showSaveThrobber(false);
		enableSaveButton();
		if (success)
			hide();
		else
			toast.show(qsTr("save-failed"), Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/reload.svg"));
	}

	Toast {
		id: toast
	}
}
