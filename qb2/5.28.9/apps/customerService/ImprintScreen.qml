import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root

	screenTitleIconUrl: "drawables/imprint.svg"
	screenTitle: qsTr("Imprint")

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.text
		text: qsTr("imprint_title_text")
		wrapMode: Text.WordWrap
	}

	Text {
		id: text
		anchors {
			left: title.left
			right: title.right
			baseline: title.bottom
			baselineOffset: Math.round(40 * verticalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.text
		text: qsTr("imprint_body_text")
		wrapMode: Text.WordWrap
	}
}
