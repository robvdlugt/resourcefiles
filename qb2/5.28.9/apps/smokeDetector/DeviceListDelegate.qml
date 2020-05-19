import QtQuick 2.1

import qb.components 1.0

Item {
	id: deviceListDelegate

	signal editDeviceClicked()

    width: parent.width
	height: deviceListItemLabel.height

	Component.onCompleted: {
		editButton.clicked.connect(editDeviceClicked);
		deviceListItemLabel.clicked.connect(editDeviceClicked);
	}

	Component.onDestruction: {
		editButton.clicked.disconnect(editDeviceClicked);
		deviceListItemLabel.clicked.disconnect(editDeviceClicked);
	}

	SingleLabel {
		id: deviceListItemLabel

		leftText: device.name ? device.name : device.type
		leftTextFormat: Text.PlainText // Prevent XSS/HTML injection

        anchors {
            left: parent.left
            right: editButton.left
            rightMargin: designElements.hMargin6
        }

		Text {
			id: customRightText
			anchors {
				right: battIcon.visible ? battIcon.left : parent.right
				rightMargin: battIcon.visible ? designElements.hMargin10 : 0
				verticalCenter: parent.verticalCenter
			}
			font.pixelSize: qfont.titleText

			Component.onCompleted: {
				if (!device.connected || device.connected === "0") {
					visible = true;
					text = qsTr("No connection");
					font.family = qfont.italic.name;
				} else if (device.batteryLevel > 0) {
					visible = true;
					text = device.batteryLevel + "%";
					font.family = qfont.regular.name;
				} else {
					visible = false;
				}
			}
		}

		Image {
			id: battIcon
			anchors {
				right: parent.right
				rightMargin: designElements.hMargin10
				verticalCenter: parent.verticalCenter
			}

			Component.onCompleted: {
				if (!device.connected || device.connected === "0") {
					source = ""
				} else {
					if (device.batteryLevel >= 51) {
						source = "image://scaled/images/battery-full.svg";
					} else if (device.batteryLevel >= 26) {
						source = "image://scaled/images/battery-high.svg";
					} else if (device.batteryLevel >= 11) {
						source = "image://scaled/images/battery-mid.svg";
					} else if (device.batteryLevel >= 0) {
						source = "image://scaled/images/battery-low.svg";
					} else {
						source = "image://scaled/images/battery-unknown.svg";
					}
				}
			}
		}
	}

	IconButton {
		id: editButton
		iconSource: "qrc:/images/edit.svg"
		anchors {
			top: deviceListItemLabel.top
			right: parent.right
		}
		height: deviceListItemLabel.height
		width: height
		bottomClickMargin: 3
		topClickMargin: 3
	}
}

