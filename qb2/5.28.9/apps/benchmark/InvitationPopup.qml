import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Item {
	property alias contentText: text.text

	anchors.fill: parent

	Throbber {
		id: throbber

		width: Math.round(150 * horizontalScaling)
		height: Math.round(150 * verticalScaling)

		smallRadius: 4
		mediumRadius: 5
		largeRadius: 7
		bigRadius: 10

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
		}
	}

	Image {
		id: image

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
		}
	}

	Text {
		id: text

		width: parent.width - Math.round(100 * horizontalScaling)

		anchors {
			top: image.bottom
			topMargin: Math.round(20 * verticalScaling)
			horizontalCenter: image.horizontalCenter
		}

		wrapMode: Text.WordWrap
		horizontalAlignment: Text.AlignHCenter

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	state: "BUSY"
	states: [
		State {
			name: "BUSY"
			PropertyChanges { target: throbber; visible: true; }
			PropertyChanges { target: image; visible: false; }
			PropertyChanges { target: text; visible: false; }
		},
		State {
			name: "SUCCESS"
			PropertyChanges { target: throbber; visible: false; }
			PropertyChanges { target: image; visible: true; source: "image://scaled/apps/benchmark/drawables/GoodbyeMan.svg"; }
			PropertyChanges { target: text; visible: true; text: qsTr("Invitation send"); }
		},
		State {
			name: "ERROR"
			PropertyChanges { target: throbber; visible: false; }
			PropertyChanges { target: image; visible: true; source: "image://scaled/apps/benchmark/drawables/NoGoodbyeMan.svg" }
			PropertyChanges { target: text; visible: true; }
		}
	]
}
