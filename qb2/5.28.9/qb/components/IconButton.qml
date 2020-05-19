import QtQuick 2.1

import BasicUIControls 1.0;

StyledButton {
	id: root

	property bool primary: false

	property color colorUp:              colors.ibColorUp
	property color colorUpPrimary:       colors.ibColorUpPrimary
	property color colorDown:            colors.ibColorDown
	property color colorDownPrimary:     colors.ibColorDownPrimary
	property color colorSelected:        colors.ibColorSelected
	property color colorDisabled:        colors.ibColorDisabled
	property color overlayColorUp:       colors.ibOverlayColorUp
	property color overlayColorDown:     colors.ibOverlayColorDown
	property color overlayColorSelected: colors.ibOverlayColorSelected
	property color overlayColorDisabled: colors.ibOverlayColorDisabled
	property color borderColorUp:        colors.ibBorderColorUp
	property color borderColorDown:      colors.ibBorderColorDown
	property color borderColorSelected:  colors.ibBorderColorSelected
	property color borderColorDisabled:  colors.ibBorderColorDisabled
	property bool overlayWhenUp: false
	property bool overlayWhenDown: true
	property bool overlayWhenSelected: false

	radius: designElements.radius

	leftMargin: 0
	rightMargin: 0
	width: height
	height: designElements.buttonSize

	leftClickMargin: 10
	rightClickMargin: 10
	topClickMargin: 10
	bottomClickMargin: 10

	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root; color: primary ? colorUpPrimary : colorUp}
			PropertyChanges { target: root; overlayColor: overlayColorUp}
			PropertyChanges { target: root; useOverlayColor: overlayWhenUp}
			PropertyChanges { target: root; borderColor: borderColorUp}
		},
		State {
			name: "down"
			PropertyChanges { target: root; color: primary ? colorDownPrimary : colorDown}
			PropertyChanges { target: root; overlayColor: overlayColorDown}
			PropertyChanges { target: root; useOverlayColor: overlayWhenDown}
			PropertyChanges { target: root; borderColor: borderColorDown}
		},
		State {
			name: "selected"
			PropertyChanges { target: root; color: colorSelected}
			PropertyChanges { target: root; overlayColor: overlayColorSelected}
			PropertyChanges { target: root; useOverlayColor: overlayWhenSelected}
			PropertyChanges { target: root; borderColor: borderColorSelected}
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; color: colorDisabled}
			PropertyChanges { target: root; overlayColor: overlayColorDisabled}
			PropertyChanges { target: root; useOverlayColor: true}
			PropertyChanges { target: root; borderColor: borderColorDisabled}
		}
	]

	onPressed: {
		root.state = "down";
	}

	onReleased: {
		if (selected) {
			root.state = "selected";
		} else {
			root.state = "up";
		}
	}

	onExited: {
		root.state = "up";
	}

	onEntered: {
		root.state = "down";
	}

	onSelectedChanged: {
		if (selected) {
			root.state = "selected";
		} else {
			root.state = "up";
		}
	}

	onEnabledChanged: {
		discardPressingEndTime();
		if (enabled) {
			root.state = "up";
		} else {
			root.state = "disabled";
		}
	}
}
