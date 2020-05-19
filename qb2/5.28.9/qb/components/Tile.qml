import QtQuick 2.1

import qb.base 1.0

/**
 * A component that represents a tile
 *
 * A tile is a clickable element that is ususally displayed in the home screen.
 * Clicking it usually opens a full screen app. However it can also contain
 * clickable controls.
 * This type should be extended to create the tiles that are provided by Apps.
 * The clicked signal is fired when the tile is touched.
 */
BaseTile {
	id: widget

	/// Tile was clicked
	signal clicked(variant mouse)
	/// Stores the UUID of this tile instance in the config
	property string uuid
	/// Stores the Id to log to kpi on pressed. Set to filename in onCompleted
	property string kpiId
	property alias bgColor: background.color

	Component.onCompleted: {
		if (widgetInfo)
			kpiId = widgetInfo.url.toString().split("/").pop();
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: colors.tileBackground
		radius: designElements.radius
		visible: !dimState
	}

	MouseArea {
		id: mouseArea
		anchors.fill: parent

		property int pressAndHoldDuration: 550
		property bool isLongPress: false

		function longPressed() {
			// Create object that describes tile position relative to root document
			// and give result object knowledge of tile position on page (0..3)
			var tilePos = mapToItem(null,x,y);
			tilePos.page = page;
			tilePos.position = position;
			homeApp.removeTilePopup.tileInfo = widgetInfo;
			homeApp.removeTilePopup.tilePos = tilePos;
			homeApp.removeTilePopup.originalTile = widget;
			homeApp.removeTilePopup.show();
		}

		onPressed: {
			if (!pressAndHoldTimer.running) {
				isLongPress = false;
			}
		}

		onClicked: {
			if (!isLongPress)
				widget.clicked(mouse);
		}

		Timer {
			id:  pressAndHoldTimer
			interval: parent.pressAndHoldDuration
			running: mouseArea.pressed
			repeat: false
			onTriggered: {
				mouseArea.isLongPress = true;
				mouseArea.longPressed()
			}
		}
	}

	states: [
		State {
			name: "up"
		},
		State {
			name: "down"
			when: mouseArea.pressed
			PropertyChanges {
				target: background
				color: colors.tileBackgroundDown
			}
			PropertyChanges {
				target: widget
				explicit: true
				x: x + 2
				y: y + 2
			}
		}
	]
}
