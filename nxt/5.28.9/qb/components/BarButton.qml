import QtQuick 2.1

Rectangle {
	id: barButton
	width: Math.round(41 * horizontalScaling)
	height: Math.round(41 * verticalScaling)
	color: state === "down" && !imageIsButton ? colors.barButtonBckgDown : colors.barButtonBckgUp

	property url imageUp
	property url imageDown
	property bool imageIsButton: false

	property string kpiPostfix: imageUp.toString().split("/").pop()

	signal clicked()

	Image {
		id: icon
		anchors {
			centerIn: parent
			horizontalCenterOffset: barButton.state === "down" && imageIsButton ? 2 : 0
			verticalCenterOffset: anchors.horizontalCenterOffset
		}
		source: barButton.state === "down" ? imageDown : imageUp
	}

	MouseArea {
		id: btnMouseArea
		anchors.fill: parent
		onPressed: barButton.state = "down"
		onReleased: barButton.state = ""
		onClicked: barButton.clicked()
	}
}
