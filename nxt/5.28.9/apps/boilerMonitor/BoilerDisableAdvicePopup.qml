import QtQuick 2.1

import qb.components 1.0

Item {
	id: root

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(25 * horizontalScaling)
			right: image.left
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors._gandalf
		wrapMode: Text.WordWrap
		text: qsTr("boiler_noAdvice_title")
	}

	Text {
		id: text
		anchors {
			top: titleText.bottom
			topMargin: Math.round(20 * verticalScaling)
			left: titleText.left
			right: titleText.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors._harry
		wrapMode: Text.WordWrap
		text: qsTr("boiler_noAdvice_text")
	}

	Image {
		id: image
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Math.round(25 * horizontalScaling)
		}
		source:"image://scaled/apps/boilerMonitor/drawables/boiler-noConsent.svg"
	}
}
