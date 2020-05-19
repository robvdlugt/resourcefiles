import QtQuick 2.11
import QtQuick.Layouts 1.3
import BasicUIControls 1.0;
import BxtClient 1.0

import qb.components 1.0

Screen {
	id: districtHeatingTypeSelectScreen

	property ThermostatSettingsApp app

	screenTitleIconUrl: ""
	screenTitle: qsTr("District Heating type")
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
			if (instTypes.itemAt(i).smartHeat === (app.doSetupSmartHeat || app.hasSmartHeat)) {
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
		var smartHeat = instTypes.itemAt(index).smartHeat;
		console.log("Setting smart heat setup to: ", smartHeat ? "enabled" : "disabled");

		app.doSetupSmartHeat = smartHeat;
		if (!smartHeat)
			wizardstate.setStageCompleted("boiler", true);
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
			leftMargin: Math.round(72 * horizontalScaling)
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
				property string kpiId: "SmartHeatingTypeSelectScreen.radioButton" + index
				property bool smartHeat: model.smartHeat
			}
		}
	}

	ListModel {
		id: instTypeModel

		// fill model with data when it's ready
		Component.onCompleted: {
			append({smartHeat: false, leftText: qsTranslate("HeatingFrame", "District Heat")});
			append({smartHeat: true,  leftText: qsTranslate("HeatingFrame", "Smart District Heat")});
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
		anchors {
			top: radioButtonList.top
			left: radioButtonList.right
			leftMargin: Math.round(24 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(72 * horizontalScaling)
		}
		height: warningColumn.height + (warningColumn.anchors.margins * 2)

		GridLayout {
			id: warningColumn
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				margins: designElements.vMargin20
			}
			rowSpacing: designElements.vMargin10
			columnSpacing: designElements.hMargin20
			columns: 2

			Image {
				id: imgWarning
				Layout.alignment: Qt.AlignTop
				source: "image://scaled/images/warning.svg"
			}

			Text {
				id: txtWarning
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignTop
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				text: qsTr("district-heat-type-warning")
				wrapMode: Text.WordWrap
			}

			Rectangle {
				id: checkboxRect
				color: colors._winnie
				Layout.fillWidth: true
				Layout.columnSpan: 2
				Layout.preferredHeight: height
				height: checkboxRow.height + (checkboxRow.anchors.margins * 2)
				radius: designElements.radius

				RowLayout {
					id: checkboxRow
					anchors {
						top: parent.top
						left: parent.left
						right: parent.right
						margins: designElements.vMargin10
					}
					spacing: designElements.hMargin10

					StandardCheckBox {
						id: imSureCheckbox
						// Only show the checkbox, not the text field beside it. We're doing that manually, so we
						// can support automatic wordwrapping and multiline text.
						width: Math.round(27 * horizontalScaling)
						Layout.preferredWidth: width
						Layout.alignment: Qt.AlignTop
						text: ""
						squareBackgroundColor: colors._bg
						onSelectedChanged: p.checkSaveButton()
					}

					Text {
						id: txtCheckbox
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignTop
						Layout.topMargin: Math.round(3 * verticalScaling)
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.metaText
						}
						wrapMode: Text.WordWrap
						text: qsTr("district-heat-type-confirmation")

						MouseArea {
							anchors.fill: parent
							onClicked: imSureCheckbox.toggleSelected()
						}
					}
				}
			}
		}
	}
}
