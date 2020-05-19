import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.base 1.0

Widget {
	id: baseMenuBarButton
	width: Math.max(row.width, minWidth)
	height: designElements.menubarHeight

	property string label: ""
	property string kpiPostfix: label
	property url image: ""
	property string labelFont : qfont.semiBold.name
	property bool isLeftBarButton : true
	property int minWidth: Math.round(86 * horizontalScaling)

	signal clicked()

	Rectangle {
		id: backgroundMenuBarButton
		anchors.fill: parent
		color: colors["menuButtonBackground"] // this notation so that it's not replaced by the static colors script
	}

	Row {
		id: row
		anchors.centerIn: parent
		leftPadding: designElements.hMargin15
		rightPadding: designElements.hMargin15

		RowLayout {
			spacing: designElements.spacing6
			layoutDirection: isLeftBarButton ? Qt.LeftToRight : Qt.RightToLeft

			Image {
				id: baseMenuBarArrow
				fillMode: Image.PreserveAspectFit
				source: image
			}

			Text {
				id: baseMenuBarLabel
				text: label
				color: colors.menuBarLabel
				font {
					pixelSize: qfont.titleText
					family: labelFont
				}
			}
		}
	}

	MouseArea {
		id: mouseArea
		width: parent.width
		height: parent.height + 10

		onPressed: baseMenuBarButton.state = "down"
		onReleased: baseMenuBarButton.state = "up"
		onClicked: baseMenuBarButton.clicked()
	}

	states: [
		State {
			name: "up"
		},
		State {
			name: "down"
			PropertyChanges { target: baseMenuBarLabel; color: colors.menuBarLabelDown }
			PropertyChanges { target: backgroundMenuBarButton; color: colors.background }
		},
		State {
			name: "disabled"
			when: !baseMenuBarButton.enabled
			PropertyChanges { target: baseMenuBarLabel; color: colors.menuBarLabelDisabled }
			PropertyChanges { target: mouseArea; enabled: false }
		}
	]
}
