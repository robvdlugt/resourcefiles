import QtQuick 2.1

import FileIO 1.0
import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;
import BxtClient 1.0

/// Win-Wit Application

App {
	id: winwitApp

	property Popup imageGalleryPopup

	QtObject {
		id: p

		property string scsyncUuid
		property bool winAutoStarted: false
		// These are the URL's for the QML resources from which our widgets will be instantiated.
		// By making them a URL type property they will automatically be converted to full paths,
		// preventing problems when passing them around to code that comes from a different path.
		property url whatIsToonMenuUrl : "WhatIsToonMenu.qml"
		property url whatIsNewMenuUrl : "WhatIsNewMenu.qml"
		property url imageGalleryPopupUrl : "ImageGalleryPopup.qml"
		property url demoTileUrl : "DemoTile.qml"
		property bool showSolar: false
	}

	function init() {
		if (feature.appWhatIsToonEnabled()) {
			globals.startWhatIsToon.connect(showWhatIsToon);
			registry.registerWidget("menuItem", p.whatIsToonMenuUrl, winwitApp, null, {weight: 160});
		}
		if (feature.appWhatIsNewEnabled()) {
			globals.startWhatIsNew.connect(showWhatIsNew);
			registry.registerWidget("menuItem", p.whatIsNewMenuUrl, winwitApp, null, {weight: 150});
		}
		registry.registerWidget("popup", p.imageGalleryPopupUrl, winwitApp, "imageGalleryPopup");

		var demos = feature.demoTiles();
		for (var demoIdx in demos) {
			var demoDir = demos[demoIdx];
			registry.registerWidget("tile", p.demoTileUrl, winwitApp, null, {thumbLabel: qsTr("Demo"),  thumbIcon: Qt.resolvedUrl(demoDir + "/tileIcon.png"), config: {demoDir:demoDir}, thumbCategory: "general", thumbWeight: 50, baseTileWeight: 25, thumbIconVAlignment: "center"});
		}

		imageGalleryPopup.lastPageButtonClicked.connect(handleLastPageButtonClick);
		imageGalleryPopup.hidden.connect(handlePopupClose);
	}

	function showWhatIsToon() {
		if (imageGalleryPopup) {
			stage.navigateHome();

			if (feature.appStrvFeatureEnabled() && globals.heatingMode === "zone") {
				imageGalleryPopup.imageDir = "drawables/witstrv/";
			} else if (feature.enabledHeatingModeNoHeating() && globals.heatingMode === "none") {
				imageGalleryPopup.imageDir = "drawables/wit-noheating/";
			} else if ((parseInt(globals.productOptions["other_provider_elec"]) | parseInt(globals.productOptions["other_provider_gas"])) === 1) {
				imageGalleryPopup.imageDir = "drawables/witoonly/";
			} else {
				imageGalleryPopup.imageDir = "drawables/wit/";
			}

			imageGalleryPopup.showCentralButtonOnFirstPage = true;
			imageGalleryPopup.showCentralButtonOnLastPage = false;
			imageGalleryPopup.buttonText = qsTr("Start the tour");
			imageGalleryPopup.state = "dialogPopup";
			imageGalleryPopup.show();
		}
		sendWhatsnewFinished();
	}

	function showWhatIsNew() {
		if (imageGalleryPopup) {
			stage.navigateHome();
			// show different whatsnew for users who already had solar or not ("win") and who have installed solar after updating("win_solar_post")
			imageGalleryPopup.imageDir = "drawables/" + (p.showSolar ? "win_solar_post" : "win") + "/";
			imageGalleryPopup.showCentralButtonOnFirstPage = false;
			imageGalleryPopup.showCentralButtonOnLastPage = !p.showSolar;
			imageGalleryPopup.buttonText = qsTr("Go to What is Toon");
			imageGalleryPopup.state = "transparentPopup";
			imageGalleryPopup.show();
		}
	}

	function showDemo(demoDir) {
		if (imageGalleryPopup) {
			imageGalleryPopup.imageDir = demoDir + "qrc:/images/";
			imageGalleryPopup.showCentralButtonOnFirstPage = true;
			imageGalleryPopup.showCentralButtonOnLastPage = false;
			imageGalleryPopup.buttonText = qsTr("Start the tour");
			imageGalleryPopup.state = "dialogPopup";
			imageGalleryPopup.show();
		}
	}

	function sendWhatsnewFinished() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "WhatsnewFinished");
		bxtClient.sendMsg(msg);
	}

	function handlePopupClose() {
		var imagePathSlices = imageGalleryPopup.imageDir.toString().split("/");
		var imageDrawablesDir = "";
		if (imagePathSlices.length > 1)
			imageDrawablesDir = imagePathSlices[imagePathSlices.length - 2];

		if (imageDrawablesDir.indexOf("win") === 0 && p.winAutoStarted) {
			sendWhatsnewFinished();
			p.winAutoStarted = false;
		}
	}

	function handleLastPageButtonClick() {
		showWhatIsToon();
	}

	function checkForWhatIsNew() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.scsyncUuid, "specific1", "GetDoWhatsnew");
		bxtClient.sendMsg(msg);
	}

	function getDemoTitle(demoDir) {
		fileIO.source = Qt.resolvedUrl(demoDir + "/Title");
		return fileIO.read();
	}

	function getImages(dir) {
		fileIO.source = Qt.resolvedUrl(dir);
		// first check for lang specific images
		var images = fileIO.entryList([locale + "_*.png"]);
		// if none found use default ones
		if (images.length === 0)
			images = fileIO.entryList(["_*.png"]);

		return images;
	}

	FileIO {
		id: fileIO
	}

	BxtResponseHandler {
		response: "GetDoWhatsnewResponse"
		onResponseReceived: {
			var doWhatsNewNow = message.getArgument("doWhatsnew") === "true";
			p.showSolar = message.getArgument("doSolarWhatsnew") === "true" && globals.solarInHcbConfig;

			if (doWhatsNewNow) {
				p.winAutoStarted = true;
				showWhatIsNew();
			}
		}
	}

	BxtDiscoveryHandler {
		id: scsyncDiscoHandler
		deviceType: "happ_scsync"
		onDiscoReceived: {
			p.scsyncUuid = deviceUuid;
			if (feature.appWhatIsNewAutostart()) {
				checkForWhatIsNew();
			}
		}
	}
}
