import QtQuick 2.11

import qb.base 1.0
import BasicUIControls 1.0;
import Feedback 1.0

StyledRectangle {
	id: root

	enum Position {
		Left,
		Top,
		Right
	}

	property int position: FeedbackButton.Position.Top
	property var targets
	property bool visibleConditions: true

	width: Math.round(40 * horizontalScaling)
	height: Math.round(48 * verticalScaling)
	color: colors._winnie
	visible: visibleConditions && feedbackController.active && !canvas.dimState

	radius: (width / 2)
	topLeftRadiusRatio: 0
	topRightRadiusRatio: 0
	bottomLeftRadiusRatio: 0
	bottomRightRadiusRatio: 0

	leftClickMargin: designElements.hMargin10
	rightClickMargin: designElements.hMargin10
	topClickMargin: designElements.vMargin10
	bottomClickMargin: designElements.vMargin10

	onClicked: {
		var feedbackPopup = feedbackPopupCmp.createObject(root, {"campaign": feedbackController.campaign, "container": home});
		feedbackPopup.show();
		feedbackPopup.hidden.connect(function () {
			feedbackPopup.destroy();
		});
	}

	FeedbackController {
		id: feedbackController
		targets: root.targets
	}

	Component {
		id: feedbackPopupCmp
		FeedbackPopup {}
	}

	Image {
		id: image
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(8 * verticalScaling)
		}
		source: "image://scaled/images/feedback-white.svg"
	}

	StyledRectangle {
		id: bgShadow
		width: parent.width
		height: parent.height
		radius: parent.radius
		color: colors.slidePanelButtonShadow
		visible: !canvas.dimState
		mouseEnabled: false
		x: 1
		y: 1
		z: -1

		topLeftRadiusRatio: parent.topLeftRadiusRatio
		topRightRadiusRatio: parent.topRightRadiusRatio
		bottomLeftRadiusRatio: parent.bottomLeftRadiusRatio
		bottomRightRadiusRatio: parent.bottomRightRadiusRatio
	}

	states: [
		State {
			name: "LEFT"
			when: position === FeedbackButton.Position.Left
			PropertyChanges { target: root; topRightRadiusRatio: 1; bottomRightRadiusRatio: 1; height: width }
			PropertyChanges { target: bgShadow; x: 1; y: 1}
		},
		State {
			name: "TOP"
			when: position === FeedbackButton.Position.Top
			PropertyChanges { target: root; bottomLeftRadiusRatio: 1; bottomRightRadiusRatio: 1}
			PropertyChanges { target: bgShadow; x: 0; y: 2}
		},
		State {
			name:"RIGHT"
			when: position === FeedbackButton.Position.Right
			PropertyChanges { target: root; topLeftRadiusRatio: 1; bottomLeftRadiusRatio: 1; height: width}
			PropertyChanges { target: bgShadow; x: -1; y: 1}
		}

	]
}
