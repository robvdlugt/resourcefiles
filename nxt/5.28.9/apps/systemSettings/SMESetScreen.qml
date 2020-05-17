import QtQuick 2.1

import qb.components 1.0

Screen {
	id: smeSetScreen

	screenTitle: qsTr("Environment")
	isSaveCancelDialog: true
	anchors.fill: parent

	QtObject {
		id: p
		property bool wasSaved: false
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		radioButtonList.currentIndex = app.enableSME ? 1 : 0
		p.wasSaved = false;
	}

	onHidden: {
		// this property is used to indicate that the user clicked on Save
		// so we don't mess with the screenStateController here, as this
		// signal handler will be called only AFTER the popup displayed by the onSaved
		// handler, which will already set the screenStateController property accordingly
		if (!p.wasSaved)
			screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		p.wasSaved = true;
		screenStateController.screenColorDimmedIsReachable = true;
		var enableSMENew = radioButtonList.currentIndex === 1;
		if (app.enableSME !== enableSMENew)
			app.setSMEOption(enableSMENew);
	}

	Text {
		id: bodyText

		wrapMode: Text.WordWrap
		color: colors.foreground
		text: qsTr("sme-title-text")

		font {
			pixelSize: qfont.navigationTitle
			family: qfont.semiBold.name
		}

		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(70 * horizontalScaling)
		}
	}

	RadioButtonList {
		id: radioButtonList
		radioLabelWidth: Math.round(150 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyText.baseline
			topMargin: Math.round(40 * horizontalScaling)
		}

		title: qsTr("Select your environment")

		Component.onCompleted: {
			addItem(qsTr("Home"));
			addItem(qsTr("Business"));
			forceLayout();
		}
	}

	Text {
		id: bottomText

		wrapMode: Text.WordWrap
		color: colors.foreground
		
		lineHeight: 1.5

		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}

		anchors {
			left: parent.left
			right: parent.right
			top: radioButtonList.bottom
			leftMargin: Math.round(70 * horizontalScaling)
			rightMargin: anchors.leftMargin
			topMargin: Math.round(30 * verticalScaling)
		}

		text: qsTr("sme-bottom-text")
	}
}
