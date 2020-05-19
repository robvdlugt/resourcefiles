import QtQuick 2.1

Item {
	id: benchmarkSmallBalloon
	width: balloonImage.width
	height: balloonImage.height

	property alias name: name.text
	property url imageSource
	property bool colorize: false
	property color colorizeColor
	property alias textWidth: name.width
	property alias nameY: name.y
	property string kpiPostfix: "SmallBalloon"

	signal clicked()

	function setTextHorizontalCenter() {
		name.anchors.left = undefined;
		name.anchors.right = undefined;
		name.anchors.horizontalCenter = benchmarkSmallBalloon.horizontalCenter;
	}

	function setTextRight(absX) {
		name.anchors.horizontalCenter = undefined;
		name.anchors.right = undefined;
		name.anchors.left = undefined;
		name.x = absX - x;
	}

	function setTextVerticalOffset(offset) {
		name.anchors.bottomMargin = 3 + offset;
	}

	function setTextLeft(absX) {
		name.anchors.horizontalCenter = undefined;
		name.anchors.left = undefined;
		name.anchors.right = undefined;
		name.x = absX - name.width - x;
	}

	Text {
		id: name
		color: colors.balloonNameText
		anchors {
			bottom: balloonImage.top
			bottomMargin: Math.round(3 * verticalScaling)
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.metaText
		}
	}

	Image {
		id: balloonImage
		anchors.bottom: parent.bottom
		source: (colorize ? "image://colorized/" + colorizeColor.toString() : "image://scaled/") + qtUtils.urlPath(imageSource)

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			onClicked: benchmarkSmallBalloon.clicked()
		}
	}
}
