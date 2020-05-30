import QtQuick 2.1

import BasicUIControls 1.0;

/**
 * A component that represents a checkbox
 *
 */

StyledCheckBox {
	id: root
	width: Math.round(216 * horizontalScaling)
	height: Math.round(36 * verticalScaling)

	text: itemtext
	radius: designElements.radius

	topClickMargin: 4
	bottomClickMargin: 4
	leftClickMargin: 10
	rightClickMargin: 10

	squareOffset: 2
	spacing: designElements.spacing8
	leftMargin: Math.round(8 * horizontalScaling)

	squareRadius: Math.round(13 * verticalScaling)
	smallSquareRadius: Math.round(5 * verticalScaling)

	fontFamily: qfont.regular.name
	fontPixelSize: qfont.bodyText

	backgroundColor: colors.cbBackground
	checkMarkColor: colors.cbCheckMark

	property string fontFamilyUnselected: qfont.regular.name

	// allow change of 'selected' design
	property color fontColorSelected: colors.cbTextSelected
	property string fontFamilySelected: qfont.regular.name
	property color squareSelectedColor: colors.white
	property color squareUnselectedColor: colors.white
	property color squareDisabledColor: colors.cbBackground

	state: "unselected"

	property string kpiPostfix: text.length ? text : "checkbox"

	states: [
		State {
			name: "unselected"
			PropertyChanges { target: root; fontColor: colors.cbText }
			PropertyChanges { target: root; squareColor: squareUnselectedColor }
			PropertyChanges { target: root; fontFamily: fontFamilyUnselected }
		},
		State {
			name: "selected"
			PropertyChanges { target: root; fontColor: fontColorSelected }
			PropertyChanges { target: root; squareColor: squareSelectedColor }
			PropertyChanges { target: root; fontFamily: fontFamilySelected }
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; fontColor: colors.cbTextDisabled }
			PropertyChanges { target: root; squareColor: squareDisabledColor }
			PropertyChanges { target: root; fontFamily: qfont.regular.name }
		}
	]

	onSelectedChanged: {
		if (!enabled)
			return;

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

