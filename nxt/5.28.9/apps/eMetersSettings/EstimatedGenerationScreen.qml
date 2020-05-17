import QtQuick 2.1
import qb.components 1.0

Screen {
	id: estimatedGenerationScreen
	screenTitle: qsTr("Estimated generation")

	property EMetersSettingsApp app
	property bool inWizard: false

	isSaveCancelDialog: true
	hasBackButton: false
	saveEnabled: estimationLabel.acceptableInput
	synchronousSave: true

	QtObject {
		id: p

		property int estimation: 0
		property bool isSolarWizard: false
		property bool editing: false
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args) {
			inWizard = args.from === "wizard" ? true : false;
			p.isSolarWizard = (args.from === "solarwizard" ? true : false);
			p.editing = (args.editing !== undefined ? args.editing : false);

			if (p.editing)
				p.estimation = p.isSolarWizard ? app.solarWizardEstimatedGeneration : app.estimatedGeneration;
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		p.estimation = parseInt(estimationLabel.inputText, 10);
		if (inWizard && feature.appWhatIsNewEnabled()) {
			app.setStandardYearTargets(p.estimation);
			globals.startWhatIsNew();
		} else if (p.isSolarWizard) {
			app.solarWizardEstimatedGeneration = p.estimation;
			if (!p.editing) {
				stage.openFullscreenInner(app.solarOverviewScreenUrl, {from: "solarwizard"}, false);
			} else {
				hide();
			}
		} else {
			app.setStandardYearTargets(p.estimation);
			hide();
		}
	}

	Text {
		id: bodyText
		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(125 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		wrapMode: Text.WordWrap
		text: inWizard ? qsTr("estimated_generation_text1", "wizard") : qsTr("estimated_generation_text1", "notWizard");
	}

	EditTextLabel {
		id: estimationLabel
		anchors {
			left: bodyText.left
			right: unitText.left
			rightMargin: designElements.hMargin10
			top: bodyText.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		labelText: qsTr("Estimated generation")
		leftTextAvailableWidth: width * 0.5
		inputAlignment: Text.AlignRight
		prefilledText: p.estimation
		inputHints: Qt.ImhDigitsOnly
		validator: IntValidator { bottom: 0; top: 999999 }

		onInputFocusChanged: {
			if (inputFocus && inputText === "0")
				inputText = "";
		}
	}

	Text {
		id: unitText
		anchors {
			right: bodyText.right
			verticalCenter: estimationLabel.verticalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTranslate("EMeterFrame", "kWh per year")
	}

	Text {
		id: wizardText
		anchors {
			top: estimationLabel.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: bodyText.left
			right: bodyText.right
		}
		visible: inWizard
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		wrapMode: Text.WordWrap
		text: qsTr("estimated_generation_text2")
	}
}
