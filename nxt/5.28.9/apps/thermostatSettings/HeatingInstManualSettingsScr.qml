import QtQuick 2.1

import qb.components 1.0

Screen {
	id: heatingInstManualSettingsScr

	screenTitle: qsTr("Heating installation")
	isSaveCancelDialog: true

	anchors.fill: parent

	property alias manualMaxTemp: heatingTempSpinner.value
	property alias manualHeatRate: heatingRateSpinner.value

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args) {
			if (args.manualMaxTemp)
				app.tempManualHeatingMaxTemp = manualMaxTemp = args.manualMaxTemp;
			if (args.manualHeatRate)
				app.tempManualHeatingHeatRate = manualHeatRate = args.manualHeatRate;
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		app.tempManualHeatingMaxTemp = manualMaxTemp;
		app.tempManualHeatingHeatRate = manualHeatRate;
	}

	Text {
		id: heatingTempLabel

		anchors {
			left: heatingTempSpinner.left
			baseline: heatingTempSpinner.top
			baselineOffset: -10
		}

		text: qsTr("Heating temperature");
		color: colors.heatInstSettingsTitle
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
	}

	NumberSpinner {
		id: heatingTempSpinner

		anchors {
			top: parent.top
			topMargin: Math.round(136 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(160 * horizontalScaling)
		}

		increment: 1
		valueSuffix: "°"

		rangeMin: 6
		rangeMax: 90
		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		function valueToText(value) {
			return i18n.number(value, 0) + valueSuffix;
		}
	}


	Text {
		id: heatingRateLabel

		anchors {
			left: heatingRateSpinner.left
			baseline: heatingRateSpinner.top
			baselineOffset: -10
		}

		text: qsTr("Max. heating rate");
		color: colors.heatInstSettingsTitle
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
	}

	NumberSpinner {
		id: heatingRateSpinner

		anchors {
			top: parent.top
			topMargin: Math.round(136 * verticalScaling)
			left: heatingTempSpinner.right
			leftMargin: Math.round(98 * horizontalScaling)
		}

		increment: 1
		valueSuffix: "°"

		rangeMin: 1
		rangeMax: 8
		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		function valueToText(value) {
			return i18n.number(value, 0) + valueSuffix;
		}
	}

	Text {
		id: heatingRateTimeLable

		anchors {
			verticalCenter: heatingRateSpinner.verticalCenter
			left: heatingRateSpinner.right
			leftMargin: Math.round(16 * horizontalScaling)
		}

		text: qsTr("per hour");
		color: colors.heatInstSettingsTitle
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
	}

}
