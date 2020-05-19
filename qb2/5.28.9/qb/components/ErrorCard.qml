import QtQuick 2.1

Rectangle {
	width:Math.round(230 * horizontalScaling)
	height: parent ? parent.height : 0
	radius: designElements.radius
	color: colors.contentBackground
	property alias label: labelText.text
	property alias icon: mainIcon.source
	property alias statusIcon: statusIcon.source
	property alias statusText: statusText.text
	property string errorCode

	signal buttonClicked()

	Text {
		id: labelText
		anchors {
			baseline: parent.top
			baselineOffset: font.pixelSize + designElements.vMargin15
			left: parent.left
			leftMargin: designElements.hMargin20
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.bold.name
		}
		wrapMode: Text.WordWrap
		elide: Text.ElideRight
		lineHeight: 0.8
		maximumLineCount: 2
		color: colors._gandalf
		horizontalAlignment: Text.AlignHCenter
		text: " "
	}

	Image {
		id: mainIcon
		anchors {
			bottom: labelText.baseline
			bottomMargin: - Math.round(120 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		Image {
			id: statusIcon
			height: Math.round(60 * verticalScaling)
			sourceSize.height: height
			fillMode: Image.PreserveAspectFit
			anchors {
				left: parent.horizontalCenter
				leftMargin: designElements.hMargin20
				bottom: parent.bottom
				bottomMargin: Math.round(30 * verticalScaling)
			}
		}
	}

	Text {
		id: statusText
		anchors {
			top: mainIcon.bottom
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: designElements.hMargin20
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors._harry
		text: " "
		wrapMode: Text.WordWrap
	}

	Text {
		id: errorCodeText
		anchors {
			bottom: adviceButton.top
			left: parent.left
			right: parent.right
			margins: designElements.vMargin20
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors._harry
		text: qsTr("Error code: %1").arg(errorCode)
		visible: errorCode ? true : false
	}

	StandardButton {
		id: adviceButton
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			margins: designElements.vMargin20
		}
		primary: true
		text: qsTr("What can I do?")
		onClicked: buttonClicked()
	}
}
