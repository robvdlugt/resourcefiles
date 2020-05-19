import QtQuick 2.1

import BasicUIControls 1.0;

StyledButton {
	id: root

	fontFamily: qfont.semiBold.name
	fontPixelSize: designElements.hMargin15

	radius: designElements.radius

	overlayColor: fontColor

	leftMargin: Math.round(10 * horizontalScaling)
	rightMargin: Math.round(10 * horizontalScaling)
	spacing: Math.round(10 * horizontalScaling)
	defaultHeight: Math.round(44 * verticalScaling)

	leftClickMargin: Math.round(10 * horizontalScaling)
	rightClickMargin: Math.round(10 * horizontalScaling)
	topClickMargin: Math.round(10 * verticalScaling)
	bottomClickMargin: Math.round(10 * verticalScaling)

	timerEnabled: true
	longPressStartTime: 500
	longPressIntervalTime: 200
	pressingEndTime: 0
	acceleration: 0.1

	property bool manualStateChange: true

	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root; color: colors.btnUp}
			PropertyChanges { target: root; fontColor: colors.btnText}
			PropertyChanges { target: root; useOverlayColor: false}
		},
		State {
			name: "down"
			PropertyChanges { target: root; color: colors.btnDown}
			PropertyChanges { target: root; fontColor: colors.btnTextDown}
			PropertyChanges { target: root; useOverlayColor: true}
		},
		State {
			name: "fixed"
			PropertyChanges { target: root; color: colors.btnUp}
			PropertyChanges { target: root; fontColor: colors.btnTextSelected}
			PropertyChanges { target: root; useOverlayColor: true}
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; color: colors.btnDisabled}
			PropertyChanges { target: root; fontColor: colors.btnTextDisabled}
			PropertyChanges { target: root; useOverlayColor: true}
		}
	]

	onPressed: {
		if (root.manualStateChange)
			root.state = "down"
	}

	onReleased: {
		if (root.manualStateChange)
			root.state = "up"
	}

	onExited: {
		if (root.manualStateChange)
			root.state = "up"
	}

	onEntered: {
		if (root.manualStateChange)
			root.state = "down"
	}

	onEnabledChanged: {
		if (enabled) {
			root.state = "up"
		} else {
			root.state = "disabled"
		}
	}
}
