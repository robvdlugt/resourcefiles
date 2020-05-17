import QtQuick 2.1

import qb.base 1.0

/**
 * A component that represents a SystrayIcon
 *
 * A SystrayIcon is a clickable element that is usually displayed in the systray.
 * Clicking it usually opens a full screen app.
 * The clicked signal is fired when the SystrayIcon is touched.
 * The icons are sorted numerically according to the posIndex property.
 * For predefined ordering, please see http://confluence/display/DEV/Qt+Components
 */

Widget {
	id: baseSystrayIcon
	width: Math.round(55 * horizontalScaling)
	height: designElements.menubarHeight

	property url image: ""
	/// determines the order in which the icons are displayed, from right to left, so 0 is right
	property int posIndex: -999
	/// Stores the Id to log to kpi on pressed.
	property string kpiId

	/// SystrayIcon was clicked
	signal clicked(variant mouse);

	onDoInit: {
		kpiId = widgetInfo.url.toString().split("/").pop();
	}

	Component.onCompleted: {
		mouseArea.clicked.connect(clicked)
	}

	Rectangle {
		id: backgroundSystrayIcon
		height: parent.height - 1
		width: parent.width - 1
		color: colors.systrayIconBackground
	}

	Image {
		id: baseMenuItemIcon
		anchors.centerIn: parent
		source: image.toString() ? "image://scaled/" + qtUtils.urlPath(image) : ""
	}

	MouseArea {
		id: mouseArea
		width: parent.width
		height: parent.height + 10

		onPressed: {
			baseSystrayIcon.state = "down";
		}
		onReleased: {
			baseSystrayIcon.state = "up";
		}
	}

	states: [
		State {
			name: "up"
		},
		State {
			name: "down"

			PropertyChanges {
				target: backgroundSystrayIcon
				color: colors.background
			}
		}
	]
}
