import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

ControlPanelItem {
	id: root
	iconSource: "drawables/smartplug-button.svg"

	onStatusInfoChanged: {
		if (statusInfo && statusInfo.IsConnected === "1") {
			if (statusInfo.CurrentState === "1") {
				if (statusInfo.CurrentUsage === "NaN")
				{
					itemText = qsTr("Not available");
					buttonOverlayColorUp = colors.controlPanelItemUnavailable;
				}
				else if (statusInfo.CurrentUsage)
				{
					var usage = statusInfo.CurrentUsage - 0;
					itemText = qsTr("%1 Watt").arg((i18n.number(usage, 0)));
					if (usage <= 50) buttonOverlayColorUp = colors.controlPanelPowerColor1;
					else if (usage <= 100) buttonOverlayColorUp = colors.controlPanelPowerColor2;
					else if (usage <= 500) buttonOverlayColorUp = colors.controlPanelPowerColor3;
					else if (usage <= 1000) buttonOverlayColorUp = colors.controlPanelPowerColor4;
					else buttonOverlayColorUp = colors.controlPanelPowerColor5;
				} else {
					itemText = qsTr("On");
					buttonOverlayColorUp = colors.controlPanelItemOn;
				}
			} else {
				itemText = qsTr("Off");
				buttonOverlayColorUp = colors.controlPanelItemOff;
			}
		} else {
			itemText = qsTr("Not available");
			buttonOverlayColorUp = colors.controlPanelItemUnavailable;
		}
	}
}
