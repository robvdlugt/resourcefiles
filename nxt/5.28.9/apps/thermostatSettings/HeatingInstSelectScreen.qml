import QtQuick 2.1
import BasicUIControls 1.0;

import qb.components 1.0

Screen {
	id: heatingInstTypeSelectScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Heating installation")
	isSaveCancelDialog: true

	QtObject {
		id: p
		property bool amEditing: false
		// This array contains mapping of bxt values (value in array) to item order in list (array index)
		property variant mapping: [3, 0]
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;

		if (!p.amEditing)
			setHeatInstInfo(app.heatingInstInfo);
		else
			setManualSettings(app.tempManualHeatingMaxTemp, app.tempManualHeatingHeatRate);

		p.amEditing = true;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		// Save values to app settings
		var index = radioButtonGroup.currentControlId;
		var type = p.mapping[index];
		var inst = instTypeModel.get(index);
		var maxTemp = inst.temp;
		var heatRate = inst.rate;

		app.setHeatInstInfo(type, maxTemp, heatRate);

		p.amEditing = false;

		wizardstate.setStageCompleted("boiler", true);
	}

	onCanceled: p.amEditing = false

	function setHeatInstInfo(heatingInstInfo) {
		var type = parseInt(heatingInstInfo.type);
		radioButtonGroup.currentControlId = (type === 3 ? 0 : 1);

		var maxTemp = parseFloat(heatingInstInfo.maxTemp);
		var heatRate = parseFloat(heatingInstInfo.heatRate);

		if (type === 3 || isNaN(type) || isNaN(maxTemp) || isNaN(heatRate)) {
			maxTemp = 80.0;
			heatRate = 3.0;
		}

		setManualSettings(maxTemp, heatRate);
	}

	function setManualSettings(maxTemp, heatRate) {
		instTypeModel.set(1, { temp: maxTemp, rate: heatRate });
	}

	Text {
		id: title

		anchors {
			left: radioButtonList.left
			bottom: radioButtonList.top
			bottomMargin: designElements.vMargin10
		}

		text: qsTr("Type")
		color: colors.rbTitle
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true
	}

	Column {
		id: radioButtonList
		width: childrenRect.width
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(115 * verticalScaling)
		}
		spacing: Math.round(6 * horizontalScaling)

		Repeater {
			id: instTypes
			property int maxWidth: 0
			onItemAdded: {
				maxWidth = Math.max(maxWidth, item.implicitWidth + item.rightTextWidth + designElements.hMargin20);
			}
			model: instTypeModel
			delegate: StandardRadioButton {
				width: instTypes.maxWidth

				controlGroupId: index
				controlGroup: radioButtonGroup
				text: model.leftText
				property alias rightTextWidth: rightText.paintedWidth

				Text {
					id: rightText
					text: qsTr("(%1°, max. %2° /hour)").arg(i18n.number(model.temp, 0)).arg(i18n.number(model.rate, 0))

					anchors {
						verticalCenter: parent.verticalCenter
						right: parent.right
						rightMargin: Math.round(8 * horizontalScaling)
					}

					color: model.enabled ? colors.rbText : colors.rbTextDisabled
					font {
						family: qfont.italic.name
						pixelSize: qfont.bodyText
					}
					property string kpiId: "HeatingInstSelectScreen." + text
				}
				enabled: model.enabled
			}
		}
	}


	ListModel {
		id: instTypeModel

		// fill model with data when it's ready
		Component.onCompleted: {
			append({ leftText: qsTr("Default"), temp: 90.0, rate: 3.0, enabled: true});
			append({ leftText: qsTr("Manual"), temp: 0.0, rate: 0.0, enabled: true});
		}
	}

	IconButton {
		id: manualSettingsButton

		width: designElements.buttonSize
		iconSource: "qrc:/images/edit.svg"

		anchors {
			bottom: radioButtonList.bottom
			left: radioButtonList.right
			leftMargin: designElements.hMargin6
		}

		onClicked: {
			radioButtonGroup.setControlSelectState(1, true);
			stage.openFullscreen(app.heatingInstManualSettingsScrUrl, {manualMaxTemp:instTypeModel.get(1).temp, manualHeatRate:instTypeModel.get(1).rate});
		}
	}
}

