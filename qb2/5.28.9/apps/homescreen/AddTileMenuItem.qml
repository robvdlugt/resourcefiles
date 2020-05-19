import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

MenuItem {
	property HomescreenApp app
	label: qsTr("Tegel toevoegen")
	image: "drawables/add-tile.svg"
	weight: 1000
	objectName: "addTileMenuItem"

	onClicked: {
		if (app && app.homeScreen && app.chooseTileScreen) {
			var emptyPos = app.homeScreen.getFirstEmptyTilePos();
			app.chooseTileScreen.tilePage = emptyPos[0];
			app.chooseTileScreen.tilePos = emptyPos[1];
			app.chooseTileScreen.show();
		}
	}
}
