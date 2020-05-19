import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

EditScreen {
	id: root
	screenTitle: qsTr("screen-title")

	onScreenShown: {
		var now = new Date();
		var maxDate = new Date(now.getTime());
		if (app.boilerStatus.maintenance.dueBy) {
			var dueDate = qtUtils.stringToDate(app.boilerStatus.maintenance.dueBy, "yyyy-MM-dd");
			if (qtUtils.isDateValid(dueDate) && dueDate.getTime() > maxDate.getTime())
				maxDate.setTime(dueDate.getTime());
		}
		maxDate.setMonth(maxDate.getMonth() + 3);
		dateSpinner.maxDateTime = maxDate;
		if (app.lastMaintenance && app.lastMaintenance.getFullYear() !== 1970)
			dateSpinner.minDateTime = app.lastMaintenance;
		else if (app.boilerInfo.productionYear)
			dateSpinner.minDateTime = new Date(app.boilerInfo.productionYear, 0, 1);
		else
			dateSpinner.minDateTime = new Date(1990, 0, 1);
		dateSpinner.init(now);
	}

	onScreenSaved: {
		var selectedDate = app.getDateYYYYMMDD(dateSpinner.selectedDateTime);
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
		text: qsTr("header-text")
	}

	DateSpinner {
		id: dateSpinner
		anchors {
			top: headerText.bottom
			topMargin: Math.round(80 * verticalScaling)
			left: headerText.left
		}

		showDay: true
		showTime: false
		fullMonths: true

		fieldSpacing: Math.round(16 * horizontalScaling)
		fieldHeight: Math.round(80 * verticalScaling)
		monthFieldWidth: Math.round(286 * verticalScaling)
	}
}
