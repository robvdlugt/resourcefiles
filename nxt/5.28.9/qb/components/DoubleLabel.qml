import QtQuick 2.1

Item {
	id: root
	width: Math.round(450 * horizontalScaling)
	height: Math.round(72 * verticalScaling)

	property alias topText: textBlockLabel.text
	property alias topTextFormat: textBlockLabel.textFormat
	property alias bottomText: textBlockBody.text
	property alias bottomTextFontFamily: textBlockBody.font.family
	property alias bottomTextPixelSize: textBlockBody.font.pixelSize
	property alias bottomTextFormat: textBlockBody.textFormat

	Rectangle {
		anchors.fill: parent
		color: colors.labelBackground
		radius: designElements.radius
	}

	Text {
		id: textBlockLabel

		text: " "
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.titleText
		color: parent.enabled ? colors.doubleLabelTopText : colors.doubleLabelDisabledText

		anchors {
			left: root.left
			leftMargin: Math.round(13 * horizontalScaling)
			right: root.right
			rightMargin: Math.round(13 * horizontalScaling)
			baseline: root.top
			baselineOffset: Math.round(23 * verticalScaling)
		}
	}

	Text {
		id: textBlockBody

		text: " "
		elide: Text.ElideRight
		font.family: qfont.italic.name
		font.pixelSize: qfont.bodyText
		color: parent.enabled ? colors.doubleLabelBottomText : colors.doubleLabelDisabledText

		anchors {
			left: root.left
			leftMargin: Math.round(13 * horizontalScaling)
			right: root.right
			rightMargin: Math.round(13 * horizontalScaling)
			baseline: root.bottom
			baselineOffset: Math.round(-10 * verticalScaling)
		}
	}
}
