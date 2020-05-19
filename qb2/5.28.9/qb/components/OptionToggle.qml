import QtQuick 2.1

import BasicUIControls 1.0;

StyledToggle {
	id: root

	incorporateTextsInSize: true
	useOnOffTexts: false
	useBoldChangeForLeftRight: true

	radius: sliderHeight / 2
	shadowPixelSize: 1

	sliderWidth: Math.round(46 * horizontalScaling)
	sliderHeight: Math.round(24 * verticalScaling)
	knobWidth: Math.round(20 * horizontalScaling)

	backgroundColorKnob: colors.optionToggleKnobBackground
	shadowColorKnob: colors.none

	backgroundColorLeft: colors.optionToggleLeft
	shadowColorLeft: colors.optionToggleLeftShadow
	backgroundColorRight: colors.optionToggleRight
	shadowColorRight: colors.optionToggleRightShadow

	fontFamily: qfont.regular.name
	fontPixelSize: qfont.bodyText
	fontColor: colors.optionToggleText

	leftSpacing: Math.round(10 * horizontalScaling)
	rightSpacing: leftSpacing
	topSpacing: Math.round(10 * verticalScaling)
	bottomSpacing: topSpacing

	leftClickMargin: 10
	rightClickMargin: 10
	topClickMargin: 10
	bottomClickMargin: 10

	states: [
		State {
			name: "disabled"
			when: !enabled
			PropertyChanges {
				target: root
				backgroundColorLeft: colors.optionToggleDisabled
				shadowColorLeft: colors.optionToggleDisabledShadow
				backgroundColorRight: colors.optionToggleDisabled
				shadowColorRight: colors.optionToggleDisabledShadow
				fontColor: colors.optionToggleTextDisabled
			}
		}
	]
}
