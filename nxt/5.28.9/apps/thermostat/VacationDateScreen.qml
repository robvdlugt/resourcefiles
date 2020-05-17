import QtQuick 2.1
import qb.components 1.0

Screen {
	id: vacationDateScreen
	screenTitle: qsTr("Select start time")
	isSaveCancelDialog: true

	property variant daysInMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	property string dateToChange: "startTime"

	onSaved: {
		var newTmpVacationData = app.tmpVacationData;
		newTmpVacationData[dateToChange] = (new Date(nsYear.value, nsMonth.value - 1, nsDay.value, nsHour.value, nsMinute.value, 0, 0)).getTime();
		app.tmpVacationData = newTmpVacationData;
	}

	QtObject {
		id: p
		property date minDateTime
		property date maxDateTime

		function setSpinnerMin(spinner, enable, min) {
			spinner.wrapAtMinimum = !enable;
			spinner.disableButtonAtMinimum = enable;
			spinner.rangeMin = min;
		}

		function setSpinnerMax(spinner, enable, max) {
			spinner.wrapAtMaximum = !enable;
			spinner.disableButtonAtMaximum = enable;
			spinner.rangeMax = max;
		}

		function checkMinMaxDatetime() {
			// same minimum year => set minimum month
			if (nsYear.value === p.minDateTime.getFullYear()) {
				setSpinnerMin(nsMonth, true, p.minDateTime.getMonth() + 1);
			} else {
				setSpinnerMin(nsMonth, false, 1);
			}

			// same maximum year => set maximum month
			if (nsYear.value === p.maxDateTime.getFullYear()) {
				setSpinnerMax(nsMonth, true, p.maxDateTime.getMonth() + 1);
			} else {
				setSpinnerMax(nsMonth, false, 12);
			}

			// same minimum year and month => set minimum day
			if (nsYear.value === p.minDateTime.getFullYear() &&
					(nsMonth.value === p.minDateTime.getMonth() + 1)) {
				setSpinnerMin(nsDay, true, p.minDateTime.getDate());
			} else {
				setSpinnerMin(nsDay, false, 1);
			}

			// same maximum year and month => set maximum day
			if (nsYear.value === p.maxDateTime.getFullYear() &&
					(nsMonth.value === p.maxDateTime.getMonth() + 1)) {
				setSpinnerMax(nsDay, true, p.maxDateTime.getDate());
			} else {
				setSpinnerMax(nsDay, false, getMaxDayInMonth());
			}

			// same date => set minimum hour
			if (nsYear.value === p.minDateTime.getFullYear() &&
					(nsMonth.value === p.minDateTime.getMonth() + 1) &&
					(nsDay.value === p.minDateTime.getDate())) {
				setSpinnerMin(nsHour, true, p.minDateTime.getHours());
			} else {
				setSpinnerMin(nsHour, false, 0);
			}

			// same date => set maximum hour
			if (nsYear.value === p.maxDateTime.getFullYear() &&
					(nsMonth.value === p.maxDateTime.getMonth() + 1) &&
					(nsDay.value === p.maxDateTime.getDate())) {
				setSpinnerMax(nsHour, true, p.maxDateTime.getHours());
			} else {
				setSpinnerMax(nsHour, false, 23);
			}

			// same date and hour => set minimum minutes
			if (nsYear.value === p.minDateTime.getFullYear() && (nsMonth.value === p.minDateTime.getMonth() + 1) &&
					(nsDay.value === p.minDateTime.getDate()) && (nsHour.value === p.minDateTime.getHours())) {
				setSpinnerMin(nsMinute, true, p.minDateTime.getMinutes());
			} else {
				setSpinnerMin(nsMinute, false, 0);
			}

			// same date and hour => set maximum minutes
			if (nsYear.value === p.maxDateTime.getFullYear() && (nsMonth.value === p.maxDateTime.getMonth() + 1) &&
					(nsDay.value === p.maxDateTime.getDate()) && (nsHour.value === p.maxDateTime.getHours())) {
				setSpinnerMax(nsMinute, true, p.maxDateTime.getMinutes());
			} else {
				setSpinnerMax(nsMinute, false, 50);
			}
		}

		function getMaxDayInMonth() {
			// is leap year?
			if ((nsMonth.value === 2) && ((nsYear.value % 4) === 0)) {
				return 29;
			} else {
				return daysInMonth[nsMonth.value - 1];
			}
		}
	}

	function initValue(datetime, minDateTime, maxDateTime) {
		p.minDateTime = new Date(minDateTime);
		p.maxDateTime = new Date(maxDateTime);

		nsYear.rangeMin = p.minDateTime.getFullYear();
		nsYear.rangeMax = p.maxDateTime.getFullYear();

		nsYear.value = datetime.getFullYear();
		nsMonth.value = datetime.getMonth() + 1;
		nsDay.value = datetime.getDate();
		nsHour.value = datetime.getHours();
		nsMinute.value = datetime.getMinutes();
	}

	onShown: {
		if (args) {
			if (args.dateToChange)
				dateToChange = args.dateToChange;

			if (args.initDt && args.minDt && args.maxDt)
				initValue(args.initDt, args.minDt, args.maxDt);
		}
	}

	onDateToChangeChanged: {
		if (dateToChange === "startTime") {
			screenTitle = qsTr("Select start time");
		} else {
			screenTitle = qsTr("Select end time");
		}
	}

	Column {
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
		spacing: Math.round(20 * horizontalScaling)

		Row {
			anchors {
				horizontalCenter: parent.horizontalCenter
			}
			spacing: Math.round(20 * horizontalScaling)

			NumberSpinner {
				id: nsDay
				rangeMin: 1
				rangeMax: 31
				increment: 1
				value: 1
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onMinimumWrapped: nsMonth.decrementValue();
				onMaximumWrapped: nsMonth.incrementValue();
				onValueChanged:	p.checkMinMaxDatetime();
			}

			NumberSpinner {
				id: nsMonth
				rangeMin: 1
				rangeMax: 12
				increment: 1
				value: 1
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) {return i18n.monthsShort[value - 1];}

				onMinimumWrapped: nsYear.decrementValue();
				onMaximumWrapped: nsYear.incrementValue();
				onValueChanged:	p.checkMinMaxDatetime();
			}

			NumberSpinner {
				id: nsYear
				rangeMin: 2014
				rangeMax: 2099
				increment: 1
				value: 2014
				disableButtonAtMaximum: true
				disableButtonAtMinimum: true

				function valueToText(value) { return value;	}

				onValueChanged: p.checkMinMaxDatetime();
			}
		}

		Row {
			anchors {
				horizontalCenter: parent.horizontalCenter
			}
			spacing: Math.round(20 * horizontalScaling)

			NumberSpinner {
				id: nsHour
				rangeMin: 0
				rangeMax: 23
				increment: 1
				value: 0
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onValueChanged: p.checkMinMaxDatetime();
			}

			Item {
				height: nsHour.height
				width: colon.width * 4

				Text {
					id: colon
					anchors {
						horizontalCenter: parent.horizontalCenter
						verticalCenter: parent.verticalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.spinnerText
					}
					text: ":"
					color: colors.numberSpinnerNumber
				}
			}

			NumberSpinner {
				id: nsMinute
				rangeMin: 0
				rangeMax: 50
				increment: 10
				value: 0
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onMinimumWrapped: nsHour.decrementValue();
				onMaximumWrapped: nsHour.incrementValue();
				onValueChanged: p.checkMinMaxDatetime();
			}
		}
	}
}
