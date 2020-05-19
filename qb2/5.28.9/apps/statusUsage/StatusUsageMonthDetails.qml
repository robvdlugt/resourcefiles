import QtQuick 2.0
import QtQuick.Layouts 1.3

import qb.components 1.0

Item {
	id: root
	property bool isCurrentMonth
	/* Format:
	[{
		resource: "elec",
		isGood: true,
		estimationCost: "€48,-",
		estimationUsage: "240 kWh",
		actualCost: "€34,-",
		actualUsage: "170 kWh"
	}]
	*/
	property alias model: detailsRepeater.model

	Text {
		anchors {
			left: line1.left
			leftMargin: designElements.hMargin10
			right: line2.right
			top: container.top
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		color: colors.titleText
		text: qsTr("Estimated for the whole month")
	}

	Text {
		anchors {
			left: line2.left
			leftMargin: designElements.hMargin10
			right: container.right
			top: container.top
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		color: colors.titleText
		text: isCurrentMonth ? qsTr("Consumed until now") : qsTr("Consumed this month")
	}

	Column {
		id: container
		anchors {
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
			right: parent.right
			leftMargin: Math.round(55 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		spacing: designElements.vMargin20

		Text {
			id: heightPlaceholder
			width: parent.width
			font {
				pixelSize: qfont.titleText
				family: qfont.regular.name
			}
			text: " "
		}

		Repeater {
			id: detailsRepeater

			Rectangle {
				width: parent.width
				height: Math.round(56 * verticalScaling)
				color: colors.contrastBackground

				Item {
					id: iconContainer
					width: Math.round(70 * horizontalScaling)
					height: parent.height

					Image {
						anchors.centerIn: parent
						source: "image://scaled/apps/statusUsage/drawables/%1_%2.svg".arg(modelData.resource).arg(modelData.isGood ? "good" : "bad")
						sourceSize.height: Math.round(32 * verticalScaling)
					}
				}

				Row {
					anchors {
						left: iconContainer.right
						leftMargin: designElements.vMargin10
						verticalCenter: parent.verticalCenter
					}
					spacing: Math.round(30 * horizontalScaling)

					Text {
						id: estimationCostText
						width: Math.round(55 * horizontalScaling)
						font {
							pixelSize: qfont.bodyText
							family: qfont.bold.name
						}
						color: colors.text
						horizontalAlignment: Text.AlignRight
						text: modelData.estimationCost
					}

					Text {
						id: estimationUsageText
						font {
							pixelSize: qfont.bodyText
							family: qfont.regular.name
						}
						color: colors.text
						text: modelData.estimationUsage
					}
				}

				Row {
					anchors {
						left: iconContainer.right
						leftMargin: line2.anchors.leftMargin + designElements.vMargin10
						verticalCenter: parent.verticalCenter
					}
					spacing: Math.round(30 * horizontalScaling)

					Text {
						id: actualCostText
						width: Math.round(55 * horizontalScaling)
						font {
							pixelSize: qfont.bodyText
							family: qfont.bold.name
						}
						color: colors.text
						horizontalAlignment: Text.AlignRight
						text: modelData.actualCost
					}

					Text {
						id: actualUsageText
						font {
							pixelSize: qfont.bodyText
							family: qfont.regular.name
						}
						color: colors.text
						text: modelData.actualUsage
					}
				}
			}
		}
	}

	Rectangle {
		id: line1
		width: 1
		height: container.height
		anchors {
			left: container.left
			leftMargin: Math.round(70 * horizontalScaling)
			bottom: container.bottom
		}
		color: colors._pressed
	}

	Rectangle {
		id: line2
		width: 1
		height: container.height
		anchors {
			left: line1.right
			leftMargin: (container.width - line1.anchors.leftMargin) / 2
			bottom: container.bottom
		}
		color: colors._pressed
	}

	StandardButton {
		anchors {
			left: container.left
			top: container.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		text: qsTr("Estimated yearly usage")
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, text, "")
			qdialog.context.contentLoader.setSource(app.estimationsPopupUrl, {"app": app})
		}
	}
}
