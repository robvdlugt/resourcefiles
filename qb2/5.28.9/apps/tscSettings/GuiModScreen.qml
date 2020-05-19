import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Screen {
	id: guiModScreen

	property TscSettingsApp app

	function updateRotateTiles() {
		switch(globals.tsc["rotateTiles"]) {
			case 0: rotateTilesLabel.rightText = "Disabled"; break;
			case 1: rotateTilesLabel.rightText = "Mode 1"; break;
			case 2: rotateTilesLabel.rightText = "Mode 2"; break;
			case 3: rotateTilesLabel.rightText = "Mode 3"; break;
			default: rotateTilesLabel.rightText = "unknown"; break;
		}
	}

	function updateHideErrorSystray() {
		hideErrorSystrayLabel.rightText = globals.tsc["hideErrorSystray"] ? "Enabled" : "Disabled";
	}

	function updateHideToonLogo() {
		switch(globals.tsc["hideToonLogo"]) {
			case 0: hideToonLogoLabel.rightText = "Disabled"; break;
			case 1: hideToonLogoLabel.rightText = "Only during dim"; break;
			case 2: hideToonLogoLabel.rightText = "Always"; break;
			default: hideToonLogoLabel.rightText = "unknown"; break;
		}
	}

	function updateCustomToonLogo() {
		switch(globals.tsc["customToonLogo"]) {
			case 0: customToonLogoLabel.rightText = "Disabled"; break;
			case 1: customToonLogoLabel.rightText = "Enabled"; break;
			default: customToonLogoLabel.rightText = "unknown"; break;
		}
	}


	onShown: {
		updateRotateTiles();
		updateHideToonLogo();
		updateHideErrorSystray();
		updateCustomToonLogo();
	}

	anchors.fill: parent

	Item {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: 25
			left: parent.left
			leftMargin: Math.round(44 * 1.28)
			right: parent.right
			rightMargin: Math.round(27 * 1.28)
		}

		SingleLabel {
			id: rotateTilesLabel
			anchors {
				left: parent.left
				right: rotateTilesButton.left
				rightMargin: 8
			}
			leftText: qsTr("Rotate tiles")
			rightText: ""

		}

		IconButton {
			id: rotateTilesButton

			width: 45
			height: rotateTilesLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: rotateTilesLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.rotateTilesScreenUrl);
			}
		}

		SingleLabel {
			id: hideErrorSystrayLabel
			anchors {
				top: rotateTilesLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideErrorSystrayButton.left
				rightMargin: 8
			}
			leftText: qsTr("Hide error systray icon")
			rightText: ""

		}

		IconButton {
			id: hideErrorSystrayButton

			width: 45
			height: hideErrorSystrayLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: hideErrorSystrayLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.hideErrorSystrayScreenUrl);
			}
		}

		SingleLabel {
			id: hideToonLogoLabel
			anchors {
				top: hideErrorSystrayLabel.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideToonLogoButton.left
				rightMargin: 8
			}
			leftText: qsTr("Hide Toon logo")
			rightText: ""

		}

		IconButton {
			id: hideToonLogoButton

			width: 45
			height: hideToonLogoLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg" 

			anchors {
				top: hideToonLogoLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.hideToonLogoScreenUrl);
			}
		}

		SingleLabel {
			id: customToonLogoLabel
			anchors {
				top: hideToonLogoButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
				left: parent.left
				right: hideToonLogoButton.left
				rightMargin: 8
			}
			leftText: qsTr("Custom Toon logo")
			rightText: ""

		}

		IconButton {
			id: customToonLogoButton

			width: 45
			height: customToonLogoLabel.height

			enabled: !app.localSettings.locked

			iconSource: "qrc:/images/edit.svg"

			anchors {
				top: customToonLogoLabel.top
				right: parent.right
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.customToonLogoScreenUrl);
			}
		}



	}

}
