import QtQuick 2.1

import qb.components 1.0

Rectangle {
	id: root
	anchors.fill: parent
	color: qtUtils.addColorAlpha(colors.dialogMaskedArea, 0.75)
	property alias titleText: pinTitle.text
	property alias bottomText: bottomText.text
	property alias titleFontSize: pinTitle.font.pixelSize

	signal clicked()
	signal closed()
	signal bottomTextClicked()
	signal pinEntered(var pin)
	signal wrongPin() // incoming signal, called by user to signal that the pin entered is wrong

	function show() {
		pinKeyboard.clear();
		root.visible = true;
	}

	function hide() {
		wrongPinIcon.visible = false;
		root.visible = false;
		pinKeyboard.clear();
	}

	onWrongPin: {
		pinKeyboard.wrongPin();
		wrongPinIcon.visible = true;
	}

	MouseArea {
		property string kpiId: "PinEntry.Underlay"
		anchors.fill: parent
		onClicked: parent.clicked()
	}

	Rectangle {
		id: backgroundRect
		anchors.centerIn: parent
		width: pinKeyboard.width + Math.round(90 * horizontalScaling)
		height: pinColumn.height + Math.round(50 * verticalScaling)
		radius: designElements.radius
		color: colors.canvas

		IconButton {
			id: closeBtn
			width: designElements.buttonSize
			height: width
			anchors {
				top: parent.top
				topMargin: designElements.vMargin5
				right: parent.right
				rightMargin: anchors.topMargin
			}
			colorUp: "transparent"
			iconSource: "qrc:/images/DialogCross.svg"
			onClicked: root.closed()
		}

		Column {
			id: pinColumn
			anchors {
				left: parent.left
				leftMargin: Math.round(15 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
				bottom: parent.bottom
				bottomMargin: anchors.leftMargin
			}
			spacing: pinKeyboard.buttonSpace

			Text {
				id: pinTitle
				anchors {
					left: parent.left
					right: parent.right
				}
				font {
					family: qfont.bold.name
					pixelSize: qfont.titleText
				}
				color: colors.black
				wrapMode: Text.WordWrap
				horizontalAlignment: Text.AlignHCenter
			}

			NumericKeyboard {
				id: pinKeyboard
				anchors.horizontalCenter: parent.horizontalCenter
				buttonWidth: Math.round(60 * verticalScaling)
				buttonHeight: Math.round(50 * verticalScaling)
				buttonSpace: designElements.vMargin10
				pinMode: true
				maxTextLength: 4

				onPinEntered: root.pinEntered(pin)
				onDigitEntered: wrongPinIcon.visible = false
			}

			Text {
				id: bottomText
				anchors {
					left: parent.left
					right: parent.right
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
					underline: true
				}
				color: colors._fantasia
				elide: Text.ElideRight
				horizontalAlignment: Text.AlignHCenter
				visible: text ? true : false

				MouseArea {
					width: parent.width
					height: parent.height + designElements.vMargin10
					anchors.centerIn: parent
					onClicked: bottomTextClicked()
				}
			}
		}

		Image {
			id: wrongPinIcon
			anchors {
				top: pinColumn.top
				topMargin: pinKeyboard.y + designElements.vMargin10
				left: pinColumn.left
				leftMargin: pinKeyboard.x + pinKeyboard.width + designElements.hMargin10
			}
			height: Math.round(24 * verticalScaling)
			sourceSize.height: height
			source: "image://scaled/images/bad.svg"
			visible: false
		}
	}
}
