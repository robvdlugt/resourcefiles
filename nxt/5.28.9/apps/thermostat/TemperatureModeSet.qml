import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

// See \\ssot\design\1_Toon\1_Designs UI\5_Redesign UI\04_Documentation\01_Definitions\Stijl_definities\Defining_thermostatapp.pdf

StyledRectangle {
	id: thermostatModeSet

	width: Math.round(308 * horizontalScaling)
	height: Math.round(111 * verticalScaling)
	radius: designElements.radius

	property alias label: label.text
	property alias temperature: modeValue.value
	property real maxEcoTemperature: 0.0
	property string kpiPrefix: "TemperaturePresetScreen." + label.text + "."

	Item {
		anchors {
			fill: parent
			topMargin: Math.round(13 * verticalScaling)
			rightMargin: Math.round(16 * horizontalScaling)
			bottomMargin: Math.round(13 * verticalScaling)
			leftMargin: Math.round(16 * horizontalScaling)
		}

		Text {
			id: label
			color: colors.white
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		NumberSpinner {
			id: modeValue
			anchors.fill: parent

			spacing: Math.round(12 * horizontalScaling)
			buttonWidth: Math.round(36 * verticalScaling)
			buttonsRounded: true

			fontFamily: qfont.regular.name
			fontPixelSize: qfont.timeAndTemperatureText
			fontColor: colors.white
			textBaseline: height - designElements.vMargin10
			alignment: StyledValueLabel.AlignmentLeft

			backgroundColor:            colors.none
			backgroundColorButtonsUp:   colors.tpBackgroundButtonsUp
			backgroundColorButtonsDown: colors.tpBackgroundButtonsDown
			overlayColorButtonsUp:      thermostatModeSet.color
			overlayColorButtonsDown:    thermostatModeSet.color
			upIconSource: "drawables/icon_plus.svg"
			downIconSource: "drawables/icon_minus.svg"

			rangeMin: 6.0
			rangeMax: 30.0
			disableButtonAtMaximum: true
			disableButtonAtMinimum: true
			increment: 0.5
			valueSuffix: "°"
		}

		Image {
			id: ecoIcon
			visible: modeValue.value <= maxEcoTemperature

			anchors {
				bottom: parent.bottom
				bottomMargin: designElements.vMargin10
				left: parent.left
				leftMargin: Math.round(115 * horizontalScaling)
			}

			source: "image://colorized/white/apps/thermostat/drawables/leaf.svg"
		}
	}
}
