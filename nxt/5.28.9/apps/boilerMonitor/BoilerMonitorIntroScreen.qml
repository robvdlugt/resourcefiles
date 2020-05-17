import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

import "BoilerMonitorConstants.js" as Constants

Screen {
	id: boilerMonitorIntroScreen
	screenTitle: app.appName
	screenTitleIconUrl: app.boilerImageUrl
	inNavigationStack: false

	signal saveFinished(variant success)

	Component.onCompleted: {
		qtUtils.queuedConnect(boilerMonitorIntroScreen, "saveFinished(QVariant)", boilerMonitorIntroScreen, "saveCallback(QVariant)");
	}

	onShown: screenStateController.screenColorDimmedIsReachable = false
	onHidden: screenStateController.screenColorDimmedIsReachable = true

	QtObject {
		id: p
		property bool needConsent: app.hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG) && !app.serviceConfiguration["automaticConsent"] &&
										app.hasBackendData(Constants.BACKEND_DATA.CONSENT) && app.consentSet !== true
	}

	function saveCallback(success) {
		if (success) {
			if (app.consentSet === false)
				stage.navigateHome();
			else
				stage.openFullscreen(app.boilerMonitorScreenUrl, {resetNavigation: true, openProfile: true});
		} else {
			toast.show(qsTranslate("EditScreen", "save-failed"), Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/reload.svg"));
			progressThrobber.visible = false;
			acceptButton.enabled = false;
			declineButton.enabled = false;
		}
	}

	function setConsent(enabled) {
		progressThrobber.visible = true;
		acceptButton.enabled = false;
		declineButton.enabled = false;

		app.setConsent(enabled, boilerMonitorIntroScreen);
	}

	Text {
		id: firstUseTitle
		text:	pageSelector.currentPage === 0 ? qsTr("boilerMonitor first use page1 title") :
				pageSelector.currentPage === 1 ? qsTr("boilerMonitor first use page2 title") :
												 qsTr("boilerMonitor first use page3 title")
		wrapMode: Text.WordWrap

		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: firstUseImage.left
			rightMargin: Math.round(30 * horizontalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
	}

	Text {
		id: firstUseText

		text:	pageSelector.currentPage === 0 ? qsTr("boilerMonitor_first_use_page1_body_text") :
				pageSelector.currentPage === 1 ? qsTr("boilerMonitor_first_use_page2_body_text") :
												 qsTr("boilerMonitor_first_use_page3_body_text")
		wrapMode: Text.WordWrap

		anchors {
			top: firstUseTitle.bottom
			topMargin: Math.round(20 * verticalScaling)
			left: firstUseTitle.left
			right: firstUseTitle.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	StandardButton {
		id: acceptButton
		anchors {
			left: firstUseTitle.left
			top: firstUseText.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		kpiPostfix: "enableAdvice"
		text: p.needConsent ? qsTr("Turn on boiler advice") : qsTr("Fill in the boiler profile")
		visible: pageSelector.currentPage === 2
		primary: p.needConsent

		onVisibleChanged: if (visible) app.confirmFirstUse()

		onClicked: {
			if (p.needConsent) {
				setConsent(true);
			} else {
				stage.openFullscreen(app.boilerMonitorScreenUrl, {resetNavigation: true, openProfile: true});
			}
		}
	}

	StandardButton {
		id: declineButton
		anchors {
			top: acceptButton.top
			left: acceptButton.right
			leftMargin: designElements.hMargin15
		}
		visible: p.needConsent && pageSelector.currentPage === 2
		text: qsTr("No, thank you")

		onClicked: app.confirmDisableAdvice(boilerMonitorIntroScreen)
	}

	Throbber {
		id: progressThrobber
		anchors {
			verticalCenter: declineButton.verticalCenter
			left: declineButton.right
			leftMargin: designElements.hMargin15
		}
		visible: false
	}

	Toast {
		id: toast
	}

	Image {
		id: firstUseImage
		source: "image://scaled/apps/boilerMonitor/drawables/" +
				(pageSelector.currentPage === 0 ? "intro-01.svg" :
				(pageSelector.currentPage === 1 ? "intro-02.svg" :
												  "intro-03.svg"))
		anchors {
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
			bottom: pageSelector.top
		}
	}

	DottedSelector {
		id: pageSelector
		pageCount: 3

		leftArrowEnabled: currentPage != 0
		rightArrowEnabled: currentPage != pageCount - 1
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(20 * verticalScaling)
		}
	}
}
