import QtQuick 2.1

import qb.base 1.0

import "ThumbnailObjs.js" as ThumbnailObjsJS

Item {
	id: thumbnailCategory

	// Tile button is 64 pixels (scaled), 54 pixels are reserved for spacing and the text on the bottom
	height: Math.round((64 + 54) * verticalScaling) * rowCount
	// Use parent width if available. (During initialization of this component, the parent is not set
	// yet, so binding directly to parent.width used to generate a warning. This prevents that warning.)
	width: parent !== null ? parent.width : (700 * horizontalScaling)


	property App app
	property Util util: Util{}

	property string type: ""
	property int weight: 0
	property alias labelText: label.text

	property int thumbnailCount: 0
	property int rowCount: Math.ceil(thumbnailCount/6)

	property url thumbnailUrl: "TileThumbnail.qml"
	property alias thumbnailContainerChildren: thumbnailContainer.children

	property Item container

	QtObject {
		id: p
		property bool bottomClipped: (y >= container.contentY) && (y < (container.contentY + container.height)) && ((y + height) > (container.contentY + container.height))
	}


	property int page: 0

	// Create new thumbnail and add it to flow
	function addNewThumbnail(tileWidgetInfo) {
		var thumbnailObj = util.loadComponent(thumbnailUrl, thumbnailContainer, {tileWidgetInfo: tileWidgetInfo, app:app});

		if (!thumbnailObj) {
			console.log("Failed to create thumbnail!");
			return false;
		}
		else {
			util.insertItem(thumbnailObj, thumbnailContainer, "thumbWeight");
			ThumbnailObjsJS.thumbnailObjsByWidget[tileWidgetInfo.uid] = thumbnailObj;
			thumbnailCount += 1;
			return true;
		}
	}

	// Removes the thumbnail attached to the given uid
	function removeThumbnail(uid) {
		var obj = ThumbnailObjsJS.thumbnailObjsByWidget[uid];
		util.removeItem(thumbnailContainer, obj);
		ThumbnailObjsJS.thumbnailObjsByWidget[uid] = undefined;
		thumbnailCount -= 1;
	}

	// Checks if the category contains a widget with the given uid
	function containsThumbnail(uid) {
		if (ThumbnailObjsJS.thumbnailObjsByWidget[uid])
			return true;
		return false;
	}

	// Place given thumbnails at begining of flow
	function placeThumbnailRowAtBeginning(thumbnails) {
		for(var i = 0; i < thumbnails.length; i++) {
			util.insertItemAt(thumbnails[i], thumbnailContainer, 0);
			thumbnails[i].visible = true;
			thumbnailCount += 1;
		}
	}

	// Place given thumbnails at end of flow
	function placeThumbnailRowAtEnd(thumbnails) {
		for(var i = thumbnails.length - 1; i >= 0; i--) {
			thumbnails[i].parent = thumbnailContainer;
			thumbnails[i].visible = true;
			thumbnailCount += 1;
		}
	}

	// Get first row of thumbnails from flow
	function getFirstRowThumbnails() {
		var thumbnails = [];
		for (var i = 0; i < 6 && thumbnailContainer.children.length; i++) {
			var firstThumbnail = thumbnailContainer.children[0];
			firstThumbnail.visible = false;
			firstThumbnail.parent = null;
			thumbnails.push(firstThumbnail);
			thumbnailCount -= 1;
		}
		return thumbnails;
	}

	// Get last row of thumbnails from flow
	function getLastRowThumbnails() {
		var thumbnails = [];
		var targetThumbnailCount = 6 * (rowCount - 1);
		while (thumbnailCount != targetThumbnailCount) {
			var lastThumbnail = thumbnailContainer.children[thumbnailCount-1];
			lastThumbnail.parent = null;
			thumbnailCount -= 1;
			thumbnails.push(lastThumbnail);
		}
		return thumbnails;
	}

	Flow {
		id: thumbnailContainer

		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.left: label.right
		anchors.right: parent.right
	}

	Text {
		id:label

		width: Math.round(95 * horizontalScaling)

		anchors.bottom: horizontalLine.bottom
		anchors.bottomMargin: Math.round(7 * verticalScaling)
		anchors.left: parent.left

		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignLeft
		wrapMode: Text.WordWrap

		font.pixelSize: qfont.bodyText
		font.family: qfont.bold.name

		color: colors.thumbnailCategoryLabel
	}

	Rectangle{
		id: horizontalLine

		height: Math.round(1 * verticalScaling)
		width: parent.width

		anchors.bottom: parent.bottom

		states: State {
			name: "bottomClipped"
			when: p.bottomClipped
			AnchorChanges {
				target: horizontalLine
				anchors.bottom: undefined
			}
			PropertyChanges {
				target: horizontalLine
				y: container.contentY + container.height - parent.y - height
			}
		}

		opacity: 0.2
		color: colors.thumbnailCategoryHorizontalLine
	}
}
