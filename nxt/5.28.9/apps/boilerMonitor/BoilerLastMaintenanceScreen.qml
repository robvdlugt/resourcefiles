import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

EditScreen {
	id: root
	screenTitle: qsTr("boiler_lastMaintenance_screenTitle")

	QtObject {
		id: p
		property int thisYear
		property int thisMonth
	}

	onScreenShown: {
		var now = new Date();
		dateSpinner.maxDateTime = now;
		var minYear = app.boilerInfo.productionYear;
		if (!minYear)
			minYear = 1990;
		dateSpinner.minDateTime = new Date(minYear, 0, 1);
		if (app.lastMaintenance && app.lastMaintenance.getFullYear() !== 1970) {
			dateSpinner.init(app.lastMaintenance);
			dateRadioButton.selected = true;
		} else {
			now.setFullYear(now.getFullYear() - 1);
			dateSpinner.init(now);
			neverRadioButton.selected = true;
		}
	}

	onScreenSaved: {
		var selectedDate;
		switch(radioControlGroup.currentControlId) {
		case 0:
			var date = new Date(dateSpinner.selectedDateTime);
			date.setDate(15);
			selectedDate = app.getDateYYYYMMDD(date);
			break;
		case 1:
		default:
			selectedDate = "1970-01-01";
			break;
		}
		app.setBoilerLastMaintenance(selectedDate, root);
	}

	Text {
		id: headerText
		anchors {
			top: parent.top
			topMargin: Math.round(42 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}
		wrapMode: Text.WordWrap
		text: qsTr("header_text")
	}

	ControlGroup {
		id: radioControlGroup
		exclusive: true
	}

	StandardRadioButton {
		id: dateRadioButton
		anchors {
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: dateSpinner.right
			verticalCenter: dateSpinner.verticalCenter
		}
		controlGroupId: 0
		controlGroup: radioControlGroup
		property string kpiPostfix: "Date"
	}

	DateSpinner {
		id: dateSpinner
		anchors {
			top: headerText.top
			topMargin: Math.round(70 * verticalScaling)
			left: headerText.left
			leftMargin: Math.round(68 * horizontalScaling)
		}

		showDay: false
		showTime: false
		fullMonths: true

		fieldSpacing: Math.round(16 * horizontalScaling)
		fieldHeight: Math.round(80 * verticalScaling)
		monthFieldWidth: Math.round(286 * verticalScaling)

		onSelectedDateTimeChanged: radioControlGroup.currentControlId = 0
	}

	StandardRadioButton {
		id: neverRadioButton
		width: neverRadioButton.implicitWidth
		anchors {
			left: dateRadioButton.left
			top: dateSpinner.bottom
			topMargin: Math.round(40 * verticalScaling)
		}
		spacing:Math.round(40 * horizontalScaling)
		controlGroupId: 1
		controlGroup: radioControlGroup
		text: qsTr("Never") + " / " + qsTr("I don't know")
	}
}
