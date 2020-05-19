import QtQuick 2.1
import BxtClient 1.0
import ScreenStateController 1.0

import qb.components 1.0
import qb.base 1.0;

/// Application to manage domestic hot water settings.

App {
	id: domesticHotWaterApp

	property url sidePanelUrl : "DHWSidePanel.qml"
	property url sidePanelButtonUrl : "DHWSidePanelButton.qml"
	property url weekProgramUrl : "DHWWeekProgramTab.qml"
	property url weekProgramButtonUrl : "DHWWeekProgramButton.qml"
	property url dhwFrameUrl: "DHWFrame.qml"
	property url dhwTemperatureSettingScreenUrl: "DHWTempSettingScreen.qml"
	property url hotWaterControlSwitchScreenUrl: "HotWaterControlSwitchScreen.qml"
	property url editDayUrl: "DHWEditDayScreen.qml"
	property url editBlockUrl: "DHWEditBlockScreen.qml"
	property url copyDayUrl: "DHWCopyDayScreen.qml"

	property int _DHW_STATE_UNKNOWN: -1
	property int _DHW_STATE_OFF: 0
	property int _DHW_STATE_ON:  1
	property int _DHW_STATE_ERROR: 2

	property int dhwState : _DHW_STATE_UNKNOWN
	property variant stateName:  [qsTr('Off'),   qsTr('On'), "unknown"]
	property variant stateColor: [colors.dhwOff, colors.dhwOn, colors._extragrey]

	property variant dhwProgram: [[], [], [], [], [], [], []]
	// When editing, contains an edited copy of the dhwProgram
	property variant dhwProgramEdited: null
	// True while editing (i.e. the DHWEditDayScreen is on the screen-stack)
	property bool dhwProgramEditing: false
	property bool dhwProgramEnabled: false

	property variant dhwAbsoluteEntries: []

	property string prominentWidgetUuid: ""
	property string prominentButtonUuid: ""
	property string programWidgetUuid: ""
	property string programButtonUuid: ""
	property string editDayScreenUuid: ""
	property string editBlockScreenUuid: ""
	property string copyDayScreenUuid: ""

	// State of current weekly schedule (int)
	property int curWeeklyScheduleState: 2
	// String of state of current weekly schedule (string)
	property string curWeeklyScheduleStateString: stateName[curWeeklyScheduleState]
	// Timestamp when current 'On' period ends (= next 'Off' transition) (timestamp int)
	property int nextWeeklyScheduledOffTimestamp
	// Complete string when current 'On' period end (= next 'Off' transition)
	property string nextWeeklyScheduledOffString: ""
	// Weekday/tomorrow when current 'On' period end
	property string nextWeeklyScheduledOffWhenString
	// Time when current 'On' period end
	property string nextWeeklyScheduledOffTimeString
	// Complete string when next 'On' period begins (string)
	property string nextWeeklyScheduledOnString: ""
	// Weekday when next 'On' period begins
	property string nextWeeklyScheduledOnWhenString
	// Time when next 'On' period begins
	property string nextWeeklyScheduledOnTimeString

	property string scheduleHash : ""
	property bool scheduleIsEmpty : false

	/*readonly*/ property string dhwScheduleId: "dhw"
	/*readonly*/ property string dhwScheduleName: "Domestic Hot Water Schedule"

	property variant boilerInfo: {
		'otBoiler' : false,
		'dhwTemp' : "-",
		'dhwTempMin': "-",
		'dhwTempMax': "-",
		'dhwPreheat' : false,
	}

	QtObject {
		id: p

		property variant supportedScheduleProperties: [
			'id',
			'name',
			'active',
			'weeklyEntries',
			'absoluteEntries',
		]

		property string thermostatUuid

		property string dhwSettingsFrameUuid: ""

		function parseDhwRestSchedule(restSchedule) {
			// iterators
			var i, j, k
			// List of 7 empty day entries
			var retProgram = [[], [], [], [], [], [], []];

			var restScheduleObj;
			try {
				restScheduleObj = JSON.parse(restSchedule);
			} catch (parseError) {
				console.log("Error while parsing DHW schedule:", parseError)
				return retProgram;
			}
			console.log("DHW schedule parsed succesfully")

			// Parse the active field from the Json object
			if (typeof(restScheduleObj.active) !== "undefined")
			{
				dhwProgramEnabled = restScheduleObj.active;
			} else {
				dhwProgramEnabled = false; // Default false
			}

			if (typeof(restScheduleObj.absoluteEntries) !== "undefined") {
				parseAbsoluteEntries(restScheduleObj.absoluteEntries);
			}

			// Reformat/parse the schedule
			var entries = restScheduleObj.weeklyEntries;
			for (i = 0; i < entries.length; ++i) {
				var entry = createEntryFromJSON(entries[i]);
				var dayIndex = scheduleUtil.dayToIndex(entries[i].dayOfWeek);
				entry['day'] = dayIndex;
				retProgram[dayIndex].push(entry);
			}
			// If we receive an empty schedule, create the placeholder entries for all days and we're done.
			if (entries.length === 0) {
				for (i = 0; i < 7; ++i) {
					entry = createEntry("off", 0, 0);
					entry['day'] = (i + 6) % 7; // = previous day (with wrap around)
					retProgram[i].push(entry);
				}
				return retProgram;
			}

			// Ensure entries are ordered
			for (j = 0; j < retProgram.length; ++j) {
				retProgram[j].sort(function(a,b) { return (a.startHour * 60 + a.startMinute) - (b.startHour * 60 + b.startMinute)});
			}

			// Copy the last entry of each day to the first entry of the next day
			// in order to deal with 'fall-through' of the schedule.
			// Use a temporary program to inspect so we're not confused by the
			// placeholder entries we're adding right now.
			var tmpProgram = cloneProgram(retProgram);
			for (j = 0; j < retProgram.length; ++j) {
				var yesterdayProgram;
				// Iterate backwards over the previous days until we find a non-empty one
				// This means we might end up back to the current day.
				for (k = 6; k >= 0; --k) {
					yesterdayProgram = tmpProgram[(j + k) % 7];
					// If we found a day with entries, we can use it's last entry
					if (yesterdayProgram.length !== 0) {
						break;
					}
				}
				var lastEntryYesterday = duplicateEntry(yesterdayProgram[yesterdayProgram.length - 1]);
				lastEntryYesterday['day'] = (j + k) % 7;
				retProgram[j].unshift(lastEntryYesterday);
			}

			// Log when we have:
			// - multiple 'on' entries in a row
			// - multiple 'off' entries in a row
			// Unfortunately, we don't have a way to highlight this in the console logging.
			for (j = 0; j < retProgram.length; ++j) {
				var curProgram = retProgram[j];
				for (k = 1; k < curProgram.length; ++k) {
					if (curProgram[k].targetState === curProgram[k - 1].targetState) {
						console.log("Multiple", stateName[curProgram[k].targetState] , "entries in a row found for day", j);
					}
				}
			}
			return retProgram;
		}

		function createEntryFromJSON(jsonEntry) {
			var timeArr = jsonEntry.startTime.split(":");
			return createEntry(jsonEntry.state, parseInt(timeArr[0]), parseInt(timeArr[1]));
		}

		// Transform our internal representation of a program to a schedule as defined by the REST API
		function program2DhwRestSchedule(tmpProgram) {
			var schedule = [];
			for (var i = 0; i < 7; ++i) {
				// Start at j = 1, to skip over the placeholder entry
				for (var j = 1; j < tmpProgram[i].length; j++) {
					schedule.push(entry2RestEntry(i, tmpProgram[i][j]));
				}
			}
			return schedule;
		}

		function entry2RestEntry(day, entry) {
			return {
				dayOfWeek: scheduleUtil.indexToDay(day),
				startTime: formatTime(entry.startHour, entry.startMinute),
				state: entry.targetState ? "on" : "off"
			};
		}

		function parseAbsoluteEntries(newAbsoluteEntries) {
			var tmpDhwAbsoluteEntries = [];
			for (var i = 0; i < newAbsoluteEntries.length; ++i) {
				tmpDhwAbsoluteEntries.push(createAbsoluteEntryFromJSON(newAbsoluteEntries[i]));
			}
			dhwAbsoluteEntries = tmpDhwAbsoluteEntries;
		}

		function createAbsoluteEntryFromJSON(jsonEntry) {
			var retVal = duplicateEntry(jsonEntry);

			retVal.startDateTime = qtUtils.fromISOString(jsonEntry.startDateTime);
			retVal.endDateTime = qtUtils.fromISOString(jsonEntry.endDateTime);

			return retVal;
		}

		function capitalizeString(str) {
			return str.charAt(0).toUpperCase() + str.slice(1);
		}
	}

	QtObject {
		id: scheduleUtil
		// Perhaps we can remove these utility functions to something like Util.qml?

		function dayToIndex(dayString) {
			switch (dayString) {
			case "sun": return 0;
			case "mon": return 1;
			case "tue": return 2;
			case "wed": return 3;
			case "thu": return 4;
			case "fri": return 5;
			case "sat": return 6;
			default: return -1;
			}
		}
		function indexToDay(dayIndex) {
			switch (dayIndex) {
			case 0: return "sun";
			case 1: return "mon";
			case 2: return "tue";
			case 3: return "wed";
			case 4: return "thu";
			case 5: return "fri";
			case 6: return "sat";
			default: return "";
			}
		}
	}

	function init() {
		registry.registerWidget("screen", dhwTemperatureSettingScreenUrl, domesticHotWaterApp, null, {lazyLoadScreen: true});
		checkFeatures();
		globals.thermostatFeaturesChanged.connect(checkFeatures);
	}

	function checkFeatures() {
		if (globals.thermostatFeatures["FF_Dhw_UiElements_Settings"]) {
			if (registry.getWidgetInfo("screen", hotWaterControlSwitchScreenUrl) === undefined) {
				registry.registerWidget("screen", hotWaterControlSwitchScreenUrl, domesticHotWaterApp, null, {lazyLoadScreen: true});
			}
		}
		checkShowHotWaterControls();
		checkShowHotWaterFrame();
	}

	function toggleShowHotWaterControls(toggle) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "specific1", "SetFeatureToggleState");

		// Toggle T_Dhw_UiElements_usr is mapped to feature flag FF_Dhw_UiElements
		msg.addArgument("toggle","FT_Dhw_UiElements_usr");
		msg.addArgument("state", toggle ? 1 : 0);
		bxtClient.sendMsg(msg);
	}

	function cloneProgram(prog) {
		// Use JSON to clone the JS object
		// See https://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-deep-clone-an-object-in-javascript
		return JSON.parse(JSON.stringify(prog));
	}

	function cloneProgramDay(progDay) {
		return JSON.parse(JSON.stringify(progDay));
	}

	function sundayBaseToMondayBase(dayIdx) {
		return (dayIdx + 6) % 7;
	}

	function mondayBaseToSundayBase(dayIdx) {
		return (dayIdx + 1) % 7;
	}

	function formatTime(hour, minute) {
		if (hour === -1) hour = 0;
		if (minute === -1) minute = 0;
		return hour + ':' + (minute < 10 ? '0' : '') + minute
	}

	function programIsEmpty(program) {
		for (var i = 0; i < 7; ++i) {
			// If the program contains more than just the placeholder entry for a day, then it's not empty.
			if (program[i].length > 1) {
				return false;
			}
		}
		return true;
	}

	// program = app.dhwProgram OR app.dhwProgramEdited (or any local copy of those)
	// dayIdx 0 = sunday
	function getNextEntry(program, dayIdx, entryIdx) {
		var entry;
		if (entryIdx === program[dayIdx].length - 1) {
			for (var i = 1; i <= 7; ++i) {
				var day = (dayIdx + i) % 7;
				if (program[day].length >= 2) {
					entry = program[day][1];
					entry['day'] = day;
					break;
				}
			}
		} else {
			entry = program[dayIdx][entryIdx + 1];
			entry['day'] = dayIdx;
		}
		return entry;
	}

	// program = app.dhwProgram OR app.dhwProgramEdited (or any local copy of those)
	// dayIdx 0 = sunday
	function getPrevEntry(program, dayIdx, entryIdx) {
		var entry;
		if (entryIdx === 0 || entryIdx === 1) {
			for (var i = 6; i >= 0; --i) {
				var day = (dayIdx + i) % 7;
				if (program[day].length >= 2) {
					entry = program[day][program[day].length - 1];
					entry['day'] = day;
					break;
				}
			}
		} else {
			entry = program[dayIdx][entryIdx - 1];
			entry['day'] = dayIdx;
		}
		return entry;
	}

	function createEntry(targetState, startHour, startMinute, startDay) {
		var targetStateIndex;
		switch (targetState) {
		case _DHW_STATE_ON:
		case "on": targetStateIndex = _DHW_STATE_ON; break;

		case _DHW_STATE_OFF:
		case "off": targetStateIndex = _DHW_STATE_OFF; break;

		default: targetStateIndex = _DHW_STATE_ERROR; break; // Unknown
		}

		return { "targetState": targetStateIndex, "startHour": startHour, "startMinute": startMinute , "day": startDay};
	}

	function duplicateEntry(entry) {
		return JSON.parse(JSON.stringify(entry));
	}

	function entryIsEqual(entryA, entryB) {
		return (entryA.targetState === entryB.targetState &&
				entryTimeIsEqual(entryA, entryB));
	}

	function entryTimeIsEqual(entryA, entryB) {
		return (entryA.day         === entryB.day &&
				entryA.startHour   === entryB.startHour &&
				entryA.startMinute === entryB.startMinute);
	}

	// Both sourceDayIndex and the indices in targetDaysList are sunday-based
	function copyDayToDays(tmpProgram, sourceDayIndex, targetDaysList) {
		if (targetDaysList.indexOf(sourceDayIndex) !== -1) {
			console.log("Cannot copy day to itself!");
			return tmpProgram;
		}

		var sourceDay = tmpProgram[sourceDayIndex];

		var isSourceDayConstantOn = sourceDay.length === 1 && sourceDay[0].targetState === 1;

		// Copy to the selected days
		for (var i = 0; i < targetDaysList.length; ++i) {
			var targetDayIndex = targetDaysList[i];
			tmpProgram[targetDayIndex] = cloneProgramDay(sourceDay);
			for (var j = 1; j < tmpProgram[targetDayIndex].length; ++j) {
				tmpProgram[targetDayIndex][j].day = targetDayIndex;
			}
		}

		// Now, let's see if we ended up with a mismatch between the first and last entries of each day.
		for (i = 0; i < 7; ++i) {
			var prevDayIndex = (i + 6) % 7;
			var prevDay = tmpProgram[prevDayIndex];
			if (prevDay[prevDay.length - 1].targetState !== tmpProgram[i][0].targetState) {
				// Insert an entry at the beginning, unless there is one already there (at 0:00)
				if (tmpProgram[i].length >= 2 && tmpProgram[i][1].startHour === 0 && tmpProgram[i][1].startMinute === 0) {
					// If there is an entry at 0:00, it is the opposite of the placeholder, meaning
					// it is the same as the last entry of the previous day. Because it's the same
					// we can just remove it and be done.
					tmpProgram[i].splice(1, 1);
					tmpProgram[i].splice(0, 1, duplicateEntry(getPrevEntry(tmpProgram, i, 0)));
				} else {
					tmpProgram[i].splice(1, 0, createEntry(tmpProgram[i][0].targetState, 0, 0));
				}
			}
		}

		updatePlaceholdersInProgram(tmpProgram);

		if (isSourceDayConstantOn && tmpProgram[sourceDayIndex][0].targetState === 0) {
			// User tried to copy a day so that the schedule is constantly on.
			// This isn't allowed, so make sure to block this.
			console.log("Tried to create a constant On schedule by copying. Operation rejected.");
			return undefined;
		}

		return tmpProgram;
	}

	function updatePlaceholdersInProgram(tmpProgram) {
		var i;
		// If we've created an empty schedule, update the placeholder entries for all days.
		if (programIsEmpty(tmpProgram)) {
			for (i = 0; i < 7; ++i) {
				var entry = createEntry("off", 0, 0);
				entry['day'] = (i + 6) % 7;
				tmpProgram[i].splice(0, 1, entry);
			}
		} else {
			// Replace first entry of next day with copy of last entry of current day
			for (i = 0; i < 7; ++i) {
				tmpProgram[i].splice(0, 1, duplicateEntry(getPrevEntry(tmpProgram, i, 0)));
			}
		}
	}

	function checkShowHotWaterFrame() {
		if (globals.thermostatFeatures["FF_Dhw_PreHeat_Settings"] || globals.thermostatFeatures["FF_Dhw_UiElements_Settings"]) {
			// If we haven't added the Hot Water frame yet -> add it
			if (registry.getWidgetInfo("settingsFrame", dhwFrameUrl) === undefined) {
				p.dhwSettingsFrameUuid = registry.registerWidget("settingsFrame", dhwFrameUrl, domesticHotWaterApp, null, {categoryName: qsTr("Hot water"), categoryWeight: 310});
			}
		} else {
			if (registry.getWidgetInfo("settingsFrame", dhwFrameUrl) !== undefined) {
				registry.deregisterWidget(p.dhwSettingsFrameUuid);
				p.dhwSettingsFrameUuid = "";
			}
		}
	}

	function checkShowHotWaterControls() {
		if (globals.thermostatFeatures["FF_Dhw_UiElements"]) {

			// Only register screens once
			if (registry.getWidgetInfo("prominent", sidePanelUrl) === undefined) {
				prominentWidgetUuid = registry.registerWidget("prominent", sidePanelUrl, domesticHotWaterApp);
			}
			if (registry.getWidgetInfo("prominentTabButton", sidePanelButtonUrl) === undefined) {
				prominentButtonUuid = registry.registerWidget("prominentTabButton", sidePanelButtonUrl, domesticHotWaterApp);
			}
			if (registry.getWidgetInfo("weekProgramContent", weekProgramUrl) === undefined) {
				programWidgetUuid = registry.registerWidget("weekProgramContent", weekProgramUrl, domesticHotWaterApp);
			}
			if (registry.getWidgetInfo("weekProgramTab", weekProgramButtonUrl) === undefined) {
				programButtonUuid = registry.registerWidget("weekProgramTab", weekProgramButtonUrl, domesticHotWaterApp);
			}

			if (editDayScreenUuid === "")
				editDayScreenUuid = registry.registerWidget("screen", editDayUrl, domesticHotWaterApp, null, {lazyLoadScreen: true});
			if (editBlockScreenUuid === "")
				editBlockScreenUuid = registry.registerWidget("screen", editBlockUrl, domesticHotWaterApp, null, {lazyLoadScreen: true});
			if (copyDayScreenUuid === "")
				copyDayScreenUuid = registry.registerWidget("screen", copyDayUrl, domesticHotWaterApp, null, {lazyLoadScreen: true});

			getDHWSchedule();
		} else {
			registry.deregisterWidget(prominentButtonUuid);
			registry.deregisterWidget(prominentWidgetUuid);
			registry.deregisterWidget(programButtonUuid);
			registry.deregisterWidget(programWidgetUuid);

			// Unfortunately, Stage.qml doesn't support deregistering screens at the moment.
			// Workaround: only register the screen once.
			//registry.deregisterWidget(editDayScreenUuid);
			//registry.deregisterWidget(editBlockScreenUuid);
			//registry.deregisterWidget(copyDayScreenUuid);

			prominentButtonUuid = "";
			prominentWidgetUuid = "";
			programButtonUuid = "";
			programWidgetUuid = "";

			//editDayScreenUuid = "";
			//editBlockScreenUuid = "";
			//copyDayScreenUuid = "";
		}
	}

	function onThermostatInfoChanged(update) {
		var newDhwState;
		var auxRelayState = update.getChildText("auxRelayState");
		switch (auxRelayState) {
		case "0":
			newDhwState = _DHW_STATE_OFF;
			break;
		case "1":
			newDhwState = _DHW_STATE_ON;
			break;
		case null:
		case "":
		default:
			newDhwState = _DHW_STATE_ERROR;
			break;
		}

		if (dhwState !== newDhwState) {
			console.log("Setting dhwState to", newDhwState);
			dhwState = newDhwState;
		}

		var tempBoilerInfo = boilerInfo;
		tempBoilerInfo['otBoiler'] = parseInt(update.getChildText("haveOTBoiler")) == 1;
		boilerInfo = tempBoilerInfo;
	}

	function updateNextTransitionString() {
		if (dhwProgramEnabled === false || scheduleIsEmpty) {
			nextWeeklyScheduledOffString = "";
			nextWeeklyScheduledOnString = "";
		} else {
			// Set scheduled off string
			if (curWeeklyScheduleState === 0) {
				nextWeeklyScheduledOffString = "";
			} else if (nextWeeklyScheduledOffWhenString === "") {
				// No "next" string, so interpret as "today"
				nextWeeklyScheduledOffString = qsTr("until %1").arg(nextWeeklyScheduledOffTimeString);
			} else {
				nextWeeklyScheduledOffString = qsTr("until %1 at %2").arg(nextWeeklyScheduledOffWhenString).arg(nextWeeklyScheduledOffTimeString);
			}
			nextWeeklyScheduledOffString = p.capitalizeString(nextWeeklyScheduledOffString);

			// Set scheduled on string
			if (nextWeeklyScheduledOnWhenString === "") {
				// No "next" string, so interpret as "today"
				nextWeeklyScheduledOnString = qsTr("At %1 set to %2").arg(nextWeeklyScheduledOnTimeString).arg(stateName[1]);
			} else {
				nextWeeklyScheduledOnString = qsTr("%1 at %2 set to %3").arg(nextWeeklyScheduledOnWhenString).arg(nextWeeklyScheduledOnTimeString).arg(stateName[1]);
			}
			nextWeeklyScheduledOnString = p.capitalizeString(nextWeeklyScheduledOnString);
		}
	}

	function jsonStateStringToState(stateString) {
		switch (stateString) {
		case "off":
			return _DHW_STATE_OFF;
		case "on":
			return _DHW_STATE_ON;
		default:
			return _DHW_STATE_ERROR;
		}
	}

	// timestamp in seconds
	function timestampToWhenTimeString(timestamp) {
		var whenTime = { when: "", time: "" };

		const MILLISECONDS_IN_A_DAY = 1000 * 60 * 60 * 24;

		var now = new Date();
		var transitionDate = new Date(timestamp * 1000);

		// 'when' string must contain an indication to the user when the next transition is scheduled.
		if (transitionDate.getTime() - now.getTime() < MILLISECONDS_IN_A_DAY) {
			// Within 24 hours, we don't have to say on which day (even if it is tomorrow)
			whenTime.when = "";
		} else if (transitionDate.getDay() == now.getDay()) {
			if (transitionDate.getTime() - now.getTime() > MILLISECONDS_IN_A_DAY) {
				// next week
				whenTime.when = qsTr("next") + " " + i18n.daysFull[transitionDate.getDay()];
			} else {
				// Today
				whenTime.when = "";
			}
		} else if ((now.getDay()+1) % 7 == transitionDate.getDay()) {
			whenTime.when = qsTr("tomorrow");
		} else {
			whenTime.when = i18n.daysFull[transitionDate.getDay()]
		}

		whenTime.time = formatTime(transitionDate.getHours(), transitionDate.getMinutes())

		return whenTime;
	}

	function handleScheduleRuntimeChanged(update) {

		var restScheduleRuntimeObj;
		try {
			restScheduleRuntimeObj = JSON.parse(update.text);
		} catch (parseError) {
			console.log("Error while parsing DHW schedule runtime:", parseError)
			return;
		}
		console.log("Schedule Runtime info parsed succesfully")

		for(var scheduleId in restScheduleRuntimeObj) {
			if (scheduleId === dhwScheduleId) {
				var thisSchedule = restScheduleRuntimeObj[scheduleId];

				if (thisSchedule.stateTransitions.length >= 3 ) {
					/* The first 'state transition' element is the most recent state transition
					 * and defines the current state. The second element is the first transition to come.
					 */
					curWeeklyScheduleState = jsonStateStringToState(thisSchedule.stateTransitions[0].state);

					var nextOffTransitionIndex;
					var nextOnTransitionIndex;
					if (thisSchedule.stateTransitions[1].state === "off") {
						nextOffTransitionIndex = 1;
						nextOnTransitionIndex = 2;
					} else {
						nextOnTransitionIndex = 1;
						nextOffTransitionIndex = 2;
					}
					nextWeeklyScheduledOffTimestamp = parseInt(thisSchedule.stateTransitions[nextOffTransitionIndex].startTimestamp);

					var offWhenTime = timestampToWhenTimeString(parseInt(thisSchedule.stateTransitions[nextOffTransitionIndex].startTimestamp));
					nextWeeklyScheduledOffWhenString = offWhenTime.when;
					nextWeeklyScheduledOffTimeString = offWhenTime.time;

					var nextOnWhenTime = timestampToWhenTimeString(parseInt(thisSchedule.stateTransitions[nextOnTransitionIndex].startTimestamp));
					nextWeeklyScheduledOnWhenString = nextOnWhenTime.when;
					nextWeeklyScheduledOnTimeString = nextOnWhenTime.time;

					scheduleIsEmpty = false;
				} else {
					/* State transitions array is empty. This means there is no
					 * schedule, although it may be active.
					 */
					console.log("Schedule with Id ", scheduleId, " is empty");
					scheduleIsEmpty = true;
				}

				scheduleHash = thisSchedule.scheduleHash;

				dhwProgramEnabled = restScheduleRuntimeObj[scheduleId].active;
				updateNextTransitionString();

				break;
			}
		}
	}

	function getDWHInfo() {
		var getDWHInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetDhwSettings");
		bxtClient.sendMsg(getDWHInfoMessage);
	}

	function storeDHWInfo() {
		var setDHWInfoMessage = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetDhwSettings");
		setDHWInfoMessage.addArgument("dhwEnabled", boilerInfo.dhwPreheat ? 1 : 0);
		setDHWInfoMessage.addArgument("dhwSetpoint", boilerInfo.dhwTemp);
		bxtClient.sendMsg(setDHWInfoMessage);
	}

	function setDHWTemp(temp) {
		var tmpInfo = boilerInfo;
		tmpInfo.dhwTemp = temp;
		boilerInfo = tmpInfo;
		storeDHWInfo();
	}

	function setDHWEnabled(enabled) {
		var tmpInfo = boilerInfo;
		tmpInfo.dhwPreheat = enabled;
		boilerInfo = tmpInfo;
		storeDHWInfo();
	}

	function getDHWSchedule() {
		var getScheduleMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Schedule", "GetScheduleById");
		var getBody = { id : dhwScheduleId };
		getScheduleMessage.addArgument("body", JSON.stringify(getBody));
		bxtClient.doAsyncBxtRequest(getScheduleMessage, getDHWScheduleCallback, 30);
	}

	function creatDHWSchedule() {
		var createScheduleMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Schedule", "CreateSchedule");
		var triggerDefaultSchedule = { id: dhwScheduleId, name: dhwScheduleName, weeklyEntries: [] };
		var triggerDefaultScheduleJSON = JSON.stringify(triggerDefaultSchedule);
		createScheduleMessage.addArgument("body", triggerDefaultScheduleJSON);
		bxtClient.doAsyncBxtRequest(createScheduleMessage, createDHWScheduleCallback, 30);
	}

	function updateDHWSchedule(argProgram) {
		var tmpProgram = p.program2DhwRestSchedule(argProgram);

		// TODO:: Update is removed from the schedule API, remove function also entirely from UI.
		// For now prepare call to patch schedule with same parameters (This avoid extra testing work)
		var updateBody = { id: dhwScheduleId, name: dhwScheduleName, active: dhwProgramEnabled, weeklyEntries: tmpProgram };
		patchDHWSchedule(updateBody);
	}
	
	function patchDHWSchedule(schedulePatch) {
		if (schedulePatch && schedulePatch !== "undefined") {

			// Check the supplied entries against a const array containing the parent elements in the patch json schema
			for (var prop in schedulePatch) {
				if (p.supportedScheduleProperties.indexOf(prop) < 0 ) {
					console.log("Error: Invalid property given for patching the DHW schedule: " + prop);
					return;
				}
			}

			// Check if the DHW schedule is is already given. If not add it
			if (!('id' in schedulePatch)) {
				schedulePatch['id'] = dhwScheduleId;
			}

			// Add the schedule patch to the body
			var patchScheduleBodyJSON  = JSON.stringify(schedulePatch);

			// Create an empty bxt msg
			var patchScheduleMessage =  bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Schedule", "PatchSchedule");
			// Add the newly created JSON body to it
			patchScheduleMessage.addArgument("body", patchScheduleBodyJSON);

			bxtClient.doAsyncBxtRequest(patchScheduleMessage, getDHWScheduleCallback, 30);
		} else {
			console.log("Error invalid DHW schedule patch given!");
		}
	}

	function addBoostPeriod() {
		var newOffTime;
		var newStartTime = (new Date()).getTime();

		const MAX_BOOST_TIME = 23 * 60 * 60 * 1000;
		const BOOST_TIME     =      60 * 60 * 1000;

		// If the weekly program is enabled
		if (dhwProgramEnabled) {
			// and the weekly program is not empty
			if (dhwState === _DHW_STATE_ON) {
				// we want to extend the current on period

				// So, lets see if we already have an absolute entry, because then we should extend that one
				if (dhwAbsoluteEntries.length > 0 && dhwAbsoluteEntries[0].endDateTime.getTime() > 0) {
					newStartTime = dhwAbsoluteEntries[0].startDateTime.getTime();
					newOffTime = dhwAbsoluteEntries[0].endDateTime.getTime() + BOOST_TIME;
					if (newOffTime - newStartTime > MAX_BOOST_TIME) {
						// Can't boost more than 23 hours.
						newOffTime = dhwAbsoluteEntries[0].endDateTime.getTime();
					}
				} else if (!scheduleIsEmpty) {
					// If we don't have an absolute entry, but do have a program,
					// add an absolute entry at the end of the current 'On' period
					newStartTime = nextWeeklyScheduledOffTimestamp * 1000;
					newOffTime =   nextWeeklyScheduledOffTimestamp * 1000 + BOOST_TIME;
				} else {
					// Shouldn't happen? Just in case we're 'On', but not because of a weekly or absolute schedule...
					// just boost for one hour.
					newOffTime = (new Date()).getTime() + BOOST_TIME;
				}
			} else {
				// If we're currently off, start from now for 1 hour. This will turn
				// 'On' the dhwState, so next time the button is pressed it will be handled by
				// the previous branch.
				newOffTime = (new Date()).getTime() + BOOST_TIME;
			}
		} else {
			// If the program is not enabled, we don't need to take the current/next entries into account
			// and we can just inspect if there is already an absolute entry for boost.
			if (dhwAbsoluteEntries.length > 0 && dhwAbsoluteEntries[0].endDateTime.getTime() > 0) {
				// Extend the existing absolute entry by 1 hour
				newOffTime = dhwAbsoluteEntries[0].endDateTime.getTime() + BOOST_TIME;
				if (newOffTime - newStartTime > MAX_BOOST_TIME) {
					// Can't boost more than 23 hours.
					newOffTime = dhwAbsoluteEntries[0].endDateTime.getTime();
				}
			} else {
				// Start an absolute boost entry for 1 hour.
				newOffTime = (new Date()).getTime() + BOOST_TIME;
			}

		}
		var startDateTime = Math.floor(newStartTime/1000);
		var endDateTime = Math.floor(newOffTime/1000);

		patchDHWSchedule({absoluteEntries:[
								 {startDateTime: qtUtils.toISOString(startDateTime),
									 endDateTime: qtUtils.toISOString(endDateTime),
									 state: "on"}
							 ]
						 });
	}

	onScheduleHashChanged: {
		getDHWSchedule();
	}

	onDhwProgramEnabledChanged: {
		updateNextTransitionString();
	}

	BxtDiscoveryHandler {
		id: thermstatDiscoHandler
		deviceType: "happ_thermstat"
		onDiscoReceived: {
			p.thermostatUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: thermstatInfoDsHandler
		dataset: "thermostatInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: onThermostatInfoChanged(update)
	}

	BxtDatasetHandler {
		id: scheduleRuntimeDsHandler
		dataset: "scheduleRuntime"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: handleScheduleRuntimeChanged(update)
	}

	BxtResponseHandler {
		response: "GetDhwSettingsResponse"
		serviceId: "Thermostat"
		onResponseReceived: {
			var newBoilerInfo = boilerInfo;

			newBoilerInfo.dhwTemp = message.getArgument("dhwSetpoint");
			newBoilerInfo.dhwPreheat = message.getArgument("dhwEnabled") == 1;

			var dhwMin = message.getArgument("dhwMinSetpoint");
			if (dhwMin === "0") { dhwMin = "40"; }
			newBoilerInfo.dhwTempMin = dhwMin;

			var dhwMax = message.getArgument("dhwMaxSetpoint");
			if (dhwMax === "0") { dhwMax = "90"; }
			newBoilerInfo.dhwTempMax = dhwMax;

			boilerInfo = newBoilerInfo;
		}
	}

	BxtRequestCallback {
		id: getDHWScheduleCallback
		onMessageReceived: {
			var responseCodeText = message.getArgument("response");
			if (responseCodeText === "404") {
				// Return code is HTTP_NOT_FOUND which means schedule does not exist yet
				console.log("Creating a new DHW schedule with scheduleId: " + dhwScheduleId);
				creatDHWSchedule();
				return;
			} else if (responseCodeText !== "200") {
				// Return code is not HTTP_OK
				console.log(message.stringContent);
				console.log("Unexpected response code (", responseCodeText, ") to request for DHW schedule.");
				return;
			}

			var bodyText = message.getArgument("body");
			if (typeof bodyText === "undefined" || bodyText === "") {
				console.log(message.stringContent);
				console.log("Could not get body text from request for DHW schedule.");
				return;
			}

			dhwProgram = p.parseDhwRestSchedule(bodyText);
		}
	}

	BxtRequestCallback {
		id: createDHWScheduleCallback
		onMessageReceived: {
			var responseCodeText = message.getArgument("response");
			if (responseCodeText !== "200") {
				console.log(message.stringContent);
				console.log("Unexpected response code (", responseCodeText, ") to create a DHW schedule.");
				return;
			}
			// Now get the newly created (default) schedule
			getDHWSchedule();
		}
	}
}
