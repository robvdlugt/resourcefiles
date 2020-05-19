import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: editBlockScreen

	screenTitle: qsTr("%1 block %2").arg(p.blockAction).arg(i18n.daysFull[p.daySelected])
	isSaveCancelDialog: true

	property DomesticHotWaterApp app


	QtObject {
		id: p
		property string blockAction : qsTr('Add')
		property int daySelected: -1
		property int blockSelected: -1

		property variant curProgram: null

		property int minTime: 0
		property int minHour
		property int minMinute
		property int maxTime: 23 * 60 + 50
		property int maxHour
		property int maxMinute

		property string warningText: ""
		property string txtNoOverlap: qsTr("DHW does not do preheating")
		property string txtSameStartEnd: qsTr("The start and end time are the same")
		property string txtOverlap: qsTr("Your period overlaps one or more other periods. These periods will be combined to a single period starting from %1 %2 to %3 %4")
		property string txtAcrossDay: qsTr("Your period crosses from %1 %2 to %3 %4")
		property string txtNoFullSchedule: qsTr("Your schedule cannot be constantly on")

		property bool initInProgress : false

		// for unit tests only
		property alias utestStartSpinner: startSpinner
		property alias utestEndSpinner: endSpinner

		function timeChanged() {
			if (startSpinner.value === endSpinner.value) {
				editBlockScreen.disableSaveButton();
			} else {
				editBlockScreen.enableSaveButton();
			}

			checkWarningText();
		}

		function checkWarningText() {
			warningText = "";
			if (p.daySelected === -1) {
				// Don't check while we're still populating the screen.
				return;
			}

			if (endSpinner.value > startSpinner.value) {
				checkWarningTextSameDay();
			} else if (endSpinner.value < startSpinner.value){
				checkWarningTextAcrossDay();
			} else {
				warningText = txtSameStartEnd;
			}
		}

		function calcBlockStartTime(entry, index) {
			// If the on period started on a previous day, use value '0' as the
			// blockStartTime for comparison
			if (index === 0)
				return 0;
			else
				return calcTime(entry);
		}

		function calcBlockEndTime(entry, day, blockStartTime) {
			var blockEndTime = calcTime(entry);
			// If the next entry is on another day or (heaven forbid) spanning the whole week
			// and ending earlier than the start time on the same day, then...
			if (entry.day !== day || (entry.day === day && blockEndTime < blockStartTime)) {
				// Set the blockEndTime (for comparison) to the end of the current day
				blockEndTime = 24 * 60;
			}
			return blockEndTime;
		}

		function checkWarningTextAcrossDay() {
			var curDay = p.daySelected;
			var nextDay = (p.daySelected + 1) % 7;

			// First set the warningText for crossing the day, then check if there's a more specific warning
			// we need to show.
			var startDayText  = i18n.daysFull[curDay];
			var startTimeText = app.formatTime(startSpinner.hourValue, startSpinner.minuteValue);
			var endDayText    = i18n.daysFull[nextDay];
			var endTimeText   = app.formatTime(endSpinner.hourValue,   endSpinner.minuteValue);
			warningText = txtAcrossDay.arg(startDayText).arg(startTimeText).arg(endDayText).arg(endTimeText);

			var newStartDay = curDay;
			var newStartTime = startSpinner.value;
			var newEndDay = nextDay;
			var newEndTime = endSpinner.value;
			var showWarning = false;

			var dayProgram = p.curProgram[curDay];
			var nextDayProgram = p.curProgram[nextDay];

			var i;
			var entry, nextEntry;
			var startEntry;
			var blockStartTime, blockEndTime;

			// Handle start time
			{
				for (i = 0; i < dayProgram.length; ++i) {
					entry = dayProgram[i];
					// We're looking for periods which start with an 'on' entry. So we can skip the 'off' entries.
					if (entry.targetState === 0) {
						continue;
					}
					nextEntry = app.getNextEntry(p.curProgram, curDay, i);

					blockStartTime = calcBlockStartTime(entry, i);
					blockEndTime = calcBlockEndTime(nextEntry, curDay, blockStartTime);

					if (newStartTime <= blockStartTime) {
						showWarning = true;
						startEntry = entry;
						break;
					} else if (blockStartTime <= newStartTime && newStartTime <= blockEndTime) {
						showWarning = true;
						startEntry = entry;
						newStartTime = calcTime(entry);
						newStartDay = entry.day;
						break;
					}
				}
			}

			// Handle end time
			{
				for (i = 0; i < nextDayProgram.length; ++i) {
					entry = nextDayProgram[i];
					if (entry.targetState === 0) {
						continue;
					}
					nextEntry = app.getNextEntry(p.curProgram, nextDay, i);

					blockStartTime = calcBlockStartTime(entry, i);
					blockEndTime = calcBlockEndTime(nextEntry, nextDay, blockStartTime);

					if (newEndTime < blockStartTime) {
						break;
					} else if (blockStartTime <= newEndTime && newEndTime <= blockEndTime) {
						// Handle across week corner case where the current entry is the
						// same as the one we found for the start time
						if (startEntry !== undefined && app.entryIsEqual(entry, startEntry) && (nextEntry.day + 1) % 7 === entry.day) {
							warningText = txtNoFullSchedule;
							editBlockScreen.disableSaveButton();
							return;
						}
						showWarning = true;
						newEndTime = calcTime(nextEntry);
						newEndDay = nextEntry.day;
						break;
					} else if (blockEndTime < newEndTime) {
						showWarning = true;
					}
				}
			}

			if (showWarning) {
				startDayText  = i18n.daysFull[newStartDay];
				startTimeText = app.formatTime(Math.floor(newStartTime / 60), newStartTime % 60);
				endDayText    = i18n.daysFull[newEndDay];
				endTimeText   = app.formatTime(Math.floor(newEndTime / 60),   newEndTime % 60);
				warningText = txtOverlap.arg(startDayText).arg(startTimeText).arg(endDayText).arg(endTimeText);
			}
		}

		function checkWarningTextSameDay() {
			var dayProgram = p.curProgram[p.daySelected];

			var newStartDay = p.daySelected;
			var actNewStartTime = startSpinner.value; // Value to display
			var cmpNewStartTime = startSpinner.value; // Value to compare against
			var newEndDay = p.daySelected;
			var actNewEndTime = endSpinner.value; // Value to display
			var cmpNewEndTime = endSpinner.value; // Value to compare against

			// Have we found the earliest start time yet?
			var foundStart = false;
			// Do we need to show the overlap warning?
			var showWarning = false;

			for (var i = 0; i < dayProgram.length; ++i) {
				var entry = dayProgram[i];
				if (entry.targetState === 0) {
					continue;
				}
				var nextEntry = app.getNextEntry(p.curProgram, p.daySelected, i);

				// Handle across week corner case first:
				if (i === 0 && entry.day === newStartDay && cmpNewStartTime <= calcTime(nextEntry) && calcTime(entry) <= cmpNewEndTime) {
					// If we're checking the placeholder entry
					// and the placeholder refers to the same day (i.e. it crosses the whole week and ends up at the same day)
					// if the new start time is before the end time (early on the day)
					// and the new end time is after the start time (later on the day)
					warningText = txtNoFullSchedule;
					editBlockScreen.disableSaveButton();
					return;
				}

				var blockStartTime = calcBlockStartTime(entry, i);
				var blockEndTime = calcBlockEndTime(nextEntry, p.daySelected, blockStartTime);

				if (blockStartTime <= cmpNewStartTime && cmpNewEndTime <= blockEndTime) {
					// If the new period is contained in the period we're comparing against
					showWarning = true;
					if (! foundStart) {
						foundStart = true;
						actNewStartTime = calcTime(entry);
						cmpNewStartTime = blockStartTime;
						newStartDay = entry.day;
					}
					actNewEndTime = calcTime(nextEntry);
					cmpNewEndTime = blockEndTime;
					newEndDay = nextEntry.day;
					// if the new period is fully contained in this one, there cannot
					// be any other overlap, so we're done.
					break;
				} else if (cmpNewStartTime <= blockStartTime && blockStartTime <= cmpNewEndTime && cmpNewEndTime <= blockEndTime) {
					// else if the start time of the compared period is contained in the new period,
					showWarning = true;
					actNewEndTime = calcTime(nextEntry);
					cmpNewEndTime = blockEndTime;
					newEndDay = nextEntry.day;
				} else if (blockStartTime <= cmpNewStartTime && cmpNewStartTime <= blockEndTime && blockEndTime <= cmpNewEndTime) {
					// else if the start time of the new period is contained in the period we're comparing against
					showWarning = true;
					if (! foundStart) {
						foundStart = true;
						actNewStartTime = calcTime(entry);
						cmpNewStartTime = blockStartTime;
						newStartDay = entry.day;
					}
				} else if (cmpNewStartTime <= blockStartTime && /*blockStartTime < blockEndTime &&*/ blockEndTime <= cmpNewEndTime) {
					// else if the compared period is contained in the new period
					showWarning = true;
					// Nothing to do here
				}
			}

			if (showWarning) {
				var startDayText  = i18n.daysFull[newStartDay];
				var startTimeText = app.formatTime(Math.floor(actNewStartTime / 60), actNewStartTime % 60);
				var endDayText    = i18n.daysFull[newEndDay];
				var endTimeText   = app.formatTime(Math.floor(actNewEndTime / 60),   actNewEndTime % 60);
				warningText = txtOverlap.arg(startDayText).arg(startTimeText).arg(endDayText).arg(endTimeText);
			}
		}

		function init(args) {
			if (typeof(args.blockAction) !== "undefined") {
				switch(args.blockAction) {
				case "add": p.blockAction = qsTr('Add'); break;
				case "edit": p.blockAction = qsTr('Edit'); break;
				}
			}
			if (typeof(args.daySelected) !== "undefined") {
				p.daySelected = args.daySelected;
			}
			if (typeof(args.blockSelected) !== "undefined") {
				p.blockSelected = args.blockSelected;
			} else {
				p.blockSelected = -1;
			}

			var tmpProgram = app.cloneProgram(app.dhwProgramEdited);
			p.curProgram = tmpProgram;

			// We need to normalize the "selected" block, because we can have one of the following two
			// situations:
			// | app.dhwProgramEdited[day][last] | app.dhwProgramEdited[day + 1][0] | app.dhwProgramEdited[day + 1][1] |
			// ---------------------------------------------------------------------------------------------------------
			// | Monday 23:00                    |                                  | Tuesday 01:00                    |
			// |                                 | Monday 23:00                     | Tuesday 01:00                    |
			if (p.blockSelected === 0) {
				var curEntry = tmpProgram[p.daySelected][p.blockSelected]
				p.daySelected = curEntry.day;
				p.blockSelected = tmpProgram[p.daySelected].length - 1;
			}

			if (p.blockSelected === -1) {
				startSpinner.setTime(12, 0);
				endSpinner.setTime(12, 30);
			} else {
				var tmpDayProgram = tmpProgram[p.daySelected];
				var tmpNextDayProgram = tmpProgram[(p.daySelected + 1) % 7];

				// Copy the entries matching the selected block, then remove them from the program
				var startEntry = tmpDayProgram[p.blockSelected];
				var endEntry = app.getNextEntry(tmpProgram, p.daySelected, p.blockSelected);
				if (p.blockSelected === tmpDayProgram.length - 1) {
					tmpDayProgram.splice(p.blockSelected, 1);
					tmpNextDayProgram.splice(1, 1);
				} else {
					tmpDayProgram.splice(p.blockSelected, 2);
				}

				app.updatePlaceholdersInProgram(tmpProgram)

				// Set p.curProgram before updating the spinners (so that the triggered checkWarningText()
				// can already inspect the updated program)
				p.curProgram = tmpProgram;

				startSpinner.setTime(startEntry.startHour, startEntry.startMinute);
				endSpinner.setTime(endEntry.startHour, endEntry.startMinute);
			}
		}

		function saveNewBlock() {
			var tmpProgram = p.curProgram;

			addNewBlock(tmpProgram);

			app.dhwProgramEdited = tmpProgram;
		}

		function addNewBlock(tmpProgram) {
			var tmpDayProgram = tmpProgram[p.daySelected];
			var tmpNextDayProgram = tmpProgram[(p.daySelected + 1) % 7];

			// So, when we're adding a new block, there are a couple of things we need to keep
			// in mind:
			// - There may be periods that overlap completely or partially with the new block, so we need to combine them
			// - The new block may be completely contained within another block (so we don't need to add it at all)
			// - The end of the block may be on the next day, complicating the previous two cases

			var startEntry = app.createEntry(1, startSpinner.hourValue, startSpinner.minuteValue);
			var endEntry   = app.createEntry(0, endSpinner.hourValue, endSpinner.minuteValue);
			startEntry['day'] = p.daySelected;

			if (calcTime(endEntry) < calcTime(startEntry)) {
				endEntry['day'] = (p.daySelected + 1) % 7;
				addNewBlockAcrossDay(tmpProgram, tmpDayProgram, tmpNextDayProgram, startEntry, endEntry);
			} else {
				endEntry['day'] = p.daySelected;
				addNewBlockSameDay(tmpProgram, tmpDayProgram, tmpNextDayProgram, startEntry, endEntry);
			}

			app.updatePlaceholdersInProgram(tmpProgram);
		}

		function addNewBlockAcrossDay(tmpProgram, tmpDayProgram, tmpNextDayProgram, startEntry, endEntry) {
			// The endEntry is on the next day
			// Split up the handling for the startEntry and the endEntry, since they have to end up
			// different dayPrograms.
			var spliceIndex, spliceDelete;
			// Handle the startEntry
			{
				var startIndex = findInsertIndex(startEntry, tmpDayProgram);

				spliceIndex = startIndex;
				spliceDelete = tmpDayProgram.length - startIndex;
				var insertStart = true;

				if (tmpDayProgram[startIndex - 1].targetState === startEntry.targetState) {
					// If the previous entry already had targetState = on, then we don't need to add this startEntry
					insertStart = false;
				} else if (compareEntries(tmpDayProgram[startIndex - 1], startEntry) === 0) {
					// If the previous (off) entry started at the same time as this one starts, remove
					// that off entry, and don't add this start
					spliceIndex = startIndex - 1;
					spliceDelete += 1;
					insertStart = false;
				}

				if (insertStart) {
					tmpDayProgram.splice(spliceIndex, spliceDelete, startEntry);
				} else if (spliceDelete !== 0){
					tmpDayProgram.splice(spliceIndex, spliceDelete);
				}
			}

			// Handle the endEntry
			{
				var endIndex = findInsertIndex(endEntry, tmpNextDayProgram);

				spliceIndex = 1;
				spliceDelete = endIndex - 1;
				var insertEnd = true;

				var nextEntry = app.getNextEntry(tmpProgram, (p.daySelected + 1) % 7, endIndex - 1);
				if (nextEntry.targetState === endEntry.targetState) {
					// If the next entry already has targetState = off, then we don't need to add this endEntry
					// (because we're in the middle of another period)
					insertEnd = false;
				} else if (compareEntries(nextEntry, endEntry) === 0) {
					// If the next (on) entry starts at the same time as this one ends, remove
					// that on entry, and don't add this end (effectively combining the periods)
					spliceDelete += 1;
					insertEnd = false;
				}

				if (insertEnd) {
					tmpNextDayProgram.splice(spliceIndex, spliceDelete, endEntry);
				} else if (spliceDelete !== 0){
					tmpNextDayProgram.splice(spliceIndex, spliceDelete);
				}
			}
		}

		function addNewBlockSameDay(tmpProgram, tmpDayProgram, tmpNextDayProgram, startEntry, endEntry) {
			// The startEntry and endEntry are on the same day
			var startIndex = findInsertIndex(startEntry, tmpDayProgram);
			var endIndex = findInsertIndex(endEntry, tmpDayProgram);

			if (endIndex < startIndex) {
				console.log("End entry is sorted before begin entry in same day. Should not happen!");
				return;
			}

			var spliceIndex = startIndex;
			var spliceDelete = endIndex - startIndex;
			var insertStart = true;
			var insertEnd = true;

			if (tmpDayProgram[startIndex - 1].targetState === startEntry.targetState) {
				// If the previous entry already had targetState = on, then we don't need to add this startEntry
				insertStart = false;
			} else if (app.entryTimeIsEqual(tmpDayProgram[startIndex - 1], startEntry)) {
				// If the previous (off) entry started at the same time as this one starts, remove
				// that off entry, and don't add this start
				spliceIndex = startIndex - 1;
				spliceDelete += 1;
				insertStart = false;
			}

			var nextEntry = app.getNextEntry(tmpProgram, p.daySelected, endIndex - 1);
			if (nextEntry !== undefined && nextEntry.targetState === endEntry.targetState) {
				// If the next entry already has targetState = off, then we don't need to add this endEntry
				// (because we're in the middle of another period)
				insertEnd = false;
			} else if (nextEntry !== undefined && compareEntries(nextEntry, endEntry) === 0) {
				// If the next (on) entry starts at the same time as this one ends, remove
				// that on entry, and don't add this end (effectively combining the periods)
				spliceDelete += 1;
				insertEnd = false;
			}

			if (insertStart && insertEnd) {
				tmpDayProgram.splice(spliceIndex, spliceDelete, startEntry, endEntry);
			} else if (insertStart) {
				tmpDayProgram.splice(spliceIndex, spliceDelete, startEntry);
			} else if (insertEnd) {
				tmpDayProgram.splice(spliceIndex, spliceDelete, endEntry);
			} else if (spliceDelete !== 0){
				tmpDayProgram.splice(spliceIndex, spliceDelete);
			}
		}

		function findInsertIndex(newEntry, tmpDayProgram) {
			var entryValue = calcTime(newEntry);
			for (var i = 1; i < tmpDayProgram.length; ++i) {
				if (entryValue < calcTime(tmpDayProgram[i])) {
					return i;
				}
			}
			return tmpDayProgram.length;
		}

		function calcTime(entry) {
			return entry.startHour * 60 + entry.startMinute;
		}

		function createEntry(targetState, startHour, startMinute) {
			return { "targetState": targetState, "startHour": startHour, "startMinute": startMinute };
		}

		function duplicateEntry(entry) {
			return JSON.parse(JSON.stringify(entry));
		}

		function compareEntries(a, b) {
			if (a.day === b.day)
				return calcTime(a) - calcTime(b);
			else
				return a.day - b.day;
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;

		p.init(args);
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		p.saveNewBlock();
	}

	onCanceled: {
	}

	TimeNumberSpinner {
		id: startSpinner
		spacing: Math.round(9 * horizontalScaling)
		anchors {
			left: parent.left
			leftMargin: Math.round(30 * horizontalScaling)
			top: parent.top
			topMargin: Math.round(112 * verticalScaling)
		}

		minuteIncrement: 10

		onValueChanged: p.timeChanged();
	}

	Text {
		id: fromText
		text: qsTr("From %1").arg(i18n.daysFull[p.daySelected])
		color: colors.dhwTempTitle

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}

		anchors {
			left: startSpinner.left
			bottom: startSpinner.top
			bottomMargin: designElements.vMargin6
		}
	}

	TimeNumberSpinner {
		id: endSpinner
		spacing: startSpinner.spacing
		anchors {
			left: startSpinner.right
			leftMargin: Math.round(30 * horizontalScaling)
			verticalCenter: startSpinner.verticalCenter
		}

		minuteIncrement: 10

		onValueChanged: p.timeChanged();
	}

	Text {
		id: toText
		text: qsTr("Till %1").arg(i18n.daysFull[startSpinner.value <= endSpinner.value ? p.daySelected : (p.daySelected + 1) % 7])
		color: colors.dhwTempTitle

		font {
			family: fromText.font.family
			pixelSize: fromText.font.pixelSize
		}

		anchors {
			left: endSpinner.left
			bottom: fromText.bottom
		}
	}

	Rectangle {
		id: infoMessage
		height: Math.round(65 * verticalScaling)
		radius: designElements.radius
		color: colors.contentBackground

		anchors {
			top: startSpinner.bottom
			topMargin: Math.round(37 * verticalScaling)
			left: startSpinner.left
			right: endSpinner.right
		}

		Text {
			id: infoText
			text: p.txtNoOverlap
			anchors {
				fill: parent
				leftMargin: designElements.hMargin20
				rightMargin: designElements.hMargin20
				topMargin: designElements.vMargin10
				bottomMargin: designElements.vMargin10
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.italic.name
			}
			color: colors.foreground
			wrapMode: Text.WordWrap
			elide: Text.ElideRight
		}
	}

	WarningBox {
		id: warning
		height: Math.round(80 * verticalScaling)
		visible: (p.warningText !== "")
		warningText: p.warningText
		anchors {
			top: infoMessage.top
			left: infoMessage.left
			right: infoMessage.right
		}
	}
}
