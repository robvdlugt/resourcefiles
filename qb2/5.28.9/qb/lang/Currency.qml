import QtQuick 2.1

QtObject {
	id: root
	// place the currency symbol after the amount
	property bool symbolAfterAmount: false
	// use <decimal separator>- for whole (integer) amounts
	property bool dashForWholeAmount: false
	property string currencySymbol: "$"

	function init(props) {
		for (var prop in props)
			if (typeof root[prop] !== "undefined")
				root[prop] = props[prop];
	}

	function format(amount, options, maxDecimals) {
		// '\xa0' is non-breaking space
		var stringFormat = symbolAfterAmount ? "%1\xa0%2" : "%2\xa0%1";
		var maxDecimalsToUse = !isNaN(maxDecimals) ? maxDecimals : 2;
		if (amount !== undefined) {
			if (options & i18n.curr_round) {
				return stringFormat.arg(i18n.number(amount, 0) + (dashForWholeAmount ? i18n.decimalSeparator() + "-" : "")).arg(currencySymbol);
			} else {
				var numberAsString = i18n.number(amount, maxDecimalsToUse, options);
				if (maxDecimalsToUse > 2) {
					var regex = new RegExp("^\\d+\\" + i18n.decimalSeparator() + "\\d{2,}?(?=0*$)")
					var matches = numberAsString.match(regex);
					if (Array.isArray(matches) && matches[0])
						numberAsString = matches[0];
				}
				return stringFormat.arg(numberAsString).arg(currencySymbol);
			}
		} else {
			return currencySymbol;
		}
	}

}
