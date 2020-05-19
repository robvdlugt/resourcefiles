import QtQuick 2.1

import qb.base 1.0

/**
 * A component that represents a menuitem
 *
 * A menuitem is a clickable element that is ususally displayed in the menu app screen.
 * Clicking it usually opens a full screen app.
 * The clicked signal is fired when the menuitem is touched.
 */

Widget {
	id: baseMenuItem
	width: Math.round(128 * horizontalScaling)
	height: Math.round(104 * verticalScaling)

	property string label
	property url image
	property int weight: 0
	/// Stores the Id to log to kpi on pressed.
	property string kpiPostfix: label
	property alias locked: lockedOverlay.visible

	/// MenuItem was clicked
	signal clicked(variant mouse);

	function init() {
		console.debug("stub init for MenuItem " + widgetInfo.url);
	}

	Column {
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: Math.round(4 * verticalScaling)

		Rectangle {
			id: background
			width: Math.round(88 * horizontalScaling)
			height: Math.round(64 * verticalScaling)
			color: baseMenuItem.state === "down" ? colors.menuItemBG : colors.background
			radius: designElements.radius
			anchors.horizontalCenter: parent.horizontalCenter

			Image {
				id: icon
				anchors.centerIn: parent
				source: image.toString() ? (baseMenuItem.state === "down" ? "image://colorized/white" : "image://scaled") + qtUtils.urlPath(image) : ""
			}

			Rectangle {
				id: lockedOverlay
				anchors.fill: parent
				color: colors._fantasia
				radius: designElements.radius
				opacity: 0.5
				visible: false
			}

			Image {
				id: lockedIcon
				anchors {
					right: parent.right
					top: parent.top
					margins: designElements.vMargin5
				}
				source: visible ? "image://scaled/qb/components/drawables/lock.svg" : ""
				visible: lockedOverlay.visible
			}
		}

		Text {
			id: baseMenuItemLabel
			anchors.horizontalCenter: parent.horizontalCenter
			height: Math.round(21 * verticalScaling)
			width: Math.round(120 * horizontalScaling)

			color: baseMenuItem.state === "down" ? colors.menuLabelDown : colors.menuLabel
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			text: label
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
			lineHeight: 0.75
			maximumLineCount: 2
		}

	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent

		onPressed: baseMenuItem.state = "down";
		onReleased: baseMenuItem.state = "up";
		onClicked: baseMenuItem.clicked(mouse)
	}
}
