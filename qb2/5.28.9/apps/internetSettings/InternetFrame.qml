import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

Widget {
	id: internetFrame

	property InternetSettingsApp app

	function init() {
		app.internetStatusTextChanged.connect(updateStatusLabel);
		app.wifiNetworkNameChanged.connect(updateWifiLabel);

		app.localAccessEnabledChanged.connect(updateLocalAccess);
		app.mobileAccessEnabledChanged.connect(updateMobileAccess);
		app.researchParticipationEnabledChanged.connect(updateResearchParticipation);

		QT_TRANSLATE_NOOP("InternetFrame", "Research participation", "Viesgo")
	}

	function updateWifiLabel() {
		wifiLabel.rightText = app.wifiNetworkName;
	}

	function updateStatusLabel() {
		internetStatusLabel.rightText = app.internetStatusText;
	}

	function updateLocalAccess() {
		localAccessLabel.rightText = app.localAccessEnabled ? qsTr("On") : qsTr("Off");
	}

	function updateMobileAccess() {
		mobileAccessLabel.rightText = app.mobileAccessEnabled ? qsTr("On") : qsTr("Off");
	}

	function updateResearchParticipation() {
		researchLabel.rightText = app.researchParticipationEnabled ? qsTr("On") : qsTr("Off");
	}

	anchors.fill: parent

	onShown: {
		// Request the interface info
		app.getIfaceInfo(app.activeInterface);

		app.requestResearchState();
		app.requestLocalAccessState();
		app.requestMobileAccessState();

		updateWifiLabel();
		updateStatusLabel();
		updateLocalAccess();
		updateMobileAccess();
		updateResearchParticipation();
	}

	Component.onDestruction: {
		app.internetStatusTextChanged.disconnect(updateStatusLabel);
		app.wifiNetworkNameChanged.disconnect(updateWifiLabel);

		app.localAccessEnabledChanged.disconnect(updateLocalAccess);
		app.mobileAccessEnabledChanged.disconnect(updateMobileAccess);
		app.researchParticipationEnabledChanged.disconnect(updateResearchParticipation);
	}

	Column {
		id: labelsContainer
		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			bottom:parent.bottom
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		Item {
			id: wifiItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: wifiLabel
				anchors {
					left: parent.left
					right: wifiSelectButton.left
					rightMargin: designElements.hMargin6
				}

				leftText: qsTr("Wireless network")
				rightText: ""
				rightTextFormat: Text.PlainText // Prevent XSS/HTML injection
			}

			IconButton {
				id: wifiSelectButton
				width: designElements.buttonSize
				height: wifiLabel.height
				iconSource: "qrc:/images/edit.svg"
				anchors {
					top: wifiLabel.top
					right: parent.right
				}

				onClicked: {
					app.refreshWifiList = true;
					stage.openFullscreen(app.wifiSettingScreenUrl);
				}
			}
		}

		SingleLabel {
			id: internetStatusLabel
			width: wifiLabel.width
			leftText: qsTr("Status")
			rightText: app.internetStatusText
		}

		SingleLabel {
			id: ipAddressLabel
			width: wifiLabel.width
			leftText: qsTr("IP-address")
			rightText: (app.smStatus >= app._ST_CONFIGURED) ? app.wlanIpAddress : ""
		}

		SingleLabel {
			id: macAddressLabel
			width: wifiLabel.width
			leftText: qsTr("MAC-address")
			rightText: app.wlanMacAddress
		}

		Item {
			id: spacer
			width: parent.width
			height: Math.round(18 * verticalScaling)
		}

		Item {
			id: localAccessItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: localAccessLabel
				anchors {
					left: parent.left
					right: localAccessButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Local access")
			}

			IconButton {
				id: localAccessButton
				width: designElements.buttonSize
				height: localAccessLabel.height
				iconSource: "qrc:/images/edit.svg"
				anchors {
					top: localAccessLabel.top
					right: parent.right
				}
				bottomClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.localAccessScreenUrl);
				}
			}
		}

		Item {
			id: mobileAccessItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: mobileAccessLabel
				anchors {
					left: parent.left
					right: mobileAccessButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Mobile access")
			}

			IconButton {
				id: mobileAccessButton
				width: designElements.buttonSize
				height: mobileAccessLabel.height
				iconSource: "qrc:/images/edit.svg"
				anchors {
					top: mobileAccessLabel.top
					right: parent.right
				}
				topClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.mobileAccessScreenUrl);
				}
			}
		}

		Item {
			id: researchItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: researchLabel
				anchors {
					left: parent.left
					right: researchButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Research participation", globals.tenant)
			}

			IconButton {
				id: researchButton
				width: designElements.buttonSize
				height: researchLabel.height
				iconSource: "qrc:/images/edit.svg"
				anchors {
					top: researchLabel.top
					right: parent.right
				}

				onClicked: {
					stage.openFullscreen(app.researchParticipationScreenUrl);
				}
			}
		}

		Item {
			id: spacer2
			width: parent.width
			height: Math.round(18 * verticalScaling)
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: dataExportLabel
				anchors {
					left: parent.left
					right: dataExportBtn.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Toon data")
			}

			IconButton {
				id: dataExportBtn
				width: designElements.buttonSize
				height: researchLabel.height
				iconSource: "qrc:/images/export.svg"
				anchors {
					top: dataExportLabel.top
					right: parent.right
				}

				onClicked: {
					stage.openFullscreen(app.dataExportScreenUrl);
				}
			}
		}
	}
}
