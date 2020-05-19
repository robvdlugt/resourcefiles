import QtQuick 2.1

import BasicUIControls 1.0;

Row {
	id: root

	property int minHour: 0
	property int minMinute: 0
	property int maxHour: 23
	property int maxMinute: 50

	property int hourIncrement: 1
	property int minuteIncrement: 1

	property int hourValue: -1
	property int minuteValue: -1
	/*readonly*/ property int value: hourValue * 60 + minuteValue

	property alias fontFamily:      hourValueLabel.fontFamily
	property alias fontPixelSize:   hourValueLabel.fontPixelSize
	property alias fontColor:       hourValueLabel.fontColor
	property alias textBaseline:    hourValueLabel.textBaseline
	property alias alignment:       hourValueLabel.alignment
	property alias leftMargin:      hourValueLabel.leftMargin
	property alias backgroundColor: hourValueLabel.color

	property color backgroundColorButtonsUp:   colors.numberSpinnerButtonsUp
	property color backgroundColorButtonsDown: colors.numberSpinnerButtonsDown
	property color backgroundColorButtonsDisabled: colors.numberSpinnerButtonsDisabled
	property bool  overlayButtonWhenUp:        true
	property alias overlayButtonWhenDown:      hourUpButton.overlayWhenDown
	property color overlayColorButtonsUp:      colors.numberSpinnerOverlayButtonsUp
	property color overlayColorButtonsDown:    colors.numberSpinnerOverlayButtonsDown
	property alias borderColorUp:              hourUpButton.borderColorUp
	property alias borderColorDown:            hourUpButton.borderColorDown
	property alias borderWidth:                hourUpButton.borderWidth
	property alias borderStyle:                hourUpButton.borderStyle

	property string kpiPrefix: "timeNumberSpinner"

	function setTime(hour, minute) {
		// Not going to bother with validation. Garbage in = garbage out.
		hourValue = hour;
		minuteValue = minute;
	}

	function valueToText(value) { return value < 10 ? "0" + value : value; }

	QtObject {
		id: p;

		property int minTime: minHour * 60 + minMinute
		property int maxTime: maxHour * 60 + maxMinute

		function addToHour(delta) {
			addToHourPrivate(delta);

			updateHourButtonState(hourValue, minuteValue);
			updateMinuteButtonState(hourValue, minuteValue);
		}

		function addToMinute(delta) {
			addToMinutePrivate(delta);

			updateHourButtonState(hourValue, minuteValue);
			updateMinuteButtonState(hourValue, minuteValue);
		}

		function addToHourPrivate(delta) {
			var newHourValue = hourValue + delta;
			if (newHourValue < minHour) hourValue = minHour;
			else if (newHourValue > maxHour) hourValue = maxHour;
			else hourValue = newHourValue;
		}

		function addToMinutePrivate(delta) {
			var newMinuteValue = minuteValue + delta;

			if (newMinuteValue >= 0) {
				addToHourPrivate(Math.floor(newMinuteValue / 60), false);
				minuteValue = newMinuteValue % 60;
			} else {
				addToHourPrivate(Math.floor(newMinuteValue / 60), false);
				newMinuteValue = newMinuteValue % 60;
				if (newMinuteValue < 0) newMinuteValue += 60;
				minuteValue = newMinuteValue;
			}
		}

		function updateHourButtonState(h, m) {
			// If adding (hourIncrement) hours would go over the maxtime, disable up
			if ((h + hourIncrement) * 60 + m > maxTime) {
				hourUpButton.enabled = false;
			} else {
				hourUpButton.enabled = true;
			}

			// If detracting (hourIncrement) hours would go below the mintime, disable down
			if ((h - hourIncrement) * 60 + m < minTime) {
				hourDownButton.enabled = false;
			} else {
				hourDownButton.enabled = true;
			}
		}

		function updateMinuteButtonState(h, m) {
			// If adding (minuteIncrement) minutes would go over the maxtime, disable up
			if (h * 60 + m + minuteIncrement > maxTime) {
				minuteUpButton.enabled = false;
			} else {
				minuteUpButton.enabled = true;
			}

			// If detracting (minuteIncrement) minutes would go below the mintime, disable down
			if (h * 60 + m - minuteIncrement < minTime) {
				minuteDownButton.enabled = false;
			} else {
				minuteDownButton.enabled = true;
			}
		}
	}

	Item {
		id: nsHour
		property string kpiPrefix: root.kpiPrefix + "nsHour"

		width: Math.round(161 * horizontalScaling)
		height: Math.round(112 * verticalScaling)

		property real radius: designElements.radius
		property real spacing: Math.round(4 * horizontalScaling)
		property real buttonWidth: Math.round(50 * horizontalScaling)
		property int pressingEndTime: 0

		StyledValueLabel {
			id: hourValueLabel

			text: root.valueToText(root.hourValue)

			width: parent.width - parent.buttonWidth - parent.spacing
			height: parent.height
			color: colors.numberSpinnerBackground

			fontFamily: qfont.regular.name
			fontPixelSize: qfont.spinnerText
			fontColor: colors.numberSpinnerNumber

			radius: parent.radius

			topLeftRadiusRatio: 1
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 1

			mouseEnabled: false
		}

		IconButton {
			id: hourUpButton

			anchors.left: hourValueLabel.right
			anchors.leftMargin: parent.spacing
			anchors.top: hourValueLabel.top

			width: parent.buttonWidth
			height: (parent.height - parent.spacing) / 2.0

			colorUp: backgroundColorButtonsUp
			colorDown: backgroundColorButtonsDown
			colorDisabled: backgroundColorButtonsDisabled
			overlayWhenUp: overlayButtonWhenUp
			overlayColorUp: overlayColorButtonsUp
			overlayColorDown: overlayColorButtonsDown

			radius: parent.radius

			topLeftRadiusRatio: 0
			topRightRadiusRatio: 1
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 0

			leftClickMargin: parent.spacing
			rightClickMargin: 10
			topClickMargin: 10
			bottomClickMargin: parent.spacing / 2.0

			timerEnabled: true
			pressingEndTime: parent.pressingEndTime

			iconSource: "qrc:/images/arrow-up.svg"

			onPressed: {
				p.addToHour(hourIncrement);
			}

			onLongPressInterval: {
				p.addToHour(hourIncrement);
			}
		}

		IconButton {
			id: hourDownButton

			anchors.left: hourValueLabel.right
			anchors.leftMargin: parent.spacing
			anchors.top: hourUpButton.bottom
			anchors.topMargin: parent.spacing

			width: parent.buttonWidth
			height: hourUpButton.height

			overlayWhenUp: hourUpButton.overlayWhenUp
			overlayWhenDown: hourUpButton.overlayWhenDown
			colorUp: backgroundColorButtonsUp
			colorDown: backgroundColorButtonsDown
			colorDisabled: backgroundColorButtonsDisabled
			overlayColorUp: overlayColorButtonsUp
			overlayColorDown: overlayColorButtonsDown
			borderColorUp: hourUpButton.borderColorUp
			borderColorDown: hourUpButton.borderColorDown
			borderWidth: hourUpButton.borderWidth
			borderStyle: hourUpButton.borderStyle

			radius: parent.radius

			topLeftRadiusRatio: 0
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 1
			bottomLeftRadiusRatio: 0

			leftClickMargin: parent.spacing
			rightClickMargin: 10
			topClickMargin: parent.spacing / 2.0
			bottomClickMargin: 10

			mouseIsActiveInDimState: hourUpButton.mouseIsActiveInDimState

			timerEnabled: true
			pressingEndTime: parent.pressingEndTime

			iconSource: "qrc:/images/arrow-down.svg"

			onPressed: {
				p.addToHour(-1 * hourIncrement);
			}

			onLongPressInterval: {
				p.addToHour(-1 * hourIncrement);
			}
		}
	}

	Text {
		id: colon
		text: ":"
		anchors.verticalCenter: parent.verticalCenter

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.spinnerText
		}
	}

	Item {
		id: nsMinute
		property string kpiPrefix: root.kpiPrefix + "nsMinute"

		width: Math.round(161 * horizontalScaling)
		height: Math.round(112 * verticalScaling)

		property real radius: designElements.radius
		property real spacing: Math.round(4 * horizontalScaling)
		property real buttonWidth: Math.round(50 * horizontalScaling)
		property int pressingEndTime: 0

		StyledValueLabel {
			id: minuteValueLabel

			text: root.valueToText(root.minuteValue)

			width: parent.width - parent.buttonWidth - parent.spacing
			height: parent.height
			color: colors.numberSpinnerBackground

			fontFamily: qfont.regular.name
			fontPixelSize: qfont.spinnerText
			fontColor: colors.numberSpinnerNumber

			radius: parent.radius

			topLeftRadiusRatio: 1
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 1

			mouseEnabled: false
		}

		IconButton {
			id: minuteUpButton

			anchors.left: minuteValueLabel.right
			anchors.leftMargin: parent.spacing
			anchors.top: minuteValueLabel.top

			width: parent.buttonWidth
			height: (parent.height - parent.spacing) / 2.0

			colorUp: backgroundColorButtonsUp
			colorDown: backgroundColorButtonsDown
			colorDisabled: backgroundColorButtonsDisabled
			overlayWhenUp: overlayButtonWhenUp
			overlayColorUp: overlayColorButtonsUp
			overlayColorDown: overlayColorButtonsDown

			radius: parent.radius

			topLeftRadiusRatio: 0
			topRightRadiusRatio: 1
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 0

			leftClickMargin: parent.spacing
			rightClickMargin: 10
			topClickMargin: 10
			bottomClickMargin: parent.spacing / 2.0

			timerEnabled: true
			pressingEndTime: parent.pressingEndTime

			iconSource: "qrc:/images/arrow-up.svg"

			onPressed: {
				p.addToMinute(minuteIncrement);
			}

			onLongPressInterval: {
				p.addToMinute(minuteIncrement);
			}
		}

		IconButton {
			id: minuteDownButton

			anchors.left: minuteValueLabel.right
			anchors.leftMargin: parent.spacing
			anchors.top: minuteUpButton.bottom
			anchors.topMargin: parent.spacing

			width: parent.buttonWidth
			height: minuteUpButton.height

			overlayWhenUp: minuteUpButton.overlayWhenUp
			overlayWhenDown: minuteUpButton.overlayWhenDown
			colorUp: backgroundColorButtonsUp
			colorDown: backgroundColorButtonsDown
			colorDisabled: backgroundColorButtonsDisabled
			overlayColorUp: overlayColorButtonsUp
			overlayColorDown: overlayColorButtonsDown
			borderColorUp: minuteUpButton.borderColorUp
			borderColorDown: minuteUpButton.borderColorDown
			borderWidth: minuteUpButton.borderWidth
			borderStyle: minuteUpButton.borderStyle

			radius: parent.radius

			topLeftRadiusRatio: 0
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 1
			bottomLeftRadiusRatio: 0

			leftClickMargin: parent.spacing
			rightClickMargin: 10
			topClickMargin: parent.spacing / 2.0
			bottomClickMargin: 10

			mouseIsActiveInDimState: minuteUpButton.mouseIsActiveInDimState

			timerEnabled: true
			pressingEndTime: parent.pressingEndTime

			iconSource: "qrc:/images/arrow-down.svg"

			onPressed: {
				p.addToMinute(-1 * minuteIncrement);
			}

			onLongPressInterval: {
				p.addToMinute(-1 * minuteIncrement);
			}
		}
	}
}
