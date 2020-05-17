import QtQuick 2.1

import qb.components 1.0

Screen {
	id: restartScreen

	screenTitle: qsTr("Toon restart")
	anchors.fill: parent
	hasCancelButton: true

	onCustomButtonClicked: {
		app.restartToon();
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Restart"));
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: image.left
			rightMargin: designElements.hMargin20
		}
		font {
			pixelSize: qfont.largeTitle
			family: qfont.semiBold.name
		}
		color: colors.text
		text: qsTr("restart_title")
		wrapMode: Text.WordWrap

	}

	Text {
		id: bodyText
		anchors {
			top: titleText.bottom
			topMargin: designElements.vMargin20
			left: titleText.left
			right: titleText.right
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.text
		text: qsTr("restart_content")
		wrapMode: Text.WordWrap
	}

	Image {
		id: image
		anchors {
			right: parent.right
			bottom: parent.bottom
			bottomMargin: - designElements.bottomBarHeight
		}
		source: "image://scaled/apps/systemSettings/drawables/reboot.svg"
	}
}
