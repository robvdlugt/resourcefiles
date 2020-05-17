import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

Widget {
	id: thermostatWeekProgramTab

	property string kpiPrefix: "ThermostatWeekProgramTab."
	property ThermostatApp app
	property url sourceUrl: app.thermostatWeekProgramUrl

	width: Math.round(784 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	function init(context) {
		app.thermostatProgramChanged.connect(p.programChanged);
	}

	property variant thermStates: app.thermStates
	/**
	 * Modify program day option selected
	 * @param type:int index of the selected day (Sunday == 0)
	 */
	signal modifyProgramDay(int day);

	QtObject {
		id: p

		// design height of the program for day
		property int programDayHeight: isNxt ? 288 : 216
		// type of the change done to save: 0 - no change, 1 - edit day program, 2 - copy day program
		property int savingProgram: 0
		// argument for saving the program change
		property variant saveProgramArgs

		// updates time scale to actually selected day program. see timeScale component description
		function updateTimeScale() {
			var day = programSchedule.selectedDay;
			var program;
			if (app.thermostatProgram && app.thermostatProgram[day]) {
				program = app.thermostatProgram[day];
			} else {
				return;
			}
			timeScale.populateModel(program);
		}

		function getToday() {
			var now = new Date();
			return now.getDay();
		}

		// maps index of the program state (0..3: comfort, home, sleep, away) to extendend program state as it is in dataset (vacation, undefined in addition)
		function programStateIdxToAppStateIdx(stateIdx) {
			var idx = app.thermStateUndef
			switch (stateIdx) {
			case 0: idx = app.thermStateAway; break;
			case 1: idx = app.thermStateSleep; break;
			case 2: idx = app.thermStateActive; break;
			case 3: idx = app.thermStateRelax; break;
			}

			return idx;
		}

		// retreives program state temperature from the dataset based on the limited (0..3: comfort, home, sleep, away) index
		function getStateTemp(stateIdx) {
			return thermStates[app.thermStatesMap[programStateIdxToAppStateIdx(stateIdx)]].temperature;
		}

		/// formats temperature value to text including unit sign
		function formatTemp(temp) {
			return i18n.number(temp, 1) + "°";
		}

		function programChanged() {
			programSchedule.populate();
			updateTimeScale();
		}
	}

	function showTab() {
		p.updateTimeScale();
		programSchedule.selectDay(p.getToday());
		show();
	}

	function hideTab() {
		timeScale.timeEnabled = false;
		hide();
	}

	ThermostatProgramSchedule {
		id: programSchedule

		anchors {
			top: parent.top
			topMargin: Math.round(9 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
			// Use offset on Toon to prevent items on the right side from falling off
			// Should probably use some heuristic during resizing to see if it can be
			// centered, or if the screen is too small and requires an offset.
			horizontalCenterOffset: -20 * horizontalScaling
		}

		onSelectedDayChanged: {
			p.updateTimeScale();
		}
	}

	TimeScale {
		id: timeScale
		anchors {
			top: programSchedule.top
			topMargin: (36 + 8) * verticalScaling
			right: programSchedule.left
			rightMargin: Math.round(7 * horizontalScaling)
		}
		programDayHeight: p.programDayHeight
		programWidth: programSchedule.width

		timeEnabled: true
	}

	property int dayColumnWidth: 75 * horizontalScaling
	/// buttons to "Copy" and "Modify" currently selected day program. Move with the selection of the day. Hidden when program disabled
	Item {
		id: modifyButtons

		// Sunday is index 0, for the left margin calculation it has to be converted
		property int selectedDay: programSchedule.selectedDay

		width: parent.dayColumnWidth * 7 + designElements.spacing8 * 6 + 2 * 10 // dayColumnWidth*7 -> program width, 8*6 -> program spacing, 2*10 -> border
		height: 8 * 3 + btnCopyProgram.height * 2 //8*3 -> spacing, 36*2 -> button heignt
		anchors.top: programSchedule.bottom
		anchors.topMargin: Math.round(8 * verticalScaling)
		anchors.left: programSchedule.left
		anchors.leftMargin: (selectedDay == 0 ? 6 : selectedDay - 1) * (designElements.spacing8 + parent.dayColumnWidth)

		IconButton {
			id: btnModifyProgram

			width: Math.round(36 * horizontalScaling)
			iconSource: "qrc:/images/edit.svg"
			bottomClickMargin: 4
			rightClickMargin: Math.round(2 * horizontalScaling)
			overlayWhenUp: true

			anchors {
				top: parent.top
				left: parent.left
			}

			onClicked: {
				modifyProgramDay(modifyButtons.selectedDay);
				app.startEditProgram(modifyButtons.selectedDay);
			}
		}

		IconButton {
			id: btnCopyProgram

			width: Math.round(36 * horizontalScaling)
			iconSource: "drawables/icon_copy.svg"
			bottomClickMargin: 4
			leftClickMargin: Math.round(1 * horizontalScaling)
			overlayWhenUp: true

			anchors {
				top: parent.top
				left: btnModifyProgram.right
				leftMargin: Math.round(4 * horizontalScaling)
			}

			onClicked: {
				stage.openFullscreen(app.copyProgramDayScreenUrl, {fromDay: modifyButtons.selectedDay});
			}
		}
	}

	Text {
		id: programText
		anchors {
			top: programSchedule.top
			left: programSchedule.right
			leftMargin: Math.round(10 * horizontalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.bodyText
		}
		color: colors.tpModeLabel
		text: qsTr("Program")
	}

	OnOffToggle {
		id: programToggle
		height: Math.round(36 * verticalScaling)
		anchors.left: programText.left
		anchors.top: programText.bottom
		anchors.topMargin: Math.round(4 * verticalScaling)

		fontColor: colors.spText
		isSwitchedOn: app.programEnabled
		leftIsSwitchedOn: false

		onSelectedChangedByUser: app.sendProgramState(isSwitchedOn);
	}

	/// displaying 4 temperature preset values, colors and names (away, sleep, home, confort) using a Repeater. Particular item's index has to be mapped to
	/// indexes used in dataset defined in ThermostatApp
	Item {
		id: programLegend

		width: thermostatWeekProgramTab.width
		height: Math.round(170 * verticalScaling)
		anchors.left: programToggle.left
		anchors.top: programToggle.bottom
		anchors.topMargin: Math.round(12 * verticalScaling)

		Column {
			anchors.top: parent.top
			spacing: Math.round(10 * horizontalScaling)
			Repeater {
				id: legendRepeater
				model: 4 // number of temp. presets
				delegate: Item {
					width: programLegend.width
					height: Math.round(28 * verticalScaling)

					Rectangle {
						id: modeColorRectangle
						objectName: "modeColorRec" + index
						width: Math.round(8 * horizontalScaling)
						height: parent.height

						anchors.left: parent.left
						color: app.thermStateColor[legendRepeater.count - index - 1]
					}

					Text {
						id: modeNameText
						objectName: "modeNameText" + index
						anchors.left: modeColorRectangle.right
						anchors.leftMargin: Math.round(8 * horizontalScaling)
						anchors.baseline: parent.top
						anchors.baselineOffset: 11
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.metaText
						color: colors.tpModeLabel
						text: app.thermStateName[legendRepeater.count - index - 1]
					}

					Text {
						id: modeTempText
						objectName: "modeTempText" + index
						anchors.left: modeNameText.left
						anchors.baseline: parent.bottom
						font.family: qfont.regular.name
						font.pixelSize: qfont.metaText
						color: colors.tpModeLabel
						text: p.formatTemp(p.getStateTemp(index))
					}
				}
			}
		}
	}

	StandardButton {
		id: btnSetTemp

		width: Math.round(95 * horizontalScaling)
		height: Math.round(36 * verticalScaling)
		anchors.bottom: programSchedule.bottom
		anchors.left: programLegend.left
		text: qsTr("Set")

		onClicked: {
			stage.openFullscreen(app.temperaturePresetScreenUrl);
		}
	}
}
