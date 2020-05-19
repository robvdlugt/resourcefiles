import QtQuick 2.1

import BasicUIControls 1.0;

StyledButton {
	id: root

	property bool useExtension: colors.tabButtonUseExtension
	property real extensionHeight: Math.round(4 * verticalScaling)
	property bool bottomTab: false
	property string kpiId

	property color colorUp: colors.tabButtonColorUp
	property color colorSelected: colors.tabButtonColorSelected
	property color colorDisabled: colors.tabButtonColorDisabled

	property bool iconOverlayWhenUp: false
	property bool iconOverlayWhenSelected: false
	property color iconColorUp: colors.tabButtonIconColorUp
	property color iconColorSelected: colors.tabButtonIconColorSelected
	property color iconColorDisabled: colors.tabButtonIconColorDisabled

	fontFamily: qfont.regular.name
	fontPixelSize: qfont.bodyText

	radius: designElements.radius
	topLeftRadiusRatio: root.bottomTab ? 0 : 1
	topRightRadiusRatio: root.bottomTab ? 0 : 1
	bottomLeftRadiusRatio: root.bottomTab ? 1 : 0
	bottomRightRadiusRatio: root.bottomTab ? 1 : 0

	useOverlayColor: false

	leftMargin: designElements.hMargin10
	rightMargin: designElements.hMargin10
	spacing: designElements.spacing10
	defaultHeight: Math.round(45 * verticalScaling)
	minWidth: Math.round(55 * horizontalScaling)

	leftClickMargin: 0
	rightClickMargin: 0
	topClickMargin: 10
	bottomClickMargin: 10

	selectionTrigger: "OnClick"
	unselectionTrigger: "None"

	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root; color: root.colorUp}
			PropertyChanges { target: root; overlayColor: root.iconColorUp}
			PropertyChanges { target: root; useOverlayColor: root.iconOverlayWhenUp}
			PropertyChanges { target: root; fontColor: colors.tabButtonText}
			PropertyChanges { target: extension; visible: false}
		},
		State {
			name: "selected"
			PropertyChanges { target: root; color: root.colorSelected}
			PropertyChanges { target: root; overlayColor: root.iconColorSelected}
			PropertyChanges { target: root; useOverlayColor: root.iconOverlayWhenSelected}
			PropertyChanges { target: root; fontColor: colors.tabButtonTextSelected}
			PropertyChanges { target: extension; visible: useExtension ? true : false}
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; color: root.colorDisabled}
			PropertyChanges { target: root; overlayColor: root.iconColorDisabled}
			PropertyChanges { target: root; useOverlayColor: true}
			PropertyChanges { target: root; fontColor: colors.tabButtonTextDisabled}
			PropertyChanges { target: extension; visible: false}
		}
	]

	onSelectedChanged: {
		if (selected) {
			root.state = "selected"
		} else {
			root.state = "up"
		}
	}

	onEnabledChanged: {
		if (enabled) {
			root.state = "up"
		} else {
			root.state = "disabled"
		}
	}

	Rectangle {
		id: extension
		anchors {
			top: root.bottomTab ? undefined : root.bottom
			bottom : root.bottomTab ? root.top : undefined
			left: root.left
		}
		width: root.width
		height: root.extensionHeight
		color: root.color
	}
}
