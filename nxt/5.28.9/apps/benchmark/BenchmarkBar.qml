import QtQuick 2.1

Item {
	id: benchmarkBar

	property variant friends: []
	property alias currentBigBalloonColor: yourselfBalloon.colorizeColor
	property int percentileCount: 19
	// increase grid granularity by increasing gridFactor
	property int gridFactor: 5
	property int labelGridColumns: percentileCount * gridFactor
	property real slotPixels: width / labelGridColumns
	// Grid used to arrange labels on screen
	// will be set up in resetPercentileOccupancy()
	property variant percentileOccupancy: [[]]
	property int labelGridRows: 6
	property int yourselfPercentile
	property int rowHeight: Math.round(16 * verticalScaling)
	property int percentileWidth: benchmarkBar.width / (percentileCount + 1)

	signal friendClicked

	QtObject {
		id: p

		property bool currentDimState: false
		property color yourselfBalloonColor
	}

	width: Math.round(640 * horizontalScaling)
	height: yourselfBalloon.height + yourselfBalloon.anchors.bottomMargin + benchmarkBarImage.height

	function getXForPercentile(percentile) {
		return (percentile + 1) * percentileWidth;
	}

	function setYourselfBalloon(usage, percentile) {
		yourselfBalloon.usage = usage;
		yourselfBalloon.anchors.horizontalCenterOffset = getXForPercentile(percentile);
		p.yourselfBalloonColor = colors.percentileColors[percentile];
		yourselfBalloon.colorizeColor = (p.currentDimState ? colors.yourselfBalloonDim : p.yourselfBalloonColor).toString();
		resetPercentileOccupancy();
		claimYourselfLabelSpace(percentile);
		yourselfPercentile = percentile;
	}

	function resetPercentileOccupancy() {
		var po = new Array(labelGridColumns);
		for (var i = 0; i < labelGridColumns; i++) {
			po[i] = new Array(labelGridRows);
		}
		percentileOccupancy = po;
	}

	function claimYourselfLabelSpace(percentile) {
		var horizontalGridPosition = percentile * gridFactor;
		var percentileRadius = Math.ceil(yourselfBalloon.width / slotPixels / 2);
		var po = percentileOccupancy;
		for (var i = 0; i < 3; i++) {
			po[horizontalGridPosition][i] = 1;
			for (var j = 1; j < percentileRadius; j++) {
				if (horizontalGridPosition + j < labelGridColumns)
					po[horizontalGridPosition + j][i] = 1;
				if (j <= horizontalGridPosition)
					po[horizontalGridPosition - j][i] = 1;
			}
		}
		percentileOccupancy = po;

		// stringify to debug
//		for (i = 0; i < labelGridRows; i++) {
//			var debugString = "";
//			for (j = 0; j < labelGridColumns; j++) {
//				debugString += po[j][i] ? po[j][i] : 0;
//			}
//			console.debug(debugString);
//		}
	}

	function findSpaceOnTopOfYourself(bal, percentile, index) {
		var horizontalGridPosition = percentile * gridFactor;
		var percentileRadius = Math.ceil(bal.textWidth / slotPixels / 2);
		var foundSpace = true;
		var po = percentileOccupancy;
		for (var i = 0; i < 3; i++) {
			foundSpace = true;
			if (po[horizontalGridPosition][3 + i]) {
				foundSpace = false;
			}
			if (foundSpace) {
				for (var j = 1; j <= percentileRadius; j++) {
					if ((horizontalGridPosition + j < labelGridColumns && po[horizontalGridPosition + j][3 + i]) ||
							(j <= horizontalGridPosition && po[horizontalGridPosition - j][3 + i])) {
						foundSpace = false;
						break;
					}
				}
			}
			if (foundSpace)
				break;
		}
		if (foundSpace) {
			po[horizontalGridPosition][3 + i] = index;
			for (var k = 1; k <= percentileRadius; k++) {
				if (horizontalGridPosition + k < labelGridColumns)
					po[horizontalGridPosition + k][3 + i] = index;
				if (k <= horizontalGridPosition)
					po[horizontalGridPosition - k][3 + i] = index;
			}
			bal.setTextVerticalOffset((3 + i) * rowHeight);
			bal.setTextHorizontalCenter();
			percentileOccupancy = po;
		}
	}

	function findSpaceLeftOfYourself(bal, percentile, index) {
		var horizontalGridPosition = (yourselfPercentile - 1) * gridFactor;
		var percentileWidth = Math.ceil(bal.textWidth / slotPixels);
		var po = percentileOccupancy;
		var foundSpace = true;
		for (var row = 0; row < labelGridRows; row++) {
			foundSpace = true;
			for (var i = 0; i < percentileWidth; i++) {
				if (i <= horizontalGridPosition && po[horizontalGridPosition - i][row]) {
					foundSpace = false;
					break;
				}
			}
			if (foundSpace)
				break;
		}
		for (i = 0; i < percentileWidth; i++) {
			if (i <= horizontalGridPosition)
				po[horizontalGridPosition - i][row] = index;
		}
		percentileOccupancy = po;
		bal.setTextVerticalOffset(row * rowHeight);
		bal.setTextLeft(getXForPercentile(yourselfPercentile - 1));
	}

	function findSpaceRightOfYourself(bal, percentile, index) {
		var horizontalGridPosition = (yourselfPercentile + 1) * gridFactor;
		var percentileWidth = Math.ceil(bal.textWidth / slotPixels);
		var po = percentileOccupancy;
		var foundSpace = true;
		for (var i = 0; i < labelGridRows; i++) {
			foundSpace = true;
			for (var j = 0; j < percentileWidth; j++) {
				if (horizontalGridPosition + j < labelGridColumns && po[horizontalGridPosition + j][i]) {
					foundSpace = false;
					break;
				}
			}
			if (foundSpace)
				break;
		}
		for (j = 0; j < percentileWidth; j++) {
			if (horizontalGridPosition + j < labelGridColumns)
				po[horizontalGridPosition + j][i] = index;
		}
		percentileOccupancy = po;
		bal.setTextVerticalOffset(i * rowHeight);
		bal.setTextRight(getXForPercentile(yourselfPercentile + 1));
	}

	function claimFriendLabelSpace(bal, percentile, index) {
		var horizontalGridPosition = percentile * gridFactor;

		// calculate dimensions of label
		var percentileRadius = Math.ceil(bal.textWidth / slotPixels / 2);

		// search a free space in labelGridX x labelGridY array
		var free;
		var i = 1;
		var labelRow = 0;
		var conflictSamePosition;
		var conflictLeft;
		var conflictRight;
		for (; labelRow < labelGridRows; labelRow++) {
			conflictSamePosition = 0;
			conflictLeft = 0;
			conflictRight = 0;
			free = true;
			if (percentileOccupancy[horizontalGridPosition][labelRow]) {
				conflictSamePosition = percentileOccupancy[horizontalGridPosition][labelRow];
				free = false;
			}
			if (free) {
				for (; i <= percentileRadius; i++) {
					if (i <= horizontalGridPosition && percentileOccupancy[horizontalGridPosition - i][labelRow]) {
						conflictLeft = percentileOccupancy[horizontalGridPosition - i][labelRow];
						free = false;
						break;
					}
					if ((i + horizontalGridPosition) < labelGridColumns && percentileOccupancy[horizontalGridPosition + i][labelRow]) {
						conflictRight = percentileOccupancy[horizontalGridPosition + i][labelRow];
						free = false;
						break;
					}
				}
			}
			if (free || conflictLeft === 1 || conflictRight === 1 || conflictSamePosition === 1)
				break;
		}		
		if (free) {
			// if free space was found, reserve space by putting the balloon index
			var po = percentileOccupancy;
			po[horizontalGridPosition][labelRow] = index;
			for (i = 1; i <= percentileRadius; i++) {
				if (horizontalGridPosition + i < labelGridColumns)
					po[horizontalGridPosition + i][labelRow] = index;
				if (i <= horizontalGridPosition)
					po[horizontalGridPosition - i][labelRow] = index;
			}
			bal.setTextVerticalOffset(labelRow * rowHeight);
			bal.setTextHorizontalCenter();
			percentileOccupancy = po;
		} else {
			// conflict with YourselfBalloon
			if (conflictSamePosition) {
				findSpaceOnTopOfYourself(bal, percentile, index);
			} else if (conflictLeft) {
				findSpaceRightOfYourself(bal, percentile, index);
			} else if (conflictRight) {
				findSpaceLeftOfYourself(bal, percentile, index);
			} else {
				console.debug("COULDN'T FIND A SPOT AT ALL for balloon with index " + index);
			}
		}

		// stringify to debug
//		for (i = 0; i < labelGridRows; i++) {
//			var debugString = "";
//			for (var j = 0; j < labelGridColumns; j++) {
//				debugString += percentileOccupancy[j][i] ? percentileOccupancy[j][i] : 0;
//			}
//			console.debug(debugString);
//		}
	}

	function dim (dimState) {
		if (state == "TILE_NORESULT" || state == "TILE_YOURSELF" || state == "TILE_FRIENDS") {
			p.currentDimState = dimState;
			if (dimState) {
				benchmarkBarImage.source = "image://scaled/apps/benchmark/drawables/TileBenchmarkBarDim.svg";
				yourselfBalloon.colorizeColor = "dim";
			} else {
				benchmarkBarImage.source = "image://scaled/apps/benchmark/drawables/TileBenchmarkBar.svg";
				yourselfBalloon.colorizeColor = p.yourselfBalloonColor.toString();
			}
		}
	}

	function displayFriendsSummarised(newFriends) {
		var balloon = friendsRepeater.itemAt(0);
		balloon.name = qsTr("Four friends");
		balloon.setTextHorizontalCenter();
		balloon.setTextVerticalOffset(3 * rowHeight);
		balloon.x = getXForPercentile(newFriends[0].percentile) - balloon.width/2;
		for (var i = 1; i < 4; i++) {
			balloon = friendsRepeater.itemAt(i);
			balloon.visible = false;
		}
		friends = newFriends;
	}

	function setFriends(newFriends) {
		for (var i = 0; i < 4; i++) {
			var balloon = friendsRepeater.itemAt(i);

			if (i < newFriends.length)  {
				var compareFriend = newFriends[i];

				var visible = balloon.visible = compareFriend.percentile !== "NaN";
				if (visible) {
					if (state != "TILE_FRIENDS")
						balloon.name = compareFriend.friend.name;
					balloon.x = getXForPercentile(compareFriend.percentile) - balloon.width/2;
					if (state === "FRIENDS")
						claimFriendLabelSpace(balloon, compareFriend.percentile, i + 2);
				}
			} else
				balloon.visible = false;
		}
		friends = newFriends;
	}

	BenchmarkSmallBalloon {
		id: leafBalloon
		anchors {
			bottom: benchmarkBarImage.top
			bottomMargin: designElements.vMargin5
			horizontalCenter: benchmarkBar.left
			horizontalCenterOffset: Math.round(128 * horizontalScaling)
		}
		imageSource: "drawables/leafFilled.svg"
		visible: false
	}

	BenchmarkSmallBalloon {
		id: averageBalloon
		anchors {
			bottom: benchmarkBarImage.top
			bottomMargin: designElements.vMargin5
			horizontalCenter: benchmarkBar.horizontalCenter
		}
		imageSource: "drawables/averageFilled.svg"
		visible: false

		onClicked: friendClicked()
	}

	BenchmarkBigBalloon {
		id: yourselfBalloon
		anchors {
			bottom: benchmarkBarImage.top
			bottomMargin: designElements.vMargin5
			horizontalCenter: benchmarkBar.left
		}

		onClicked: friendClicked()
	}

	Image {
		id: benchmarkBarImage
		anchors.bottom: parent.bottom
		width: parent.width
		// Height is scaled automatically from the implicit size of the SVG.
		sourceSize.width: parent.width
		source: "image://scaled/apps/benchmark/drawables/bigbenchmark.svg"
	}


	Rectangle {
		id: averageDot
		anchors {
			verticalCenter: benchmarkBarImage.verticalCenter
			horizontalCenter: benchmarkBarImage.horizontalCenter
		}
		width: height
		height: Math.round(6 * verticalScaling)
		radius: height / 2
		color: dimmableColors.background
		visible: false
	}

	Rectangle {
		id: yourselfDot
		anchors {
			verticalCenter: benchmarkBarImage.verticalCenter
			horizontalCenter: yourselfBalloon.horizontalCenter
		}
		width: height
		height: Math.round(10 * verticalScaling)
		radius: height / 2
		color: dimmableColors.background
		visible: false
	}

	Rectangle {
		id: dotConnector
		height: Math.round(2 * verticalScaling)
		anchors {
			verticalCenter: benchmarkBarImage.verticalCenter
			left: yourselfDot.horizontalCenter
			right: averageDot.horizontalCenter
		}
		color: dimmableColors.background
		visible: false
	}

	Item {
		id: friendsContainer
		anchors {
			bottom: benchmarkBarImage.top
			bottomMargin: designElements.vMargin5
		}
		width: benchmarkBarImage.width
		height: Math.round(62 * verticalScaling)
		visible: false

		Repeater {
			id: friendsRepeater
			model: 4

			BenchmarkSmallBalloon {
				anchors.bottom: parent.bottom
				imageSource: benchmarkBar.state == "TILE_FRIENDS" ? "drawables/TileBenchmarkLittleBaloon.svg" : "drawables/blueballoon.svg"
				colorize: p.currentDimState
				colorizeColor: "white"

				onClicked: friendClicked()
			}
		}
	}

	// uncomment this to see some mark on the bar for possible balloon positions
//	Item {
//		id: markContainer

//		height: Math.round(2 * verticalScaling)
//		width: benchmarkBarImage.width
//		anchors.top: benchmarkBarImage.top

//		Repeater {
//			id: markRepeater

//			model: 19

//			Rectangle {
//				anchors.bottom: parent.bottom
//				width: Math.round(4 * horizontalScaling)
//				height: Math.round(4 * verticalScaling)
//				radius: 2
//				Text {
//					id: markName
//					text: index
//					anchors.horizontalCenter: parent.horizontalCenter
//					anchors.top: parent.bottom
//					color: "white"
//				}
//			}
//		}
//		Component.onCompleted: {
//			for (var i = 0; i < 19; i++) {
//				markRepeater.itemAt(i).x = getXForPercentile(i) - 2;
//			}
//		}
//	}

	state: "TILE_NORESULT"
	states: [
		State {
			name: "YOURSELF"
			PropertyChanges { target: leafBalloon; visible: true }
			PropertyChanges { target: averageBalloon; visible: true }
			PropertyChanges { target: yourselfBalloon; visible: true; nameFont.family: qfont.light.name }
		},
		State {
			name: "FRIENDS"
			PropertyChanges { target: friendsContainer; visible: true }
			PropertyChanges { target: yourselfBalloon; visible: true; usage: "" }
		},
		State {
			name: "NORESULT"
			PropertyChanges { target: yourselfBalloon; visible: false }
		},
		State {
			name: "TILE_NORESULT"
			PropertyChanges {
				target: benchmarkBarImage
				source: "image://scaled/apps/benchmark/drawables/TileBenchmarkBar" + (p.currentDimState  ? "Dim" : "") +".svg"
			}
			PropertyChanges { target: yourselfBalloon; visible: false }
		},
		State {
			name: "TILE_YOURSELF"
			PropertyChanges {
				target: benchmarkBarImage
				source: "image://scaled/apps/benchmark/drawables/TileBenchmarkBar" + (p.currentDimState  ? "Dim" : "") +".svg"
			}
			PropertyChanges {
				target: averageBalloon
				visible: true
				imageSource: "drawables/TileAverageBalloon" + (p.currentDimState ? "_dim" : "") + ".svg"
				anchors.bottomMargin: 0
			}
			PropertyChanges { target: averageDot; visible: true }
			PropertyChanges { target: yourselfDot; visible: true }
			PropertyChanges { target: dotConnector; visible: true }
			PropertyChanges {
				target: yourselfBalloon
				visible: true
				name: ""
				imageSource: "drawables/TileYourselfBalloon.svg"
				anchors.bottomMargin: 0
			}
		},
		State {
			name: "TILE_FRIENDS"
			PropertyChanges {
				target: benchmarkBarImage;
				source: "image://scaled/apps/benchmark/drawables/TileBenchmarkBar" + (p.currentDimState  ? "Dim" : "") +".svg"
			}
			PropertyChanges { target: friendsContainer; visible: true; anchors.bottomMargin: 0 }
			PropertyChanges {
				target: yourselfBalloon
				visible: true
				name: ""
				imageSource: "drawables/TileYourselfBalloon.svg"
				anchors.bottomMargin: 0
			}
			PropertyChanges { target: yourselfDot; visible: true }
		}
	]
}
