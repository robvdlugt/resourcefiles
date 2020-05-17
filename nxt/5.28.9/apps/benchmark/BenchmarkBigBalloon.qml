import QtQuick 2.1

Column {
	id: benchmarkBigBalloon
	// Spacing 0 allows us to explicitely add spacers where necessary.
	spacing: 0

	property alias name: name.text
	property alias usage: usage.text
	property string colorizeColor: "transparent"
	property url imageSource: "drawables/yourballoon.svg"
	property alias textWidth: name.width
	property alias nameFont: name.font
	property string kpiPostfix: "BigBalloon"

	signal clicked()

	Text {
		id: name
		color: colors.balloonNameText

		anchors.horizontalCenter: parent.horizontalCenter

		font {
			family: qfont.regular.name
			pixelSize: qfont.metaText
		}
		text: qsTr("Yourself")
	}

	Text {
		id: usage
		color: colors.balloonUsageText

		anchors.horizontalCenter: parent.horizontalCenter

		font {
			family: qfont.regular.name
			pixelSize: qfont.metaText
		}
	}

	Item {
		id: spacer
		height: Math.round(3 * verticalScaling)
		// No need to scale the width, since it's just a spacer. Can't make it 0, because
		// then the column would not render/apply it anymore.
		width: 1
	}

	Item {
		id: balloonItem
		height: balloonImage.height
		width: balloonImage.width
		anchors.horizontalCenter: parent.horizontalCenter

		// Item is used to group the balloonImage + the colored background for it
		Rectangle {
			id: balloonFill
			width: balloonImage.width / 2
			height: balloonImage.height / 1.5

			anchors {
				horizontalCenter:balloonImage.horizontalCenter
				top: balloonImage.top
				topMargin: balloonImage.height / designElements.vMargin10
			}

			color: colors.background
		}

		Image {
			id: balloonImage
			anchors.bottom: parent.bottom
			source: "image://colorized/" + colorizeColor + qtUtils.urlPath(imageSource)

			MouseArea {
				id: mouseArea
				anchors.fill: parent
				onClicked: benchmarkBigBalloon.clicked()
			}
		}
	}
}
