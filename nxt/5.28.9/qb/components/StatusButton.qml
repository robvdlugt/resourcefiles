import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

import BasicUIControls 1.0;

Widget {
	id: statusButton

	width: Math.round(168 * horizontalScaling)
	height: Math.round(280 * verticalScaling)

	property int errorCount: 0
	property int weight

	property string kpiPostfix
	property string kpiPrefix
	property alias domainIconSource : domainIcon.source

	property alias titleText: title.text
	property alias statusText: status.text

	signal clicked

	function init() {
		kpiPostfix = "statusButton" + widgetArgs.weight;
	}

	Rectangle {
		id: background
		anchors.fill: parent
		radius: designElements.radius
		color: errorCount !== 0 ? colors.contentBackground : colors.contrastBackground

		MouseArea {
			anchors.fill: parent
			onClicked: statusButton.clicked()
		}

		Text {
			id: title
			anchors {
				top: parent.top
				topMargin: designElements.vMargin10
				left: parent.left
				leftMargin: anchors.topMargin
				right: parent.right
				rightMargin: anchors.topMargin
			}
			font {
				family: qfont.bold.name
				pixelSize: qfont.titleText
			}
			color: colors._gandalf
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
		}

		Image {
			id: domainIcon
			width: Math.round(120 * horizontalScaling)
			sourceSize.width: width
			anchors {
				bottom: errorButton.top
				bottomMargin: designElements.vMargin20
				horizontalCenter: parent.horizontalCenter
			}
		}

		Image {
			id: statusIcon
			width: Math.round(60 * horizontalScaling)
			sourceSize.width: width
			fillMode: Image.PreserveAspectFit
			anchors {
				right: domainIcon.right
				top: domainIcon.top
				topMargin: - designElements.hMargin10
			}
			source: "image://scaled/images/" +
					(errorCount === -1 ? "unknown" : (errorCount > 0 ? "bad" : "good")) + ".svg"
		}

		StandardButton {
			id: errorButton
			anchors {
				bottom: parent.bottom
				bottomMargin: designElements.vMargin15
				left: parent.left
				leftMargin: anchors.bottomMargin
				right: parent.right
				rightMargin: anchors.bottomMargin
			}
			primary: true
			visible: errorCount > 0 ? true :false
			text: qsTr("%n issues(s)", "", errorCount)

			onClicked: statusButton.clicked()
		}

		Text {
			id: status
			anchors {
				bottom: errorButton.bottom
				left: errorButton.left
				right: errorButton.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._gandalf
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
			text: " "
		}
	}
}
