import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

SidePanelButton {
	id: thermostatSidePanelButton

	property string kpiPostfix: "thermostatSidePanelButton"

	property ThermostatApp app
	panelUrl: app.sidePanelUrl

	QtObject {
		id: p

		property string flameIconState: "off"

		//for unit tests
		property alias flameIconSource : flameIcon.source

		function onThermostatDatasetsChanged() {
			var flameState = "off";

			var modulationLevel = app.thermInfo['currentModulationLevel'];
			// burnerInfo 0=off, 1=heat, 2=water, 3=preheat, 4=error
			var burnerInfo = app.thermInfo['burnerInfo'];
			//When burner is set to on (heating or preheating) use the modulation level as a guide
			switch (burnerInfo) {
			case 1:
			case 3:
				//Show flames based on modulation level
				if (modulationLevel > 70) {
					flameState = "3";
				} else if (modulationLevel > 35) {
					flameState = "2";
				} else {
					flameState = "1";
				}
				break;
			case 2:
				//Heating water now handled by DHW panel
				flameState = "hw";
				break;
			case 4:
				//Error
				flameState = "error";
				break;
			}

			if (app.thermInfo.boilerModuleConnected === 0) {
				flameState = "error";
			} else if (app.thermInfo.haveOTBoiler === 1 && app.thermInfo.otCommError === 1) {
				flameState = "error";
			} else if (app.thermInfo.haveOTBoiler === 1 && app.thermInfo.hasBoilerFault === 1) {
				flameState = "error";
			}

			if (!app.isUndef(app.heatRecoveryInfo)) {
				if (app.heatRecoveryInfo["BlockingState"] || app.heatRecoveryInfo["CurrentFaultcode"] || !app.heatRecoveryInfo["IsConnected"]) {
					flameState = "heatwinner-error";
				} else if (app.heatRecoveryInfo["CurrentState"]) {
					if (flameState === "off") {
						flameState = "heatwinner";
					} else if (flameState === "hw") {
						flameState = "heatwinner-hw";
					} else if (flameState !== "error") {
						flameState = "heatwinner-boiler";
					}
				}
			}

			p.flameIconState = flameState;
		}
	}

	function init() {
		app.thermInfoChanged.connect(p.onThermostatDatasetsChanged);
		app.heatRecoveryInfoChanged.connect(p.onThermostatDatasetsChanged);
	}

	Image {
		id: flameIcon
		source: "image://scaled/apps/thermostat/drawables/ts-" + (canvas.dimState ? "dim" : thermostatSidePanelButton.state) + "-" + p.flameIconState + ".svg"
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter:   parent.verticalCenter
			verticalCenterOffset: canvas.dimState ? Math.round(60 * verticalScaling) : 0
		}
	}

	Connections {
		target: canvas
		onDimStateChanged: {
			if (canvas.dimState) {
				sendShowPanel();
				flameIcon.anchors.horizontalCenter = undefined;
				flameIcon.anchors.left = thermostatSidePanelButton.left
			} else {
				flameIcon.anchors.left = undefined;
				flameIcon.anchors.horizontalCenter = thermostatSidePanelButton.horizontalCenter;
			}
		}
	}
	
//TSC waste show mod start

	Image {
		id: wasteIconHide
		source: app.wasteControlIcon
		anchors {
			baseline: parent.top
			right: parent.right
		}
		cache: false
       		visible: dimState ? false : (app.wasteIconShow || app.wasteIcon2Show) // only show in non-dim state if icons are displayed in dimstate
		MouseArea {
			id: hideIcon
			anchors.fill: parent
			onClicked: {
				if (app.wasteIconShow) {
					if (app.wasteIconBackShow) {
						app.wasteIconBackShow = false;
						app.wasteIconShow = false;
					} else {
						app.wasteIconBackShow = true;
						app.wasteControlIcon = "file:///qmf/qml/apps/wastecollection/drawables/iconHide.png";
					}
				}
				if (app.wasteIcon2Show) {
					if (app.wasteIcon2BackShow) {
						app.wasteIcon2BackShow = false;
						app.wasteIcon2Show = false;
					} else {
						app.wasteIcon2BackShow = true;
						app.wasteControlIcon = "file:///qmf/qml/apps/wastecollection/drawables/iconHide.png";
					}
				}
			}
		}
	}

//TSC waste show mod end

}
