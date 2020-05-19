import QtQuick 2.1

Item {
	property int wo: 0
	property int ho: 0
	property int wi: 0
	property int hi: 0
	property color co : colors.separator1
	property color ci : colors.separator2

	width: childrenRect.width
	height: childrenRect.height

	Rectangle {
		id: lineLeft
		width: wo
		height: ho
		color: co
	}

	Rectangle {
		id: lineRight
		width: wi
		height: hi
		color: ci
		anchors.left: lineLeft.right
	}
}
