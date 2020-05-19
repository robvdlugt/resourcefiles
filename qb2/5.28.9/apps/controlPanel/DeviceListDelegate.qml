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

		leftText: name
		leftTextFormat: Text.PlainText // Prevent XSS/HTML injection

		anchors {
			left: parent.left
			right: editButton.left
			rightMargin: designElements.hMargin6
		}

		Image {
			id: deviceLockedIcon
			anchors {
				right: parent.right
				rightMargin: Math.round(21 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			source: "image://scaled/apps/controlPanel/drawables/lock.svg"
			visible: isLocked
		}

		Image {
			id: deviceLinkIcon
			anchors {
				right: parent.right
				rightMargin: Math.round(21 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			source: "image://scaled/apps/controlPanel/drawables/group.svg"
			visible: isLinked && !isLocked
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
