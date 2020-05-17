import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Popup {
	id: removeTileArea
	objectName: "rmTileArea"

	property Tile tile
	property Tile originalTile
	property variant tileInfo
	property variant tilePos
	property string kpiPrefix: "removeTilePopup."

	onHidden: tile.destroy();

	onVisibleChanged: {
		// Create tile object
		var xShift = 0;
		var yShift = 0;
		if(visible) {
			tile = util.loadComponent(tileInfo.url, removeTileArea, {app: originalTile.app, x: tilePos.x - 1, y: tilePos.y - 1, width: originalTile.width, height: originalTile.height});
			tile.initWidget(tileInfo);
			removeButton.anchors.top = tile.top;
			removeButton.anchors.topMargin = -5;
			removeButton.anchors.horizontalCenter = (screenStateController.prominentWidgetLeft ? tile.left : tile.right);
		}
	}

	function hideRemovePopup() {
		// remove tile from app config
		tile.app.widgetUninstantiated(tile);
		hide();
	}

	MouseArea {
		id: cancelArea

		// Fills whole area (tile and green leave button included)
		z: 1
		anchors.fill: parent
		property string kpiPostfix: "cancelRemove"

		onClicked: {
			hideRemovePopup();
		}
	}

	// Non-clickable transparent masked area
	Rectangle {
		id: maskedArea
		color: colors.dialogMaskedArea
		opacity: 0.35
		anchors.fill: parent
	}

	// Remove tile button
	Item {
		id: removeButton
		width: Math.round(76 * horizontalScaling)
		height: Math.round(56 * verticalScaling)

		z: 1

		Rectangle {
			id: removebackground
			width: Math.round(36 * horizontalScaling)
			height: width

			radius: width / 2
			color: colors.tileBackground
			anchors.centerIn: parent

			Rectangle {
				id: removeColor
				width: parent.width-2
				height: width

				anchors.centerIn: parent
				radius: width / 2
				color: colors.removeTileConfirm

				Image {
					id: removeImage
					source: "image://scaled/apps/homescreen/drawables/delete-tile.svg"
					anchors.centerIn: parent
				}
			}
		}

		MouseArea {
			id: removeArea
			property string kpiPostfix: "remove"
			anchors.fill: parent
			onClicked: {
				// Code for home remove tile method
				app.homeScreen.removeTile(originalTile.page, originalTile.position);
				originalTile.app.widgetUninstantiated(originalTile);
				hideRemovePopup();
			}
		}
	}

	// Leave tile button (does not need to have MouseArea)
	Item {
		id: okButton
		width: Math.round(36 * horizontalScaling)
		height: width

		z: 1

		anchors.bottom: removeButton.bottom
		anchors.bottomMargin: Math.round(-43 * verticalScaling)
		anchors.horizontalCenter: removeButton.horizontalCenter

		Rectangle {
			id: okBackground
			width: Math.round(36 * horizontalScaling)
			height: width

			radius: width / 2
			color: colors.tileBackground

			Rectangle {
				id: okColor
				width: parent.width - 2
				height: width

				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter: parent.horizontalCenter
				radius: width / 2
				color: colors.removeTileCancel

				Image {
					id: okImage
					source: "image://scaled/apps/homescreen/drawables/ok-tile.svg"
					anchors.centerIn: parent
				}
			}
		}
	}
}
