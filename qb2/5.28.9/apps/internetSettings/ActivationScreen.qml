import QtQuick 2.1
import qb.base 1.0
import qb.components 1.0

Screen {
	id: activationScreen
	hasBackButton: false
	hasCancelButton: true
	hasHomeButton: false

	property alias selectorWizardFrames: selectorWizard.frameUrls
	property alias selectorWizardSelector: selectorWizard.selector

	function init(context) {
		selectorWizard.app = context;
		selectorWizard.selector.maxPageCount = 3;
		// frames are shown in order
		selectorWizard.frameUrls = [
			app.enterActivationCodeFrameUrl, //0, next  1, prev -1
			app.getRegistrationInfoFrameUrl, //1, next  2, prev  0
			app.confirmActivationFrameUrl,   //2, next  3, prev  0, incorrect  4
			app.sendActivationCodeFrameUrl,  //3, next  5, prev  2
			app.incorrectDataFrameUrl,       //4, next -1, prev  0
			app.activationCompletedFrameUrl  //5, next -1, prev -1
		];
	}

	function navigateToPage(page) {
		selectorWizard.selector.navigateBtn(page);
	}

	onCustomButtonClicked: {
		// TODO Functionality here?
		selectorWizard.clear();
		hide();
	}

	onCanceled: {
		// Reset initial values for activation info procedure
		var actInfo = {
			 "activationCode": ""
			,"errorCode": app._AC_NO_ERROR
			,"errorReason": ""
			,"firstName": ""
			,"insert": ""
			,"lastName": ""
			,"streetName": ""
			,"houseNumber": ""
			,"houseNumberExtension": ""
			,"zipCode": ""
			,"city": ""
			,"productVariant": ""
		}
		app.activationInfo = actInfo
	}

	onShown: {
		selectorWizard.selector.navigateBtn(app.activationNextPage)
		app.activationNextPage = 0
		if (args && args.reset === true) {
			selectorWizard.selector.navigateBtn(0);
		}
		screenStateController.screenColorDimmedIsReachable = false;
		globals.activationProcedureActive = true
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		globals.activationProcedureActive = false
	}

	// Override the 'selected' dot in the DottedSelector.
	// We set the maximum pages (dots) to 3 in the init() function, so now here
	// we can match the actual pages to the virtual ones.
	Connections {
		target: selectorWizard.selector
		onNavigate: {
			var virtualPage
			switch(page) {
			case 0:
			case 1:
				virtualPage = 0
				break;
			case 2:
			case 3:
			case 4: // Page 4 actually hides the selector dots
				virtualPage = 1
				break;
			case 5:
				virtualPage = 2
				break;
			default:
				console.log("Unexpected page index in ActivationScreen.")
			}

			selectorWizard.selector.setVirtualPage(virtualPage);
		}
	}

	SelectorWizard {
		id: selectorWizard
		customNextPage: true
		customPrevPage: true

		function appNavigatePage(page) {
			if (page === frameUrls.length - 1) {
				var buttonText = qsTr("Reboot")
				if (isWizardMode) {
					buttonText = qsTr("Continue")
				}
				addCustomTopRightButton(buttonText);
			} else {
				clearTopRightButtons();
			}
		}
	}
}
