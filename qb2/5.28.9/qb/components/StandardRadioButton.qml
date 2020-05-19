import QtQuick 2.1

import BasicUIControls 1.0;

/**
 * A component that represents a radiobutton
 *
 */

StyledRadioButton {
	id: root
	width: Math.round(216 * horizontalScaling)
	height: Math.round(36 * verticalScaling)

	text: typeof itemtext !== "undefined" ? itemtext : ""
	radius: designElements.radius

	topClickMargin: 4
	bottomClickMargin: 4

	dotOffset: 2
	spacing: designElements.spacing8
	leftMargin: Math.round(8 * horizontalScaling)
	rightMargin: Math.round(8 * horizontalScaling)

	dotRadius: Math.round(13 * horizontalScaling)
	smallDotRadius: Math.round(5 * horizontalScaling)

	fontFamily: qfont.regular.name
	fontPixelSize: qfont.bodyText

	backgroundColor: colors.rbBackground

	smallDotColor: colors.rbSmallDot
	smallDotShadowColor: colors.rbShadowDot

	smallDotColorSelected: colors.rbSmallDotSelected
	smallDotShadowColorSelected: colors.rbShadowDotSelected

	shadowPixelSizeSmallDot: 1

	state: "unselected"

	property string kpiPostfix: text.length ? text : "radio"

	leftClickMargin: 10

	states: [
		State {
			name: "unselected"
			PropertyChanges { target: root; fontColor: colors.rbText }
			PropertyChanges { target: root; dotColor: colors.white }
		},
		State {
			name: "selected"
			PropertyChanges { target: root; fontColor: colors.rbTextSelected }
			PropertyChanges { target: root; dotColor: colors.rbBackground }
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; fontColor: colors.rbTextDisabled }
			PropertyChanges { target: root; dotColor: colors.rbBackground }
		}
	]

	onSelectedChanged: {
		if (selected) {
			root.state = "selected"
		} else {
			root.state = "unselected"
		}
	}

	onEnabledChanged: {
		if (enabled) {
			if (root.selected) {
				root.state = "selected"
			} else {
				root.state = "unselected"
			}
		} else {
			root.state = "disabled"
		}
	}
}

