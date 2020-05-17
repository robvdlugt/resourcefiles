import QtQuick 2.1
import qb.components 1.0

Screen {
	id: welcomScreen

	screenTitle: qsTr("Smoke detector")
	screenTitleIconUrl: "drawables/smokedetector.svg"
	anchors.fill: parent

	hasBackButton: false

	Text {
		id: titleLabel
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(60 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: illustration.left
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
		color: colors.text
		lineHeight: 0.8
		text: qsTr("title_text")
		wrapMode: Text.WordWrap
	}

	Text {
		id: bodyText
		anchors {
			top: titleLabel.bottom
			topMargin: designElements.vMargin20
			left: titleLabel.left
			right: illustration.left
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.smokedetectorBody
		text: qsTr("body_text")
		wrapMode: Text.WordWrap
	}

	Image {
		id: illustration
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(-8 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
		}
		source: "image://scaled/apps/smokeDetector/drawables/smokedetector_illustration.svg"
	}

	StandardButton {
		id: startButton
		anchors {
			top: bodyText.bottom
			topMargin: designElements.vMargin20
			left: titleLabel.left
		}
		minWidth: Math.round(100 * horizontalScaling)
		primary: true
		text: qsTr("Link")

		onClicked: {
			stage.openFullscreen(app.addSmokeDetectorScreenUrl);
		}
	}
}
