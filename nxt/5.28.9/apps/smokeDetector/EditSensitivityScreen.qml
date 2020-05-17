import QtQuick 2.1
import qb.components 1.0

Screen {
	id: editSensitivityScreen
	isSaveCancelDialog: true
	screenTitle: qsTr("Smoke Detector Sensitivity")
	property Item context

	onShown: {
		if (args && args.context) {
			sensitivityChoice.currentIndex = args.context.currentSmokeDetector.sensitivityLevel - 2;
			context = args.context;
		}
	}

	// Fibaro smoke detector (FGSD-002) has three sensitivity levels
	// High sensitivity		1
	// Medium sensitivity	2
	// Low sensitivity		3
	// Here, only Medium and Low are used
	onSaved: {
		var tempSmokeDetector = context.currentSmokeDetector;
		tempSmokeDetector.sensitivityLevel = (sensitivityChoice.currentIndex + 2).toString();
		context.currentSmokeDetector = tempSmokeDetector;
		app.setSDSensitivity(context.currentSmokeDetector.devUuid, sensitivityChoice.currentIndex + 2);
	}

	Text {
		id: topText

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(verticalScaling * 50)
			left: bottomText.left
		}

		text: qsTr("edit-smoke-detector-sensitivity-screen-top-text")
		color: colors.foreground

		font.pixelSize: qfont.titleText
		font.family: qfont.semiBold.name
	}

	Text {
		id: bottomText

		anchors {
			baseline: topText.baseline
			baselineOffset: Math.round(verticalScaling * 25)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(horizontalScaling * 500)
		wrapMode: Text.WordWrap

		text: qsTr("edit-smoke-detector-sensitivity-screen-bottom-text")
		color: colors.smokedetectorBody

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}

	RadioButtonList {
		id: sensitivityChoice
		width: Math.round(horizontalScaling * 200)

		anchors {
			top: bottomText.bottom
			topMargin: Math.round(verticalScaling * 20)
			horizontalCenter: parent.horizontalCenter
		}

		Component.onCompleted: {
			addItem(qsTr("Normal"));
			addItem(qsTr("Low"));
			forceLayout();
		}
	}

	Text {
		id: tipsText

		color: colors.smokedetectorBody
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(verticalScaling * 20)
			left: bottomText.left
		}

		text: qsTr("online-tips-text")

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}
}
