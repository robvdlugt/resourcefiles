import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

EditScreen {
	id: root
	screenTitle: qsTr("year_title")

	onScreenShown: {
		var date = new Date();
		var thisYear = date.getFullYear();
		if (app.lastMaintenance && app.lastMaintenance.getFullYear() !== 1970)
			yearSelectorSpinner.rangeMax = app.lastMaintenance.getFullYear();
		else
			yearSelectorSpinner.rangeMax = thisYear;

		yearSelectorSpinner.value = (app.boilerInfo.productionYear ? app.boilerInfo.productionYear : yearSelectorSpinner.rangeMax);
		radioButtonList.currentIndex = (app.boilerInfo.productionYear === 0 ? 1 : 0);
	}

	onScreenSaved: {
		var selectedYear = radioButtonList.currentIndex === 0 ? yearSelectorSpinner.value : 0;
		app.setBoilerProductionYear(selectedYear, root);
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(216 * horizontalScaling)
		anchors {
			top: parent.top
			topMargin: Math.round(103 * verticalScaling)
			right: yearSelectorSpinner.right
		}
		listSpacing: Math.round(40 * verticalScaling)
		Component.onCompleted: {
			addItem("");
			addItem(qsTr("year_dont_know"));
			forceLayout();
		}
	}

	NumberSpinner {
		id: yearSelectorSpinner
		anchors {
			top: parent.top
			topMargin: Math.round(80 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		height: Math.round(80 * verticalScaling)
		width: Math.round(180 * verticalScaling)

		rangeMin: 1990
		increment: 1
		maxValidDecimals: 0
		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		onValueChanged: radioButtonList.currentIndex = 0
	}

	WarningBox {
		id: infoBox
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(75 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(640 * horizontalScaling)
		height: Math.round(86 * verticalScaling)

		warningText: qsTr("year_infobox_body")
		warningIcon: Qt.resolvedUrl("qrc:/images/info_warningbox.svg")
	}
}
