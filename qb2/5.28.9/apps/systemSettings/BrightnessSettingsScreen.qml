import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: brightnessSettingsScreen

	property int idx: 0
	property variant presets: [30,60,90,120,180]

	screenTitle: qsTr("Brightness")
	isSaveCancelDialog: true
	anchors.fill: parent

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		brightSpin.value = screenStateController.backLightValueScreenActive;
		dimSpin.rangeMax = screenStateController.getMaxBackLightValueScreenDimmed();
		dimSpin.value = screenStateController.backLightValueScreenDimmed;
		if (dimSpin.value > dimSpin.rangeMax)
			dimSpin.value = dimSpin.rangeMax;
		autoBrightRadioGroup.currentControlId = (globals.features["displayAutoBrightness"] && screenStateController.autoBrightnessControl ? 0 : 1);
		for (var e in presets) {
			if (presets[e] === screenStateController.timeBeforeDimmingInSec) {
				dimTimeoutRadioList.currentIndex = e;
				break;
			}
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		screenStateController.autoBrightnessControl = (autoBrightRadioGroup.currentControlId === 0);
		screenStateController.backLightValueScreenActive = brightSpin.value;
		screenStateController.timeBeforeDimmingInSec = presets[dimTimeoutRadioList.currentIndex];
		screenStateController.backLightValueScreenDimmed = dimSpin.value;
		screenStateController.notifyChangeOfSettings();
	}

	ControlGroup {
		id: autoBrightRadioGroup
		exclusive: true
	}

	Column {
		id: brightnessRow
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
		}
		spacing: Math.round(30 * verticalScaling)

		Text {
			id: brightnessText
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.rbTitle
			text: qsTr("Screen brightness")
		}

		StandardRadioButton {
			id: autoRadio
			width: Math.round(364 * horizontalScaling)
			text: qsTr("Adjust automatically to surrounding")
			controlGroupId: 0
			controlGroup: autoBrightRadioGroup
			visible: globals.features["displayAutoBrightness"] !== undefined && screenStateController.canAutoBrightness
			property string kpiId: "BrightnessSettings.Automatic"
		}

		Item {
			width: childrenRect.width
			height: childrenRect.height

			StandardRadioButton {
				id: manualRadio
				width: autoRadio.width
				text: qsTr("Manually")
				controlGroupId: 1
				controlGroup: autoBrightRadioGroup
				visible: globals.features["displayAutoBrightness"] !== undefined && screenStateController.canAutoBrightness
				property string kpiId: "BrightnessSettings.Manual"
			}

			Grid {
				anchors {
					top: manualRadio.visible ? manualRadio.bottom : parent.top
					topMargin: manualRadio.visible ? spacing : 0
					left: manualRadio.visible ? manualRadio.left : parent.left
					leftMargin: manualRadio.visible ? manualRadio.dotOffset + (2 * manualRadio.dotRadius) + manualRadio.spacing : 0
				}
				columns: 2
				spacing: designElements.spacing6

				Text {
					id: brightSpinTitle
					font.pixelSize: qfont.bodyText
					font.family: qfont.semiBold.name
					color: colors.rbTitle
					text: qsTr("Active")
				}

				Text {
					id: dimSpinTitle
					font.pixelSize: qfont.bodyText
					font.family: qfont.semiBold.name
					color: colors.rbTitle
					text: qsTr("Dimmed state")
				}

				NumberSpinner {
					id: brightSpin

					rangeMin: 5.0
					rangeMax: 100.0
					increment: 1
					valueSuffix: "%"
					disableButtonAtMaximum: true
					disableButtonAtMinimum: true
					enabled: manualRadio.selected

					property string kpiPrefix: "BrightnessSettingsScreen.brightness."

					function valueToText(value) {
						return value.toFixed(0)+valueSuffix;
					}
				}

				NumberSpinner {
					id: dimSpin

					rangeMin: 5.0
					rangeMax: 100.0
					increment: 1
					valueSuffix: "%"
					disableButtonAtMaximum: true
					disableButtonAtMinimum: true
					enabled: manualRadio.selected

					property string kpiPrefix: "BrightnessSettingsScreen.dim."

					function valueToText(value) {
						return value.toFixed(0)+valueSuffix;
					}
				}
			}
		}
	}

	Rectangle {
		id: dimTimeoutBg
		width: dimTimeoutRadioList.width + Math.round(16 * verticalScaling)
		height: dimTimeoutRadioList.height + Math.round(16 * verticalScaling)
		anchors.centerIn: dimTimeoutRadioList
		color: colors.contrastBackground
		radius: designElements.radius
	}

	RadioButtonList {
		id: dimTimeoutRadioList
		width: Math.round(224 * horizontalScaling)
		anchors {
			top: brightnessRow.top
			right: parent.right
			rightMargin: brightnessRow.anchors.leftMargin
		}
		title: qsTr("To dimmed state after:")
		listDelegate: StandardRadioButton {
			id: radioButton
			width: dimTimeoutRadioList.width
			height: Math.round(48 * verticalScaling)
			controlGroup: model.controlGroup
			fontFamily: qfont.semiBold.name
			smallDotRadius: 0; dotRadius: 0; dotOffset: 0; spacing: 0
			enabled: model.itemEnabled
			property string kpiId: "ActiveModeTimeout." + presets[index] + "secs"
		}

		Component.onCompleted: {
			addItem(qsTr("1/2 minute"));
			addItem(qsTr("1 minute"));
			addItem(qsTr("1 1/2 minute"));
			addItem(qsTr("2 minutes"));
			addItem(qsTr("3 minutes"));
			forceLayout();
		}
	}
}
