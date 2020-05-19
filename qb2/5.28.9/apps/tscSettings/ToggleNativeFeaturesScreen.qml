import QtQuick 2.1

import FileIO 1.0

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: toggleNativeFeaturesScreen

        property TscSettingsApp app

        isSaveCancelDialog: true


	screenTitle: qsTr("Toggle Toon features")

	property variant settings: {}

	onShown: {
		app.getAgreementDetails();
		var temp = JSON.parse(tenantSettingsFile.read());
		settings = temp;
		benchmarkToggle.isSwitchedOn = settings["appBenchmarkEnabled"];
		customerServiceToggle.isSwitchedOn = settings["appCustomerServiceEnabled"];
		boilerMonitorToggle.isSwitchedOn = settings["appBoilerMonitorEnabled"];
		winToggle.isSwitchedOn = settings["appWhatIsNewEnabled"];
		witToggle.isSwitchedOn = settings["appWhatIsToonEnabled"];
		smokeDetectorToggle.isSwitchedOn = settings["appSmokeDetectorEnabled"];
		statusUsageToggle.isSwitchedOn = settings["appStatusUsageEnabled"];
		if ( settings["appWeather"] !== "" ) {
			weatherToggle.isSwitchedOn = true;
		}
		else {
			weatherToggle.isSwitchedOn = false;
		}
	}

	onSaved: {
		var saveSettings = settings;
                saveSettings["appBenchmarkEnabled"] = benchmarkToggle.isSwitchedOn;
                saveSettings["appCustomerServiceEnabled"] = customerServiceToggle.isSwitchedOn;
                saveSettings["appBoilerMonitorEnabled"] = boilerMonitorToggle.isSwitchedOn;
                saveSettings["appWhatIsNewEnabled"] = winToggle.isSwitchedOn;
                saveSettings["appWhatIsToonEnabled"] = witToggle.isSwitchedOn;
                saveSettings["appSmokeDetectorEnabled"] = smokeDetectorToggle.isSwitchedOn;
		saveSettings["appStatusUsageEnabled"] = statusUsageToggle.isSwitchedOn;
                if (weatherToggle.isSwitchedOn) {
                	saveSettings["appWeather"]  = "weather"
                }
                else {
                	saveSettings["appWeather"]  = ""
                }
                // save the new settings into the tentant file and then restart QT or reboot the Toon
		var saveFile = new XMLHttpRequest();
                saveFile.open("PUT", "file:///qmf/qml/config/TenantSettings.json",false); // do synchronous, wait for send to complete
		saveFile.send(JSON.stringify(saveSettings,null,"\t"));
                //rebooting the toon to change the options
		app.rebootToon()
	}

	FileIO {
		id: tenantSettingsFile
		source: "file:////qmf/qml/config/TenantSettings.json"
		onError: console.log("TSC: Can't open /qmf/qml/config/TenantSettings.json")
	}


	Text {
		id: bodyText

		width: Math.round(600 * 1.28)
		wrapMode: Text.WordWrap

		text: "Disabling Toon subscription features will save memory and will therefore improve the usability of the first generation Toon thermostat. Most of these features will not work anyway on modified Toons as they require a Eneco contract. Updating your Toon firmware could enable some features again.\n----- Saving these settings will restart your Toon! ---- "
		color: "#000000"

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name

		anchors {
			top: parent.top
			topMargin: isNxt ? Math.round(60 * 1.28) : 10
			horizontalCenter: parent.horizontalCenter
		}
	}

        Text {
                id: benchmarkText
                anchors {
                        left: bodyText.left
                        top: bodyText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Benchmark against other users"
        }

        OnOffToggle {
                id: benchmarkToggle
                height: 36
                anchors.left: benchmarkText.right
                anchors.leftMargin: 10
                anchors.top: benchmarkText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: weatherText
                anchors {
                        left: benchmarkText.left
                        top: benchmarkText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Native weather app"
        }

        OnOffToggle {
                id: weatherToggle
                height: 36
                anchors.left: benchmarkToggle.left
                anchors.leftMargin: 0
                anchors.top: weatherText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: customerServiceText
                anchors {
                        left: weatherText.left
                        top: weatherText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Eneco customer service"
        }

        OnOffToggle {
                id: customerServiceToggle
                height: 36
                anchors.left: benchmarkToggle.left
                anchors.leftMargin: 0
                anchors.top: customerServiceText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: boilerMonitorText
                anchors {
                        left: customerServiceText.left
                        top: customerServiceText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Boiler monitor app"
        }

        OnOffToggle {
                id: boilerMonitorToggle
                height: 36
                anchors.left: benchmarkToggle.left
                anchors.leftMargin: 0
                anchors.top: boilerMonitorText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: winText
                anchors {
                        left: benchmarkToggle.right
                        top: benchmarkToggle.top
                        leftMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "What is new wizard"
        }

        OnOffToggle {
                id: winToggle
                height: 36
                anchors.left: winText.right
                anchors.leftMargin: 10
                anchors.top: winText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: witText
                anchors {
                        left: winText.left
                        top: winText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "What is Toon wizard"
        }

        OnOffToggle {
                id: witToggle
                height: 36
                anchors.left: winToggle.left
                anchors.leftMargin: 0
                anchors.top: witText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: smokeDetectorText
                anchors {
                        left: witText.left
                        top: witText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Smokedetector app"
        }

        OnOffToggle {
                id: smokeDetectorToggle
                height: 36
                anchors.left: winToggle.left
                anchors.leftMargin: 0
                anchors.top: smokeDetectorText.top
                leftIsSwitchedOn: false
	}

        Text {
                id: statusUsageText
                anchors {
                        left: smokeDetectorText.left
                        top: smokeDetectorText.bottom
                        topMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Status usage app"
        }

        OnOffToggle {
                id: statusUsageToggle
                height: 36
                anchors.left: winToggle.left
                anchors.leftMargin: 0
                anchors.top: statusUsageText.top
                leftIsSwitchedOn: false
        }

        Text {
                id: solarText
                anchors {
                        left: winToggle.right
                        top: winToggle.top
                        leftMargin: 40
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Zon Op Toon"
        }

        OnOffToggle {
                id: solarToggle
                height: 36
                anchors.left: solarText.right
                anchors.leftMargin: 10
                anchors.top: solarText.top
                leftIsSwitchedOn: false
		selected: app.agreementDetails["SolarActivated"] === "1";
                onSelectedChangedByUser: app.toggleSolarSubscription()

        }


}
