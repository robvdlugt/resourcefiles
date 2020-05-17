import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.components 1.0
import BasicUIControls 1.0

Screen {
	screenTitle: qsTr("upsell-screen-title")

	Column {
		id: textColumn
		anchors {
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(25 * verticalScaling)
			right: moreInfoRect.left
			rightMargin: Math.round(25 * horizontalScaling)
		}
		spacing: Math.round(25 * verticalScaling)

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
			text: qsTr("upsell-title-general")
		}

		GridLayout {
			width: parent.width
			columns: 2
			rowSpacing: designElements.vMargin15
			columnSpacing: designElements.vMargin15

			Image {
				source: "image://scaled/apps/upsell/drawables/insight-bullet.svg"
			}

			Text {
				Layout.fillWidth: true
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.text
				wrapMode: Text.WordWrap
				lineHeight: 0.8
				text: qsTr("upsell-insight-bullet-text")
			}

			Image {
				source: "image://scaled/apps/upsell/drawables/heating-bullet.svg"
			}

			Text {
				Layout.fillWidth: true
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.text
				wrapMode: Text.WordWrap
				lineHeight: 0.8
				text: qsTr("upsell-heating-bullet-text")
			}

			Image {
				source: "image://scaled/apps/upsell/drawables/boiler-bullet.svg"
			}

			Text {
				Layout.fillWidth: true
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.text
				wrapMode: Text.WordWrap
				lineHeight: 0.8
				text: qsTr("upsell-boiler-bullet-text")
			}
		}

		Text {
			id: bodyText
			width: parent.width
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.9
			text: qsTr("upsell-body-general")
		}
	}

	Rectangle {
		id: moreInfoRect
		width: Math.round(260 * horizontalScaling)
		height: Math.round(80 * verticalScaling)
		anchors {
			bottom: illustration.top
			bottomMargin: Math.round(60 * verticalScaling)
			horizontalCenter: illustration.horizontalCenter
		}
		color: colors.white
		radius: height / 2

		Text {
			id: moreInfoText
			anchors.fill: parent
			padding: designElements.vMargin10
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			z: 10
			color: colors.text
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
			lineHeight: 0.8
			text: qsTr("upsell-moreinfo").arg(colors._branding.toString()).arg(qsTr("upsell-url"))
		}
	}

	Rectangle {
		id: qrBubble
		width: Math.round(85 * horizontalScaling)
		height: width
		radius: height / 2
		anchors {
			top: moreInfoRect.bottom
			topMargin: - Math.round(20 * verticalScaling)
			right: moreInfoRect.right
			rightMargin: Math.round(30 * horizontalScaling)
		}
		color: colors.white

		QrCode {
			anchors.centerIn: parent
			width: height
			height: Math.round(50 * verticalScaling)
			content: qsTr("upsell-url")
		}
	}

	Image {
		id: illustration
		anchors {
			bottom: parent.bottom
			bottomMargin: - designElements.bottomBarHeight
			right: parent.right
			rightMargin: Math.round(75 * horizontalScaling)
		}
		source: "image://scaled/apps/upsell/drawables/surprise-box.svg"
	}
}
