import QtQuick 2.1

import BasicUIControls 1.0

Item {
	id: progressBar
	width: Math.round(100 * horizontalScaling)
	height: Math.round(16 * verticalScaling)

	property alias colorBg: progressBarBg.color
	property alias colorProgress: progressBarFg.color
	property real progress: 0.0
	property alias radius: progressBarBg.radius
	property real topLeftCornerRadiusRatio: 1.0
	property real topRightCornerRadiusRatio: 1.0
	property real bottomLeftCornerRadiusRatio: 1.0
	property real bottomRightCornerRadiusRatio: 1.0

	StyledRectangle {
		id: progressBarBg
		radius: (height / 2)
		anchors.fill: parent
		color: colors.progressBarBg
		topLeftRadiusRatio: topLeftCornerRadiusRatio
		topRightRadiusRatio: topRightCornerRadiusRatio
		bottomLeftRadiusRatio: bottomLeftCornerRadiusRatio
		bottomRightRadiusRatio: bottomRightCornerRadiusRatio

		StyledRectangle {
			id: leftCorner
			width: height
			height: parent.height
			anchors {
				left: parent.left
				verticalCenter: parent.verticalCenter
			}
			color: progressBarFg.color
			radius: parent.radius
			visible: progress > 0

			topLeftRadiusRatio: topLeftCornerRadiusRatio
			bottomLeftRadiusRatio: bottomLeftCornerRadiusRatio
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 0
			mouseEnabled: false
		}

		StyledRectangle {
			id: rightCorner
			width: height
			height: parent.height
			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			color: progressBarFg.color
			radius: parent.radius
			visible: progressBarFg.width === progressBarMask.width

			topLeftRadiusRatio: 0
			bottomLeftRadiusRatio: 0
			topRightRadiusRatio: topRightCornerRadiusRatio
			bottomRightRadiusRatio: bottomRightCornerRadiusRatio
			mouseEnabled: false
		}

		Rectangle {
			id: progressBarMask
			height: parent.height
			color: parent.color
			anchors {
				left: leftCorner.horizontalCenter
				right: rightCorner.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
		}

		Rectangle {
			id: progressBarFg
			width: progressBarMask.width * progress
			height: parent.height
			anchors {
				left: leftCorner.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			color: colors.progressBarFill
		}
	}
}
