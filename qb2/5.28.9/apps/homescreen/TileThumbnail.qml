import QtQuick 2.1

import qb.base 1.0

/**
 * A stub that represents a tile thumbnail
 **/

Item {
	id: tileThumbnail

	property App app

	property string kpiPostfix: tileWidgetInfo.url.toString().split("/").pop()
	property url tileUrl: tileWidgetInfo.url
	property string tileName: ""
	property variant tileWidgetInfo
	property int thumbWeight: tileWidgetInfo ? (tileWidgetInfo.args.thumbWeight ? tileWidgetInfo.args.thumbWeight : 1000) : 1000
	property url captionUrl: "TileThumbnailCaption.qml"

	property alias labelText: label.text
	property alias iconSource: icon.source

	function init() {
		console.debug("stub init for TileThumbnail " + widgetInfo.url);
	}

	property int iconWidth:  Math.round(88 * horizontalScaling)
	property int iconHeight: Math.round(64 * verticalScaling)

	/*
	* 88px icon width
	* 10px horizontal spacing
	*/
	width: iconWidth + Math.round(10 * horizontalScaling)

	/* 21px top vertical spacing
	*  64px icon height
	*  2px  shadow
	*  19px text offset
	*  12px bottom vertical spacing
	*/
	height: iconHeight + Math.round((2 + 19 + 12 + 21) * verticalScaling)

	Component.onCompleted: {
		if (tileWidgetInfo.args.thumbIconVAlignment === "center") {
			icon.anchors.bottom = undefined;
			icon.anchors.verticalCenter = background.verticalCenter;
		}
		if (tileWidgetInfo.args.thumbCaption) {
			captionLoader.source = captionUrl;
		}
	}

	Rectangle {
		id: background
		width: iconWidth
		height: iconHeight
		color: colors.background
		radius: designElements.radius
		anchors.top: parent.top
		anchors.topMargin: Math.round(21 * verticalScaling)
		anchors.horizontalCenter: parent.horizontalCenter

		Loader {
			id: captionLoader
			anchors {
				bottom: icon.top
				horizontalCenter: parent.horizontalCenter
			}
		}

		Image {
			id: icon
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: designElements.vMargin10
			}
			fillMode: Image.PreserveAspectFit
			source: "image://scaled" + qtUtils.urlPath(tileWidgetInfo.args.thumbIcon)
		}
	}

	Text {
		id: label

		width: iconWidth

		anchors.bottom: parent.bottom
		anchors.bottomMargin: Math.round(7 * verticalScaling)
		anchors.horizontalCenter: parent.horizontalCenter

		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignBottom

		color: colors.thumbnailLabel
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
		text: tileWidgetInfo.args.thumbLabel
		textFormat: Text.PlainText // Prevent XSS/HTML injection
	}

	MouseArea {
		id: mouseArea
		anchors {
			top: parent.top
			topMargin: Math.round(11 * verticalScaling)
			left: parent.left
			right: parent.right
			bottom: parent.bottom
			bottomMargin: Math.round(3 * verticalScaling)
		}

		onClicked: {
			app.homeScreen.createTile(tileWidgetInfo, app.chooseTileScreen.tilePage, app.chooseTileScreen.tilePos);
			app.homeScreen.navigatePageFromThumbnail(app.chooseTileScreen.tilePage);
			// Clear navigation stack (except bottom Homescreen), so that after adding a tile,
			// the user returns to the Homescreen.
			stage.clearNavigationStack(1);
			app.chooseTileScreen.hide();
		}
	}
}
