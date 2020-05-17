.pragma library

var homePresetUuid = "2882d3da-d01c-4376-9d2c-9775e01f3200";
var sleepPresetUuid = "885df844-0801-4579-bfb4-dfa6b72313f6";
var awayPresetUuid = "25e0537e-c816-493b-b546-3c161c6552a3";
var comfortPresetUuid = "aef62078-7829-4009-a20f-c5b93d8cc570";


function createHvacPresets() {
	var hvacPresets = [
				{
				  "uuid": homePresetUuid,
				  "name": "home"
				},
				{
				  "uuid": sleepPresetUuid,
				  "name": "sleep"
				},
				{
				  "uuid": awayPresetUuid,
				  "name": "away"
				},
				{
				  "uuid": comfortPresetUuid,
				  "name": "comfort"
				}
			];

	return hvacPresets;
}

function createMinimalHvacSchedule() {
	var hvacSchedule = [
				{
				  "secondsSinceMondayMidnight": 0,
				  "presetUUID": awayPresetUuid
				}
			];

	return hvacSchedule;
}

function calcSec(day, hour, minute) {
	return (((day * 24) + hour) * 60 + minute) * 60;
}

function createEntry(preset, ssmm) {
	return {
		"secondsSinceMondayMidnight": ssmm,
		"presetUUID": preset
	};
}

function createDefaultHvacSchedule() {
	var hvacSchedule = [
				createEntry(homePresetUuid,    calcSec(0,  7, 0)),
				createEntry(awayPresetUuid,    calcSec(0,  8, 0)),
				createEntry(comfortPresetUuid, calcSec(0, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(0, 23, 0)),

				createEntry(homePresetUuid,    calcSec(1,  7, 0)),
				createEntry(awayPresetUuid,    calcSec(1,  8, 0)),
				createEntry(comfortPresetUuid, calcSec(1, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(1, 23, 0)),

				createEntry(homePresetUuid,    calcSec(2,  7, 0)),
				createEntry(awayPresetUuid,    calcSec(2,  8, 0)),
				createEntry(comfortPresetUuid, calcSec(2, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(2, 23, 0)),

				createEntry(homePresetUuid,    calcSec(3,  7, 0)),
				createEntry(awayPresetUuid,    calcSec(3,  8, 0)),
				createEntry(comfortPresetUuid, calcSec(3, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(3, 23, 0)),

				createEntry(homePresetUuid,    calcSec(4,  7, 0)),
				createEntry(awayPresetUuid,    calcSec(4,  8, 0)),
				createEntry(comfortPresetUuid, calcSec(4, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(4, 23, 0)),

				createEntry(homePresetUuid,    calcSec(5, 10, 0)),
				createEntry(comfortPresetUuid, calcSec(5, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(5, 23, 0)),

				createEntry(homePresetUuid,    calcSec(6, 10, 0)),
				createEntry(comfortPresetUuid, calcSec(6, 18, 0)),
				createEntry(sleepPresetUuid,   calcSec(6, 23, 0))
			];

	return hvacSchedule;
}

function blockEquals(block1, block2) {
	return  block1.startDayOfWeek === block2.startDayOfWeek &&
			block1.startHour      === block2.startHour &&
			block1.startMin       === block2.startMin &&
			block1.targetState    === block2.targetState &&
			block1.presetUuid     === block2.presetUuid;
}

function daysEqual(dayList1, dayList2, includeDummy) {
	if (dayList1.length !== dayList2.length) {
		return false;
	}

	if (typeof(includeDummy) === "undefined")
		includeDummy = true;

	for (var i = includeDummy ? 0 : 1; i < dayList1.length; ++i) {
		if (! blockEquals(dayList1[i], dayList2[i]))
			return false;
	}
	return true;
}

