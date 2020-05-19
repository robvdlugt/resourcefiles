import QtQuick 2.1
import BasicUIControls 1.0;

import qb.components 1.0

Screen {
	id: heatingTypeSelectScreen

	property ThermostatSettingsApp app

	screenTitleIconUrl: ""
	screenTitle: qsTr("Heating type")
	isSaveCancelDialog: true
	inNavigationStack: false

	QtObject {
		id: p

		function checkSaveButton() {
			if (imSureCheckbox.selected && (radioButtonGroup.currentControlId !== -1)) {
				enableSaveButton();
			} else {
				disableSaveButton();
			}
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		// Save button is disabled initially. When the currently selected
		// radio button is changed, the save button is enabled.
		disableSaveButton();

		// Populate the current setting
		for (var i = 0; i < instTypes.count; ++i) {
			if (instTypes.itemAt(i).heatingType === app.heatingSourceType) {
				radioButtonGroup.currentControlId = i;
			}
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		// Save values to app settings
		var index = radioButtonGroup.currentControlId;
		var type = instTypes.itemAt(index).heatingType;
		console.log("Setting fuel type to:", type)

		app.setHeatingSourceType(type);
		// We don't need to read the value back here, that will be done
		// from the 'onShow' of the HeatingFrame.
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true

		onCurrentControlIdChanged: p.checkSaveButton()
	}

	Column {
		id: radioButtonList

		width: Math.round(290 * horizontalScaling)

		anchors {
			top: parent.top
			topMargin: Math.round(74 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(50 * horizontalScaling)
		}

		spacing: designElements.vMargin6

		function updateWidth() {
			var maxWidth = Math.round(290 * horizontalScaling);
			for(var i = 0; i < instTypeModel.count; i++) {
				var itemWidth = instTypes.itemAt(i).implicitWidth;
				if (itemWidth >= maxWidth) {
					maxWidth = itemWidth;
				}
			}
			width = maxWidth;
		}

		Repeater {
			id: instTypes

			Component.onCompleted: {
				radioButtonList.updateWidth()
			}

			model: instTypeModel
			delegate: StandardRadioButton {
				id: curRadioButton
				width: radioButtonList.width
				controlGroupId: index
				controlGroup: radioButtonGroup
				text: model.leftText
				property string kpiId: "HeatingFuelSelectScreen.radioButton" + index
				property string heatingType: model.heatingType
			}
		}
	}

	ListModel {
		id: instTypeModel

		// fill model with data when it's ready
		Component.onCompleted: {
			append({heatingType: app._HEATINGTYPE_GAS,        leftText: qsTr("heatingType-gas")});
			append({heatingType: app._HEATINGTYPE_OIL,        leftText: qsTr("heatingType-oil")});
			append({heatingType: app._HEATINGTYPE_ELECTRIC,   leftText: qsTr("heatingType-elec")});
			append({heatingType: app._HEATINGTYPE_HEATPUMP,   leftText: qsTr("heatingType-elecHeatPump")});
			append({heatingType: app._HEATINGTYPE_COLLECTIVE, leftText: qsTr("heatingType-collective")});
		}
	}

	Rectangle {
		id: warningBox
		radius: designElements.radius
		color: colors.warningBackground
		border {
			width: Math.round(2 * horizontalScaling)
			color: colors.warningBorder
		}
		implicitHeight: txtWarning.implicitHeight + (designElements.vMargin15 * 3) + checkboxRect.implicitHeight

		anchors {
			top: radioButtonList.top
			left: radioButtonList.right
			leftMargin: Math.round(24 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(50 * horizontalScaling)
		}

		Image {
			id: imgWarning
			source: "image://scaled/images/warning.svg"
			anchors {
				left: parent.left
				leftMargin: designElements.margin22
				top: txtWarning.top
			}
		}

		Text {
			id: txtWarning
			text: qsTr("Heating Type Warning")
			wrapMode: Text.WordWrap
			anchors {
				left: imgWarning.right
				leftMargin: designElements.margin20
				right: parent.right
				rightMargin: designElements.margin20
				top: parent.top
				topMargin: designElements.vMargin15
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
			}
		}

		Rectangle {
			id: checkboxRect
			color: colors._winnie
			implicitHeight: txtCheckbox.implicitHeight + (designElements.vMargin15 * 2)
			radius: designElements.radius

			anchors {
				top: txtWarning.bottom
				topMargin: designElements.vMargin15
				left: parent.left
				leftMargin: designElements.hMargin20
				right: parent.right
				rightMargin: designElements.hMargin20
			}

			StandardCheckBox {
				id: imSureCheckbox
				// Only show the checkbox, not the text field beside it. We're doing that manually, so we
				// can support automatic wordwrapping and multiline text.
				width: Math.round(27 * horizontalScaling)
				text: ""
				squareBackgroundColor: colors._bg
				anchors {
					top: txtCheckbox.top
					left: parent.left
					leftMargin: designElements.hMargin10
				}
				onSelectedChanged: p.checkSaveButton()
			}

			Text {
				id: txtCheckbox
				wrapMode: Text.WordWrap
				text: qsTr('confirmation_text')

				anchors {
					top: parent.top
					topMargin: designElements.vMargin15
					left: imSureCheckbox.right
					leftMargin: designElements.hMargin20
					right: parent.right
					rightMargin: designElements.hMargin20
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
			}

			MouseArea {
				anchors.fill: parent
				onClicked: imSureCheckbox.toggleSelected()
			}
		}
	}
}
