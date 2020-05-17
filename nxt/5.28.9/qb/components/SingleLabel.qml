import QtQuick 2.1
import BasicUIControls 1.0

Item {
	id: singleLabel

	width: Math.round(450 * horizontalScaling)
	height: defaultHeight

	property int defaultHeight: Math.round(36 * verticalScaling)

	property alias leftText: textBlockLabel.text
	property alias rightText: textBlockBody.text
	property color leftTextColor : colors.singleLabelLeftText
	property color rightTextColor : colors.singleLabelRightText
	property alias leftTextFormat: textBlockLabel.textFormat
	property alias rightTextFormat: textBlockBody.textFormat
	property alias leftTextSize: textBlockLabel.font.pixelSize
	property alias rightTextSize: textBlockBody.font.pixelSize
	property alias rightTextFont: textBlockBody.font.family
	property alias leftTextHeight: textBlockLabel.implicitHeight
	property int rightTextMargin: 0
	property alias iconSource: icon.source
	property alias mouseEnabled: backgroundRect.mouseEnabled
	property string kpiPostfix: textBlockLabel.text
	signal clicked

	StyledRectangle {
		id: backgroundRect
		anchors.fill: parent
		color: singleLabel.enabled ? colors.labelBackground : colors.labelBgDisabled
		radius: designElements.radius
		bottomClickMargin: 3
		topClickMargin: 3
		leftClickMargin: 10
		rightClickMargin: 3
		onClicked: singleLabel.clicked()
	}

	Image {
		id: icon
		anchors {
			left: parent.left
			leftMargin: Math.round(13 * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}
	}

	Text {
		id: textBlockLabel

		font.family: qfont.semiBold.name
		font.pixelSize: qfont.titleText
		color: parent.enabled ? leftTextColor : colors.singleLabelDisabledText

		anchors {
			left: icon.source.toString() ? icon.right : parent.left
			leftMargin: Math.round((icon.source.toString() ? 10 : 13) * horizontalScaling)
			verticalCenter: parent.verticalCenter
		}
	}

	Text {
		id: textBlockBody

		elide: Text.ElideRight
		horizontalAlignment: Text.AlignRight
		font.family: qfont.regular.name
		font.pixelSize: qfont.titleText
		color: parent.enabled ? rightTextColor : colors.singleLabelDisabledText

		anchors {
			left: textBlockLabel.right
			leftMargin: 10
			right: parent.right
			rightMargin: Math.round(13 * horizontalScaling) + rightTextMargin
			verticalCenter: parent.verticalCenter
		}
	}
}
