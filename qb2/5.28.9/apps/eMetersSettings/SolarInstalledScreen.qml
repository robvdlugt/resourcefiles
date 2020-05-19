import QtQuick 2.1
import qb.components 1.0

Screen {
	screenTitle: qsTr("Installed Solar")

	hasHomeButton: false
	hasBackButton: false
	inNavigationStack: false

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;

		// Reset the values used by the solar wizard
		app.solarWizardUuid                = "";
		app.solarWizardDivider             = -1;
		app.solarWizardDividerType         = -1;
		app.solarWizardEstimatedGeneration = -1;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	Text {
		id: titleText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(124 * horizontalScaling)
		}
		text: qsTr("Congratulations, Toon Solar is installed!")
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
	}

	Text {
		id: explanationText
		anchors {
			baseline: titleText.baseline
			baselineOffset: Math.round(35 * verticalScaling)
			left: titleText.left
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTr("solar_installed_explanation")
	}

	StandardButton {
		id: continueButton
		anchors {
			top: explanationText.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: titleText.left
		}
		text: qsTr("Continue")
		onClicked: stage.openFullscreen(app.selectSolarEMeterScreenUrl);
	}

	Image {
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(60 * verticalScaling)
			right: parent.right
			rightMargin: anchors.bottomMargin
		}
		source: "image://scaled/apps/eMetersSettings/drawables/bigsunpanels.svg"
	}
}


