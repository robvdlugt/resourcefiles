import QtQuick 2.1

Item {
	id: root
	property int wo: Math.round(50 * horizontalScaling)
	property int ho: 1
	property int wi: Math.round(50 * horizontalScaling)
	property int hi: 1
	property color co : colors.separator1
	property color ci : colors.separator2

	width: childrenRect.width
	height: childrenRect.height

	Rectangle {
		id: lineTop
		width: wo
		height: ho
		color: co
	}

	Rectangle {
		id: lineBottom
		width: wi
		height: hi
		color: ci
		anchors.left: lineTop.left
		anchors.top: lineTop.bottom
	}
}
