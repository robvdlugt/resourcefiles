import QtQuick 2.1
import QtQuick.Layouts 1.3

import BasicUIControls 1.0
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: eMeterIndicationScreen

	property EMetersSettingsApp app

	screenTitleIconUrl: ""
	screenTitle: qsTr("Indication and Values")
	hasCancelButton: true

	QtObject {
		id: p

		property int savedDividerType : -1
		property string savedDivider : ""
		property bool isSolarWizard: false
		property variant resourceUnits
		property string deviceUuid: ""
		property string resource
		property int meterType
		property bool editing: false
		property bool unitBefore: false
		property string unitName

		property bool argsSaved
	}

	function calculateDivider(unitIdx, value)
	{
		var divider = 0.0;
		if (p.resourceUnits.units[unitIdx].divisor) {
			divider = p.resourceUnits.units[unitIdx].divisor / value;
		} else if (p.resourceUnits.units[unitIdx].multi) {
			divider = value * p.resourceUnits.units[unitIdx].multi;
		} else {
			divider = value;
		}
		return divider;
	}

	function inputSave(text) {
		var validation = validateInput(text);
		if (validation === null) {
			p.savedDividerType = p.resourceUnits.units[radioGroup.currentControlId].id;
			p.savedDivider = text;
			enableCustomTopRightButton();
		} else if (typeof validation === "object") {
			qdialog.showDialog(qdialog.SizeSmall, qsTr("Error"), validation.content);
			qdialog.setClosePopupCallback(function() { valueLabel.setFocus(true) });
			disableCustomTopRightButton();
		}
	}

	function validateInput(text) {
		// replace locale decimal separator by dot in order to parse as float
		var newDividerFloat = parseFloat(text.replace(i18n.decimalSeparator(),"."));
		var selectedUnit = p.resourceUnits.units[radioGroup.currentControlId];
		if (newDividerFloat) {
			var newDivider = calculateDivider(radioGroup.currentControlId, newDividerFloat);
			var largerErrorMsg = qsTranslate("EMeterFrame", "Please enter a value larger than %1");
			var smallerErrorMsg = qsTranslate("EMeterFrame", "Please enter a value smaller than %1");
			// Check the divider range
			if (isNaN(newDivider) || newDivider < p.resourceUnits.min) {
				return {content: (selectedUnit.divisor ? smallerErrorMsg : largerErrorMsg).arg(app.getDividerString(p.resource, selectedUnit.id, p.resourceUnits.min))};
			} else if (newDivider > p.resourceUnits.max) {
				return {content: (selectedUnit.divisor ? largerErrorMsg : smallerErrorMsg).arg(app.getDividerString(p.resource, selectedUnit.id, p.resourceUnits.max))};
			}
		} else {
			return {content: qsTr("Incorrect value")};
		}
		return null;
	}

	function generateUnitsString(unitName) {
		if(this.text !== "")
			this.text += "\n\n";
		if(typeof unitName === "object" && unitName.unitBefore)
			this.text += unitName.name + " ... ";
		else
			this.text += " ... " + unitName;
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Save"));
		if (args) {
			p.isSolarWizard = (args.from !== undefined ? (args.from === "solarwizard") : false);
			p.resource  = (args.resource !== undefined ? args.resource: "elec");
			p.meterType  = (args.meterType !== undefined  ? args.meterType : 0);
			p.deviceUuid = (args.uuid !== undefined ? args.uuid : "");
			p.editing = (args.editing !== undefined ? args.editing : false);
			p.argsSaved = true;

			p.resourceUnits = Constants.cValueUnits[p.resource][p.meterType];
			if (!p.resourceUnits)
				console.log("No units found for given resource and meter type!");

			disableCustomTopRightButton();
			if (p.editing) {
				if (p.isSolarWizard) {
					p.savedDividerType = app.solarWizardDividerType;
					p.savedDivider = app.getDividerString(p.resource, p.savedDividerType, app.solarWizardDivider);
				} else {
					var usageDevice = app.getUsageDeviceByUuid(p.deviceUuid);
					var usage = app.getUsageByTypeFromDevice(usageDevice, p.resource);
					if (usage) {
						p.savedDividerType = usage.dividerType;
						p.savedDivider = app.getDividerString(p.resource, p.savedDividerType, usage.divider);
					}
				}
				p.resourceUnits.units.some(function(unit, index) {
					if(p.savedDividerType === unit.id) {
						radioGroup.currentControlId = index;
						return true;
					}
				});
				if (p.savedDivider) {
					valueLabel.inputText = p.savedDivider;
				}
			}
		}

		var textObj = {'text': ""};
		// for now only support two sets
		for(var i=0; i < 2; i++) {
			var radioButtonObj = i === 1 ? radioButton2 : radioButton1;
			if(p.resourceUnits.units[i]["unitNames"].length > 1) {
				textObj.text = qsTr("One of the following:");
				radioButtonObj.height = Math.round(40 * verticalScaling);
			} else {
				textObj.text = "";
				radioButtonObj.height = 0;
			}
			p.resourceUnits.units[i]["unitNames"].forEach(generateUnitsString, textObj);
			radioButtonObj.text = textObj.text;
			radioButtonObj.height += p.resourceUnits.units[i]["unitNames"].length * Math.round(40 * verticalScaling);
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCustomButtonClicked: {
		var newDividerType = p.resourceUnits.units[radioGroup.currentControlId].id;
		// replace locale decimal separator by dot in order to parse as float
		var newDividerFloat = parseFloat(valueLabel.inputText.replace(i18n.decimalSeparator(),"."));
		var newDivider = calculateDivider(radioGroup.currentControlId, newDividerFloat);

		var configObj = {
			"type": p.resource,
			"divider": newDivider,
			"dividerType": newDividerType
		};

		if (p.isSolarWizard) {
			app.solarWizardDivider = newDivider;
			app.solarWizardDividerType = newDividerType;
			if (!p.editing) {
				stage.openFullscreenInner(app.estimatedGenerationScreenUrl, {from: "solarwizard"}, false);
			} else {
				hide();
			}
		} else {
			app.setMeterConfiguration(p.deviceUuid, p.resource, undefined, newDivider, newDividerType);
			hide();
		}
	}

	Row {
		id: contentRow
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
		}

		spacing: Math.round(30 * horizontalScaling)

		Item {
			id: indicationItem
			width: Math.round(300 * verticalScaling)
			height: childrenRect.height

			Text {
				id: indicationLabel
				anchors {
					left: parent.left
					right: parent.right
				}
				color: colors.tempCorrSystemTitle
				font.pixelSize: qfont.navigationTitle
				font.family: qfont.semiBold.name
				text: qsTr("Indication:")
			}

			Item {
				id: radioButtonList
				anchors {
					left: parent.left
					leftMargin: - (radioButton1.spacing + (radioButton1.dotRadius * 2))
					right: parent.right
					top: indicationLabel.bottom
					topMargin: Math.round(12 * verticalScaling)
				}

				ControlGroup {
					id: radioGroup
					exclusive: true

					onCurrentControlIdChanged: {
						(currentControlId >= 0) ? enableCustomTopRightButton() : disableCustomTopRightButton();

						var newDividerType = p.resourceUnits.units[radioGroup.currentControlId].id;

						if(p.savedDividerType !== newDividerType) {
							var newDivider = p.resourceUnits.units[radioGroup.currentControlId].defVal;
							valueLabel.inputText = app.getDividerString(p.resource, newDividerType, newDivider);
						} else {
							valueLabel.inputText = p.savedDivider;
						}

						var selectedUnit = p.resourceUnits.units[radioGroup.currentControlId].unitNames[0];
						if (typeof selectedUnit === "object") {
							p.unitBefore = selectedUnit.unitBefore;
							p.unitName = selectedUnit.name;
						} else {
							p.unitBefore = false;
							p.unitName = selectedUnit;
						}
					}
				}

				StandardRadioButton {
					id: radioButton1
					width: parent.width
					controlGroupId: 0
					controlGroup: radioGroup
					property string kpiPostfix: "radioButton1"
					text: ""
				}

				StandardRadioButton {
					id: radioButton2
					anchors {
						left: radioButton1.left
						top: radioButton1.bottom
						topMargin: Math.round(8 * verticalScaling)
					}
					width: parent.width
					controlGroupId: 1
					controlGroup: radioGroup
					property string kpiPostfix: "radioButton2"
					text: ""
				}
			}
		}

		Item {
			id: valueItem
			width: Math.round(250 * verticalScaling)
			height: childrenRect.height

			Text {
				id: valueTitle
				color: colors.tempCorrSystemTitle
				font.pixelSize: qfont.navigationTitle
				font.family: qfont.semiBold.name
				text: qsTr("Value:")
			}

			RowLayout {
				anchors {
					top: valueTitle.bottom
					topMargin: Math.round(12 * verticalScaling)
					left: parent.left
				}
				width: parent.width
				layoutDirection: p.unitBefore ? Qt.LeftToRight : Qt.RightToLeft
				spacing: designElements.hMargin10

				Text {
					id: unitText
					Layout.fillWidth: true
					font {
						pixelSize: qfont.bodyText
						family: qfont.regular.name
					}
					color: colors._harry
					text: p.unitName
				}

				EditTextLabel {
					id: valueLabel
					Layout.preferredWidth: Math.round(200 * horizontalScaling)
					inputHints: Qt.ImhDigitsOnly

					onInputAccepted: inputSave(inputText)
					onInputEdited: disableCustomTopRightButton()
				}
			}
		}
	}
}
