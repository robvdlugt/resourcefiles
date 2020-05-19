import QtQuick 2.11

import qb.base 1.0
import qb.components 1.0

Popup {
	id: imageGallery

	property url imageDir
	property string kpiPrefix
	property bool showCentralButtonOnFirstPage: false
	property bool showCentralButtonOnLastPage: false

	property alias buttonText: centralBtn.text

	state: "dialogPopup"

	states: [
		State {
			name: "dialogPopup"
			PropertyChanges { target: centralBtn; color: colors.btnUp}
			PropertyChanges { target: centralBtn; fontColor: colors.btnText}
			PropertyChanges { target: centralBtn; useOverlayColor: false}
			PropertyChanges { target: centralBtn; defaultHeight: Math.round(36 * verticalScaling)}
			PropertyChanges { target: centralBtn; borderWidth: 0}
			PropertyChanges { target: closeBtn; overlayWhenUp: false}
			PropertyChanges { target: closeBtn; colorDown: colors.dsColorDown}
			PropertyChanges { target: closeBtn; overlayColorDown: colors.dsOverlayColorDown}
		},
		State {
			name: "transparentPopup"
			PropertyChanges { target: centralBtn; color: colors.igpTransparentBackgrnd}
			PropertyChanges { target: centralBtn; fontColor: colors.igpTransparentForegrnd}
			PropertyChanges { target: centralBtn; useOverlayColor: true}
			PropertyChanges { target: centralBtn; defaultHeight: Math.round(40 * verticalScaling)}
			PropertyChanges { target: centralBtn; borderWidth: 2}
			PropertyChanges { target: closeBtn; overlayWhenUp: true}
			PropertyChanges { target: closeBtn; overlayColorUp: colors.igpTransparentForegrnd}
			PropertyChanges { target: imageSelector;  arrowOverlayWhenUp: true}
			PropertyChanges { target: imageSelector;  arrowOverlayColorUp: colors.igpTransparentForegrnd}
			PropertyChanges { target: imageSelector;  arrowColorDown: colors.ibColorDown}
			PropertyChanges { target: imageSelector;  arrowOverlayColorDown: colors.igpTransparentForegrnd}
		}
	]

	QtObject {
		id: p
		property int pageOffsetNavigator: 0
		property int currentPage: 0
		property int numberOfImages: 0
		property variant images
	}

	signal lastPageButtonClicked

	onShown: {
		imageSelector.currentPage = 0;
		imageSelector.navigate(0);
		navigatePage(0);
	}

	onHidden: {
		state = "dialogPopup";
		gallery.source = "";
	}

	onShowCentralButtonOnFirstPageChanged: {
		p.pageOffsetNavigator = showCentralButtonOnFirstPage ? 1 : 0;
	}

	onImageDirChanged: {
		p.images = app.getImages(imageDir);
		p.numberOfImages = p.images.length;

		var dirs = imageDir.toString().split("/");
		kpiPrefix = dirs[dirs.length - 2] + ".";
	}

	function navigatePage(page) {
		p.currentPage = page;
		gallery.source = imageDir + p.images[p.currentPage];
		if (page < p.pageOffsetNavigator) {
			imageSelector.visible = false;
		} else {
			imageSelector.visible = imageSelector.pageCount > 1 ? true : false;
			imageSelector.leftArrowVisible = page > p.pageOffsetNavigator;
			imageSelector.rightArrowVisible = page < p.numberOfImages - 1;
		}
		centralBtn.visible = ((page === 0) && showCentralButtonOnFirstPage) || ((page === p.numberOfImages-1) && showCentralButtonOnLastPage);
		finishedBtn.visible = (page === p.numberOfImages-1);
	}

	function handleCentralButtonClicked() {
		if (p.currentPage == 0 && showCentralButtonOnFirstPage) {
			navigatePage(1);
		} else {
			hide();
			lastPageButtonClicked();
		}
	}

	MouseArea {
		anchors.fill: parent
		property string kpiPostfix: "greyArea"
	}

	Image {
		id: gallery
		anchors.fill: parent
		cache: false

		fillMode: Image.PreserveAspectCrop
		mipmap: true
	}

	IconButton {
		id: closeBtn
		width: Math.round(45 * horizontalScaling)
		height: Math.round(45 * verticalScaling)

		anchors.right: parent.right
		anchors.rightMargin: 16
		anchors.top: parent.top
		anchors.topMargin: Math.round(16 * verticalScaling)
		iconSource: "qrc:/images/DialogCross.svg"

		leftClickMargin: 16
		rightClickMargin: 16
		topClickMargin: 16
		bottomClickMargin: 16

		colorUp: colors.igpTransparentBackgrnd

		onClicked: {
			hide();
		}
	}

	StandardButton {
		id: centralBtn

		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Math.round(150 * verticalScaling)

		borderStyle: Qt.SolidLine
		borderColor: colors.igpTransparentForegrnd
		radius: designElements.radius

		property int pageIndex: 0

		onClicked: handleCentralButtonClicked()
	}

	DottedSelector {
		id: imageSelector
		width: Math.round(488 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(21 * verticalScaling)
		}

		arrowColorUp: colors.igpTransparentBackgrnd
		arrowOverlayColorUp: colors.igpTransparentForegrnd

		pageCount: p.numberOfImages - p.pageOffsetNavigator
		onNavigate: navigatePage(page + p.pageOffsetNavigator)
	}

	IconButton {
		id: finishedBtn
		width: Math.round(30 * horizontalScaling)
		height: Math.round(30 * verticalScaling)
		radius: 15
		anchors.right: imageSelector.right
		anchors.verticalCenter: imageSelector.verticalCenter
		iconSource: "drawables/green-check.svg"

		colorUp: colors.dialogHeaderBar

		onClicked: {
			hide();
		}
	}
}
