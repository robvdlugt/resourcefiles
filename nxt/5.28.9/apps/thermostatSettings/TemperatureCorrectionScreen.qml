import QtQuick 2.1

import qb.components 1.0

Screen {
	id: temperatureCorrectionScreen

	screenTitle: qsTr("Temperature correction")
	anchors.fill: parent
	isSaveCancelDialog: true
	property real tempMeasured : 0
	property real tempDeviation : 0
	property real tempCorrection : 0

	onSaved: {
		if (nsTemperatureCorrection.enabled) {
			app.setTempCorrection(tempCorrection);
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		slAdjustment.rightText = "-°"
		initTemp();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	SingleLabel {
		id: slTempMeasure

		leftTextColor: colors.tempCorrTitle
		rightTextColor: colors.tempCorrBody
		leftText: qsTr("Temperature measurement")
		rightText: "-°";

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
	}

	Text {
		id: text

		anchors {
			baseline: slTempMeasure.bottom
			baselineOffset: Math.round(54 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		text: qsTr("Adjust temperature to")
		color: colors.tempCorrSystemTitle

		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name

	}

	NumberSpinner {
		id: nsTemperatureCorrection

		anchors {
			top: text.bottom
			topMargin: Math.round(19 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		rangeMin: (tempMeasured - 6).toFixed(1)
		rangeMax: (tempMeasured + 6).toFixed(1)
		increment: 0.1
		valueSuffix: '°'
		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		onValueChanged: {
			tempCorrection = value - tempMeasured;
			slAdjustment.rightText = i18n.number(tempCorrection, 1) + '°';
		}
	}

	SingleLabel {
		id: slAdjustment

		leftTextColor: colors.tempCorrTitle
		rightTextColor: colors.tempCorrBody
		leftText: qsTr("Deviation adjustment")

		anchors {
			top: nsTemperatureCorrection.bottom
			topMargin: Math.round(31 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
	}

	function initTemp() {
		tempMeasured = (parseFloat(app.boilerInfo.tempMeasured) / 100).toFixed(1);
		if (!isNaN(tempMeasured)) {
			tempDeviation = parseFloat(app.boilerInfo.tempDeviation);
			slTempMeasure.rightText = i18n.number(tempMeasured, 1) + '°';
			nsTemperatureCorrection.value = tempMeasured + tempDeviation;
			slAdjustment.rightText = i18n.number(tempDeviation, 1) + '°';
		} else {
			nsTemperatureCorrection.enabled = false;
		}
	}
}
