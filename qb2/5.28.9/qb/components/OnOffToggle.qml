import QtQuick 2.1

import BasicUIControls 1.0;

StyledToggle {
	id: root

	leftIsSwitchedOn: false
	incorporateTextsInSize: true
	useOnOffTexts: true
	useBoldChangeForLeftRight: false

	radius: sliderHeight / 2
	shadowPixelSize: 1

	sliderWidth: Math.round(46 * horizontalScaling)
	sliderHeight: Math.round(24 * verticalScaling)
	knobWidth: Math.round(20 * horizontalScaling)

	backgroundColorKnob: colors.onOffToggleKnobBackground
	shadowColorKnob: colors.none

	backgroundColorLeft: colors.onOffToggleLeft
	shadowColorLeft: colors.onOffToggleLeftShadow
	backgroundColorRight: colors.onOffToggleRight
	shadowColorRight: colors.onOffToggleRightShadow

	fontFamily: qfont.semiBold.name
	fontPixelSize: qfont.bodyText

	leftSpacing: Math.round(10 * horizontalScaling)
	rightSpacing: leftSpacing
	topSpacing:  Math.round(10 * verticalScaling)
	bottomSpacing: topSpacing

	leftClickMargin: 10
	rightClickMargin: 10
	topClickMargin: 10
	bottomClickMargin: 10
}
