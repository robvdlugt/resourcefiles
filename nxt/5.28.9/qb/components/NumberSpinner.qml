import QtQuick 2.1

import BasicUIControls 1.0;

Item {
	id: root
	implicitWidth: Math.round(161 * horizontalScaling)
	implicitHeight: Math.round(112 * verticalScaling)

	property real rangeMin: 0.0
	property real rangeMax: 0.0
	property real increment: 0.0
	property real value: 0.0
	property bool wrapAtMaximum: false
	property bool wrapAtMinimum: false
	property string valuePrefix: ""
	property string valueSuffix: ""
	property alias mouseIsActiveInDimState: upButton.mouseIsActiveInDimState
	property int pressingEndTime: 0
	/// If value === NaN, display this string instead
	property string displayNaNString: "-"

	property real radius: designElements.radius
	property real spacing: Math.round(4 * horizontalScaling)
	property real buttonWidth: Math.round(50 * horizontalScaling)
	property bool buttonsRounded: false

	property alias topLeftRadiusRatio:     valueLabel.topLeftRadiusRatio
	property alias topRightRadiusRatio:    upButton.topRightRadiusRatio
	property alias bottomLeftRadiusRatio:  valueLabel.bottomLeftRadiusRatio
	property alias bottomRightRadiusRatio: downButton.bottomRightRadiusRatio

	property alias fontFamily:      valueLabel.fontFamily
	property alias fontPixelSize:   valueLabel.fontPixelSize
	property alias fontColor:       valueLabel.fontColor
	property alias textBaseline:    valueLabel.textBaseline
	property alias alignment:       valueLabel.alignment
	property alias leftMargin:      valueLabel.leftMargin
	property alias backgroundColor: valueLabel.color

	property color backgroundColorButtonsUp:   colors.numberSpinnerButtonsUp
	property color backgroundColorButtonsDown: colors.numberSpinnerButtonsDown
	property color backgroundColorButtonsDisabled: colors.numberSpinnerButtonsDisabled
	property bool  overlayButtonWhenUp:        true
	property alias overlayButtonWhenDown:      upButton.overlayWhenDown
	property color overlayColorButtonsUp:      colors.numberSpinnerOverlayButtonsUp
	property color overlayColorButtonsDown:    colors.numberSpinnerOverlayButtonsDown
	property alias borderColorUp:              upButton.borderColorUp
	property alias borderColorDown:            upButton.borderColorDown
	property alias borderWidth:                upButton.borderWidth
	property alias borderStyle:                upButton.borderStyle

	// When no iconsource is set the default up and down arrows are used
	property alias upIconSource: upButton.iconSource
	property alias downIconSource: downButton.iconSource

	property alias enabledUpButton: upButton.enabled
	property alias enabledDownButton: downButton.enabled

	property alias upButtonTopClickMargin: upButton.topClickMargin
	property alias downButtonBottomClickMargin: downButton.bottomClickMargin

	property bool disableButtonAtMaximum: false
	property bool disableButtonAtMinimum: false

	// Used for round in comparision. Needs to be changed only if number spinner will hold value with more than 1 valid decimal.
	property int maxValidDecimals: 1

	property alias valueField: valueLabel
	property alias upField: upButton
	property alias downField: downButton
	// when user release one of the iconButtons, signal is fired
	signal buttonPressed();
	signal buttonReleased();

	signal minimumWrapped();
	signal maximumWrapped();

	/*readonly*/ property alias inProgress: p.inProgress

	function valueToText(value) {
		if (isNaN(value)) {
			return displayNaNString;
		}
		return valuePrefix + i18n.number(value, maxValidDecimals) + valueSuffix;
	}

	function incrementValue() {
		p.changeValue(1);
		root.value = p.value;
	}

	function decrementValue() {
		p.changeValue(-1);
		root.value = p.value;
	}

	function updateValue() {
		p.changeValue(0);
		root.value = p.value;
	}

	function forceCommit() {
		upButton.onPressingEnded();
		downButton.onPressingEnded();
	}

	QtObject {
		id: p
		property real value: 0.0
		property bool inProgress: false

		function changeValue(delta) {
			var newValue = (p.value + delta * root.increment).toFixed(maxValidDecimals);
			if (newValue < rangeMin) {
				if (wrapAtMinimum) {
					minimumWrapped();
					p.value = root.value = rangeMax;
				}
			} else if (newValue > rangeMax) {
				if (wrapAtMaximum) {
					maximumWrapped();
					p.value = root.value = rangeMin;
				}
			} else {
				p.value = root.value = newValue;
			}
			valueLabel.text = valueToText(p.value);
		}
	}

	Component.onCompleted: {
		p.value = root.value;
		valueLabel.text = valueToText(root.value);
	}

	onRangeMinChanged: {
		if ((!p.inProgress) && (root.value < rangeMin)) root.value = rangeMin;
	}

	onRangeMaxChanged: {
		if ((!p.inProgress) && (root.value > rangeMax)) root.value = rangeMax;
	}

	onValueChanged: {
		p.value = root.value;
		valueLabel.text = valueToText(root.value);
	}

	StyledValueLabel {
		id: valueLabel

		width: root.width - root.buttonWidth - root.spacing
		height: root.height
		color: colors.numberSpinnerBackground

		fontFamily: qfont.regular.name
		fontPixelSize: qfont.spinnerText
		fontColor: root.enabled ? colors.numberSpinnerNumber : colors.numberSpinnerNumberDisabled

		radius: root.radius

		topLeftRadiusRatio: 1
		topRightRadiusRatio: 0
		bottomRightRadiusRatio: 0
		bottomLeftRadiusRatio: 1

		mouseEnabled: false
	}

	IconButton {
		id: upButton

		anchors.left: valueLabel.right
		anchors.leftMargin: root.spacing
		anchors.top: valueLabel.top

		width: root.buttonWidth
		height: (root.height - root.spacing) / 2.0

		colorUp: backgroundColorButtonsUp
		colorDown: backgroundColorButtonsDown
		colorDisabled: backgroundColorButtonsDisabled
		overlayWhenUp: overlayButtonWhenUp
		overlayColorUp: overlayColorButtonsUp
		overlayColorDown: overlayColorButtonsDown

		radius: root.radius

		topLeftRadiusRatio: buttonsRounded
		topRightRadiusRatio: 1
		bottomRightRadiusRatio: buttonsRounded
		bottomLeftRadiusRatio: buttonsRounded

		leftClickMargin: root.spacing
		rightClickMargin: 10
		topClickMargin: 10
		bottomClickMargin: root.spacing / 2.0

		timerEnabled: true
		pressingEndTime: root.pressingEndTime

		iconSource: "qrc:/images/arrow-up.svg"

		enabled: (disableButtonAtMaximum && !p.inProgress && (p.value >= rangeMax)) ?  false : root.enabled && !isNaN(p.value);

		onPressed: {
			p.inProgress = true;
			downButton.discardPressingEndTime();
			p.changeValue(1);
			root.buttonPressed();
		}

		onLongPressInterval: {
			if (enabled) p.changeValue(1);
		}

		onPressingEnded: {
			p.inProgress = false;
			root.value = p.value;
			root.buttonReleased();
		}
	}

	IconButton {
		id: downButton

		anchors.left: valueLabel.right
		anchors.leftMargin: root.spacing
		anchors.top: upButton.bottom
		anchors.topMargin: root.spacing

		width: root.buttonWidth
		height: upButton.height

		overlayWhenUp: upButton.overlayWhenUp
		overlayWhenDown: upButton.overlayWhenDown
		colorUp: backgroundColorButtonsUp
		colorDown: backgroundColorButtonsDown
		colorDisabled: backgroundColorButtonsDisabled
		overlayColorUp: overlayColorButtonsUp
		overlayColorDown: overlayColorButtonsDown
		borderColorUp: upButton.borderColorUp
		borderColorDown: upButton.borderColorDown
		borderWidth: upButton.borderWidth
		borderStyle: upButton.borderStyle

		radius: root.radius

		topLeftRadiusRatio: buttonsRounded
		topRightRadiusRatio: buttonsRounded
		bottomRightRadiusRatio: 1
		bottomLeftRadiusRatio: buttonsRounded

		leftClickMargin: root.spacing
		rightClickMargin: 10
		topClickMargin: root.spacing / 2.0
		bottomClickMargin: 10

		mouseIsActiveInDimState: upButton.mouseIsActiveInDimState

		timerEnabled: true
		pressingEndTime: root.pressingEndTime

		iconSource: "qrc:/images/arrow-down.svg"

		enabled: (disableButtonAtMinimum && !p.inProgress && (p.value <= rangeMin)) ? false : root.enabled && !isNaN(p.value);

		onPressed: {
			p.inProgress = true;
			upButton.discardPressingEndTime();
			p.changeValue(-1);
			root.buttonPressed();
		}

		onLongPressInterval: {
			if (enabled) p.changeValue(-1);
		}

		onPressingEnded: {
			root.value = p.value;
			p.inProgress = false;
			root.buttonReleased();
		}
	}
}

