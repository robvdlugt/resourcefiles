import QtQuick 2.1

Item {
	id: root
	width: Math.round(470 * horizontalScaling)
	height: Math.round(45 * verticalScaling)

	visible: pageCount > 1

	property real currentPage: 0
	property real pageCount: 0
	// set maxPageCount other than 0 to limit drawing of dots
	// if set, highlighted button position will remain the same
	// during navigation until
	// currentPage < maxPageCount / 2 or
	// currentPage > pageCount - maxPageCount / 2
	property int maxPageCount: 0

	property bool leftArrowVisible:  !hideArrowsOnBounds || (hideArrowsOnBounds && currentPage > 0)
	property alias leftArrowEnabled: arrowLeft.enabled
	property bool rightArrowVisible: !hideArrowsOnBounds || (hideArrowsOnBounds && currentPage < pageCount - 1)
	property alias rightArrowEnabled: arrowRight.enabled
	property bool hideArrowsOnBounds: false

	property bool customArrowCallback: false

	property alias arrowOverlayWhenUp:        arrowLeft.overlayWhenUp
	property alias arrowColorUp:              arrowLeft.colorUp
	property alias arrowColorDown:            arrowLeft.colorDown
	property alias arrowColorDisabled:        arrowLeft.colorDisabled
	property alias arrowOverlayColorUp:       arrowLeft.overlayColorUp
	property alias arrowOverlayColorDown:     arrowLeft.overlayColorDown
	property alias arrowOverlayColorDisabled: arrowLeft.overlayColorDisabled

	signal rightArrowClicked
	signal leftArrowClicked

	signal navigate(real page);

	QtObject {
		id: p
		property int virtualPage: 0
	}

	onNavigate: {
		var tmpVirtualPage = page;
		if (maxPageCount  && pageCount > maxPageCount) {
			if (page < (maxPageCount / 2)) {
				tmpVirtualPage = page;
			} else if (page > (pageCount - maxPageCount / 2)) {
				tmpVirtualPage = maxPageCount - (pageCount - page);
			} else {
				tmpVirtualPage = maxPageCount / 2;
			}
		}
		p.virtualPage = tmpVirtualPage;
	}

	// TODO: check if still needed
	// currently only being used in ActivationScreen.qml
	function setVirtualPage(virtualPage) {
		p.virtualPage = virtualPage;
	}

	function navigateLeft() {
		if (customArrowCallback) {
			leftArrowClicked();
		} else {
			if (currentPage > 0) {
				currentPage -= 1;
				navigate(currentPage);
			} else {
				currentPage = pageCount - 1;
				navigate(currentPage);
			}
		}
	}

	function navigateRight() {
		if (customArrowCallback) {
			rightArrowClicked();
		} else {
			if (currentPage < (pageCount - 1)) {
				currentPage += 1;
				navigate(currentPage);
			} else {
				currentPage = 0;
				navigate(currentPage);
			}
		}
	}

	function navigateBtn(i) {
		currentPage = i;
		navigate(i);
	}

	IconButton {
		id: arrowLeft
		width: Math.round(45 * horizontalScaling)
		height: Math.round(45 * verticalScaling)
		anchors.left: root.left
		anchors.leftMargin: 0
		iconSource: "qrc:/images/arrow-left.svg"
		visible: leftArrowVisible

		overlayWhenUp:        false
		colorUp:              colors.dsColorUp
		colorDown:            colors.dsColorDown
		colorDisabled:        colors.dsColorDisabled
		overlayColorUp:       colors.dsOverlayColorUp
		overlayColorDown:     colors.dsOverlayColorDown
		overlayColorDisabled: colors.dsOverlayColorDisabled

		onClicked: navigateLeft()
	}

	Row {
		id: widgetNavIndex
		anchors.centerIn: root
		spacing: designElements.hMargin15

		Repeater {
			model: maxPageCount ? Math.min(pageCount, maxPageCount) : pageCount
			DottedSelectorDot {
				selected: (p.virtualPage === index)
			}
		}
	}

	IconButton {
		id: arrowRight
		width: Math.round(45 * horizontalScaling)
		height: Math.round(45 * verticalScaling)
		anchors.right: root.right
		anchors.rightMargin: 0
		iconSource: "qrc:/images/arrow-right.svg"
		visible: rightArrowVisible

		overlayWhenUp:        arrowLeft.overlayWhenUp
		colorUp:              arrowLeft.colorUp
		colorDown:            arrowLeft.colorDown
		colorDisabled:        arrowLeft.colorDisabled
		overlayColorUp:       arrowLeft.overlayColorUp
		overlayColorDown:     arrowLeft.overlayColorDown
		overlayColorDisabled: arrowLeft.overlayColorDisabled

		onClicked: navigateRight()
	}
}
