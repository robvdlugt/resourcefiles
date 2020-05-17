import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: editDaycreen

	screenTitle: qsTr("Edit")
	isSaveCancelDialog: true

	property DomesticHotWaterApp app

	QtObject {
		id: p
		// 0 == Sunday
		property int daySelected: -1
		property int editedBlockIdx: 0
		property bool addingNewBlock: false
		property int maxBlocksInDay : 6
		property string blockAction: qsTr('Add')

		// 0 = sunday
		function selectDay(dayIdx) {
			// Unselect previous day
			if (daySelected !== -1) {
				dayBtnRow.children[app.sundayBaseToMondayBase(daySelected)].isDaySelected = false;
			}
			dayBtnRow.children[app.sundayBaseToMondayBase(dayIdx)].isDaySelected = true;
			daySelected = dayIdx;

			// Limitations: We're going to assume there are no 'on' periods longer
			// than 24 hours.

			dayProgramModel.clear();
			var dayProgram = app.dhwProgramEdited[daySelected];
			for (var i = 0; i < dayProgram.length; ++i) {
				var curEntry = dayProgram[i];
				if (curEntry.targetState === 1) {
					curEntry['index'] = i;
					// Determine the start and end of the On period
					if (i === 0) {
						curEntry['startDay'] = curEntry.day;
					} else {
						curEntry['startDay'] = daySelected;
					}

					var nextEntry = app.getNextEntry(app.dhwProgramEdited, daySelected, i);
					curEntry['endHour'] = nextEntry.startHour;
					curEntry['endMinute'] = nextEntry.startMinute;
					curEntry['endDay'] = nextEntry.day;

					dayProgramModel.append(curEntry);
					if (dayProgramModel.count >= p.maxBlocksInDay) {
						console.log("More than", p.maxBlocksInDay, "On periods in day program. Not showing the rest of the periods.");
						break;
					}
				}
			}

			addItemContainer.hideOverride = false;
			if (dayProgramModel.count === 1) {
				curEntry = dayProgramModel.get(0);

				var startDay = curEntry.startDay;
				var selectedDay = p.daySelected;
				var endDay = curEntry.endDay;

				// Deal with the end day and/or the selectedDay wrapping around
				if (endDay < startDay) {
					endDay += 7;
				}
				if (selectedDay < startDay) {
					selectedDay += 7;
				}

				if (startDay < selectedDay && selectedDay < endDay) {
					addItemContainer.hideOverride = true;
				}
			}
		}

		function openAddItemScreen() {
			stage.openFullscreen(app.editBlockUrl, {blockAction: "add",  daySelected: p.daySelected});
		}

		function openEditItemScreen(index) {
			// We open the DHWEditBlockScreen with the current selected day and the selected (start) index.
			// If the start index is 0 (i.e. the copied last entry from the previous day), then the
			// DHWEditBlockScreen will handle that.
			stage.openFullscreen(app.editBlockUrl, {blockAction: "edit", daySelected: p.daySelected, blockSelected: index});
		}

		function deleteBlock(index) {
			var tmpProgram = app.dhwProgramEdited;
			var beginDay = p.daySelected;
			var beginIndex = index;
			var endDay = p.daySelected;
			var endIndex = index + 1;

			if (beginIndex === 0) {
				var beginEntry = app.getPrevEntry(tmpProgram, beginDay, beginIndex);
				beginDay = beginEntry.day;
				beginIndex = tmpProgram[beginDay].length - 1;
			}
			if (beginIndex === tmpProgram[beginDay].length - 1) {
				var endEntry = app.getNextEntry(tmpProgram, beginDay, beginIndex);
				endDay = endEntry.day;
				endIndex = 1;
			}

			if (beginDay === endDay && beginIndex + 1 === endIndex) {
				// Just a normal entry on one day
				tmpProgram[beginDay].splice(beginIndex, 2);
			} else if (beginDay === endDay && beginIndex > endIndex) {
				// Wow, ok... so we have an entry that spanned across a whole week and
				// ended back up at the same day.
				// Ok, so the endIndex is before the startIndex... We can just remove both of them.
				tmpProgram[beginDay].splice(beginIndex, 1);
				tmpProgram[endDay].splice(endIndex, 1);
			} else if (beginDay !== endDay) {
				// beginDay and endDay are different, so we can just remove the entries on those
				// days and indices.
				tmpProgram[beginDay].splice(beginIndex, 1);
				tmpProgram[endDay].splice(endIndex, 1);
			}

			app.updatePlaceholdersInProgram(tmpProgram);

			app.dhwProgramEdited = tmpProgram;
			// Update/reconstruct displayed model
			selectDay(p.daySelected);
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (app.dhwProgramEditing === false) {
			app.dhwProgramEditing = true;
			app.dhwProgramEdited = app.cloneProgram(app.dhwProgram);
		}

		if (args !== null && typeof(args) !== "undefined" && typeof(args.curDay) !== "undefined") {
			p.selectDay(args.curDay);
		} else {
			// Refresh current day if we return from the DHWEditBlockScreen
			p.selectDay(p.daySelected);
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		var tmpProgram = app.dhwProgramEdited;
		app.updateDHWSchedule(tmpProgram);
		// app.dhwProgram will be updated by the reply for the updateDHWSchedule call.

		app.dhwProgramEditing = false;
		app.dhwProgramEdited = null;
	}

	onCanceled: {
		app.dhwProgramEditing = false;
		app.dhwProgramEdited = null;
	}

	Component {
		id: dayButton
		Item {
			id: dayButtonItem
			property bool isDaySelected: false
			width: Math.round(88 * horizontalScaling)
			height: Math.round(36 * verticalScaling)
			property string kpiPostfix: "day" + index

			Rectangle {
				id: txtDay
				width: parent.width
				height: Math.round(36 * verticalScaling)
				radius: designElements.radius
				color: isDaySelected ? colors.psDayBckgSelected : colors.psDayBckgUnselected

				Text {
					text: i18n.daysExtraShort[index + 1] // Monday based index
					color:  isDaySelected ? colors.esDayTextSelected : colors.esDayTextUnselected
					anchors.centerIn: parent
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.navigationTitle
					}
				}
			}
			MouseArea {
				id: maDayButton
				anchors.fill: parent
				onClicked: {
					p.selectDay(app.mondayBaseToSundayBase(index));
				}
			}
		}
	}

	ListModel {
		id: dayProgramModel
	}

	// Calculates the length of the period in minutes
	function calcPeriodLength(startDay, startHour, startMinute, endDay, endHour, endMinute) {
		var endTime = endHour * 60 + endMinute;
		var startTime = startHour * 60 + startMinute;
		if (endDay < startDay || (endDay === startDay &&  endTime < startTime)) {
			endDay += 7;
		}

		return ((endDay - startDay) * 24 * 60) + (endTime - startTime);
	}

	Component {
		id: programDelegate
		Rectangle {
			width: Math.round(664 * horizontalScaling)
			height: Math.round(41 * verticalScaling)
			radius: designElements.radius
			visible: true

			// Examples of content of the row:
			// [] On  (Fr) 23:00 - 1:00
			// [] On        7:00 - 10:00
			// [] On       23:00 - 1:00 (Sa)

			Rectangle {
				id: colorRect
				height: parent.height / 2
				width: height
				radius: designElements.radius
				color: app.stateColor[1]

				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: width / 2
				}
			}

			Text {
				id: onText
				text: app.stateName[app._DHW_STATE_ON]
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.bold.name
				anchors {
					verticalCenter: parent.verticalCenter
					left: colorRect.right
					leftMargin: designElements.hMargin20
				}
			}

			Text {
				id: dashText
				text: "-"
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.regular.name
				anchors {
					verticalCenter: parent.verticalCenter
					left: onText.right
					leftMargin: Math.round(120 * horizontalScaling)
				}
			}

			Text {
				id: startDayText
				text: "(" + i18n.daysExtraShort[startDay] + ")"
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.regular.name
				visible: startDay !== p.daySelected
				anchors {
					verticalCenter: parent.verticalCenter
					right: startTimeText.left
					rightMargin: designElements.hMargin6
				}
			}

			Text {
				id: startTimeText
				width: Math.round(43 * horizontalScaling)
				horizontalAlignment: Text.AlignRight
				text: app.formatTime(startHour, startMinute)
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.regular.name
				anchors {
					verticalCenter: parent.verticalCenter
					right: dashText.left
					rightMargin: designElements.hMargin5
				}
			}

			Text {
				id: endTimeText
				text: app.formatTime(endHour, endMinute)
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.regular.name
				anchors {
					verticalCenter: parent.verticalCenter
					left: dashText.right
					leftMargin: designElements.hMargin5
				}
			}

			Text {
				id: endDayText
				text: "(" + i18n.daysExtraShort[endDay] + ")"
				color: colors.esLabel
				font.pixelSize: qfont.titleText
				font.family: qfont.regular.name
				visible: endDay !== p.daySelected
				anchors {
					verticalCenter: parent.verticalCenter
					left: endTimeText.right
					leftMargin: designElements.hMargin6
				}
			}

			BarButton {
				id: editIconButton
				width: height
				height: parent.height
				anchors {
					verticalCenter: parent.verticalCenter
					right: deleteIconButton.left
					rightMargin: designElements.hMargin10
				}
				imageUp: "image://scaled/apps/thermostat/drawables/edit-block.svg"
				imageDown: "image://scaled/apps/thermostat/drawables/edit-block-down.svg"

				onClicked: p.openEditItemScreen(index)

				// Edit is only visible/available for periods that span across two days or less
				// (Periods that are longer than 24 hours run across 3 days or more, and
				//  editing those with the DHWEditBlockScreen is not intuitively possible.)
				// If the user has such a period, they can only delete it.
				visible: calcPeriodLength(startDay, startHour, startMinute, endDay, endHour, endMinute) < 24 * 60
			}

			BarButton {
				id: deleteIconButton
				width: height
				height: parent.height
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
				}
				imageUp: "image://scaled/apps/thermostat/drawables/delete-block.svg"
				imageDown: "image://scaled/apps/thermostat/drawables/delete-block-down.svg"

				onClicked: p.deleteBlock(index)
			}
		}
	}

	Item {
		width: Math.round(664 * horizontalScaling)
		height: Math.round(383 * verticalScaling)

		anchors.centerIn: parent

		Row {
			id: dayBtnRow
			spacing: designElements.spacing8
			Repeater {
				id: repeatDay
				model: 7
				delegate: dayButton
			}
		}

		Column {
			id: programColumn
			spacing: designElements.spacing8
			anchors {
				top: dayBtnRow.bottom
				topMargin: designElements.vMargin20
				left: parent.left
				right: parent.right
			}

			Repeater {
				id: repeatProgram
				model: dayProgramModel
				delegate: programDelegate
			}
		}

		Item {
			id: addItemContainer
			height: Math.round(41 * verticalScaling)
			visible: dayProgramModel.count < p.maxBlocksInDay && ! hideOverride
			property bool hideOverride: false

			// Anchored to bottom of column instead of being managed by the column. This
			// prevent flickering while the dayProgramModel is being updated.
			anchors {
				top: programColumn.bottom
				topMargin: programColumn.spacing
				left: parent.left
				right: parent.right
			}

			StyledButton {
				id: addButton
				color: "transparent"
				borderColor: "white"
				borderStyle: "DashLine"
				borderWidth: 2

				onClicked: p.openAddItemScreen()
				kpiPostfix: "addButton"

				anchors {
					left: parent.left
					right: addIconButton.left
					rightMargin: designElements.hMargin5
					top: parent.top
					bottom: parent.bottom
				}

				Text {
					text: qsTr("Add 'On' period")
					font.pixelSize: qfont.bodyText
					font.family: qfont.regular.name
					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						leftMargin: designElements.hMargin10
					}
				}
			}
			IconButton {
				id: addIconButton
				iconSource: "qrc:/images/plus_add.svg"
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
				}
				topClickMargin: 3
				height: parent.height
				width: height
				onClicked: p.openAddItemScreen()
			}
		}
	}
}
