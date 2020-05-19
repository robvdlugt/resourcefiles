import QtQuick 2.1

import qb.base 1.0

/**
 * A component that represents a tile that enables user to add tiles to page
 *
 * A tile is a clickable element that exist as default tile in
 * each new home screen page
 * Clicking it opens tile selection screen that allow user to select tile
 * to be placed instead of this placeholder.
 */
BaseTile {
	id: emptyTile

	///Differentiate from normal tiles in search for first empty one
	property bool isEmptyTile: true
	property string kpiId: "EmptyTile.qml"

	function init() {
	}

	Rectangle {
		id: background
		anchors.fill: parent
		color: colors.emptyTileBackground
		radius: designElements.radius
		visible: !dimState

		Column {
			anchors.centerIn: parent

			Image {
				id: iconImage
				anchors.horizontalCenter: parent.horizontalCenter
				source: "image://scaled/apps/homescreen/drawables/add-tile.svg"
			}

			Text {
				id: text
				anchors.horizontalCenter : parent.horizontalCenter
				color: colors._fantasia
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				text: qsTr("Voeg tegel toe")
			}
		}

		MouseArea {
			anchors.fill: parent
			onClicked: {
				homeApp.chooseTileScreen.tilePage = page;
				homeApp.chooseTileScreen.tilePos = position;
				// After adding a tile, return the user to the page where this empty tile was.
				homeApp.homeScreen.restorePage = page;
				homeApp.chooseTileScreen.show();
			}
		}
	}
}
