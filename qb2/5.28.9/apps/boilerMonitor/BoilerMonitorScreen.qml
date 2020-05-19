import QtQuick 2.11

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

import "BoilerMonitorConstants.js" as Constants

Screen {
	id: root
	property BoilerMonitorApp app

	screenTitle: app.appName
	screenTitleIconUrl: app.boilerImageUrl

	property bool cancelShow: false

	signal fetchFinished(variant success)

	Component.onCompleted: {
		qtUtils.queuedConnect(root, "fetchFinished(QVariant)", root, "fetchCallback(QVariant)");
		QT_TR_NOOP("water-pressure-high-title");
		QT_TR_NOOP("water-pressure-high-text");
		QT_TR_NOOP("water-pressure-low-title");
		QT_TR_NOOP("water-pressure-low-text");
	}


	QtObject {
		id: p
		property int daysToMaintenance
		property bool doWaterPressureCheck: false

		function showAddMaintenanceScreen() {
			stage.openFullscreen(app.boilerAddMaintenanceScreenUrl);
		}

		function showMaintenanceAdvicePopup(advice) {
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl);
			qdialog.context.dynamicContent.tips = [
				{
					title: qsTr("popup-maintenance-title"),
					text: advice,
					textFormat: Text.StyledText,
					image: Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/popup-maintenance.svg"),
					align: "left"
				}
			];
		}

		function showFaultAdvicePopup(priority, advice, oemFaultCode) {
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl);
			qdialog.context.dynamicContent.tips = [
				{
					title: qsTr("Fault code: %1").arg(oemFaultCode),
					text: advice,
					textFormat: Text.StyledText,
					image: Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/popup-" + (priority === "DIY" ? "diy" : "maintenance") + ".svg"),
					align: "left"
				}
			];
		}

		function showWaterPressureCheckPopup() {
			app.waterPressureBoilerInfoRequested = true;
			app.saveAppConfig();
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl,
							   qsTr("Fill in"), function () {
								   p.doWaterPressureCheck = true;
								   stage.openFullscreen(app.boilerInfoOverviewScreenUrl);
							   },
							   qsTr("No, thanks"));
			qdialog.context.highlightPrimaryBtn = true;
			qdialog.context.closeBtnForceShow = true;
			qdialog.context.dynamicContent.tips = [
				{
					title: qsTr("water-pressure-check-popup-title"),
					text: qsTr("water-pressure-check-popup-text"),
					textFormat: Text.StyledText,
					image: Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/boiler-check-tip-image.svg"),
					align: "left"
				}
			];
		}

		function showWaterPressureResultPopup(result) {
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl,
							   result ? qsTr("Check out") : undefined, function () {
								   stage.openFullscreen(app.boilerWaterPressureScreenUrl);
							   });
			qdialog.context.highlightPrimaryBtn = true;
			qdialog.context.closeBtnForceShow = true;
			qdialog.context.dynamicContent.tips = [
				{
					title: qsTr("water-pressure-result-popup-title"),
					text: result ? qsTr("water-pressure-result-good-popup-text") : qsTr("water-pressure-result-bad-popup-text"),
					textFormat: Text.StyledText,
					image: Qt.resolvedUrl("image://scaled/apps/boilerMonitor/drawables/water-pressure-"+(!result ? "not-" : "")+"available.svg"),
					align: "left"
				}
			];
		}
	}

	onShown: {
		fetchData();
		app.removeMaintenanceNotification();
		app.confirmFirstUse();
		addWaterPressureButton();
		if (args) {
			if (args.openProfile) {
				cancelShow = true;
				stage.openFullscreen(app.boilerInfoOverviewScreenUrl);
				return;
			}
			if (args.fromWaterPressureNotification
					&& app.boilerStatus.waterPressure
					&& app.boilerStatus.waterPressure.state.indexOf("UNKNOWN") === -1) {
				cancelShow = true;
				stage.openFullscreen(app.boilerWaterPressureScreenUrl);
				return;
			}
		}
	}

	onHidden: {
		app.backendDataReceivedChanged.disconnect(updateScreen);
		app.boilerStatusChanged.disconnect(updateScreen);
	}

	Component.onDestruction: {
		fetchFinished.disconnect(fetchCallback);
		app.backendDataReceivedChanged.disconnect(updateScreen);
		app.boilerStatusChanged.disconnect(updateScreen);
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.boilerWaterPressureScreenUrl);
	}

	Connections {
		target: app
		enabled: root.visible
		onBoilerStatusChanged: {
			if (p.doWaterPressureCheck
					&& app.boilerStatus.waterPressure.state
					&& app.boilerStatus.waterPressure.state.indexOf("UNKNOWN") === -1) {
				p.showWaterPressureResultPopup(app.boilerStatus.waterPressure.state !== "UNSUPPORTED");
				p.doWaterPressureCheck = false;
			}
			addWaterPressureButton();
		}
	}

	function fetchData() {
		state = "LOADING";
		// reset boiler status data flag so we fetch it again
		app.backendDataReceived &= ~Constants.BACKEND_DATA.BOILER_STATUS
		app.fetchDataFromBackend(false, fetchFinished);
	}

	function fetchCallback(success) {
		updateScreen();
		app.backendDataReceivedChanged.connect(updateScreen);
		app.boilerStatusChanged.connect(updateScreen);
		if (app.boilerStatus.waterPressure
				&& app.boilerStatus.waterPressure.state === "BOILER_UNKNOWN"
				&& !app.waterPressureBoilerInfoRequested) {
			p.showWaterPressureCheckPopup();
		}
	}

	function updateScreen() {
		root.state = "";
		if (!app.hasBackendData(Constants.BACKEND_DATA.BOILER_STATUS) ||
				!app.hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG)) {
			root.state = "NO_DATA";
			return;
		}

		switch(app.boilerStatus.state) {
		case undefined:
		case "INFO_INCOMPLETE":
			root.state = "INFO_REQUIRED";
			break;
		case "FAULT":
			if (app.boilerStatus.fault.state === "FAULT" || app.boilerStatus.fault.state === "FAULT_UNKNOWN") {
				root.state = "FAULT";
			} else if (app.boilerStatus.fault.state === "FAULT_BOILER_UNKNOWN") {
				root.state = "FAULT_BOILER_UNKNOWN";
			}
			break;
		case "WATER_PRESSURE":
			root.state = "WATER_PRESSURE";
			break;
		case "MAINTENANCE":
			switch(app.boilerStatus.maintenance.state) {
			case "DUE":
				root.state = "MAINTENANCE_DUE";
				break;
			}
			break;
		case "OK":
									  // remove this conditional once SC sends correct root status
									  // or there is another way to know maintenance advice is disabled
			if (app.progress === 0 || (app.serviceConfiguration["enableServiceInterval"] && app.boilerStatus.maintenance.state === "UNDETERMINED"))
				root.state = "INFO_REQUIRED";
			break;
		}
	}

	function addWaterPressureButton() {
		if (root.visible
				&& app.boilerStatus.waterPressure
				&& ["OK", "LOW", "HIGH"].indexOf(app.boilerStatus.waterPressure.state) > -1) {
			if (!stage.customButton.visible)
				stage.addCustomTopRightButton(qsTr("Water pressure"));
		} else {
			if (stage.customButton.visible)
				stage.clearTopRightButtons();
		}
	}

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: Math.round(35 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: boilerProfilePanel.left
			rightMargin: Math.round(30 * horizontalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
		color: colors._harry
		wrapMode: Text.WordWrap
		lineHeight: 0.8
		text: qsTr("boiler-ok-title")
	}

	Text {
		id: primaryText
		anchors {
			top: title.bottom
			topMargin: designElements.vMargin15
			left: title.left
			right: title.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors._harry
		wrapMode: Text.WordWrap
		text: qsTr("boiler-ok-text")
	}

	StandardButton {
		id: primaryButton
		anchors {
			top: primaryText.bottom
			topMargin: designElements.vMargin20
			left: title.left
		}
		primary: true
		visible: false
	}

	Text {
		id: secondaryText
		visible: false
		anchors {
			top: primaryButton.bottom
			topMargin: Math.round(32 * verticalScaling)
			left: title.left
			right: title.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors._harry
		wrapMode: Text.WordWrap
	}

	StandardButton {
		id: secondaryButton
		anchors {
			top: secondaryText.bottom
			topMargin: designElements.vMargin20
			left: title.left
		}
		visible: false
	}

	Rectangle {
		id: boilerProfilePanel
		width: Math.round(250 * horizontalScaling)
		radius: designElements.radius
		anchors {
			top: parent.top
			topMargin: designElements.vMargin10
			bottom: parent.bottom
			bottomMargin: Math.round(27 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		color: colors.contentBackground

		Text {
			id: boilerProfileTitle
			anchors {
				top: parent.top
				topMargin: Math.round(12 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			font {
				family: qfont.bold.name
				pixelSize: qfont.titleText
			}
			color: colors._harry
			wrapMode: Text.WordWrap
			text: qsTr("boiler_profile_title")
		}

		Image {
			id: boilerIllustration
			anchors {
				top: boilerProfileTitle.bottom
				topMargin: Math.round(16 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			source: "image://scaled/apps/boilerMonitor/drawables/boiler-only.svg"

			Image {
				id: badge
				anchors {
					top: parent.top
					horizontalCenter: parent.left
				}
				source: "image://scaled/apps/boilerMonitor/drawables/badge-ok.svg"
			}
		}

		ProgressBar {
			id: progressBar
			anchors {
				top: boilerIllustration.bottom
				topMargin: Math.round(16 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(20 * horizontalScaling)
				left: parent.left
				leftMargin: anchors.rightMargin
			}
			progress: app.progress
			visible: app.hasBackendData(Constants.BACKEND_DATA.BOILER_PROFILE) &&
					 app.hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG) &&
					 !boilerFaultCode.visible
		}

		Text {
			id: boilerProfileStatusText
			anchors {
				top: progressBar.bottom
				topMargin: Math.round(23 * verticalScaling)
				left: progressBar.left
				right: progressBar.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._harry
			wrapMode: Text.WordWrap
			visible: !boilerFaultCode.visible
			text: {
				if (app.hasBackendData(Constants.BACKEND_DATA.BOILER_PROFILE) && app.hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG)) {
					if (app.progress === 1)
						qsTr("boiler_profile_complete")
					else
						qsTr("boiler_profile_status").arg(Math.floor(app.progress * 100))
				} else {
					qsTr("boiler_profile_not_available")
				}
			}
		}

		Text {
			id: boilerFaultCodeHeader
			anchors {
				top: boilerIllustration.bottom
				topMargin: Math.round(16 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._harry
			text: qsTr("Fault code")
			visible: boilerFaultCode.visible
		}

		Text {
			id: boilerFaultCode
			anchors {
				baseline: boilerFaultCodeHeader.baseline
				baselineOffset: Math.round(35 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			font {
				family: qfont.bold.name
				pixelSize: qfont.primaryImportantBodyText
			}
			color: colors._harry
			visible: false
		}

		StandardButton {
			id: boilerProfileButton
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(20 * verticalScaling)
				left: progressBar.left
				right: progressBar.right
			}
			text: app.progress === 1 ? qsTr("boiler_profile_complete_button_text") : qsTr("boiler_profile_button_text")
			enabled: app.hasBackendData(Constants.BACKEND_DATA.BOILER_PROFILE) &&
					 app.hasBackendData(Constants.BACKEND_DATA.SERVICE_CONFIG)

			onClicked: stage.openFullscreen(app.boilerInfoOverviewScreenUrl, {fetch: true})
		}
	}

	states: [
		State {
			name: "LOADING"
			PropertyChanges { target: badge; source: "image://scaled/apps/boilerMonitor/drawables/badge-loading.svg" }
			PropertyChanges { target: title; text: qsTr("retrieving-data-title") }
			PropertyChanges { target: primaryText; text: qsTr("retrieving-data-text") }
		},
		State {
			name: "NO_DATA"
			PropertyChanges { target: badge; source: "image://scaled/apps/boilerMonitor/drawables/badge-unknown.svg" }
			PropertyChanges { target: title; text: qsTr("no-backend-data-title") }
			PropertyChanges { target: primaryText; text: qsTr("no-backend-data-text") }
			PropertyChanges { target: primaryButton; visible: true; primary: false; text: qsTr("Try again"); onClicked: fetchData() }
		},
		State {
			name: "FAULT"
			PropertyChanges { target: title; explicit: true; text: app.boilerStatus.fault.description }
			PropertyChanges { target: primaryText; explicit: true; text: app.boilerStatus.fault.consequence }
			PropertyChanges {
				target: primaryButton; visible: app.boilerStatus.fault.advice ? true : false; text: qsTr("What can I do?")
				onClicked: p.showFaultAdvicePopup(app.boilerStatus.fault.priority,
												  app.boilerStatus.fault.advice,
												  app.boilerStatus.fault.oemFaultCode)
			}
			PropertyChanges {
				target: badge
				source: "image://scaled/apps/boilerMonitor/drawables/badge-" + (app.boilerStatus.fault.priority === "DIY" ? "diy" : "fault") + ".svg"
			}
			PropertyChanges { target: boilerFaultCode; explicit: true; text: app.boilerStatus.fault.oemFaultCode >= 0 ? app.boilerStatus.fault.oemFaultCode : " " }
			PropertyChanges { target: boilerFaultCode; visible: true }
		},
		State {
			name: "FAULT_BOILER_UNKNOWN"
			PropertyChanges { target: title; explicit: true; text: app.boilerStatus.fault.description }
			PropertyChanges { target: primaryText; explicit: true; text: app.boilerStatus.fault.consequence }
			PropertyChanges {
				target: primaryButton; visible: app.boilerStatus.fault.advice ? true : false; text: qsTr("What can I do?")
				onClicked: p.showFaultAdvicePopup(app.boilerStatus.fault.priority,
												  app.boilerStatus.fault.advice,
												  app.boilerStatus.fault.oemFaultCode)
			}
			PropertyChanges { target: primaryButton; primary: false; visible: true; text: qsTr("What can I do?"); }
			PropertyChanges { target: badge; source: "image://scaled/apps/boilerMonitor/drawables/badge-fault.svg" }
			PropertyChanges { target: progressBar; colorProgress: colors.errorBtnUp }
			PropertyChanges { target: boilerProfileButton; primary: true }
		},
		State {
			name: "MAINTENANCE_DUE"
			PropertyChanges { target: title; explicit: true; text: app.boilerStatus.maintenance.description }
			PropertyChanges { target: primaryText; explicit: true; text: app.boilerStatus.maintenance.consequence }
			PropertyChanges {
				target: primaryButton; visible: true; text: qsTr("What can I do?")
				onClicked: p.showMaintenanceAdvicePopup(app.boilerStatus.maintenance.advice)
			}
			PropertyChanges { target: secondaryText; visible: true; text: qsTr("maintenance-due-reset-text") }
			PropertyChanges { target: secondaryButton; visible: true; text: qsTr("Adjust"); onClicked: p.showAddMaintenanceScreen() }
			PropertyChanges { target: badge; source: "image://scaled/apps/boilerMonitor/drawables/badge-maintenance.svg" }
		},
		State {
			name: "WATER_PRESSURE"
			PropertyChanges { target: title; text: qsTr("water-pressure-"+app.boilerStatus.waterPressure.state.toLowerCase()+"-title") }
			PropertyChanges { target: primaryText; text: qsTr("water-pressure-"+app.boilerStatus.waterPressure.state.toLowerCase()+"-text") }
			PropertyChanges {
				target: primaryButton; visible: true; text: qsTr("More information")
				onClicked: stage.openFullscreen(app.boilerWaterPressureScreenUrl)
			}
			PropertyChanges {
				target: boilerIllustration
				source: "image://scaled/apps/boilerMonitor/drawables/boiler-pressure-"+app.boilerStatus.waterPressure.state.toLowerCase()+".svg"
			}
			PropertyChanges {
				target: badge
				source: "image://scaled/apps/boilerMonitor/drawables/badge-pressure-"+app.boilerStatus.waterPressure.state.toLowerCase()+".svg"
			}
		},
		State {
			name: "INFO_REQUIRED"
			PropertyChanges { target: title; text: qsTr("info-required-title") }
			PropertyChanges { target: primaryText; text: qsTr("info-required-text") }
			PropertyChanges { target: badge; source: "image://scaled/apps/boilerMonitor/drawables/badge-info-required.svg" }
		}
	]
}
