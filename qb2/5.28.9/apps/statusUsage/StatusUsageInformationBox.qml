import QtQuick 2.1
import qb.components 1.0

Item {
	id: informationBoxes
	height: Math.round(56 * verticalScaling)

	property alias leftIconSource: leftIcon.source
	property alias rightIconSource: rightIcon.source
	property alias leftText: leftText.text
	property alias rightText: rightText.text
	property string rightType
	property alias rightVisible: rightInfoBox.visible
	property int year

	Rectangle {
		id: leftInfoBox
		anchors {
			left: parent.left
			right: parent.horizontalCenter
			rightMargin: designElements.hMargin6
		}
		height: parent.height
		radius: designElements.radius
		color: colors.statusUsageInfoBox

		Image {
			id: leftIcon
			anchors {
				left: parent.left
				leftMargin: Math.round(16 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
		}

		Text {
			id: leftText
			anchors {
				left: leftIcon.right
				leftMargin: Math.round(12 * horizontalScaling)
				right: leftButton.left
				rightMargin: anchors.leftMargin
				verticalCenter: parent.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageBody
			wrapMode: Text.WordWrap
		}

		IconButton {
			id: leftButton
			height: Math.round(40 * verticalScaling)
			width: height
			radius: designElements.radius
			anchors {
				right: parent.right
				rightMargin: Math.round(8 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			iconSource: "drawables/graphs_icon.svg"
			onClicked: {
				stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "money", intervalType: "months", consumption: true, production: false, period: year})
			}
		}
	}

	Rectangle {
		id: rightInfoBox
		anchors {
			right: parent.right
			left: parent.horizontalCenter
			leftMargin: designElements.hMargin6
		}
		height: parent.height
		radius: designElements.radius
		color: colors.statusUsageInfoBox

		Image {
			id: rightIcon
			anchors {
				left: parent.left
				leftMargin: Math.round(16 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
		}

		Text {
			id: rightText
			anchors {
				left: rightIcon.right
				leftMargin: Math.round(12 * horizontalScaling)
				right: rightButton.left
				rightMargin: anchors.leftMargin
				verticalCenter: parent.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageBody
			wrapMode: Text.WordWrap
		}

		IconButton {
			id: rightButton
			height: Math.round(40 * verticalScaling)
			width: height
			radius: designElements.radius
			anchors {
				right: parent.right
				rightMargin: Math.round(8 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			iconSource: "drawables/graphs_icon.svg"
			onClicked: {
				stage.openFullscreen(app.graphScreenUrl, {agreementType: rightType, unitType: "money", intervalType: "months", consumption: true, production: false, period: year})
			}
		}
	}
}
