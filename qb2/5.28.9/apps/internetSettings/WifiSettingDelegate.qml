import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

StyledRectangle {
	id: wifiNetwork

	property string kpiPostfix: "wifiList" + index
	property bool activeNetwork: app.connectingNetworkMac === Mac

	signal clicked;

	function getSignalStrengthImage() {
		if ( Quality > 50 ) {
			return "drawables/wifi-3.svg";
		} else if ( Quality > 25 ) {
			return "drawables/wifi-2.svg";
		} else if ( Quality > 0 ) {
			return "drawables/wifi-1.svg";
		}
		return "drawables/wifi-0.svg";
	}

	function updateNetworkIcon() {
		if (activeNetwork)
			return app.getWifiIconState();
		else
			return "DEFAULT";
	}

	width: Math.round(361 * horizontalScaling)
	height: Math.round(36 * verticalScaling)
	radius: designElements.radius
	color: colors.background
	opacity: activeNetwork ? designElements.opacity : 1.0

	Component.onCompleted: {
		mouseArea.clicked.connect(clicked);
	}

	WifiStatusIcon {
		id: wifiStatusIcon

		width: designElements.statusIconSize
		height: designElements.statusIconSize

		anchors {
			left: parent.left
			leftMargin: Math.round(3 * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}

		state: updateNetworkIcon()
	}

	Text {
		id: essidText

		text: Essid
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		font.bold: activeNetwork
		color: (activeNetwork && app.smStatus >= app._ST_INTERNET && app.wifiStatus === app._CS_CONNECTED) ? colors.wifiActiveNetwork : colors.foreground

		wrapMode: Text.WrapAnywhere
		maximumLineCount: 1
		elide: Text.ElideRight
		textFormat: Text.PlainText // Prevent XSS/HTML injection

		anchors {
			left: parent.left
			leftMargin: designElements.buttonSize
			right: signalStrength.left
			rightMargin: Math.round(13 * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}
	}

	Image {
		id: signalStrength
		source: "image://scaled/" + qtUtils.urlPath(Qt.resolvedUrl(getSignalStrengthImage()));
		anchors {
			verticalCenter: parent.verticalCenter
			right: secureNetwork.left
			rightMargin: Math.round(16 * horizontalScaling)
		}
	}

	Image {
		id: secureNetwork

		source: "image://scaled/apps/internetSettings/drawables/wifi-lock.svg"
		visible: Auth != "OPEN" ? true : false

		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: designElements.hMargin10
		}
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent
	}
}
