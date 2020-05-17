import QtQuick 2.1
import BasicUIControls 1.0

Item {
	id: rootItem
	width: timeScale.width
	height: timeScale.height

	property int programWidth: 500

	readonly property int posAbove: 1
	readonly property int posHidden: 0
	readonly property int posBelow: -1

	property color scaleColor: colors.psTimeScale
	// design height of the program for day
	property int programDayHeight: isNxt ? 288 : 216
	// pixels between hour lines. Also used to calculate program block height in pixels based on start and end time
	property real pixelsPerHour: programDayHeight / 24
	// pixel count per 10 minutes == pixelsPerHour / 6. Program start/end time can be set in 10 minutes multiple
	property real pixelsPer10Minutes: pixelsPerHour / 6

	property bool timeEnabled: false

	onTimeEnabledChanged: {
		refresh();
	}

	Component.onCompleted: {
		refresh();
	}

	function refresh() {
		if (timeEnabled) {
			p.updateCurrentTimeLine();
			p.updateCurrentTimeInterval();
			currentTimeTimer.start();
		} else {
			currentTimeTimer.stop();
		}
		currentTime.visible = timeEnabled;
	}

	function populateModel(program) {
		p.populateTimeScaleModel(program);
	}

	QtObject {
		id: p

		//calculates program block height in pixels based on its duration (next program start minus this program start) in tens of minutes and pixels per tens of minute
		function getProgramHeightInPx(startTime, endTime) {
			return ((endTime - startTime) / 10) * pixelsPer10Minutes;
		}

		// calculates program block height for the last program of the day
		function getProgramHeightInPxTillEnd(startTime) {
			var heigthFromStart = getProgramHeightInPx(0, startTime);
			return height - heigthFromStart;
		}

		// updates current time line position - program height from the day start till "now"
		function updateCurrentTimeLine() {
			var now = new Date();
			currentTime.offset = p.getProgramHeightInPx(0, now.getHours() * 60 + now.getMinutes());
		}

		// updates current time line update timer interval to update at next tens of minutes
		function updateCurrentTimeInterval() {
			var now = new Date();
			currentTimeTimer.interval = ((Math.floor((now.getMinutes() + 10) / 10) * 10) - now.getMinutes()) * 60 * 1000;
		}

		// calculates program block start time in minutes from 0:00
		function getProgramStartInMinutes(programBlock) {
			var startMin = programBlock.startMinute !== undefined ? programBlock.startMinute : programBlock.startMin;
			return (programBlock.startHour * 60) + startMin;
		}

		// formats program start time in h:mm format for time scale. Program block with start hours and start minutes as input
		function formatTime(programBlock) {
			var startMin = programBlock.startMinute !== undefined ? programBlock.startMinute : programBlock.startMin;
			var m = startMin < 10 ? "0" + startMin : startMin;
			return programBlock.startHour + ":" + m;
		}

		// determins if the program block start time at index @idx of the day program @program shoudl be displayed below (default) or
		// above the line that indicates that time. see timeScale component description
		function getTimeTextPos(program, idx) {
			if (idx < 0 || idx >= program.length)
				return posHidden;

			var pos = posBelow;
			if (idx + 1 < program.length) {
				if (getProgramStartInMinutes(program[idx + 1]) - getProgramStartInMinutes(program[idx]) <= 60) {
					pos = posAbove;
				}
			}
			return pos;
		}

		function populateTimeScaleModel(program) {
			textModel.clear();

			//the first item in the day program is the last program block from the day before (can continue till today)
			for (var i = 1; i < program.length; i++) {
				var height = 0;
				var pos = posHidden;
				var posNext = posHidden;

				if (i === 1) {
					//if the first program block this day continues from the day before, create artifical item for this
					//block (0:00 till next block start == this block end), hide start time line
					height = getProgramHeightInPx(0, getProgramStartInMinutes(program[i]));
					pos = posHidden;
					posNext = getTimeTextPos(program, i);
					var firstItem = {
						"timeTextUpper": "",
						"timeTextBottom": posNext === posAbove ? formatTime(program[i]) : "",
						"programHeight": height,
						"upperVisible": pos === posBelow,
						"bottomVisible": posNext === posAbove,
						"startLineVisible": false
					};

					textModel.append(firstItem);
				}

				if (i + 1 < program.length) {
					height = getProgramHeightInPx(getProgramStartInMinutes(program[i]), getProgramStartInMinutes(program[i + 1]));
				}
				else {
					height = getProgramHeightInPxTillEnd(getProgramStartInMinutes(program[i]));
				}
				pos = getTimeTextPos(program, i);
				posNext = getTimeTextPos(program, i + 1);
				var item = {
					"timeTextUpper": pos === posBelow ? formatTime(program[i]) : "",
					"timeTextBottom": posNext === posAbove ? formatTime(program[i + 1]) : "",
					"programHeight": height,
					"upperVisible": pos === posBelow,
					"bottomVisible": pos === posBelow ? posNext === posAbove : false,
					"startLineVisible": true
				};

				textModel.append(item);
			}
		}
	}

	/// Timescale of the currently selected day program. Displayed using 2 Repeaters. One static for displaying short line for every hour - 25 lines, including 0:00.
	/// The second one to dynamicly create and display the start time of the program block. By default the time text is displayed below the line
	/// of the start time line but when two lines are an hour or less away from each other, the top one has the time placed above the line. When multiple lines are
	/// placed together, the middle ones do not show the time.
	/// There is one item in the Repeater for each program block and each item contains a long line at the top representing the start time and two texts - upper and bottom text.
	/// Upper text represents time text for current block should it be displayed below the line. The bottom text represents time for the next block should it be
	/// displayed above the line. The bottom time text can only be visible if the current block start time is below. Unused text is not visible.
	Item {
		id: timeScale

		property real scaleOpacity: 1

		property int linesCount: 25
		property int shortLength: 20
		property int longLength: 55

		anchors {
			top: parent.top
			right: parent.right
		}
		width: longLength
		height: programDayHeight

		// The textModel should contain an array of items, with each item having the following
		// contents:
		//var item = {
		//	"timeTextUpper": "10:00", // The time to place above the time item line
		//	"timeTextBottom": "10:00", // The time to place below the time item line
		//	"programHeight": height, // How how is the program item in px (if too small to render text, time is not shown)
		//	"upperVisible": true, // Should the timeTextUpper be shown?
		//	"bottomVisible": false, // Should the timeTextBottom be shown?
		//	"startLineVisible": false // Should the time item line be shown?
		//};
		// textModel.append(item);
		ListModel {
			id: textModel
		}

		Column {
			width: parent.width
			height: parent.height

			Repeater {
				id: linesRepeater
				model: timeScale.linesCount
				Item {
					id: lineWrap

					width: parent.width
					height: pixelsPerHour

					Rectangle {
						id: hourLine
						color: scaleColor
						opacity: timeScale.scaleOpacity
						height: Math.round(1 * verticalScaling)
						width: timeScale.shortLength
						anchors.right: parent.right
					}
				}
			}
		}

		Column {
			width: parent.width
			height: parent.height

			Repeater {
				id: textRepeater
				model: textModel

				Item {
					id: textWrap

					width: timeScale.width
					height: programHeight

					Rectangle {
						id: programStartTime
						color: scaleColor
						opacity: timeScale.scaleOpacity
						height: Math.round(1 * verticalScaling)
						width: timeScale.longLength
						anchors.top: parent.top
						visible: startLineVisible
					}

					Text {
						id: textRepeaterUpperText
						anchors.left: parent.left
						anchors.top: parent.top
						color: scaleColor
						opacity: timeScale.scaleOpacity
						font {
							family: qfont.regular.name
							pixelSize: qfont.thermostatTimeText
						}
						visible: upperVisible
						text: timeTextUpper
					}

					Text {
						id: textRepeaterBottomText
						anchors.left: parent.left
						anchors.bottom: parent.bottom
						color: scaleColor
						opacity: timeScale.scaleOpacity
						font {
							family: qfont.regular.name
							pixelSize: qfont.thermostatTimeText
						}
						visible: bottomVisible
						text: timeTextBottom
					}
				}
			}
		}

		states: [
			State {
				name: "up"
			},
			State {
				name: "disabled"
				when: !timeEnabled
				PropertyChanges {
					target: timeScale
					scaleOpacity: 0.3
				}
			}
		]
	}

	/// The time line showing what the curent time is. Hidden when the program is disabled. Updates its position at evry 10s of minutes.
	Item {
		id: currentTime

		property real offset: 0

		width: timeScale.width + programWidth
		height: timeScale.height
		anchors.top: timeScale.top
		anchors.left: timeScale.left
		z: 0.5

		Rectangle {
			id: currentTimeLine

			color: colors.psCurrentTimeLine
			width: programWidth + timeScale.shortLength + rootItem.anchors.rightMargin
			height: Math.round(1 * verticalScaling)
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.leftMargin: timeScale.longLength - timeScale.shortLength
			anchors.topMargin: currentTime.offset

			Image {
				id: currentTimeArrow

				anchors.verticalCenter: currentTimeLine.verticalCenter
				anchors.right: parent.left
				source: "image://scaled/images/time-little-arrow.svg"
			}

			Timer {
				id: currentTimeTimer
				running: false
				repeat: true
				onTriggered: {
					p.updateCurrentTimeLine();
					p.updateCurrentTimeInterval();
				}
			}
		}
	}
}
