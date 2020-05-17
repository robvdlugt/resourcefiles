import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

/**
	This component Shows program schedule for whole week. Repeater of DayProgram component is the
	only visual part. Component handles day selection / unselection.
	Note that the populate() function takes into account the difference in indexing between the
	source model (app.dhwProgram -> index 0 = sunday) and the view (dayRepeater -> index 0 = monday).
 */
Item {
	id: root

	width: 573 * horizontalScaling
	height: isNxt ? 343 : 261

	property bool programEnabled: true
	property int selectedDay : -1

	function populate() {
		var daysInProgram = Math.min(7, app.dhwProgram.length)
		for (var item = 0; item < daysInProgram; item++) {
			dayRepeater.itemAt(app.sundayBaseToMondayBase(item)).populateDayProgram(app.dhwProgram[item]);
		}
	}

	function selectDay(dayToSelect) {
		var dayToSelectMB = app.sundayBaseToMondayBase(dayToSelect)
		if (selectedDay === dayToSelect)
			return;
		else if (selectedDay >= 0) {
			dayRepeater.itemAt(app.sundayBaseToMondayBase(selectedDay)).isDaySelected = false;
		}
		selectedDay = dayToSelect;
		dayRepeater.itemAt(dayToSelectMB).isDaySelected = true;
	}

	Row {
		spacing: designElements.spacing8
		Repeater {
			id: dayRepeater
			model: 7
			delegate:  DHWDayProgram {
				height: root.height
				onDaySelected: { selectDay(dayToSelect); }
				dayEnabled: programEnabled
			}
		}
	}
}
