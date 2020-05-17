import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

/**
 * A custom delegate component for radiobutton list
 *
 * In a group of radio buttons, only one radio button can be checked at a time.
 * If the user selects another button, the previously selected button is switched off.
 */

StyledRadioButton {
	id: root

	property alias iconSource: connectionIcon.source
	property alias caption: connectionCaption.text
	property alias description: connectionDesc.text
	property string kpiId

	height: Math.round(80 * verticalScaling)
	width: Math.round(370 * horizontalScaling)
	controlGroup: model.controlGroup

	dotOffset: Math.round(2 * horizontalScaling)
	dotRadius: Math.round(13 * horizontalScaling)
	smallDotRadius: Math.round(5 * horizontalScaling)
	smallDotColor: colors.rbSmallDot
	smallDotShadowColor: colors.rbShadowDot
	smallDotColorSelected: colors.rbSmallDotSelected
	smallDotShadowColorSelected: colors.rbShadowDotSelected

	RoundedRectangle {
		id: connectionRect
		anchors {
			left: parent.left
			leftMargin: root.dotRadius * 2 + designElements.hMargin10
		}
		color: colors.labelBackground
		height: root.height
		width: root.width - anchors.leftMargin

		Image {
			id: connectionIcon
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: designElements.hMargin20
			}

			source: model.iconSource
		}

		Column {
			anchors {
				//the icons do not have same width -> could not anchor to icon right to have aligned text
				left: parent.left
				leftMargin: Math.round(100 * horizontalScaling)
				right: parent.right
				rightMargin: Math.round(10 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			Text {
				id: connectionCaption
				anchors {
					left: parent.left
					right: parent.right
				}
				visible: (text !== "")
				color: colors.localAccesBody
				text: model.connCaption
				wrapMode: Text.WordWrap
				font.pixelSize: qfont.bodyText
				font.family: qfont.bold.name
			}

			Text {
				id: connectionDesc
				anchors {
					left: connectionCaption.left
					right: connectionCaption.right
				}
				visible: (text !== "")
				color: colors.localAccesBody
				text: model.connDesc
				wrapMode: Text.WordWrap
				font.pixelSize: qfont.bodyText
				font.family: qfont.regular.name
			}
		}

	}

	state: enabled ? (selected ? "selected" : "unselected") : "disabled"

	states: [
		State {
			name: "unselected"
			PropertyChanges { target: root; dotColor: colors.white }
			PropertyChanges { target: connectionCaption; color: colors.localAccesBody }
			PropertyChanges { target: connectionDesc; color: colors.localAccesBody }
		},
		State {
			name: "selected"
			PropertyChanges { target: root; dotColor: colors.rbBackground }
			PropertyChanges { target: connectionCaption; color: colors.localAccesBody }
			PropertyChanges { target: connectionDesc; color: colors.localAccesBody }
		},
		State {
			name: "disabled"
			PropertyChanges { target: root; dotColor: colors.rbBackground }
			PropertyChanges { target: connectionCaption; color: colors.ibOverlayColorDisabled }
			PropertyChanges { target: connectionDesc; color: colors.ibOverlayColorDisabled }
		}
	]
}
