import QtQuick 2.1
import qb.components 1.0

Item {
	id: popupContent

	Item {
		id: popupContentContainer
		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
			leftMargin: 58
			rightMargin: 58
		}
		height: childrenRect.height

		Text {
			id: noConnTitle
			font {
				pixelSize: 17
				family: qfont.bold.name
			}
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-no-connection-title")
		}

		Text {
			id: noConnText
			anchors {
				left: parent.left
				right: parent.right
				baseline: noConnTitle.baseline
				baselineOffset: font.pixelSize * 1.5
			}
			font {
				pixelSize: 17
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-no-connection-text")
		}

		Image {
			id: lowBattImage
			anchors {
				verticalCenter: lowBattTitle.verticalCenter
			}
			source: "image://scaled/images/battery-low.svg"
		}


		Text {
			id: lowBattTitle
			anchors {
				top: noConnText.bottom
				topMargin: 17
				left: lowBattImage.right
				leftMargin: 10
			}
			font {
				pixelSize: 17
				family: qfont.bold.name
			}
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-low-battery-title")
		}

		Text {
			id: lowBattText
			anchors {
				left: parent.left
				right: parent.right
				baseline: lowBattTitle.baseline
				baselineOffset: font.pixelSize * 1.5
			}
			font {
				pixelSize: 17
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-low-battery-text")
		}

		Image {
			id: unknownBattImage
			anchors {
				verticalCenter: unknownBattTitle.verticalCenter
			}
			source: "image://scaled/images/battery-unknown.svg"
		}


		Text {
			id: unknownBattTitle
			anchors {
				top: lowBattText.bottom
				topMargin: 17
				left: unknownBattImage.right
				leftMargin: 10
			}
			font {
				pixelSize: 17
				family: qfont.bold.name
			}
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-unknown-battery-title")
		}

		Text {
			id: unknownBattText
			anchors {
				left: parent.left
				right: parent.right
				baseline: unknownBattTitle.baseline
				baselineOffset: font.pixelSize * 1.5
			}
			font {
				pixelSize: 17
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("sd-status-unknown-battery-text")
		}
	}
}
