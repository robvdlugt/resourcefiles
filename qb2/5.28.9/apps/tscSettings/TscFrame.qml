import QtQuick 2.1
import BxtClient 1.0

import qb.base 1.0
import qb.components 1.0

Widget {
	id: tscSettingsFrame

	property TscSettingsApp app

	function validatePin(text, isFinalString) {
		if (isFinalString) {
			if (text === app.localSettings.lockPinCode) {
				return null;
			} else {
				return { content: "You are not authorized to unlock the TSC settings" };
			}
		} else {
			return null;
		}
	}

	function setPin(text, isFinalString) {
		if (isFinalString) {
			var tempSettings = app.localSettings;
			tempSettings.lockPinCode = text; 
			app.localSettings = tempSettings;
			app.saveSettingsTsc();
			return null;
		} else {
			return null;
		}
	}


	function toggleLocking() {
		var tempSettings = app.localSettings; 
		tempSettings.locked = !tempSettings.locked
		app.localSettings = tempSettings;
		app.saveSettingsTsc();
	}

	onShown: {
		dhwPreheatToggle.isSwitchedOn = globals.tsc["noPreheatWhenAway"]
		summerToggle.isSwitchedOn =  globals.tsc["summerMode"] 
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
		Text {
		id: systemButtonsText
			text: "System functions"
			anchors {
				left: parent.left
			}
			font {
				pixelSize: isNxt ? 24 : 20
				family: qfont.italic.name
			}
			color: colors.tileTextColor
		}

		StandardButton {
			id: unlockButton

			text: qsTr("Unlock TSC settings")

			height: 40 

			visible: app.localSettings.locked

			anchors {
				left: parent.left
				top: systemButtonsText.bottom
			}

			topClickMargin: 2
			onClicked: {
				qnumKeyboard.open("TSC unlock PIN code", "", "PIN", "" , toggleLocking, validatePin);
				qnumKeyboard.state = "num_integer_clear_backspace";

			}
		}

		StandardButton {
			id: lockButton

			text: qsTr("Lock TSC settings")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: parent.left
				top: systemButtonsText.bottom
			}

			topClickMargin: 2
			onClicked: {
				qnumKeyboard.open("TSC unlock PIN code", "", "PIN", "" , toggleLocking, setPin);
				qnumKeyboard.state = "num_integer_clear_backspace";
			}
		}


		StandardButton {
			id: checkUpdateButton

			text: qsTr("Check for updates")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: lockButton.right
				top: lockButton.top
				leftMargin: isNxt ? 20 : 15
			}

			topClickMargin: 2
			onClicked: {
				// remove old TSC notifications first
				notifications.removeByTypeSubType("tsc","notify");
				notifications.removeByTypeSubType("tsc","update");
				notifications.removeByTypeSubType("tsc","firmware");
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("tscupdate");
				commandFile.close
				checkUpdateButton.enabled=false;
				disableButtonTimer.start();
			}
		}

		StandardButton {
			id: flushFirewallButton

			text: qsTr("Flush firewall rules")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: checkUpdateButton.right
				top: checkUpdateButton.top
				leftMargin: isNxt ? 20 : 15
			}

			topClickMargin: 2
			onClicked: {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("flushfirewall");
				commandFile.close
			}
		}

		StandardButton {
			id: restartGuiButton

			text: qsTr("Restart GUI")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: parent.left
				top: unlockButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
			}

			topClickMargin: 2
			onClicked: {
				Qt.quit();	
			}
		}

		StandardButton {
			id: restorePasswordButton

			text: qsTr("Restore password")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: restartGuiButton.right
				top: restartGuiButton.top
				leftMargin: isNxt ? 20 : 15
			}

			topClickMargin: 2
			onClicked: {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("restorerootpassword");
				commandFile.close
			}
		}

		StandardButton {
			id: credentialsMobileAppButton

			text: qsTr("Mobile Login")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: restorePasswordButton.right
				top: restorePasswordButton.top
				leftMargin: isNxt ? 20 : 15
			}

			topClickMargin: 2
			onClicked: {
				stage.openFullscreen(app.credentialsMobileAppScreenUrl);
			}
		}


		Text {
			id: modsButtonsText 
			text: "Modification functions"
			anchors {
				left: parent.left
				top: restartGuiButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
			}
			font {
				pixelSize: isNxt ? 24 : 20
				family: qfont.italic.name
			}
			color: colors.tileTextColor
		}

		StandardButton {
			id: guiModButton
			text: "Gui modifications"

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: parent.left 
				top: modsButtonsText.bottom
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.guiModScreenUrl);
			}
		}

		StandardButton {
			id: toggleNativeFeaturesButton
			text: "Toon subscription features"

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: guiModButton.right 
				leftMargin: isNxt ? 20 : 15
				top: guiModButton.top
			}

			topClickMargin: 3
			onClicked: {
				stage.openFullscreen(app.toggleNativeFeaturesScreenUrl);
			}
		}

		StandardButton {
			id: changeTariff

			text: qsTr("Change tariff")

			height: 40 

			visible: !app.localSettings.locked

			anchors {
				left: toggleNativeFeaturesButton.right
				top: toggleNativeFeaturesButton.top
				leftMargin: isNxt ? 20 : 15
			}

			topClickMargin: 2
			onClicked: {
				stage.openFullscreen(app.changeTariffScreenUrl);
			}
		}

       		Text {
       		        id: dhwPreheatToggleText
       		        anchors {
       		                left: parent.left
       		                top: guiModButton.bottom
				topMargin: Math.round(15 * app.nxtScale)
       		        }
			visible: !app.localSettings.locked && globals.thermostatFeatures["FF_Dhw_PreHeat_Settings"]
       		        font.pixelSize: 16
       		        font.family: qfont.semiBold.name
       		        text: "Disable hot water preheating when sleeping or away"
       		}
	
       		OnOffToggle {
       		        id: dhwPreheatToggle
       		        height: 36
       		        anchors {
				left: dhwPreheatToggleText.right
				leftMargin: isNxt ? 20 : 15
       		        	top: dhwPreheatToggleText.top
			}
			visible: !app.localSettings.locked && globals.thermostatFeatures["FF_Dhw_PreHeat_Settings"]
       		        leftIsSwitchedOn: false
                        onIsSwitchedOnChanged: {
                                if (isSwitchedOn !== globals.tsc["noPreheatWhenAway"]) {
                 			var myTsc = globals.tsc
                 			myTsc["noPreheatWhenAway"] = isSwitchedOn 
                 			globals.tsc = myTsc
                 			app.saveSettingsTsc();
                                }
                        }
	        }


       		Text {
       		        id: summerToggleText
       		        anchors {
       		                left: parent.left
       		                top: dhwPreheatToggleText.bottom
				topMargin: Math.round(15 * app.nxtScale)
       		        }
			visible: !app.localSettings.locked
       		        font.pixelSize: 16
       		        font.family: qfont.semiBold.name
       		        text: "Summer mode (lower the setpoint)"
       		}
	
       		OnOffToggle {
       		        id: summerToggle
       		        height: 36
       		        anchors {
				left: dhwPreheatToggle.left
				top: summerToggleText.top
			}
			visible: !app.localSettings.locked
       		        leftIsSwitchedOn: false
                        onIsSwitchedOnChanged: {
                                if (isSwitchedOn !== globals.tsc["summerMode"]) {
                                        var myTsc = globals.tsc
                                        myTsc["summerMode"] = isSwitchedOn
                                        globals.tsc = myTsc
                                        app.saveSettingsTsc()
					app.toggleSummerMode()
                                }
                        }
	        }


	}

	Text {
		id: versionText
		text: "Versie: " + app.tscVersion
		anchors {
			baseline: parent.bottom
			baselineOffset: -5
			horizontalCenter: parent.horizontalCenter
		}
		font {
			pixelSize: isNxt ? 18 : 15
			family: qfont.italic.name
		}
		color: colors.tileTextColor
	}

	IconButton {
		id: betaButton

		width: isNxt ? 48 : 38
		height: isNxt ? 63 : 50
		iconSource: ""

		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		colorUp : "transparent"
		colorDown : "transparent"
		onClicked: { 
			if (!app.localSettings.locked) {
				var commandFile = new XMLHttpRequest();
				commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("togglebeta");
				commandFile.close
			}
		}
	}

        Image {
                id: donateImg 
		width: isNxt ? 75 : 60
		fillMode: Image.PreserveAspectFit
                source: "qrc:/tsc/donate.png"
                anchors {
			bottom: parent.bottom
			left: parent.left
                }
        }



	Timer {
		id: disableButtonTimer

		interval: 5000 
		onTriggered: {
			checkUpdateButton.enabled=true;
			disableButtonTimer.stop();
		}
	}

}
