import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: internetSystrayIcon
	visible: false
	posIndex: 400
	objectName: "internetSystrayIcon"
	image: "drawables/wifi-0.svg"

	function init() {
		app.wifiStatusChanged.connect(updateLinkQuality);
		app.wifiLinkQualityChanged.connect(updateLinkQuality);
		app.errorsChanged.connect(updateLinkQuality);
	}

	function updateLinkQuality() {
		//either show internet error or wifi status. If this is a demoDisplay don't show errors
		var iconVisible = (!feature.demoDisplayEnabled() && app.errors) || (app.activeInterface === "wlan0" && app.wifiStatus === app._CS_CONNECTED);
		visible = iconVisible;

		// cannot check for visible property because it might be overridden by parent visible!
		if (iconVisible) {
			if (app.errors) {
				internetSystrayIcon.image = "drawables/wifi-error.svg";
			} else if (app.wifiStatus === app._CS_CONNECTED) {
				if ( app.wifiLinkQuality > 50 ) {
					internetSystrayIcon.image = dimState ? "drawables/wifi-0.svg" : "drawables/wifi-3.svg";
				} else if ( app.wifiLinkQuality > 25 ) {
					internetSystrayIcon.image = dimState ? "drawables/wifi-2_dim.svg" : "drawables/wifi-2.svg";
				} else if ( app.wifiLinkQuality > 0 ) {
					internetSystrayIcon.image = dimState ? "drawables/wifi-1_dim.svg" : "drawables/wifi-1.svg";
				} else {
					internetSystrayIcon.image = dimState ? "drawables/wifi-3.svg" : "drawables/wifi-0.svg";
				}
			}
		}
	}

	onClicked: {
		if (isNormalMode) {
			stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/settings/SettingsScreen.qml"), {categoryUrl: Qt.resolvedUrl(app.internetFrameUrl)});
		} else if (isWizardMode) {
			// Make sure that the WifiSettingScreen starts a refresh when we enter the screen
			app.refreshWifiList = true;
			// See InternetWizardOverviewItem.mainColor
			stage.colorizeTopBar("#69AAD7", "white");
			stage.openFullscreen(app.wifiSettingScreenUrl);
		}
	}

	onDimStateChanged: {
		updateLinkQuality();
	}
}
