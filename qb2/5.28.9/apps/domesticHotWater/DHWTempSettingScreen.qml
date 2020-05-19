import QtQuick 2.1

import qb.components 1.0

Screen {
	id: scrOffSettingScreen

	screenTitle: qsTr("Heating - DHW temperature")
	isSaveCancelDialog: true

	anchors.fill: parent

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;

		var rangeMin = parseInt(app.boilerInfo.dhwTempMin);
		var value = parseInt(app.boilerInfo.dhwTemp);
		var rangeMax = parseInt(app.boilerInfo.dhwTempMax);

		if (isNaN(rangeMin) || isNaN(value) || isNaN(rangeMax)) {
			dhwTempSpinner.value = 0;
			dhwTempSpinner.enabled = false;
		} else {
			dhwTempSpinner.enabled = true;
			dhwTempSpinner.rangeMin = rangeMin;
			dhwTempSpinner.value = value;
			dhwTempSpinner.rangeMax = rangeMax;
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		app.setDHWTemp(dhwTempSpinner.value);
	}

	Text {
		id: dhwTempSpinnerTitle

		anchors {
			baseline: parent.top
			baselineOffset: Math.round(126 * verticalScaling)
			left: dhwTempSpinner.left
		}

		text: qsTr("DHW temperature");
		color: colors.dhwTempTitle
		font.pixelSize: qfont.navigationTitle
		font.family: qfont.semiBold.name
	}

	NumberSpinner {
		id: dhwTempSpinner

		anchors {
			top: dhwTempSpinnerTitle.baseline
			topMargin: Math.round(19 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		disableButtonAtMaximum: true
		disableButtonAtMinimum: true
		increment: 1
		valueSuffix: "°"

		function valueToText(value) {
			return i18n.number(value, 0) + valueSuffix;
		}
	}
}
