import QtQuick 2.1

Item {
	id: root
	anchors.fill: parent

	Text {
		id: infoText1line1
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(20 * horizontalScaling)
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.controlPanelTileText

		text: qsTr("add_lamp_popup_text_1_line_1")
	}
	Text {
		id: infoText1line2
		anchors {
			baseline: infoText1line1.baseline
			baselineOffset: Math.round(23 * verticalScaling)
			left: infoText1line1.left
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.controlPanelTileText

		text: qsTr("add_lamp_popup_text_1_line_2")
	}
	Text {
		id: infoText1line3
		anchors {
			baseline: infoText1line2.baseline
			baselineOffset: infoText1line2.anchors.baselineOffset
			left: infoText1line2.left
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.controlPanelTileText

		text: qsTr("add_lamp_popup_text_1_line_3")
	}

	Text {
		id: infoText2
		anchors {
			baseline: infoText1line3.baseline
			baselineOffset: Math.round(35 * verticalScaling)
			left: infoText1line3.left
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText

		color: colors.controlPanelTileText

		text: qsTr("add_lamp_popup_text_2")
	}

	Image {
		anchors {
			right: parent.right
			bottom: parent.bottom
		}
		source: "image://scaled/apps/controlPanel/drawables/bridge.svg"
		sourceSize.height: Math.round(100 * verticalScaling)
	}
}

