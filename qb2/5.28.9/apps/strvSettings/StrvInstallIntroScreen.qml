import QtQuick 2.0

import qb.components 1.0

Screen {
	id: strvInstallIntroScreen
	screenTitle: qsTranslate("AddStrvWizardScreen", "Install smart radiator valves")

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: Math.round(35 * horizontalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.primaryImportantBodyText
		}
		text: qsTr("Getting started")
	}

	Text {
		id: contentText
		text: qsTr("add-intro-content")

		wrapMode: Text.WordWrap

		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText

		anchors {
			top: title.bottom
			topMargin: designElements.vMargin20
			left: title.left
			right: illustration.left
			rightMargin: Math.round(40 * horizontalScaling)
		}
	}

	StandardButton {
		id: startButton
		anchors {
			top: contentText.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: title.left
		}
		minWidth: Math.round(100 * horizontalScaling)
		primary: true
		text: qsTr("Start")

		onClicked: stage.openFullscreen(app.addStrvWizardScreenUrl)
	}

	Image {
		id: illustration
		anchors {
			right: parent.right
			bottom: parent.bottom
			bottomMargin: - designElements.bottomBarHeight
		}
		source: "image://scaled/apps/strvSettings/drawables/add-intro.svg"
	}
}
