import QtQuick 2.1

/**
 * Container that mimmics the interface of the Flickable container, except it's not flickable.
 * Usefull to easily switch between flickable and much-lighter non-flickable implementations of the same view.
 * The Rectangle base class allows the container to be colored.
 */
Rectangle {
	property real contentWidth
	property real contentHeight
	property variant boundsBehavior
	property variant flickableDirection
	property real contentX: 0
	property real contentY: 0

	color: "#00000000"

	onContentYChanged: {
		children[0].y = 0 - contentY;
	}
	onContentXChanged: {
		children[0].x = 0 - contentX;
	}
}
