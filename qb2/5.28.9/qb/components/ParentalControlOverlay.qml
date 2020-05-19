import QtQuick 2.1

import qb.components 1.0

PinEntryOverlay {
	id: root
	anchors.fill: parent
	visible: false
	titleText: qsTr("Enter your PIN to unlock the screen")
	bottomText: qsTr("I forgot my PIN code")

	onPinEntered: {
		if (parentalControl.isValidPin(pin)) {
			hide();
			notificationBar.show();
			notificationBar.hide(notifications.conf_HIDE_TIMEOUT);
		} else {
			wrongPin();
		}
	}

	onClosed: {
		screenStateController.manualDim = true;
	}

	onBottomTextClicked: {
		countly.sendEvent("ParentalControl.ForgotPin", null, null, -1, null);
		hide();
		stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/systemSettings/ParentalControlResetScreen.qml"))
	}
}
