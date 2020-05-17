import QtQuick 2.0

Screen {
	property alias title: titleText.text
	property url imageSource
	property string imagePosition: "bottom"
	default property alias content: content.data

	Rectangle {
		anchors {
			fill: parent
			margins: Math.round(16 * verticalScaling)
		}
		radius: designElements.radius
		color: colors.contentBackground
		clip: true

		Text {
			id: titleText
			anchors {
				top: parent.top
				topMargin: designElements.vMargin20
				left: parent.left
				leftMargin: anchors.topMargin
				right: image.left
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.8
		}

		Item {
			id: content
			anchors {
				top: titleText.baseline
				topMargin: Math.round(50 * verticalScaling)
				bottom: parent.bottom
				bottomMargin: designElements.vMargin20
				left: titleText.left
				right: image.left
				rightMargin: designElements.hMargin20
			}
		}

		Image {
			id: image
			anchors {
				verticalCenter: imagePosition === "center" ? parent.verticalCenter : undefined
				bottom: imagePosition === "bottom" ? parent.bottom : undefined
				right: parent.right
			}
			source: imageSource.toString() ? "image://scaled/" + qtUtils.urlPath(imageSource) : ""
		}
	}
}
