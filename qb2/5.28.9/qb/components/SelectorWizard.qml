import QtQuick 2.1
import qb.base 1.0

// Widget for Screen
// prerequisites: must be part of a screen because it makes use of Screen's setTitle()
// frameUrls must be an array of URLs with reference to QML files that contain a WizardFrame

Widget {
	id: selectorWizard

	property bool customNextPage: false
	property bool customPrevPage: false
	property alias selector: dottedSelector
	property alias currentFrame: frameLoader.item // The currently loaded WizardFrame
	property variant prevFrames: []
	property variant frameData: []
	property variant frameUrls: []

	QtObject {
		id: p

		function navigatePage(page) {
			frameLoader.source = frameUrls[page];
			frameLoader.item.app = parent.app;

			frameLoader.item.wizard = selectorWizard
			frameLoader.item.initWizardFrame(frameData[page]);

			appNavigatePage(page);
			setTitle(frameLoader.item.title);
		}

		function storeCurrentPageData() {
			if (frameLoader.item !== null) {
				var newFrameData = frameData;
				newFrameData[dottedSelector.currentPage] = frameLoader.item.getFrameData();
				frameData = newFrameData;
			}
		}

	}

	anchors.fill: parent

	function clear() {
		frameLoader.source = "";
		prevFrames = [];
		frameData = [];
	}

	// may be overridden by SelectorWizard instance in app
	function appNavigatePage(page) {
		dottedSelector.rightArrowVisible = frameLoader.item.hasDataSelected;

		// if this is the first page, hide the left arrow, otherwise show it
		if (page === 0) {
			selector.leftArrowVisible = false
		} else {
			selector.leftArrowVisible = true
		}

		// if this is last page hide right arrow and add confirm button
		if (page === frameUrls.length - 1) {
			dottedSelector.rightArrowVisible = false;
			addCustomTopRightButton(qsTr("Confirm"));
		} else {
			clearTopRightButtons();
		}
	}


	Loader {
		id: frameLoader

		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: dottedSelector.visible ? dottedSelector.top : parent.bottom
		}
	}

	DottedSelector {
		id: dottedSelector
		width: Math.round(488 * horizontalScaling)

		pageCount: frameUrls.length
		customArrowCallback: true
		rightArrowVisible: false

		onLeftArrowClicked: {
			p.storeCurrentPageData()
			var previousPageIndex = customPrevPage ? frameLoader.item.previousPage : prevFrames[currentPage]

			console.log("Navigating to page: ", previousPageIndex)
			navigateBtn(previousPageIndex);
		}

		onRightArrowClicked: {
			p.storeCurrentPageData()
			var nextPageIndex = customNextPage ? frameLoader.item.nextPage : currentPage + 1;

			var newInfo = prevFrames;
			newInfo[nextPageIndex] = currentPage;
			prevFrames = newInfo;

			navigateBtn(nextPageIndex);
		}

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}

		onNavigate: p.navigatePage(page)
	}
}
