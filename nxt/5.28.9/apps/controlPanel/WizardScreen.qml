import QtQuick 2.1
import qb.components 1.0

Screen {
	property alias selectorWizardFrames: selectorWizard.frameUrls
	property alias selectorWizardSelector: selectorWizard.selector
	property string plugName: app.newPlug.Name

	hasBackButton: false
	hasCancelButton: false
	hasHomeButton: false

	function init(app) {
		// frames are shown in order
		selectorWizard.frameUrls = [
			app.connectionQualityFrameUrl,
			app.nameFrameUrl,
			app.switchLockFrameUrl,
			app.allOnOffFrameUrl,
			app.resultFrameUrl
		];
	}

	onCustomButtonClicked: {
		app.setDeviceName(app.newPlug.DevUUID, plugName);
		app.setInSwitchAll(app.newPlug.DevUUID, app.addToAllOnOff === 1);
		app.setSwitchLocked(app.newPlug.DevUUID, app.switchLocked === 1);
		selectorWizard.clear();
		hide();
	}

	onShown: {
		if (args && args.reset === true) {
			selectorWizard.selector.navigateBtn(0);
			app.addToAllOnOff = 1;
			app.switchLocked = 0;
		}
		// call this to make sure the top button is set up when coming back
		// from an edit screen at the last overview frame
		selectorWizard.selector.navigateBtn(selectorWizard.selector.currentPage);
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	SelectorWizard {
		id: selectorWizard
		customNextPage: true

		function appNavigatePage(page) {
			// if this is the first page, hide the left arrow, otherwise show it
			if (page === 0) {
				selector.leftArrowVisible = false
			} else {
				selector.leftArrowVisible = true
			}

			if(page === 1) { //app.nameFrameUrl
				selector.rightArrowEnabled = Qt.binding(function () {
					return currentFrame.hasDataSelected;
				});
			} else {
				selector.rightArrowEnabled = true;
			}

			if (page === frameUrls.length - 1) {
				selector.rightArrowVisible = false;
				addCustomTopRightButton(qsTr("Confirm"));
			} else {
				selector.rightArrowVisible = true;
				clearTopRightButtons();
			}
		}
	}
}
