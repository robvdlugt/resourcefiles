import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

/**
	This component Shows program schedule for whole week. Repeater of DayProgram component is the
	only visual part. Component handles day selection / unselection.

 */
Item {
	id: root

	property int selectedDay : -1

	function populate() {
		var daysInProgram = Math.min(7, app.thermostatProgram.length)
		for (var item = 0; item < daysInProgram; item++) {
			dayRepeater.itemAt(app.sundayBaseToMondayBase(item)).populateDayProgram(app.thermostatProgram[item]);
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

	width: 573 * horizontalScaling
	height: isNxt ? 343 : 261

	Row {
		spacing: designElements.spacing8
		Repeater {
			id: dayRepeater
			model: 7
			delegate:  ThermostatDayProgram {
				height: root.height
				stateColors: app.thermStateColor
				stateNames: app.thermStateName
				dayEnabled: true

				onDaySelected: { selectDay(app.mondayBaseToSundayBase(dayToSelect)); }
			}
		}
	}
}
