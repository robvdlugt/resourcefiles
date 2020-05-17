import QtQuick 2.1
import BxtClient 1.0
import qb.components 1.0


Tile {
	property ControlPanelApp app
	property variant statusInfo: app.deviceStatusInfo[plugUuid]
	property alias itemText: powerValue.text

	property string plugUuid

	function init() {
		plugUuid = widgetArgs.config.devUuid;
	}

	QtObject {
		id: p

		function updatePlugItem() {
			if (!plugUuid || plugUuid.length == 0)
				return;

			var newColor = colors.controlPanelItemUnavailable;
			if (statusInfo && statusInfo.IsConnected === "1") {
				if (statusInfo.CurrentState === "1") {
					if (statusInfo.CurrentUsage) {
						var usage = statusInfo.CurrentUsage - 0;
						itemText = qsTr("%1 Watt").arg((i18n.number(usage, 0)));
						if (usage <= 50) newColor = colors.controlPanelPowerColor1;
						else if (usage <= 100) newColor = colors.controlPanelPowerColor2;
						else if (usage <= 500) newColor = colors.controlPanelPowerColor3;
						else if (usage <= 1000) newColor = colors.controlPanelPowerColor4;
						else newColor = colors.controlPanelPowerColor5;
					} else {
						itemText = qsTr("On");
						newColor = colors.controlPanelItemOn;
					}
				} else {
					itemText = qsTr("Off");
					newColor = colors.controlPanelItemOff;
				}
			} else if (!statusInfo) {
				removeTile();
			} else {
				itemText = qsTr("Not available");
				newColor = colors.controlPanelItemUnavailable;
			}
			if (dimState) {
				newColor = colors.controlPanelTileDim;
			}

			plugImage.overlayColor = newColor;
		}
	}

	onStatusInfoChanged: p.updatePlugItem()
	onDimStateChanged: p.updatePlugItem();

	onClicked: {
		stage.openFullscreen(app.editPlugScreenUrl, {plugUuid: plugUuid})
	}

	Text {
		id: powerWidgetText
		text: plugUuid && plugUuid.length > 0 && app.plugsTable[plugUuid] ? app.plugsTable[plugUuid].Name : ""
		textFormat: Text.PlainText // Prevent XSS/HTML injection
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
		source: "image://colorized/" + overlayColor.toString() + "/apps/controlPanel/drawables/smartplug.svg"
		sourceSize.height: Math.round(60 * verticalScaling)
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

