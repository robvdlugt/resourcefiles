import QtQuick 2.1
import qb.components 1.0

Rectangle {
	id: radarBackground
	color: throbber.visible ? colors.waNoDataAvailable : colors.none

	AnimatedImage {
		id: radarImage
		anchors.fill: parent
		cache: true
		Component.onCompleted: setSource()

		function setSource() {
			source = "https://api.buienradar.nl/image/1.0/RadarMapNL?&brand=1&hist=0&forc=60&step=2&w=" + width + "&h=" + height;
		}

		property int retries: 0
		onStatusChanged: {
			if (status === Image.Error && retries < 3) {
				retries += 1;
				setSource();
			} else {
				retries = 0;
			}
		}
	}

	Throbber {
		id: throbber
		anchors.centerIn: parent
		visible: radarImage.status === Image.Loading
	}
}
