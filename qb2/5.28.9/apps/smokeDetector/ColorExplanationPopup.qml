import QtQuick 2.1
import QtQuick.Layouts 1.3

Item {
	anchors.fill: parent

	GridLayout {
		id: popupContent
		anchors {
			left: parent.left
			leftMargin: Math.round(25 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			top: parent.top
			topMargin: designElements.vMargin20
		}
		columns: 2
		rowSpacing: designElements.vMargin20
		columnSpacing: designElements.hMargin15

		Image {
			id: greenColor
			source: "image://scaled/apps/smokeDetector/drawables/green.svg"
		}

		Text {
			id: greenText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("green-color-text")
		}

		Image {
			id: yellowColor
			source: "image://scaled/apps/smokeDetector/drawables/yellow.svg"
		}

		Text {
			id: yellowText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("yellow-color-text")
		}

		Image {
			id: purpleColor
			source: "image://scaled/apps/smokeDetector/drawables/pink.svg"
		}

		Text {
			id: purpleText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("purple-color-text")
		}

		Image {
			id: redColor
			source: "image://scaled/apps/smokeDetector/drawables/red.svg"
		}

		Text {
			id: redText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("red-color-text")
		}
	}
}
