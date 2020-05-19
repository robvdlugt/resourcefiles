import QtQuick 2.1
import qb.components 1.0

Tile {
	
	QtObject {
		id: p

		function redraw() {
			if (!app.powerUsageDataRead)
				return;
			if (parseInt(app.powerUsageData.valueSolar) === 0) {
				consumption.source = "image://scaled/apps/graph/drawables/HouseNoProduction" + (dimState ? "Dim" : "") + ".svg"
				production.width = 0;
			} else {
				consumption.source = "image://scaled/apps/graph/drawables/HouseProduction" + (dimState ? "Dim" : "") + ".svg"
				var ratio = Math.min(app.powerUsageData.valueSolar / (parseInt(app.powerUsageData.value) === 0 ? 1 : app.powerUsageData.value), 1);
				// this value is the number of pixels from the left at which the house in the image starts
				// change if icon changes!
				var houseOffset = Math.round(13 * horizontalScaling)
				production.width = houseOffset + ((yellowHouse.width -  houseOffset) * ratio);
			}
		}
	}

	function init() {
		if (app.powerUsageDataRead)
			p.redraw();
		app.powerUsageDataChanged.connect(p.redraw);
	}

	Component.onDestruction: {
		app.powerUsageDataChanged.disconnect(p.redraw);
	}

	onClicked: {
		stage.openFullscreen(app.graphScreenUrl, {agreementType: 'electricity', unitType: "energy", intervalType: "hours", consumption: true, production: true})
	}
	onDimStateChanged: {
		if (app.powerUsageDataRead)
			p.redraw();
	}

	Text {
		id: tileTitle
		color: dimmableColors.tileTitleColor
		text: qsTr("Usage now")
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.tileTitle
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignTop
		font.family: qfont.regular.name
	}

	Image {
		id: consumption
		source: "image://scaled/apps/graph/drawables/HouseNoProduction.svg"
		anchors {
			left: parent.left
			leftMargin: Math.round(83 * horizontalScaling)
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
		}
	}

	Item {
		id: production
		anchors.left: consumption.left
		anchors.bottom: consumption.bottom
		width: 0
		clip: true
		height: consumption.height
		Image {
			id: yellowHouse
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			source: "image://scaled/apps/graph/drawables/HouseFullProduction" + (dimState ? "Dim" : "") + ".svg"
		}
	}

	Text {
		id: tileText
		text: isNaN(app.powerUsageData.value) ? "-" : qsTr("%1 Watt").arg(app.powerUsageData.value)
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignRight
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
		color: dimmableColors.tileTextColor
	}
}
