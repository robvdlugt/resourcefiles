import QtQuick 2.1
import qb.components 1.0

Item {
	id: container

	property bool animate: true
	property int itemPercentage: 0
	property string itemText: ""

	Throbber {
		id: throbber
		width: Math.round(80 * horizontalScaling)
		height: Math.round(80 * verticalScaling)

		animate: container.animate

		smallRadius: 3
		mediumRadius: 4
		largeRadius: 5
		bigRadius: 6

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: itemText.top
		}

		Text {
			id: statusText
			text: "%1 \%".arg(container.itemPercentage)
			anchors.centerIn: parent
			color: colors.softUpdateWzrdBody
			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name
		}
	}
	Text {
		id: itemText
		text: container.itemText

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
		}
		horizontalAlignment: Text.AlignHCenter
		color: colors.softUpdateWzrdBody
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}
}
