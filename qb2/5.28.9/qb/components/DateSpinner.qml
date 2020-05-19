import QtQuick 2.1
import qb.components 1.0

Item {
	id: dateSpinner
	width: container.width
	height: container.height
	property date minDateTime
	property date maxDateTime
	property bool showDay: true
	property bool fullMonths: false
	property bool showTime: true
	property int fieldSpacing: Math.round(20 * horizontalScaling)
	property int rowSpacing: fieldSpacing
	property int fieldHeight
	property int monthFieldWidth

	property date selectedDateTime

	QtObject {
		id: p

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

		function updateRanges() {
			if (isNaN(minDateTime) || isNaN(maxDateTime))
				return;

			nsYear.rangeMin = minDateTime.getFullYear();
			nsYear.rangeMax = maxDateTime.getFullYear();

			// same minimum year => set minimum month
			if (nsYear.value === minDateTime.getFullYear()) {
				setSpinnerMin(nsMonth, true, minDateTime.getMonth() + 1);
			} else {
				setSpinnerMin(nsMonth, false, 1);
			}

			// same maximum year => set maximum month
			if (nsYear.value === maxDateTime.getFullYear()) {
				setSpinnerMax(nsMonth, true, maxDateTime.getMonth() + 1);
			} else {
				setSpinnerMax(nsMonth, false, 12);
			}

			if (showDay) {
				// same minimum year and month => set minimum day
				if (nsYear.value === minDateTime.getFullYear() &&
						(nsMonth.value === minDateTime.getMonth() + 1)) {
					setSpinnerMin(nsDay, true, minDateTime.getDate());
				} else {
					setSpinnerMin(nsDay, false, 1);
				}

				// same maximum year and month => set maximum day
				if (nsYear.value === maxDateTime.getFullYear() &&
						(nsMonth.value === maxDateTime.getMonth() + 1)) {
					setSpinnerMax(nsDay, true, maxDateTime.getDate());
				} else {
					setSpinnerMax(nsDay, false, getMaxDayInMonth());
				}
			}

			if (showTime) {
				// same date => set minimum hour
				if (nsYear.value === minDateTime.getFullYear() &&
						(nsMonth.value === minDateTime.getMonth() + 1) &&
						(nsDay.value === minDateTime.getDate())) {
					setSpinnerMin(nsHour, true, minDateTime.getHours());
				} else {
					setSpinnerMin(nsHour, false, 0);
				}

				// same date => set maximum hour
				if (nsYear.value === maxDateTime.getFullYear() &&
						(nsMonth.value === maxDateTime.getMonth() + 1) &&
						(nsDay.value === maxDateTime.getDate())) {
					setSpinnerMax(nsHour, true, maxDateTime.getHours());
				} else {
					setSpinnerMax(nsHour, false, 23);
				}

				// same date and hour => set minimum minutes
				if (nsYear.value === minDateTime.getFullYear() && (nsMonth.value === minDateTime.getMonth() + 1) &&
						(nsDay.value === minDateTime.getDate()) && (nsHour.value === minDateTime.getHours())) {
					setSpinnerMin(nsMinute, true, minDateTime.getMinutes());
				} else {
					setSpinnerMin(nsMinute, false, 0);
				}

				// same date and hour => set maximum minutes
				if (nsYear.value === maxDateTime.getFullYear() && (nsMonth.value === maxDateTime.getMonth() + 1) &&
						(nsDay.value === maxDateTime.getDate()) && (nsHour.value === maxDateTime.getHours())) {
					setSpinnerMax(nsMinute, true, maxDateTime.getMinutes());
				} else {
					setSpinnerMax(nsMinute, false, 50);
				}
			}

			selectedDateTime = new Date(nsYear.value,
										nsMonth.value - 1,
										showDay ? nsDay.value : 1,
										showTime ? nsHour.value : 0,
										showTime ? nsMinute.value : 0);
		}

		function getMaxDayInMonth() {
			var date = new Date(nsYear.value, nsMonth.value - 1, 1);
			return qtUtils.daysInMonth(date);
		}
	}

	onMinDateTimeChanged: p.updateRanges()
	onMaxDateTimeChanged: p.updateRanges()

	function init(datetime) {
		if (!(datetime instanceof Date))
			return;
		if (isFinite(minDateTime) && datetime < minDateTime)
			datetime = minDateTime;
		else if (isFinite(maxDateTime) && datetime > maxDateTime)
			datetime = maxDateTime;

		nsYear.value = datetime.getFullYear();
		nsMonth.value = datetime.getMonth() + 1;
		nsDay.value = datetime.getDate();
		nsHour.value = datetime.getHours();
		nsMinute.value = datetime.getMinutes();
	}

	Column {
		id: container
		spacing: rowSpacing

		Row {
			spacing: fieldSpacing

			NumberSpinner {
				id: nsDay
				height: fieldHeight ? fieldHeight : undefined
				visible: showDay

				rangeMin: 1
				rangeMax: 31
				increment: 1
				value: 1
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onMinimumWrapped: nsMonth.decrementValue();
				onMaximumWrapped: nsMonth.incrementValue();
				onValueChanged:	p.updateRanges();
			}
			NumberSpinner {
				id: nsMonth
				width: monthFieldWidth ? monthFieldWidth : undefined
				height: fieldHeight ? fieldHeight : undefined

				rangeMin: 1
				rangeMax: 12
				increment: 1
				value: 1
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return i18n[dateSpinner.fullMonths ? "monthsFull" : "monthsShort"][value - 1]; }

				onMinimumWrapped: nsYear.decrementValue();
				onMaximumWrapped: nsYear.incrementValue();
				onValueChanged:	p.updateRanges();
			}
			NumberSpinner {
				id: nsYear
				height: fieldHeight ? fieldHeight : undefined

				rangeMin: 2014
				rangeMax: 2099
				increment: 1
				value: 2014

				disableButtonAtMaximum: true
				disableButtonAtMinimum: true

				function valueToText(value) { return value;	}

				onValueChanged: p.updateRanges();
			}
		}

		Row {
			spacing: fieldSpacing
			anchors.horizontalCenter: parent.horizontalCenter
			visible: showTime

			NumberSpinner {
				id: nsHour
				height: fieldHeight ? fieldHeight : undefined

				rangeMin: 0
				rangeMax: 23
				increment: 1
				value: 0
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onValueChanged: p.updateRanges();
			}

			Item {
				width: colon.width * 4
				height: nsHour.height

				Text {
					id: colon
					anchors.centerIn: parent
					font {
						family: qfont.regular.name
						pixelSize: qfont.spinnerText
					}
					color: colors.numberSpinnerNumber
					text: ":"
				}
			}

			NumberSpinner {
				id: nsMinute
				height: fieldHeight ? fieldHeight : undefined

				rangeMin: 0
				rangeMax: 50
				increment: 10
				value: 0
				wrapAtMaximum: true
				wrapAtMinimum: true

				function valueToText(value) { return value < 10 ? "0" + value : value; }

				onMinimumWrapped: nsHour.decrementValue();
				onMaximumWrapped: nsHour.incrementValue();
				onValueChanged: p.updateRanges();
			}
		}

	}
}
