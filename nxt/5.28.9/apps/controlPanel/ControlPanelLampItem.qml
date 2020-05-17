import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

ControlPanelItem {
	id: root

	/// in non "disabled" state, the lamp icon is composed from 2 parts: lamp bulb in IconButton (changes color with overlay color)
	/// and and lamp body icon over the button. Together they form lamp icon. In "disabled" state only onle one icon is used
	iconSource: root.state === "disabled" ? "drawables/inactive-light.svg" : "drawables/colourlight-head.svg"

	onStatusInfoChanged: {
		if (statusInfo && statusInfo.IsConnected === "1") {
			if (statusInfo.CurrentState === "1") {
				if (statusInfo.CurrentUsage) {
					var usage = statusInfo.CurrentUsage - 0;
					itemText = qsTr("%1 Watt").arg((i18n.number(usage, 0)));
				} else {
					itemText = qsTr("On");
				}
				buttonOverlayColorUp = "#" + statusInfo.RgbColor;
			} else {
				itemText = qsTr("Off");
				buttonOverlayColorUp = colors.plugIconDisabled;
			}
		} else {
			itemText = qsTr("Not available");
			buttonOverlayColorUp = colors.controlPanelItemUnavailable;
		}
	}

	Image {
		id: lightBodyImage
		anchors.centerIn: button
		source: (button.state === "down" ? "image://colorized/white/" : "image://scaled/") + qtUtils.urlPath(imagePath)
		visible: root.state !== "disabled"

		property url imagePath: "drawables/colourlight-body.svg"
	}
}
