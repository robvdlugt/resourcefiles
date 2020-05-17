import QtQuick 2.1
import qb.components 1.0

Tile {
	id: root

	property variant plugStatusInfo: app.deviceStatusInfo
	property variant plugList: app.devPlugs

	function init() {
		p.statusInfoChanged();
	}

	QtObject {
		id: p
		property bool allState: true

		function checkPlugs() {
			if (app.devPlugs.length === 0) {
				removeTile();
			}
		}

		function statusInfoChanged() {
			if (app.devPlugs.length === 0) {
				removeTile();
				return;
			}

			var usage = 0, connectedCount = 0, stateOnCount = 0, hasUsageCount = 0;
			for (var i = 0; i < app.devPlugs.length; i++) {
				var statusInfo = app.deviceStatusInfo[app.devPlugs[i].DevUUID];
				if (statusInfo && statusInfo.IsConnected === "1") {
					connectedCount++;
					if (statusInfo.CurrentState === "1") {
						stateOnCount++;
						if (statusInfo.CurrentUsage) {
							hasUsageCount++;
							usage += statusInfo.CurrentUsage - 0;
						}
					}
				}
			}

			allState = false;
			var newColor = colors.controlPanelItemUnavailable;
			if (connectedCount > 0) {
				if (stateOnCount > 0) {
					if (hasUsageCount > 0) {
						if (usage <= 50) newColor = colors.controlPanelPowerColor1;
						else if (usage <= 100) newColor = colors.controlPanelPowerColor2;
						else if (usage <= 500) newColor = colors.controlPanelPowerColor3;
						else if (usage <= 1000) newColor = colors.controlPanelPowerColor4;
						else newColor = colors.controlPanelPowerColor5;
						powerValue.text = qsTr("%1 Watt").arg((i18n.number(usage, 0)));
					} else {
						powerValue.text = qsTr("On");
						newColor = colors.controlPanelItemOn;
					}
					allState = true;
				} else {
					allState = false;
					powerValue.text = qsTr("Off");
					newColor = colors.controlPanelItemOff;
				}
			} else {
				powerValue.text = qsTr("Not available");
				newColor = colors.controlPanelItemUnavailable;
			}

			if (dimState) {
				newColor = colors.controlPanelTileDim;
			}

			plugImage.overlayColor = newColor;
		}
	}

	onPlugListChanged: p.checkPlugs();
	onPlugStatusInfoChanged: p.statusInfoChanged();
	onDimStateChanged: p.statusInfoChanged();

	onClicked: {
		stage.openFullscreen(app.controlPanelScreenUrl, {tab: app.plugTabUrl});
	}

	Text {
		id: powerWidgetText
		text: qsTr("All plugs now")
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Image {
		id: plugImage
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
		source: "image://colorized/" + overlayColor.toString() + "/apps/controlPanel/drawables/triple-plug.svg"
		property color overlayColor: colors.controlPanelItemOff
	}

	Text {
		id: powerValue
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
	}
}

