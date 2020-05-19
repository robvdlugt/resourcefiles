import QtQuick 2.1

Item {
	/// Abbreviated month names (0 for January, 11 for December)
	property variant monthsShort : [qsTr("Jan.", "abbreviated"), qsTr("Feb.", "abbreviated"), qsTr("Mar.", "abbreviated"), qsTr("Apr.", "abbreviated"), qsTr("May", "abbreviated"), qsTr("June", "abbreviated"), qsTr("July", "abbreviated"), qsTr("Aug.", "abbreviated"), qsTr("Sep.", "abbreviated"), qsTr("Oct.", "abbreviated"), qsTr("Nov.", "abbreviated"), qsTr("Dec.", "abbreviated")]
	/// Full month names (0 for January, 11 for December)
	property variant monthsFull : [qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"), qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"), qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")]
	/// Abbreviated day names (0 for Sunday, 6 for Saturday)
	property variant daysShort : [qsTr("Sun."), qsTr("Mon."), qsTr("Tue."), qsTr("Wed."), qsTr("Thu."), qsTr("Fri."), qsTr("Sat."), qsTr("Sun.")]
	/// Full day names (0 for Sunday, 6 for Saturday)
	property variant daysFull : [qsTr("Sunday"), qsTr("Monday"), qsTr("Tuesday"), qsTr("Wednesday"), qsTr("Thursday"), qsTr("Friday"), qsTr("Saturday")]
	/// Two-letter day names (0 for Sunday, 6 for Saturday)
	property variant daysExtraShort : [qsTr("Su"), qsTr("Mo"), qsTr("Tu"), qsTr("We"), qsTr("Th"), qsTr("Fr"), qsTr("Sa"), qsTr("Su")]

	property variant greetings: [{"start": 0, "text": qsTr("good night")}, {"start": 6, "text": qsTr("good morning")}, {"start": 12, "text": qsTr("good afternoon")}, {"start": 18, "text": qsTr("good evening")}]
	property string greetingText: ""
	/// The currency formatter. It should be set by the concrete implementation
	property Currency currencyImpl
	// Options to be passed to the currency implementation (based on the list of properties on Currency.qml)
	property variant currencyOptions: ({})
	Component.onCompleted: currencyImpl ? currencyImpl.init(currencyOptions) : undefined

	Item {
		id: p

		function updateGreetingText() {
			var hour = new Date().getHours();
			for (var i= 0, len = greetings.length; i < len-1; i++) {
				if (hour >= greetings[i].start && hour < greetings[i+1].start) {
					greetingText = greetings[i].text;
					return;
				}
			}
			// if hour is not within the first n-1 items, then it must be in the last one
			greetingText = greetings[i].text;
		}

		Timer {
			id: greetingTextTimer
			interval: 3600000 // 3600 secs in an hour, scaled to ms
			repeat: true

			onTriggered: {
				interval = 3600000;
				p.updateGreetingText()
			}
			Component.onCompleted: {
				p.updateGreetingText();
				var now = new Date();
				var msToNextHour = interval - ((now.getMinutes() * 60 + now.getSeconds()) * 1000 + now.getMilliseconds()) + 200; // to account for possible delays
				interval = msToNextHour;
				restart();
			}
		}
	}

	/**
	 * Number options:
	 * omit_trail_zeros
	 * general_rounding
	 * - default is do not omit trailing zeros and do not do general rounding (but standard rounding)
	 */
	/// Generate representation omitting trailing zeros (e.g. 12.99843 decimals = 2 results in 13 and not 13.00
	property int omit_trail_zeros: 1 << 1
	/// Generate general rounded number, rounded to the nearest value of increment (e.g. 12.445 decimals = 2, increment = 0.25 results in 12.50)
	property int general_rounding: 1 << 2
	/**
	  * Format a number to a fixed precission. 0's will be added to match the precision.
	  * @param type:real number The number to format
	  * @param type:integer decimals The number of decimals of precision.
	  * @param type:string The character to put between the round part and the decimals.
	  * @param type:integer options The specifications to which the rendered string should comply.
	  * @param type:real increment The nearest multiple of which number should be rounded to if general_rounding is set. If not valid and general_rounding is set default value of 1 is used
	  * @return type:string The formatted string.
	  */
	function formatNumberEx(number, decimals, separator, options, increment) {
		var negative = false;
		if (number < 0) {
			negative = true;
		}

		if (options & general_rounding) {
			if (isNaN(increment) || (increment <= 0))
				increment = 1;
			number = increment * Math.round(number / increment);
		}

		var numberAsString = number.toFixed(decimals);
		if (options & omit_trail_zeros) {
			// parseFloat removes trailing zeros
			numberAsString = parseFloat(numberAsString).toString();
		} else if (negative) {
			// Prevent construction of -0.0
			if (parseFloat(numberAsString) === 0.0 && numberAsString.charAt(0) === "-") {
				numberAsString = numberAsString.substr(1);
			}
		}

		return numberAsString.replace(".", separator);
	}


	/**
	  * Format a number to a fixed precision. 0's will be added to match the precision.
	  * @param type:real number The number to format
	  * @param type:integer decimals The number of decimals of precision.
	  * @param type:integer options The specifications to which the rendered string should comply.
	  * @param type:real increment The nearest multiple of which number should be rounded to if general_rounding is set. If not valid and general_rounding is set default value of 1 is used
	  * @return type:string The formatted string.
	  */
	function number(number, decimals, options, increment) {
		console.log("Unimplemented number formatting");
		return "unformatted(" + number + ")";
	}

	/**
	 * Currency options:
	 * curr_round: round cents to nearest whole amount. results in no trailing zeros and
	 *   and depending on locale, uses different formating for whole numbers (i.e € 24,-)
	 * - default is print trailing zeros after the decimal sign for whole amounts
	 */
	/**
	 * Formats the given amount to an usual currency representation, including the currency symbol.
	 * @param type:real		amount		The amount of currency.
	 * @param type:integer	options		The specifications to which the rendered string should comply.
	 * @param type:integer	maxDecimals	The maximum number of decimals to show, defaults to 2
	 * @return type:string The formatted string
	 */
	property int curr_round: 1 << 3

	function currency(amount, options, maxDecimals) {
		return currencyImpl ? currencyImpl.format(amount, options, maxDecimals) : "";
	}

	/**
	 * Date options:
	 * Day of week
	 * - Not
	 * - short
	 * - full
	 * Month:
	 * - Numeric
	 * - short
	 * - full
	 * Century:
	 * - yes
	 * - no
	 *
	 * Time options:
	 * Seconds
	 * - yes
	 * - no
	 *
	 * Encountered date formats:
	 * inboxapp: DD MMM YYYY
	 * Encountered time formats:
	 * inboxapp: HH:MM
	 * Clock-tray: HH:MM
	 * ...
	 *
	 * TBD:
	 * common prefix yes/no?
	 * format: (dow_no / dow_opt / time_yes) or (noDow / shortDow / yesTime)?
	 */
	/// Generate representation not including Day Of Week
	property int dow_no: 1
	/// Generate representation including abbreviated Day Of Week
	property int dow_short: 2
	/// Generate representation including full Day Of Week
	property int dow_full: 4
	/// Generate representation including the date with numeric month representation (implies date_yes).
	property int mon_num: 8
	/// Generate representation including the date with abbreviated name of the month (implies date_yes).
	property int mon_short: 16
	/// Generate representation including the date with full name of the month (implies date_yes).
	property int mon_full: 32
	/// Generate representation including the date, with year (implies date_yes).
	property int year_yes: 64
	/// Generate representation without year (does not do anything if date is not included by any option).
	property int year_no: 128
	/// Generate representation including the date, with century (implies date_yes and year_yes).
	property int cent_yes: 512
	/// Generate representation including the date, without century (does not do anything if date is not included by any option).
	property int cent_no: 1024
	//Probably not needed, just including the date with no cent_yes or cent_no should do this already.
	property int cent_defaut: 2048
	/// Generate representation including the date. The date will be rendered in its shortest complete form if there are no further date specifications.
	property int date_yes: 4096
	/// Generate representation not including the date. Setting any date specification will cancel this.
	property int date_no: 8192
	/// Generate representation including the time.
	property int time_yes: 16384
	/// Generate representation not including the time.
	property int time_no: 32768
	/// Generate representation including the time, with seconds (implies time_yes)
	property int secs_yes: 65536
	/// Generate representation without seconds (useless without time_yes)
	property int secs_no: 131072
	/// Generate representation adding "h" after time string (implies time_yes)
	property int hour_str_yes: 262144
	/// Generate representation not adding "h" after time string (useless without time_yes)
	property int hour_str_no: 524288
	/// Generate representation adding leading 0 if hour is less than 10 in time string (implies time_yes)
	property int leading_0_yes: 1048576
	/// Generate representation not adding leading 0 if hour is less than 10 in time string (useless without time_yes)
	property int leading_0_no: 2097152
	/// Generate representation not including the day of the month
	property int dom_no: 4194304

	/**
	  * Generate a date/time string according to the supplied specifications in the current locale.
	  * @param type:real time_m The time to render the representation for, in milliseconds since the usual epoch (as obtained from time_t * 1000, or new Date().getTime())
	  * @param type:integer options The specifications to which the rendered string should comply.
	  * @return type:string The formatted string.
	  */
	function dateTime(time_m, options) {
		console.log("Unimplemented dateTime formatting");
		return "unformatted( " + new Date(time_m).toDateString() + ")";
	}

	function dateTimeEuropean(time_m, options, dateSep, timeSep, hour_str) {
		var formattedDate = "";
		var d = new Date(time_m);
		var haveDow = 0;
		var haveDate = 0;
		// Does it include the day?
		if (options & dow_short) {
			haveDow = 1;
			formattedDate += daysShort[d.getDay()];
		} else if (options & dow_full) {
			haveDow = 1;
			formattedDate += daysFull[d.getDay()];
		}
		// Add date part
		if (options & (date_yes | mon_num | mon_short | mon_full | year_yes | cent_yes)) {
			haveDate = 1;
			var dateString = (options & dom_no) ? "" : d.getDate();
			var dateSeparator = (options & (mon_short | mon_full))? " " : dateSep;
			if (dateString)
				dateString += dateSeparator
			if (options & mon_short) {
				dateString += monthsShort[d.getMonth()];
			} else if (options & mon_full) {
				dateString += monthsFull[d.getMonth()];
			} else {
				dateString += (d.getMonth() + 1);
			}
			if (!(options & year_no)) {
				var yearString = "" + d.getFullYear();
				if (options & cent_no) {
					yearString = yearString.substr(2, 2);
				}
				if (dateString)
					dateString += dateSeparator;
				dateString += yearString;
			}
			if (haveDow) {
				formattedDate += " ";
			}
			formattedDate += dateString;
		}
		// Add time part
		if (options & (time_yes | secs_yes)) {
			var mins = d.getMinutes();
			if (mins < 10) mins = "0" + mins;
			var hour = d.getHours();
			if ((options & leading_0_yes) && hour < 10)
				hour = "0" + hour;
			var timeString  = hour + timeSep + mins;
			if (options & secs_yes) {
				var secs = d.getSeconds();
				if (secs < 10) secs = "0" + secs;
				timeString = timeString + timeSep + secs;
			}
			if (haveDow || haveDate) {
				formattedDate += (" " + timeString);
			} else {
				formattedDate = timeString;
			}
			if (options & hour_str_yes)
				formattedDate += (" " + hour_str)
		}
		return formattedDate;
	}

	function dateTimeAmerican(time_m, options, dateSep, timeSep) {
		var formattedDate = "";
		var d = new Date(time_m);
		var haveDow = 0;
		var haveDate = 0;
		// Does it include the day?
		if (options & dow_short) {
			haveDow = 1;
			formattedDate += daysShort[d.getDay()];
		} else if (options & dow_full) {
			haveDow = 1;
			formattedDate += daysFull[d.getDay()];
		}
		// Add date part
		if (options & (date_yes | mon_num | mon_short | mon_full | cent_yes)) {
			haveDate = 1;
			var dateString = "";
			var dateSeparator = (options & (mon_short | mon_full))? "," : dateSep;
			if (options & mon_short) {
				dateString += (monthsShort[d.getMonth()]);
			} else if (options & mon_full) {
				dateString += (monthsFull[d.getMonth()]);
			} else {
				dateString += (d.getMonth() + 1);
			}
			dateString += ((options & (mon_short | mon_full))? " " : dateSep);
			dateString += d.getDate();
			if (!(options & year_no)) {
				dateString += ((options & (mon_short | mon_full))? ", " : dateSep);
				var yearString = "" + d.getFullYear();
				if (options & cent_no) {
					yearString = yearString.substr(2, 2);
				}
				dateString += yearString;
			}
			if (haveDow) {
				formattedDate += " ";
			}
			formattedDate += dateString;
		}
		// Add time part
		if (options & (time_yes | secs_yes)) {
			var mins = d.getMinutes();
			if (mins < 10) mins = "0" + mins;
			var hour = d.getHours();
			var ampm;
			if (hour >= 12) {
				ampm = " pm";
			} else {
				ampm = " am"
			}
			if (hour > 12) {
				hour -= 12;
			}
			var timeString = hour + timeSep + mins;
			if (options &secs_yes) {
				var secs = d.getSeconds();
				if (secs < 10) secs = "0" + secs;
				timeString = timeString + timeSep + secs;
			}
			timeString = timeString + ampm;
			if (haveDow || haveDate) {
				formattedDate += (" " + timeString);
			} else {
				formattedDate = timeString;
			}
		}
		return formattedDate;
	}

	/**
	  * Generate a time duration string according to the supplied flags (i.e. X h Y min Z sec / X hours, Y minutes, Z seconds)
	  * @param type:integer duration The time duration to render the representation for in seconds
	  * @param type:boolean abbreviated Whether the time units should be abbreviated (h/min/sec) or fully written
	  * @param type:boolean asSentence Whether the duration is represented in a sentence-like format (separated by commas and 'and')
	  * @param type:boolean showSeconds Whether the seconds part of the duration should be included
	  * @param type:boolean showSeconds Whether the hours part of the duration should be hidden, thus showing durations
	  * of more than one hour as its equivalent in minutes
	  * @return type:string The formatted string.
	  */
	function duration(duration, abbreviated, asSentence, showSeconds, hideHours) {
		var hours = Math.floor(duration / (60 * 60)); // 60 seconds in a minute, 60 minutes in a hour
		var minutes = Math.floor(duration / 60); // 60 seconds in a minute
		if (!hideHours)
			minutes %= 60; // get only remainder of minutes that don't complete an hour
		var secs = duration % 60;
		var retStrings = [];

		if (!hideHours && (hours > 0 || duration === 0 || (!showSeconds && hours === 0 && minutes === 0)))
			retStrings.push(!abbreviated ? qsTr("%1 hour(s)", "", hours).arg(hours) : qsTr("%1 h").arg(hours));
		if (minutes > 0 || (hideHours && (duration === 0 || (!showSeconds && hours === 0 && minutes === 0))))
			retStrings.push(!abbreviated ? qsTr("%1 minute(s)", "", minutes).arg(minutes) : qsTr("%1 min").arg(minutes));
		if (showSeconds && secs > 0)
			retStrings.push(!abbreviated ? qsTr("%1 second(s)", "", secs).arg(secs) : qsTr("%1 sec").arg(secs));

		if (asSentence) {
			return arrayToSentence(retStrings);
		} else {
			return retStrings.join(abbreviated ? " " : ", ");
		}
	}

	function capitalizeFirstChar(text) {
		if (!text || typeof text !== "string" || text.length < 2)
			return text;

		return text.charAt(0).toUpperCase() + text.slice(1);
	}

	function countValues(arr) {
		if (!Array.isArray(arr))
			return 1;
		else
			return arr.length;
	}

	function arrayToSentence(arr, elementSurroundTag, listJoinWord) {
		if (typeof arr === "undefined")
			return "";
		var tag = elementSurroundTag;
		var joiner = listJoinWord ? listJoinWord : qsTr("and");
		if (countValues(arr) <= 1) {
			if (!tag) {
				return arr.toString();
			} else {
				return "<"+tag+">"+arr.toString()+"</"+tag+">";
			}
		} else {
			if (!elementSurroundTag)
				return arr.slice(0, arr.length - 1).join(", ") + " " + joiner + " "  + arr.slice(-1);
			else
				return "<"+tag+">" +
						arr.slice(0, arr.length - 1).join("</"+tag+">, <"+tag+">") + "</"+tag+"> " +
						joiner +
						" <"+tag+">" + arr.slice(-1) + "</"+tag+">";
		}
	}
}
