import QtQuick 2.1
//import qb.base 1.0
import qb.components 1.0

Tile {
	id: clockTile

	/// Will be called when widget instantiated
	function init() {}

	onClicked: {
		stage.openFullscreen(app.fullScreenUrl);
	}

	Text {
		id: txtTimeBig
		text: app.timeStr
		color: dimmableColors.clockTileColor
		anchors.centerIn: parent
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: dimState ? qfont.clockFaceText : qfont.timeAndTemperatureText
		font.family: qfont.regular.name
	}

	Text {
		id: txtDate
		text: app.dateStr
		color: dimmableColors.clockTileColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		horizontalAlignment: Text.AlignHCenter
		font.pixelSize: qfont.tileTitle
		font.family: qfont.regular.name
		visible: !dimState
	}
}
