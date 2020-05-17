import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;


Screen {
	id: houseTypeScreen

	property int pagecount: 0
	property WizardFrame houseTypeFrame
	property WizardFrame apartmentOptionsFrame
	
	function init(context) {
		houseTypeFrame.setSource(app.houseTypeFrameUrl, {"app": app});
		houseTypeFrame.item.initWizardFrame();
		pagecount++;
		apartmentOptionsFrame.setSource(app.apartmentOptionsFrameUrl, {"app": app});
		apartmentOptionsFrame.item.initWizardFrame();
		pagecount++;

		if (houseTypeFrame.item.aptSelected !== undefined) {
			houseTypeFrame.item.aptSelected.connect(onAptSelectedChange);
		}
	}

	screenTitle: qsTr("House type")
	anchors.fill: parent
	isSaveCancelDialog: true

	onShown: {
		selector.navigateBtn(0);
		houseTypeFrame.item.setCurrentControlId(parseInt(app.profileInfo.homeType));
		apartmentOptionsFrame.item.initWizardFrame(parseInt(app.profileInfo.homeTypeAlt));
	}

	onSaved: {
		app.setProfileInfo(houseTypeFrame.item.outcomeData,
						   apartmentOptionsFrame.item.outcomeData,
						   app.profileInfo.homeSize,
						   app.profileInfo.homeBuildPeriod,
						   app.profileInfo.familyType
						   );
	}

	function onAptSelectedChange(selected) {
		if (selected) {
			selector.visible = true;
			disableSaveButton();
		} else {
			selector.visible = false;
			enableSaveButton();
		}
	}

	function navigatePage(page) {
		if (page === 1) {
			enableSaveButton();
		} else {
			disableSaveButton();
		}

		unflickableFrameContainer.contentX = page * unflickableFrameContainer.width;
	}

	UnFlickable {
		id: unflickableFrameContainer
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: selector.top
		}
		clip: true

		Loader {
			id: houseTypeFrame
			width: parent.width
			height: parent.height
		}

		Loader {
			id: apartmentOptionsFrame
			width: parent.width
			height: parent.height
			anchors.left: houseTypeFrame.right
		}
	}

	DottedSelector {
		id: selector
		width: Math.round(488 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}

		hideArrowsOnBounds: true

		pageCount: pagecount
		onNavigate: navigatePage(page)
	}
}
