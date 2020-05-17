import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Tile {
	id: benchmarkbaseTile

	property alias headTextContent: headText.text
	property alias bottomTextContent: bottomText.text
	property string type: ""
	property string unit: ""
	property bool compareToFriends: false

	/// Will be called when widget instantiated
	function init() {
		app.newDataAvailable.connect(updateTile);
		benchmarkBar.friendClicked.connect(openBenchmarkScreen);
		if (app.benchmarkDataRead) updateTile();
	}

	Component.onDestruction: {
		app.newDataAvailable.disconnect(updateTile);
		benchmarkBar.friendClicked.disconnect(openBenchmarkScreen);
	}

	/// Function updates the tile using the given type
	function updateTile() {
		var percentile = "";
		var averageUsage = "";
		var usage = "";
		var lastSampleTime = "";

		// update data from dataset if available
		if (app.benchmarkData[type]) {
			var dataIndex = 0;
			var data = app.benchmarkData[type]["day"];
			if(data) {
				lastSampleTime = data["lastSampleT"]*1000;

				dataIndex = calculateDataIndex(lastSampleTime);

				if (dataIndex >= 0 && dataIndex < data["percentiles"].length) {
					percentile = data["percentiles"][dataIndex];
					averageUsage = data["avgUsages"][dataIndex]/1000;
					usage = data["usages"][dataIndex]/1000;
				} else {
					percentile = averageUsage = usage = "NaN";
				}
			}
		} else {
			lastSampleTime = "";
		}

		// Update tile visuals
		if (!app.benchmarkInfo.wizardDone) {
			tileContent.state = "noProfile"
		} else if (lastSampleTime === "") {
			tileContent.state = "notEnoughData";
		} else if (percentile === "NaN" || averageUsage === "NaN" || usage === "NaN") {
			tileContent.state = "noResults";
		} else {
			if (compareToFriends) {
				tileContent.state = "compareToFriends";
				updateFriends(percentile);
			} else {
				tileContent.state = "compareToAverage";

				// Update the tile bottomText
				setBottomText(app.determineSummaryText(percentile), usage, averageUsage);

				// Update the yourselfBalloon on the benchmarkBar
				benchmarkBar.setYourselfBalloon("", app.getBarPercentile(percentile));
			}
		}
	}

	function calculateDataIndex(lastSampleTime) {
		var periodStartDate = new Date();
		var lastSampleDate = new Date(lastSampleTime);

		// Tile is filled with date of yesterday
		periodStartDate.setDate(periodStartDate.getDate() - 1);
		periodStartDate.setHours(0, 0, 0, 0);

		// lastSampleT is current date set always at midnight, but data is from yesterday so set one day back
		lastSampleDate.setHours(-12);

		if ( periodStartDate.getTime() > lastSampleDate.getTime() ) {
			return -1;
		} else {
			// Calculate the index of one day
			return Math.floor((lastSampleDate.getTime()-periodStartDate.getTime())/86400000 /*1000*60*60*24*/ );
		}
	}

	function updateFriends(percentile) {
		var friends = [];

		var ownPercentile = app.getBarPercentile(percentile);
		var amMostEconomical = true;
		var amLeastEconomical = true;

		for (var i = 0; i < app.benchmarkFriends.length; ++i) {
			// Update friends in benchmarkBar
			var friend = app.benchmarkFriends[i];
			if (friend.compareActive === "1") {
				var friendMissing = true;
				var typeData = friend.usage[type];

				if (typeData) {
					var data = typeData["day"];
					if (data) {
						var compareFriend = {friend: friend};
						var friendLastSampleT = data.lastSampleT * 1000;
						var friendDataIndex = calculateDataIndex(friendLastSampleT);
						var percentiles = data.percentiles;
						compareFriend.percentile = (friendDataIndex < 0 || friendDataIndex >= percentiles.length || percentiles[friendDataIndex] === "NaN") ? "NaN" : app.getBarPercentile(percentiles[friendDataIndex]);

						if (compareFriend.percentile !== "NaN") {
							friends.push(compareFriend);
							if (amLeastEconomical && compareFriend.percentile > ownPercentile)
								amLeastEconomical = false;
							else  if (amMostEconomical && compareFriend.percentile < ownPercentile)
								amMostEconomical = false;
						}
					}
				}
			}
		}

		if (friends.length === 0) {
			tileContent.state = "noResults";
		} else {
			// Update the friends balloons on the benchmarkBar
			benchmarkBar.setFriends(friends);

			// Update the yourselfBalloon on the benchmarkBar
			benchmarkBar.setYourselfBalloon("", app.getBarPercentile(percentile));

			// Update the tile bottomText
			setBottomText(amLeastEconomical === amMostEconomical ? 0 : amLeastEconomical ? 1 : -1);
		}
	}

	function setBottomText(trend, usage, averageUsage) {
		var text = "";
		if (tileContent.state == "compareToFriends") {
			// no text for losers (is demotivating)
			text = (trend === -1 ? qsTr("Congratulations!") : "");
			bottomText.text = text;
		} else {
			if (unit) {
				var difference = usage - averageUsage;
				if (trend === 0) {
					text = qsTr("Equal");
				} else if (trend === 1) {
					text = i18n.number(Math.abs(difference), 1, i18n.omit_trail_zeros) + " " + unit + " " + qsTr("more");
				}else if (trend === -1) {
					text = i18n.number(Math.abs(difference), 1, i18n.omit_trail_zeros) + " " + unit + " " + qsTr("less");
				}
				bottomText.text = text;
			}
		}
	}

	function openBenchmarkScreen() {
		if (tileContent.state == "noProfile") {
			stage.openFullscreen(app.profileWelcomeScreenUrl);
		} else {
			stage.openFullscreen(app.benchmarkScreenUrl, {type: type, period:"day", date:(new Date()).getTime() - 86400000, showFriends: compareToFriends});
		}
	}

	onDimStateChanged: {
		benchmarkBar.dim(dimState);
	}

	onClicked: {
		openBenchmarkScreen();
	}

	Item {
		id: tileContent
		anchors.fill: parent

		Text {
			id: headText
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(30 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}

			font {
				family: qfont.regular.name
				pixelSize: qfont.tileTitle
			}
			color: dimmableColors.tileTitleColor
		}

		BenchmarkBar {
			id: benchmarkBar

			height: designElements.vMargin15

			anchors {
				left: parent.left
				leftMargin: Math.round(35 * horizontalScaling)
				right: parent.right
				rightMargin: Math.round(35 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: Math.round(41 * verticalScaling)
			}
		}

		Text {
			id: bottomText
			anchors {
				baseline: parent.bottom
				baselineOffset: Math.round(-16 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.tileText
			}
			color: dimmableColors.tileTextColor
		}

		Image {
			id: noProfileImage
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(41 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}
			source: "image://scaled/apps/benchmark/drawables/TileProfileBalloon" + (dimState ? "_dim": "") + ".svg"
			visible: false
		}

		state: "compareToAverage"
		states: [
			State {
				name: "compareToAverage"
				PropertyChanges { target: benchmarkBar; state: "TILE_YOURSELF"; }
			},
			State {
				name: "compareToFriends"
				PropertyChanges { target: benchmarkBar; state: "TILE_FRIENDS"; }
			},
			State {
				name: "noResults"
				PropertyChanges { target: benchmarkBar; state: "TILE_NORESULT"; }
				PropertyChanges { target: bottomText; text:qsTr("No results"); }
			},
			State {
				name: "notEnoughData"
				PropertyChanges { target: bottomText; text:qsTr("No results"); }
			},
			State {
				name: "noProfile"
				PropertyChanges { target: bottomText; text:qsTr("Fill your profile"); }
				PropertyChanges { target: benchmarkBar; visible: false; }
				PropertyChanges { target: noProfileImage; visible:true; }
			}
		]
	}
}
