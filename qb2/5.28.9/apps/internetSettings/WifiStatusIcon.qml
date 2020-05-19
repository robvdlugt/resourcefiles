import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0


Item {
	state: "DEFAULT"

	Throbber {
		id: connectThrobber
		width: Math.round(30 * horizontalScaling)
		height: Math.round(30 * verticalScaling)
		anchors.centerIn: parent
	}

	Image {
		id: connectImage
		anchors.centerIn: parent
		height: Math.round(24 * verticalScaling)
		sourceSize{
			height: height
			width: 0
		}
	}

	states: [
		State {
			name: "DEFAULT"
			PropertyChanges { target: connectImage; source: ""; visible: false }
			PropertyChanges { target: connectThrobber; visible: false }
		},
		State {
			name: "CONNECTING"
			PropertyChanges { target: connectImage; source: ""; visible: false }
			PropertyChanges { target: connectThrobber; visible: true }
		},
		State {
			name: "CONNECTION_ERROR"
			PropertyChanges { target: connectImage; source: "qrc:/images/bad.svg"; visible: true }
			PropertyChanges { target: connectThrobber; visible: false }
		},
		State {
			name: "CONNECTED"
			PropertyChanges { target: connectImage; source: "qrc:/images/good.svg"; visible: true }
			PropertyChanges { target: connectThrobber; visible: false }
		}
	]
}
