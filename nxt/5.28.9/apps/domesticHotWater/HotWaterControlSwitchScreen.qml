import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: hotWaterControlSwitchScreen

	screenTitle: qsTr("Hot Water Controls")
	isSaveCancelDialog: true

	property DomesticHotWaterApp app

	anchors.fill: parent

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (globals.thermostatFeatures["FF_Dhw_UiElements"]) {
			radioButtonShow.toggleSelected();
		} else {
			radioButtonHide.toggleSelected();
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		app.toggleShowHotWaterControls(radioButtonShow.selected);
		if (! radioButtonShow.selected) {
			// Disable the schedule as per warning
			app.patchDHWSchedule({active:false});
		}
	}

	Text {
		id: explanationText
		text: qsTr("hot-water-controls-explanation")
		wrapMode: Text.WordWrap

		width: Math.round(500 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
		}

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.dhwText
	}

	Text {
		id: hotWaterTitle
		text: qsTr("Hot water controls")
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: explanationText.bottom
			topMargin: Math.round(10 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.dhwTitleText
	}

	ControlGroup {
		id: radioGroup
		exclusive: true
	}

	Column {
		id: radioButtonList

		width: parent.width / 4 // some 'sane' default
		spacing: designElements.vMargin6

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: hotWaterTitle.bottom
			topMargin: Math.round(10 * verticalScaling)
		}

		Component.onCompleted: {
			radioButtonList.updateWidth()
		}

		function updateWidth() {
			width = Math.max(radioButtonShow.implicitWidth, radioButtonHide.implicitWidth);
		}

		StandardRadioButton {
			id: radioButtonShow
			width: parent.width
			controlGroup: radioGroup
			text: qsTr("Show")
		}

		StandardRadioButton {
			id: radioButtonHide
			width: parent.width
			controlGroup: radioGroup
			text: qsTr("Hide")
		}
	}

	WarningBox {
		id: warningBox

		anchors {
			top: radioButtonList.bottom
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(67 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(67 * horizontalScaling)
		}

		textPixelSize: qfont.bodyText
		warningText: qsTr("hot-water-controls-warning")
	}
}
