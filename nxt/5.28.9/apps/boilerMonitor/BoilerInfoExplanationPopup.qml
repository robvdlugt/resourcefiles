import QtQuick 2.1
import qb.components 1.0

Item {
	id: popupContent
	anchors.fill: parent

	Text {
		id: explanationContent
		anchors {
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(30 * horizontalScaling)
			right: boilerInfoImage.left
			rightMargin: Math.round(40 * verticalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: qsTr("boiler_info_explanation_content")
	}

	Text {
		id: tipTextTitle
		anchors {
			bottom: tipTextContent.top
			bottomMargin: Math.round(8 * verticalScaling)
			left: tipTextContent.left
			right: tipTextContent.right
		}
		font {
			pixelSize:  qfont.titleText
			family: qfont.bold.name
		}
		wrapMode: Text.WordWrap
		text: qsTr("boiler_info_explanation_tip")
	}

	Text {
		id: tipTextContent
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * horizontalScaling)
			topMargin: Math.round(8 * verticalScaling)
			left: explanationContent.left
			right: explanationContent.right
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: qsTr("boiler_info_explanation_tip_content")
	}

	Image {
		id: boilerInfoImage
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Math.round(30 * horizontalScaling)
		}
		source: "image://scaled/apps/boilerMonitor/drawables/boiler-check-tip-image.svg"
	}
}
