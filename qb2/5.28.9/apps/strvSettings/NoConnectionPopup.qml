import QtQuick 2.0
import QtQuick.Layouts 1.3

Item {
	anchors.fill: parent

	GridLayout {
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			leftMargin: Math.round(40 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		columns: 2
		rowSpacing: designElements.vMargin10
		columnSpacing: designElements.hMargin15

		Text {
			Layout.fillWidth: true
			Layout.columnSpan: 2
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: qsTr("strv-no-connection-popup-question")
			wrapMode: Text.WordWrap
		}

		Text {
			Layout.alignment: Qt.AlignTop
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			color: colors.accent
			text: qsTr("Yes")
		}

		Text {
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: qsTr("strv-no-connection-popup-advice-one")
			wrapMode: Text.WordWrap
		}

		Text {
			Layout.alignment: Qt.AlignTop
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			color: colors.accent
			text: qsTr("No")
		}

		Text {
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: qsTr("strv-no-connection-popup-advice-two")
			wrapMode: Text.WordWrap
		}
	}
}
