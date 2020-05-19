import QtQuick 2.1

import BasicUIControls 1.0;

/*
 * This StyledButton based component is used mostly in Benchmark wizzard. It reassembles MenuItem but is compatible
 * with GroupControllers and can have different icons and label colors for selected / unselected states
 */
StyledButton {
	id: root

	property url iconSourceUnselected
	property url iconSourceSelected

	property color textColorUnselected: colors.twoStateBtnText
	property color textColorSelected: colors.twoStateBtnTextSelected

	property color btnColorUnselected: colors.twoStateBtnUp
	property color btnColorSelected: colors.twoStateBtnSelected

	property color textColor

	radius: designElements.radius

	topLeftRadiusRatio: 1
	topRightRadiusRatio: 1
	bottomLeftRadiusRatio: 1
	bottomRightRadiusRatio: 1

	leftClickMargin: 10
	rightClickMargin: 10
	topClickMargin: 10
	bottomClickMargin: 10

	selectionTrigger: "OnPress"
	unselectionTrigger: "None"

	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root; iconSource: iconSourceUnselected }
			PropertyChanges { target: root; textColor: textColorUnselected }
			PropertyChanges { target: root; color: btnColorUnselected }
		},
		State {
			name: "selected"
			PropertyChanges { target: root; iconSource: iconSourceSelected }
			PropertyChanges { target: root; textColor: textColorSelected }
			PropertyChanges { target: root; color: btnColorSelected }
		}
	]

	onSelectedChanged: {
		if (selected) {
			root.state = "selected"
		} else {
			root.state = "up"
		}
	}
}
