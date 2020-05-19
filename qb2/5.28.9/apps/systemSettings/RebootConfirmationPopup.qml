import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Item {
	id: container
	state: "waiting"

	property int timeout

	onTimeoutChanged: {
		if (timeout > 0) {
			state = "waiting";
		} else if (0 == timeout) {
			state = "timedout";
		}

		message.text = qsTr("Rebooting in %n second(s)", "", timeout) + "...";
	}

	Item {
		id: contentContainer
		anchors {
			left: parent.left
			top: parent.top
			leftMargin: Math.round(58 * horizontalScaling)
			topMargin: Math.round(53 * verticalScaling)
		}

		Text {
			id: message
			anchors {
				left: contentContainer.left
				top: contentContainer.top
				leftMargin: designElements.hMargin10
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.titleText
			width: container.width - Math.round((2 * 58) * horizontalScaling)
			wrapMode: Text.WordWrap
		}
	}

	Timer {
		id: timer
		repeat: true
		onTriggered: {
			timeout--;
		}
	}

	states : [
		State {
			name: "waiting"
			PropertyChanges { target: timer; running: true; }
			PropertyChanges { target: button1; enabled: true; }
			PropertyChanges { target: button2; enabled: true; }
		},
		State {
			name: "timedout"
			PropertyChanges { target: timer; running: false; }
			PropertyChanges { target: button1; enabled: false; }
			PropertyChanges { target: button2; enabled: false; }
		}
	]
}
