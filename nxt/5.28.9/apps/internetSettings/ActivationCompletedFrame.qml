import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	id: activationCompletedFrame
	// Page index: 5

	title: qsTr("title-activation-completed")

	nextPage: -1
	previousPage: -1

	function initWizardFrame(data) {
		outcomeData = data

		wizard.selector.visible = true
		wizard.parent.disableCancelButton()
	}

	Component.onDestruction: {
		if (isNormalMode) {
			// If we're in normal mode, once we've completed the activation procedure, restart the system so that it
			// can load the appropriate features/apps.
			qtUtils.reboot();
		}
	}

	Text {
		id: titleText
		text: qsTr("title-activation-completed")
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
		color: colors.titleText

		anchors {
			top: parent.top
			topMargin: parent.height / 4
			left: explanationText.left
		}
	}

	Image {
		id: statusIcon
		source: "qrc:/images/good.svg"
		anchors {
			verticalCenter: titleText.verticalCenter
			right: titleText.left
			rightMargin: designElements.hMargin10
		}
		height: Math.round(24 * verticalScaling)
		sourceSize {
			width: 0
			height: height
		}
	}

	Text {
		id: explanationText
		text: isNormalMode ? qsTr("activation-completed-message") : qsTr("activation-completed-no-reboot-message")
		textFormat: Text.RichText
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		color: colors.text

		clip: true

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: titleText.bottom
			topMargin: designElements.vMargin20
			bottom: parent.bottom
			bottomMargin: designElements.vMargin20
		}
	}
}
