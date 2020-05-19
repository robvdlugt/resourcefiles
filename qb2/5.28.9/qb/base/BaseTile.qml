import QtQuick 2.1

import qb.base 1.0

/**
 * Provides the base functionality for several types of Tile, but no layout.
 * Application Tiles should normally override Tile, not BaseTile
 */
Widget {
	id: widget;

	/// Page this Tile is placed on
	property int page : 0
	/// Position in the page this Tile is placed on
	property int position : 0
	/// Reference to the homeApp instance for internal use.
	property App homeApp

	/// Signal that will be triggered when the page is changed so that the Tile became visible or invisible
	signal pageChange(int page);

	width: Math.round(230 * horizontalScaling)
	height: Math.round(158 * verticalScaling)

	function init() {
		console.debug("stub init for tile " + widgetInfo.url);
	}

	/// Removes the Tile
	function removeTile() {
		homeApp.homeScreen.removeTile(page, position);
	}
}
