import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.components 1.0
import BasicUIControls 1.0

Screen {
	screenTitle: qsTranslate("UpsellGeneralScreen", "upsell-screen-title")

	Column {
		id: textColumn
		anchors {
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(25 * verticalScaling)
			right: illustration.left
			rightMargin: Math.round(50 * horizontalScaling)
		}
		spacing: designElements.vMargin15

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
			text: qsTr("upsell-heating-title")
		}

		Text {
			id: bodyText
			width: parent.width
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.9
			text: qsTr("upsell-heating-body")
		}
	}

	Image {
		id: illustration
		anchors {
			top: textColumn.top
			topMargin: - designElements.vMargin5
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		property string imageFile: "illustration-heating.svg"
		source: "image://scaled/apps/upsell/drawables/" + imageFile

		Text {
			id: moreInfoText
			anchors {
				left: parent.left
				right: parent.right
				bottom: parent.bottom
				margins: designElements.vMargin15
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.text
			wrapMode: Text.WordWrap
			lineHeight: 0.8
			text: qsTranslate("UpsellGeneralScreen", "upsell-moreinfo").arg(colors._branding.toString()).arg(qsTr("upsell-url"))
		}

		QrCode {
			anchors {
				right: parent.right
				rightMargin: Math.round(32 * verticalScaling)
				bottom: parent.bottom
				bottomMargin: Math.round(53 * verticalScaling)
			}
			implicitWidth: height
			implicitHeight: Math.round(50 * verticalScaling)
			content: qsTr("upsell-url")
		}
	}

	states: [
		State {
			name: "page-insight"
			when: pageSelector.currentPage === 1
			PropertyChanges { target: titleText; text: qsTr("upsell-insight-text") }
			PropertyChanges { target: bodyText; text: qsTr("upsell-insight-body") }
			PropertyChanges { target: illustration; imageFile: "illustration-insight.svg" }
		},
		State {
			name: "page-boiler"
			when: pageSelector.currentPage === 2
			PropertyChanges { target: titleText; text: qsTr("upsell-boiler-text") }
			PropertyChanges { target: bodyText; text: qsTr("upsell-boiler-body") }
			PropertyChanges { target: illustration; imageFile: "illustration-boiler.svg" }
		}
	]

	DottedSelector {
		id: pageSelector
		anchors {
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
			horizontalCenter: parent.horizontalCenter
		}
		pageCount: 3
	}
}
