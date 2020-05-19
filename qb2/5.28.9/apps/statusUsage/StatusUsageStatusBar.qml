import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

/**
	A StatusUsageStatusBar is a graphical representation of
	energy usage in relation to an estimated value.
	The bar can be scaled in which the progression ratio
	of the period of time related to the estimation is set.
*/
Item {
	property int consumptionBarMargin: 1
	property int barHeight: Math.round(24 * verticalScaling)

	property int estimation: 0
	property int consumption: 0
	property real progressionRatio
	property bool missingData: false
	property alias helpButton: missingDataHelpButton

	height: childrenRect.height

	function update() {
		var usageRatio = consumption / estimation;
		var estimationLineRatio;
		if (progressionRatio === 1 && usageRatio > 1) {
			estimationLineRatio = 1 / usageRatio;
		} else {
			estimationLineRatio = progressionRatio;
		}
		estimationLine.progress = estimationLineRatio;

		consumptionBarRoundTip.visible = true;
		overshootBarRoundTip.visible = false;
		overshootBarRoundTip.consumption = false;
		overshootBar.visible = false;
		if (isNaN(usageRatio) || usageRatio === 0) {
			consumptionBar.width = 0;
			consumptionBarRoundTip.visible = false;
		} else if (usageRatio <= 1) {
			consumptionBar.width = Math.round(estimationLine.anchors.horizontalCenterOffset * usageRatio);

			var distToMissingDataImage = (missingDataImage.x + (missingDataImage.width / 2)) - consumptionBar.x;
			if (missingData && consumptionBar.width < distToMissingDataImage)
				consumptionBar.width = distToMissingDataImage;

			if (usageRatio === 1 && progressionRatio === 1) {
				overshootBarRoundTip.consumption = true;
				overshootBarRoundTip.visible = true;
			}
		} else {
			consumptionBar.width = estimationLine.anchors.horizontalCenterOffset;
			overshootBar.width = Math.round((usageRatio - 1) * consumptionBar.width);

			if ((consumptionBar.width + overshootBar.width) >= barBoundingBox.width) {
				estimationLineRatio = 1 / usageRatio;
				estimationLine.progress = estimationLineRatio;
				consumptionBar.width = estimationLine.anchors.horizontalCenterOffset;
				overshootBar.width = Math.round(barBoundingBox.width - consumptionBar.width);
				overshootBarRoundTip.visible = true;
			}

			overshootBar.visible = true;
		}
	}

	Component.onCompleted: {
		estimationChanged.connect(update);
		consumptionChanged.connect(update);
		progressionRatioChanged.connect(update);
	}

	Rectangle {
		id: backgroundBar
		anchors {
			left: parent.left
			right: parent.right
		}
		height: barHeight
		radius: height / 2
		color: colors.statusUsageBackgroundBar

		StyledRectangle {
			id: consumptionBarRoundTip
			width: height
			height: consumptionBar.height
			anchors {
				left: parent.left
				leftMargin: consumptionBarMargin
				verticalCenter: parent.verticalCenter
			}
			color: colors.statusUsageConsumptionBar
			radius: height / 2

			topLeftRadiusRatio: 1
			bottomLeftRadiusRatio: 1
			topRightRadiusRatio: 0
			bottomRightRadiusRatio: 0
			mouseEnabled: false
		}

		Rectangle {
			id: barBoundingBox
			anchors {
				left: consumptionBarRoundTip.horizontalCenter
				right: overshootBarRoundTip.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			height: parent.height - (consumptionBarMargin * 2)
			color: colors.statusUsageBackgroundBar
		}

		Rectangle {
			id: consumptionBar
			height: barBoundingBox.height
			anchors {
				left: barBoundingBox.left
				verticalCenter: parent.verticalCenter
			}
			color: colors.statusUsageConsumptionBar
		}

		Image {
			id: missingDataImage
			source: "image://scaled/apps/statusUsage/drawables/bar_missing_data.svg"
			anchors {
				verticalCenter: parent.verticalCenter
				left: consumptionBarRoundTip.horizontalCenter
				leftMargin: Math.round(-3 * horizontalScaling)
			}
			visible: missingData
		}

		IconButton {
			id: missingDataHelpButton
			height: Math.round(34 * verticalScaling)
			width: height
			radius: width / 2
			anchors {
				horizontalCenter: missingDataImage.horizontalCenter
				horizontalCenterOffset: Math.round(30 * horizontalScaling)
				verticalCenter: missingDataImage.verticalCenter
				verticalCenterOffset: Math.round(-45 * verticalScaling)
			}
			iconSource: "drawables/question_mark.svg"
			visible: missingDataImage.visible
		}

		Rectangle {
			id: overshootBar
			anchors {
				left: consumptionBar.right
				verticalCenter: parent.verticalCenter
			}
			height: barBoundingBox.height
			color: colors.statusUsageOvershootBar
			visible: false
		}

		StyledRectangle {
			id: overshootBarRoundTip
			property bool consumption: false

			width: height
			height: overshootBar.height
			anchors {
				right: parent.right
				rightMargin: consumptionBarMargin
				verticalCenter: parent.verticalCenter
			}
			color: !consumption ? colors.statusUsageOvershootBar : colors.statusUsageConsumptionBar
			radius: height / 2
			visible: false

			topLeftRadiusRatio: 0
			bottomLeftRadiusRatio: 0
			topRightRadiusRatio: 1
			bottomRightRadiusRatio: 1
			mouseEnabled: false
		}

		Item {
			id: balloonContainer
			anchors {
				left: consumptionBar.right
				right: consumption <= estimation ? estimationLine.horizontalCenter : (overshootBarRoundTip.visible ? overshootBarRoundTip.right : overshootBar.right)
				bottom: parent.top
				bottomMargin: Math.round(-7 * verticalScaling)
			}
			height: childrenRect.height
			visible: !missingData

			Image {
				id: balloonImage
				source: "image://scaled/apps/statusUsage/drawables/"
						+ "balloon_bar_" + ((consumption - estimation) <= 0 ? "good" : "bad") +".svg"
				anchors.horizontalCenter: parent.horizontalCenter

				Text {
					id: differenceText
					anchors {
						baseline: parent.top
						baselineOffset: Math.round(60 * verticalScaling)
						horizontalCenter: parent.horizontalCenter
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.tileTitle
					}
					color: colors.statusUsageBalloonText
					text: i18n.currency(Math.abs(consumption - estimation), i18n.curr_round)
				}
			}
		}

		Rectangle {
			id: estimationLine
			width: Math.round(4 * horizontalScaling)
			height: Math.round(backgroundBar.height * 1.33 * verticalScaling)
			anchors {
				horizontalCenter: consumptionBar.left
				horizontalCenterOffset: Math.round(barBoundingBox.width * progress)
				verticalCenter: parent.verticalCenter
			}
			property real progress: 0
			color: colors.statusUsageEstimationLine
			radius: width / 2
			visible: progressionRatio < 1
		}

		Text {
			id: estimationText
			anchors {
				baseline: estimationLine.verticalCenter
				baselineOffset: Math.round(40 * verticalScaling)
				horizontalCenter: estimationLine.horizontalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageEstimationText
			text: qsTr("Estimated %1").arg(i18n.currency(estimation, i18n.curr_round))
		}
	}
}
