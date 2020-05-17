import QtQuick 2.1

I18n {
	/// The default currency
	currencyImpl: Currency_EUR{}

	function number(number, decimals, options, increment) {
		return formatNumberEx(number, decimals, decimalSeparator(), options, increment);
	}

	function dateTime(time_m, options) {
		return dateTimeEuropean(time_m, options, "-", ":", "uur");
	}

	function decimalSeparator() {
		return ",";
	}
}
