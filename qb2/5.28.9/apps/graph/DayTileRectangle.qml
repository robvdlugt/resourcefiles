import QtQuick 2.1

Rectangle {
	property alias leftTextText: leftText.text
	property alias rightTextText: rightText.text
	property alias dayTextText: dayText.text

	width: Math.round(60 * horizontalScaling)
	color: dimmableColors.graphTileRect
	radius: designElements.radius
	anchors.bottom: parent.bottom

	Row {
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(7 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		Text {
			id: leftText
			anchors.baseline: parent.bottom
			color: dimmableColors.graphTileRectText
			font.family: qfont.semiBold.name
			font.pixelSize: qfont.bodyText
		}

		Text {
			id: rightText
			anchors.baseline: parent.bottom
			color: dimmableColors.graphTileRectText
			font.family: qfont.italic.name
			font.pixelSize: qfont.bodyText
		}
	}

	Text {
		id: dayText
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: 25
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.navigationTitle
		}
		color: dimmableColors.tileTextColor
	}
}
