import QtQuick 2.0

import qb.components 1.0

Rectangle {
	id: root
	property alias text: exceptionText.text
	property bool loading: false
	property int year

	Item {
		id: exceptionContainer
		anchors {
			left: parent.left
			leftMargin: Math.round(54 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			top: parent.top
			bottom: exceptionInfoBox.top
		}

		Item {
			id: iconMsgContainer
			anchors.centerIn: parent
			width: childrenRect.width
			height: childrenRect.height

			Image {
				id: exceptionIcon
				source: "image://scaled/apps/statusUsage/drawables/graphs_illustration.svg"
				height: Math.round(100 * verticalScaling)
				sourceSize.height: height
			}

			Column {
				anchors {
					left: exceptionIcon.right
					verticalCenter: exceptionIcon.verticalCenter
				}
				width: Math.round(270 * horizontalScaling)

				Text {
					id: exceptionTitle
					anchors.horizontalCenter: parent.horizontalCenter
					font {
						family: qfont.regular.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.statusUsageTitle
					text: loading ? qsTr("Loading...") : qsTr("Sorry,")
				}

				Text {
					id: exceptionText
					width: parent.width
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
					}
					color: colors.statusUsageBodyAlt

					text: " "
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					visible: !loading
				}
			}
		}
	}

	Rectangle {
		id: exceptionInfoBox
		anchors {
			left: exceptionContainer.left
			right: exceptionContainer.right
			bottom: parent.bottom
			bottomMargin: Math.round(16 * verticalScaling)
		}
		height: Math.round(56 * verticalScaling)
		radius: designElements.radius
		color: colors.statusUsageInfoBox
		visible: !loading

		Text {
			anchors {
				left: parent.left
				leftMargin: Math.round(16 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageBodyAlt
			text: qsTr("Look at the details of your consumption in the graphs.")
		}

		StandardButton {
			anchors {
				right: parent.right
				rightMargin: designElements.hMargin10
				verticalCenter: parent.verticalCenter
			}
			text: qsTr("To graphs")
			onClicked: {
				stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "money", intervalType: "months", consumption: true, production: false, period: year})
			}
		}
	}
}
