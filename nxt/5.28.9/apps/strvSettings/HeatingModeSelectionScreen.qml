import QtQuick 2.1
import BasicUIControls 1.0;

import qb.components 1.0

Screen {
	id: heatingModeSelectionScreen

	property StrvSettingsApp app

	screenTitleIconUrl: ""
	screenTitle: qsTr("Heating control")
	isSaveCancelDialog: true
	inNavigationStack: false

	// heating modes
	readonly property int _HM_BOILER: 1
	readonly property int _HM_STRV: 2
	readonly property int _HM_NO_HEATING: 3

	QtObject {
		id: p

		function checkSaveButton() {
			if (radioButtonGroup.currentControlId !== -1 && understandCheckbox.selected) {
				enableSaveButton();
			} else {
				disableSaveButton();
			}
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		// Save button is disabled initially. When the currently selected
		// radio button is changed and the checkbox is checked, the save
		// button is enabled.
		disableSaveButton();

		if (wizardstate.stageCompleted("heating")) {
			for (var i = 0; i < instTypeModel.count; ++i) {
				if (instTypeModel.get(i).heatingMode === globals.heatingMode) {
					radioButtonGroup.currentControlId = i;
					break;
				}
			}
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		var index = radioButtonGroup.currentControlId;
		var heatingMode = instTypeModel.get(index).heatingMode;

		wizardstate.setStageCompleted("heating", true);

		if (heatingMode === "central") {
			// If we had zoneControl before, disable it
			app.setUserFeature("noHeating", false);
			app.setUserFeature("zoneControl", false);
			globals.heatingMode = "central";
		} else if (heatingMode === "zone") {
			// If we didn't have zoneControl yet, enable it
			app.setUserFeature("noHeating", false);
			app.setUserFeature("zoneControl", true);
			globals.heatingMode = "zone";
		} else if (heatingMode === "none") {
			app.setUserFeature("noHeating", true);
			app.setUserFeature("zoneControl", false);
			globals.heatingMode = "none";
		}
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true

		onCurrentControlIdChanged: p.checkSaveButton()
	}

	Text {
		id: title

		anchors {
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(60 * horizontalScaling)
		}

		text: qsTr("What is the setup?")
		wrapMode: Text.WordWrap
		color: colors.rbTitle
		font.pixelSize: qfont.titleText
		font.family: qfont.semiBold.name
	}

	Item {
		id: alignItem

		anchors {
			top: title.bottom
			topMargin: designElements.vMargin15
			bottom: checkboxTextBackground.top
			bottomMargin: designElements.vMargin15
			left: parent.left
			right: parent.right
			leftMargin: Math.round(175 * horizontalScaling)
			rightMargin: Math.round(175 * horizontalScaling)
		}

		Column {
			id: radioButtonList

			anchors {
				left: parent.left
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			spacing: designElements.vMargin6

			Repeater {
				id: instTypes

				model: instTypeModel
				delegate: DescriptiveRadioButton {
					id: curRadioButton
					width: radioButtonList.width

					controlGroup: radioButtonGroup
					caption: model.caption
					description: ""
					iconSource: model.iconSource
					enabled: true
					property string kpiId: "HeatingModeSelectionScreen.radioButton" + index
				}
			}
		}
	}

	ListModel {
		id: instTypeModel

		// fill model with data when it's ready
		// When changing the order of elements, be sure to update the onSaved function as well.
		Component.onCompleted: {
			append({caption: qsTr("Central heating"), iconSource: "drawables/boiler.svg", heatingMode: "central"});
			if (feature.appStrvFeatureEnabled() && isNxt)
				append({caption: qsTr("Smart radiator valves"), iconSource: "drawables/strv.svg", heatingMode: "zone"});
			if (feature.enabledHeatingModeNoHeating())
				append({caption: qsTr("No heating via Toon"), iconSource: "drawables/no-heating.svg", heatingMode: "none"});
		}
	}

	StandardCheckBox {
		id: understandCheckbox
		// Only show the checkbox, not the text field beside it. We're doing that manually, so we
		// can support automatic wordwrapping and multiline text.
		width: Math.round(27 * horizontalScaling)
		anchors {
			top: checkboxTextBackground.top
			topMargin: Math.round(5 * verticalScaling)
			left: title.left
		}

		property string kpiPostfix: "understandCheckbox"

		// Need to keep this empty text here to prevent a QML warning message
		text: ""
		selected: false

		onSelectedChanged: p.checkSaveButton()
	}

	Rectangle {
		id: checkboxTextBackground
		color: colors.labelBackground

		property string kpiPostfix: understandCheckbox.kpiPostfix

		anchors {
			left: understandCheckbox.right
			leftMargin: Math.round(7 * horizontalScaling)
			right: title.right
			bottom: parent.bottom
			bottomMargin: Math.round(30 * verticalScaling)
		}
		height: checkboxText.height + checkboxText.anchors.topMargin + checkboxText.anchors.bottomMargin
		radius: designElements.radius

		MouseArea {
			anchors.fill: parent
			onClicked: understandCheckbox.toggleSelected()
		}

		Text {
			id: checkboxText
			anchors {
				top: parent.top
				topMargin: Math.round(10 * verticalScaling)
				bottomMargin: anchors.topMargin
				left: parent.left
				leftMargin: Math.round(9 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			text: qsTr("I am aware a factory reset is required to change this setting.")
			textFormat: Text.PlainText
			wrapMode: Text.WordWrap

			color: colors.cbText
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
		}
	}
}
