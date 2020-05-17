import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.components 1.0
import BasicUIControls 1.0

Screen {
	property alias titleText: titleText.text
	property alias bodyText: bodyText.text
	property alias ctaText: ctaText.text
	property url imageSource

	Column {
		id: textColumn
		anchors {
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(15 * verticalScaling)
			right: illustration.left
			rightMargin: Math.round(25 * horizontalScaling)
		}
		spacing: Math.round(40 * verticalScaling)

		Text {
			id: titleText
			width: parent.width
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.8
		}

		Text {
			id: bodyText
			width: parent.width
			rightPadding: Math.round(30 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.9
		}
	}

	Image {
		id: illustration
		anchors {
			top: textColumn.top
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		source: imageSource.toString() ? "image://scaled" + qtUtils.urlPath(imageSource) : ""

		Column {
			anchors {
				left: parent.left
				right: parent.right
				bottom: parent.bottom
				margins: spacing
			}
			spacing: Math.round(13 * verticalScaling)

			Text {
				id: ctaText
				width: parent.width
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.bodyText
				}
				color: colors.text
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
				lineHeight: 0.9
			}

			StandardButton {
				width: parent.width
				primary: true
				text: qsTr("upsell-cta-button-label")

				onClicked: stage.openFullscreen(app.chosenScreenUrl)
			}
		}
	}
}
