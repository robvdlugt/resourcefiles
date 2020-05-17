import QtQuick 2.1

Item {
	id: root
	anchors.fill: parent

	Image {
		id: bigLamp
		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		sourceSize.width: Math.round(80 * horizontalScaling)
		source: "image://scaled/apps/controlPanel/drawables/hue-lamp.svg"
	}

	Text {
		text: qsTr('<center>With Toon you can control your Philips hue bulbs.<br>Do you want to link the bridge with Toon?</center>')
		anchors {
			top: bigLamp.bottom
			topMargin: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}

	}
}
