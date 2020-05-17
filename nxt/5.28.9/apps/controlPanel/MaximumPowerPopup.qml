import QtQuick 2.1

Item {
	Image {
		id: plug1Icon
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
		}
		sourceSize.height: Math.round(40 * verticalScaling)
		source: "image://scaled/apps/controlPanel/drawables/smartplug.svg"
	}
	Text {
		id: text1line1
		anchors {
			left: plug1Icon.right
			leftMargin: Math.round(20 * horizontalScaling)
			top: plug1Icon.top
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		font {
			pixelSize: qfont.tileTitle
			family: qfont.semiBold.name
		}
		color: colors.controlPanelTileText
		wrapMode: Text.WordWrap
		text: qsTr("text_1_line_1")
	}

	Image {
		id: plug2Icon
		anchors {
			left: plug1Icon.left
			top: text1line1.bottom
			topMargin: designElements.vMargin15
		}
		source: "image://scaled/apps/controlPanel/drawables/smartplug-dead.svg"
	}
	Text {
		id: text2line1
		anchors {
			left: text1line1.left
			top: plug2Icon.top
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		font {
			pixelSize: qfont.tileTitle
			family: qfont.semiBold.name
		}
		color: colors.controlPanelTileText
		wrapMode: Text.WordWrap
		text: qsTr("text_2_line_1")
	}
}
