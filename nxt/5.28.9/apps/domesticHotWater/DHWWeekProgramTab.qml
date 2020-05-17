import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

Widget {
	id: dhwWeekProgramTab

	property string kpiPrefix: "DhwWeekProgramTab."
	property DomesticHotWaterApp app
	property url sourceUrl: app.weekProgramUrl

	width: Math.round(784 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	function init(context) {
		programSchedule.populate();
		app.dhwProgramChanged.connect(p.programChanged);
	}

	QtObject {
		id: p

		function programChanged() {
			if (programSchedule) {
				programSchedule.populate();
				populateTimeScaleModel();
			}
		}

		function populateTimeScaleModel() {
			var day = programSchedule.selectedDay;
			if (! app.dhwProgramEnabled || day === -1) {
				return;
			}
			var program = app.dhwProgram[day];

			timeScale.populateModel(program);
		}

		function getToday() {
			var now = new Date();
			return now.getDay();
		}
	}

	function showTab() {
		programSchedule.selectDay(p.getToday());
		p.populateTimeScaleModel();
		timeScale.timeEnabled = true;

		show();
	}

	function hideTab() {
		timeScale.timeEnabled = false;
		hide();
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
		isSwitchedOn: app.dhwProgramEnabled
		leftIsSwitchedOn: false

		onSelectedChangedByUser: {
			// Send DHW program state on switch
			app.patchDHWSchedule({active:isSwitchedOn});
		}
	}

	Item {
		id: programLegend

		width: dhwWeekProgramTab.width
		height: Math.round(170 * verticalScaling)
		anchors.left: programToggle.left
		anchors.top: programToggle.bottom
		anchors.topMargin: Math.round(12 * verticalScaling)

		Column {
			anchors.top: parent.top
			spacing: Math.round(10 * horizontalScaling)
			Repeater {
				id: legendRepeater
				model: 2
				delegate: Item {
					width: programLegend.width
					height: Math.round(28 * verticalScaling)

					Rectangle {
						id: modeColorRectangle
						objectName: "modeColorRec" + index
						width: Math.round(8 * horizontalScaling)
						height: parent.height

						anchors.left: parent.left
						color: app.stateColor[legendRepeater.count - index - 1]
					}

					Text {
						id: modeNameText
						objectName: "modeNameText" + index
						anchors.left: modeColorRectangle.right
						anchors.leftMargin: Math.round(8 * horizontalScaling)
						anchors.verticalCenter: modeColorRectangle.verticalCenter
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.bodyText
						color: colors.tpModeLabel
						text: app.stateName[legendRepeater.count - index - 1]
					}
				}
			}
		}
	}

	DHWProgramSchedule {
		id: programSchedule

		programEnabled: app.dhwProgramEnabled

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
			p.populateTimeScaleModel();
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

		visible: app.dhwProgramEnabled

		IconButton {
			id: btnModifyProgram

			width: Math.round(36 * horizontalScaling)
			iconSource: "qrc:/images/edit.svg"
			bottomClickMargin: 4
			overlayWhenUp: true

			anchors {
				top: parent.top
				left: parent.left
			}

			onClicked: {
				// See ThermostatProgramScreen
				dhwWeekProgramTab.parent.rememberSelectedProgramTab();
				stage.openFullscreen(app.editDayUrl, {curDay: programSchedule.selectedDay});
			}
		}

		IconButton {
			id: btnCopyProgram

			width: Math.round(36 * horizontalScaling)
			iconSource: "qrc:/apps/thermostat/drawables/icon_copy.svg"
			bottomClickMargin: 4
			overlayWhenUp: true

			anchors {
				top: parent.top
				left: btnModifyProgram.right
				leftMargin: 4
			}

			onClicked: {
				// See ThermostatProgramScreen
				dhwWeekProgramTab.parent.rememberSelectedProgramTab();

				stage.openFullscreen(app.copyDayUrl, {curDay: programSchedule.selectedDay});
			}
		}
	}
}
