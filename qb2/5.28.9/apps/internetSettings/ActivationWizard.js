.pragma library

function validateActivationCode(text, isFinalString) {
	if ( isFinalString ) {
		if (text.length < 5) {
			return {content: qsTr("activation-key-too-short")}
		}
	}
	if (text.length > 10) {
		return {content: qsTr("activation-key-too-long")}
	}

	var activationCodeRegexIntermediate = /^[a-zA-Z0-9]{0,10}$/
	var activationCodeRegexFull = /^[a-zA-Z0-9]{6,10}$/

	if ( isFinalString ) {
		if (!activationCodeRegexFull.test(text)) {
			return {content: qsTr("activation-key-has-invalid-chars")}
		}
	} else {
		if (!activationCodeRegexIntermediate.test(text)) {
			return {content: qsTr("activation-key-has-invalid-chars")}
		}
	}

	return null
}

