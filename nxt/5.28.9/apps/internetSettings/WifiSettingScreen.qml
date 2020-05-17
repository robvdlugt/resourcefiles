import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: wifiSettingScreen
	screenTitle: qsTr("Change wifi")

	Component.onCompleted: {
		app.wifiNetworkListUpdated.connect(fillWifiList);
	}

	Component.onDestruction: {
		app.wifiNetworkListUpdated.disconnect(fillWifiList);
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		// Update the wifi list when this screen is shown
		if ( app.refreshWifiList === true ) {
			app.refreshWifiList = false;
			refreshWifiList();
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	function refreshWifiList() {
		// Clear the wifi network list
		wifiListModel.clear();

		// Change refresh and throbber to in progress
		refreshButton.enabled = false;
		refreshThrobber.visible = true;

		// Request the new wifi networks
		app.getWifiNetworkList();
	}

	// Function inserts the sorted wifi networks into the listmodel
	function fillWifiList() {
		for (var i in app.wifiList) {
			wifiListModel.insert(i, app.wifiList[i] );
		}

		// Change refresh and throbber to done
		refreshButton.enabled = true;
		refreshThrobber.visible = false;

		wifiList.initialView();
	}

	function validatePin(text, isFinalString) {
		if (isFinalString) {
			if (text === feature.featPinProtectNumber()) {
				return null;
			} else {
				return { content: qsTr("You are not authorized to change the WiFi network") };
			}
		} else {
			return null;
		}
	}

	// Function stores the clicked wifi network in the app and calls setWifiInformation wich executes the bxt call that connects to wifi
	function wifiNetworkClicked(networkId) {
		var networkInfo = {};
		var wifiModelItem = wifiListModel.get(networkId);
		networkInfo.essid = wifiModelItem.Essid;
		networkInfo.enc = wifiModelItem.Enc;
		networkInfo.auth = wifiModelItem.Auth;
		networkInfo.mac = wifiModelItem.Mac;

		if ( networkInfo.auth === "OPEN") {
			if (feature.appInternetSettingsPinProtectWifiNetworkChange()) {
				pinEntry.callback = function () { app.connectToWifi(networkInfo) };
				pinEntry.show();
			} else {
				app.connectToWifi(networkInfo);
			}
		} else {
			if (feature.appInternetSettingsPinProtectWifiNetworkChange()) {
				pinEntry.callback = function () { stage.openFullscreen(app.networkScreenUrl, {"networkInfo": networkInfo}) };
				pinEntry.show();
			} else {
				stage.openFullscreen(app.networkScreenUrl, {"networkInfo": networkInfo});
			}
		}
	}

	function openHiddenNetworkScreen() {
		app.hiddenNetworkEssid = "";
		app.hiddenNetworkAuth = -1;
		stage.openFullscreen(app.networkScreenUrl);
	}

	Column {
		spacing: Math.round(6 * horizontalScaling)
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter

		Row {
			spacing: Math.round(6 * horizontalScaling)
			anchors.fill: parent.fill
			width: title.width + refreshButton.width + refreshThrobber.width + 2 * spacing

			Text {
				id: title
				font.family: qfont.semiBold.name
				font.pixelSize: qfont.navigationTitle
				color: colors.wifiSelectTitle
				text: qsTr("Available wireless networks")
				width: Math.round(393 * horizontalScaling)
				height: refreshThrobber.height
			}

			IconButton {
				id: refreshButton;
				width: designElements.buttonSize
				height: refreshThrobber.height
				iconSource: "qrc:/images/refresh.svg"

				onClicked: {
					// Update the wifi list
					refreshWifiList();
				}
			}

			Throbber {
				id: refreshThrobber
				width: Math.round(35 * horizontalScaling)
				height: Math.round(35 * verticalScaling)
				visible: false
			}
		}

		// Datamodel to store the wifiNetwork list
		ListModel {
			id: wifiListModel
			property variant wifiNetworkList: []
		}

		// Delegate of the wifiNework list
		Component {
			id: wifiListDelegate
			WifiSettingDelegate {
				onClicked:{
					wifiList.selectVisibleItem(index);
				}
			}
		}

		Rectangle {
			id: content
			width: Math.round(439 * horizontalScaling)
			height: Math.round(238 * verticalScaling)
			color: colors.wifiListBackground
			radius: designElements.radius

			WifiSettingSimpleList {
				id: wifiList
				delegate: wifiListDelegate
				dataModel: wifiListModel
				itemsPerPage: 5
				downIcon: "qrc:/images/arrow-down.svg"
				buttonsHeight: Math.round(80 * verticalScaling)
				buttonDownStateColor: colors.ibMsgTitleSelected
				buttonDownStateBackground: colors.wifiListBackground
				scrollbarColor: colors.ibListScrollbar
				buttonsVisible: true
				scrollbarVisible: true

				onItemClicked: {
					// Reset the hidden network details when pressing another network
					app.hiddenNetworkEssid = "";
					app.hiddenNetworkAuth = -1;

					wifiNetworkClicked(dataIndex);
				}
			}
		}

		Row {
			spacing: Math.round(6 * horizontalScaling)

			SingleLabel {
				id: hiddenNetworkLabel
				height: Math.round(35 * verticalScaling)
				width: Math.round(393 * horizontalScaling)
				leftText: qsTr("Hidden network")
				rightText: app.hiddenNetworkEssid
				rightTextFormat: Text.PlainText // Prevent XSS/HTML injection
			}

			IconButton {
				id: hiddenNetworkButton;
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"

				leftClickMargin: 2
				onClicked: {
					if (feature.appInternetSettingsPinProtectWifiNetworkChange()) {
						pinEntry.callback = openHiddenNetworkScreen;
						pinEntry.show();
					} else {
						openHiddenNetworkScreen();
					}
				}
			}
		}

		Row {
			spacing: Math.round(6 * horizontalScaling)

			SingleLabel {
				id: internetStatusLabel
				width: Math.round(393 * horizontalScaling)
				height: Math.round(35 * verticalScaling)
				leftText: qsTr("Status")
				rightText: app.internetStatusText
			}

			Rectangle {
				id: wifiStatusIconContainer
				color: colors.labelBackground
				radius: designElements.radius
				width: designElements.buttonSize
				height: Math.round(35 * verticalScaling)

				WifiStatusIcon {
					id: wifiStatusIcon
					anchors.fill: parent
					visible: app.hiddenNetworkEssid ? true : false
					state: app.getWifiIconState()
				}
			}
		}
	}

	PinEntryOverlay {
		id: pinEntry
		visible: false
		titleText: qsTr("Please enter pincode to change WiFi network")
		titleFontSize: qfont.bodyText
		property var callback

		onClosed: hide()
		onPinEntered: {
			if (pin === feature.featPinProtectNumber()) {
				hide();
				if (typeof callback === "function")
					callback();
				callback = undefined;
			} else {
				wrongPin();
			}
		}
	}
}
