import QtQuick 2.1
import BxtClient 1.0
import ThermostatUtils 1.0
import ScreenStateController 1.0

import qb.components 1.0
import qb.base 1.0;

/// Application to manage thermostat settings.

App {
	id: thermostatApp

	property url editBlockScreenUrl : "EditBlockScreen.qml"
	property url vacationSetScreenUrl : "VacationSetScreen.qml"
	property url vacationDateScreenUrl : "VacationDateScreen.qml"
	property url copyProgramDayScreenUrl : "CopyProgramDayScreen.qml"
	property url vacationOverviewScreenUrl : "VacationOverviewScreen.qml"
	property url temperaturePresetScreenUrl : "TemperaturePresetScreen.qml"
	property url sidePanelUrl : "ThermostatSidePanel.qml"
	property url sidePanelButtonUrl : "ThermostatSidePanelButton.qml"
	property url tipsPopupUrl: "qrc:/qb/components/TipsPopup.qml"
	property url thermostatWeekProgramUrl : "ThermostatWeekProgramTab.qml"
	property url thermostatWeekProgramButtonUrl : "ThermostatWeekProgramButton.qml"
	property url temporaryOverridePopupUrl : "TemporaryOverridePopup.qml"

	// for unit tests
	property BxtDatasetHandler tst_thermInfoHandler: thermstatInfoDsHandler
	property BxtDatasetHandler tst_thermStatesHandler: thermstatStatesDsHandler

	property bool programEnabled: false

	//Edit day screen
	property Screen editDayScreen

	property variant tmpVacationData: ({})
	property variant vacationData : {
		'temperature': 6.0,
		'startTime': 0,
		'endTime' : 0,
		'entryId' : ""
	}

	property int currentConfigRandomId: 0
	property variant thermostatProgram : [ ]
	property variant thermostatProgramEdited: []
	property bool programWasEdited: false
	property Screen programScreen
	property Popup waitPopup

	property variant thermInfo : {
		'currentTemp': 0,
		'currentSetpoint': 0,
		'currentDisplayTemp': 0,
		'realSetpoint': 0,
		'programState': 0,
		'setByLoadShifting': 0,
		'activeState': 0,
		'nextProgram': 0,
		'nextState': 0,
		'nextTime': 0,
		'nextSetpoint': 0,
		'randomConfigId': 0,
		'errorFound': 0,
		'hasBoilerFault': 0,
		'boilerModuleConnected': 0,
		'zwaveOthermConnected' : 0,
		'burnerInfo': 0,
		'preheating': 0,
		'otCommError': 0,
		'currentModulationLevel': 0,
		'haveOTBoiler': 0
	}

	property variant thermStates : {
		'thermStateRelax':   { 'temperature': 20.0, 'dhw': 0, 'index': thermStateRelax },
		'thermStateActive':  { 'temperature': 18.0, 'dhw': 0, 'index': thermStateActive },
		'thermStateSleep':   { 'temperature': 15.0, 'dhw': 0, 'index': thermStateSleep },
		'thermStateAway':    { 'temperature': 12.0, 'dhw': 0, 'index': thermStateAway },
		'thermStateHoliday': { 'temperature':  6.0, 'dhw': 0, 'index': thermStateHoliday },
		'thermStateUnknown': { 'temperature':  6.0, 'dhw': 0, 'index': thermStateUnknown }
	}

	property variant maxEcoTemperatures : { 'comfort': 19, 'home': 19, 'sleep': 15, 'away': 15 }

	property variant thermStatesMap : ['thermStateRelax', 'thermStateActive', 'thermStateSleep', 'thermStateAway', 'thermStateHoliday', 'thermStateUnknown']
	property variant thermStateName : p.enableSME ? [ qsTr('Comfort'), qsTr('Open'), qsTr('Closed'), qsTr('Away'), qsTr('Vacation') ] : [ qsTr('Comfort'), qsTr('Home'), qsTr('Sleep'), qsTr('Away'), qsTr('Vacation') ]
	property variant thermStateColor : p.enableSME ? [colors.tpModeComfort, colors.tpModeAway, colors.tpModeSleep, colors.tpModeHome] : [colors.tpModeComfort, colors.tpModeHome, colors.tpModeSleep, colors.tpModeAway]
	property variant thermStateMaxEcoTemperature : [maxEcoTemperatures['comfort'], maxEcoTemperatures['home'], maxEcoTemperatures['sleep'], maxEcoTemperatures['away'], maxEcoTemperatures['away']]
	property double currentMaxEcoTemperature: maxEcoTemperatures['home'];

	property variant boilerErrorInfo: {
		'errorActive': false,
		'SCDataReady': false,
		'errorCode': 255,
		'errorTitle': ''
	}

	property variant heatRecoveryInfo

	//thermStates
	property int thermStateUndef  : -1
	property int thermStateRelax  : 0
	property int thermStateActive : 1
	property int thermStateSleep  : 2
	property int thermStateAway   : 3
	property int thermStateHoliday: 4
	property int thermStateUnknown: 5
	property int thermStateManual : 6

	//programStates
	property int progStateUndefinedState     : -1
	property int progStateManualControl      : 0
	property int progStateBaseScheme         : 1
	property int progStateTemperatureOverride: 2
	property int progStateHoliday            : 4
	property int progStateLockedBaseScheme   : 8

	property bool programFirstUse: true
	property variant programFirstRunTexts : {
		'programFirstRunTitle': qsTr("programFirstRunTitle"),
		'programFirstRunText': qsTr("programFirstRunText"),
		'programFirstRunButtonText': qsTr("programFirstRunButtonText")
	}

	//burner states
	property int burnerOff : 0
	// Normal heating
	property int burnerOn : 1
	// Heating for hot water
	property int burnerDhw : 2
	//Preheating for the next setpoint
	property int burnerPreheat : 3

	property bool thermostatStatesSaved: false
	property bool vacationRunning: false
	property bool hasVacation: false
	property bool setByLoadShifting: false

	property bool hasHeatRecovery: feature.appHeatRecoveryEnabled() && typeof heatRecoveryInfo !== "undefined"
	property bool hasSmartHeat: globals.features["pilot-UtrechtWarmte"] === true

	signal thermostatProgramLoaded
	signal vacationSet

	QtObject {
		id: p

		property url temperaturePresetImageUrl : "drawables/Temperature.svg"
		/// vacation related
		property url vacationImageUrl : "drawables/vacation.svg"
		property url programScreenUrl : "ThermostatProgramScreen.qml"
		property url programImageUrl : "drawables/program.svg"
		property url vacationSystrayUrl: "VacationSystray.qml"

		property url editDayScreenUrl : "EditDayScreen.qml"
		property url waitPopupUrl: "qrc:/qb/components/WaitPopup.qml"

		property string thermostatUuid
		property string hcbConfigUuid
		property string eventmgrUuid

		property variant homescreenPopup: {'priority': 100, 'uuid': 'vacationActive'}

		property bool enableSME: globals.productOptions["SME"] === "1"

		function unregisterHsPopup() {
			stage.unregisterHomescreenPopup(p.homescreenPopup.uuid);
		}

		function getDefaultTempPresets(SME_defaults) {
			if (SME_defaults)
				return {'thermStateRelax': 20,
						 'thermStateActive': 18,
						 'thermStateSleep': 12,
						 'thermStateAway': 15
						};
			else
				return {'thermStateRelax': 20,
						 'thermStateActive': 18,
						 'thermStateSleep': 15,
						 'thermStateAway': 12
						};
		}

		function compareTempPresets(presets) {
			return  thermStates.thermStateRelax.temperature === presets.thermStateRelax &&
					thermStates.thermStateActive.temperature === presets.thermStateActive &&
					thermStates.thermStateSleep.temperature === presets.thermStateSleep &&
					thermStates.thermStateAway.temperature === presets.thermStateAway;
		}

		function onSMEFeatureChanged() {
			var oldDefaultProgram = p.enableSME ? ThermostatUtils.getDefaultSchedule() : ThermostatUtils.getDefaultBusinessSchedule();
			var oldDefaultPresets = p.getDefaultTempPresets(!p.enableSME);
			if (ThermostatUtils.comparePrograms(thermostatProgram, oldDefaultProgram) &&
					p.compareTempPresets(oldDefaultPresets)) {
				var newPresets = p.getDefaultTempPresets(p.enableSME);
				updateTemperaturePreset(newPresets, function() {
					// on callback of the first store config (temp presets), do the second one (program)
					var newProgram = p.enableSME ? ThermostatUtils.getDefaultBusinessSchedule() : ThermostatUtils.getDefaultSchedule();
					newProgram = ThermostatUtils.swapHoliday(thermostatProgram, newProgram);
					storeThermostatProgram(newProgram);
					getThermostatProgram();
				});
			}
		}

		function parseHeatRecoveryInfo(node) {
			var tempNode = node.child;
			if (tempNode) {
				var tempInfo = heatRecoveryInfo;
				if (isUndef(tempInfo))
					tempInfo = {};

				while (tempNode) {
					tempInfo[tempNode.name] = parseInt(tempNode.text);
					tempNode = tempNode.sibling;
				}
				heatRecoveryInfo = tempInfo;
			} else {
				heatRecoveryInfo = undefined;
			}
		}
	}

	function init() {
		registry.registerWidget("screen", temperaturePresetScreenUrl, thermostatApp);
		registry.registerWidget("menuItem", null, thermostatApp, null, {objectName: "temperatureMenuItem", label: qsTr("Temperature"), image: p.temperaturePresetImageUrl, screenUrl: temperaturePresetScreenUrl, weight: 20});
		registry.registerWidget("prominent", sidePanelUrl, thermostatApp);
		registry.registerWidget("prominentTabButton", sidePanelButtonUrl, thermostatApp);
		registry.registerWidget("screen", vacationOverviewScreenUrl, thermostatApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", vacationSetScreenUrl, thermostatApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", vacationDateScreenUrl, thermostatApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.programScreenUrl, thermostatApp, "programScreen");
		registry.registerWidget("menuItem", null, thermostatApp, null, {objectName: "programMenuItem", label: qsTr("Program"), image: p.programImageUrl, screen: "programScreen", weight: 10});
		registry.registerWidget("screen", copyProgramDayScreenUrl, thermostatApp, null, {lazyLoadScreen: true});
		registry.registerWidget("screen", p.editDayScreenUrl, thermostatApp, "editDayScreen");
		registry.registerWidget("screen", editBlockScreenUrl, thermostatApp, null, {lazyLoadScreen: true});
		registry.registerWidget("popup", p.waitPopupUrl, thermostatApp, "waitPopup");
		registry.registerWidget("weekProgramContent", thermostatWeekProgramUrl, thermostatApp);
		registry.registerWidget("weekProgramTab", thermostatWeekProgramButtonUrl, thermostatApp);

		if (!hasSmartHeat) {
			registry.registerWidget("menuItem", null, thermostatApp, null, {objectName: "vacationMenuItem", label: qsTr("Vacation"), image: p.vacationImageUrl, screenUrl: vacationOverviewScreenUrl, weight: 30});
			registry.registerWidget("systrayIcon", p.vacationSystrayUrl, thermostatApp);
		}

		waitPopup.title = qsTr("One moment...");
		waitPopup.text = qsTr("Your programm is saving");
		if (feature.featSMEEnabled())
			p.enableSMEChanged.connect(p.onSMEFeatureChanged);

	}

	function onThermostatInfoChanged(node) {
		var tempInfo = thermInfo;

		var tempNode = node.child;
		while (tempNode) {
			tempInfo[tempNode.name] = parseFloat(tempNode.text);
			tempNode = tempNode.sibling;
		}
		thermInfo = tempInfo;
		initVarDone(1);
	}

	function onThermostatStatesChanged(node) {
		var tempStates = thermStates;

		var nodeState = node.getChild("state");
		while (nodeState) {
			var id = parseInt(nodeState.getChildText("id"));
			if (thermStatesMap[id] && tempStates[thermStatesMap[id]]) {
				tempStates[thermStatesMap[id]].temperature = parseFloat(nodeState.getChildText("tempValue")) / 100;
				tempStates[thermStatesMap[id]].dhw = parseInt(nodeState.getChildText("dhw"));
			}
			nodeState = nodeState.next;
		}

		var statesSaved = node.getChildText("statesSaved");
		thermostatStatesSaved = statesSaved === "true";

		thermStates = tempStates;
		var vacData = vacationData;
		vacData.temperature = tempStates[thermStatesMap[thermStateHoliday]].temperature;
		vacationData = vacData;

		initVarDone(2);
	}

	function sendSetPoint(temperature) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, null, "ChangeSchemeState");
		msg.addArgument("state", thermInfo['programState'] === progStateManualControl ?
							progStateManualControl : progStateTemperatureOverride);
		msg.addArgument("temperature", temperature * 100);
		bxtClient.sendMsg(msg);
	}

	function sendTempState(tempState) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, null, "ChangeSchemeState");
		msg.addArgument("state", thermInfo['programState'] === progStateManualControl ?
							progStateManualControl : progStateTemperatureOverride);
		msg.addArgument("temperatureState", tempState);
		bxtClient.sendMsg(msg);
	}

	function setVacationUntil(endDate, temperature) {
		var now = new Date();
		now.setMinutes(now.getMinutes() - 1);

		updateVacationData(
					{
						startTime: now.getTime(),
						endTime: endDate.getTime(),
						temperature: temperature / 100.0
					});
	}

	function showSmartHeatSchedulePopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("smart-heat-schedule-popup-title"), "");
		qdialog.context.contentLoader.setSource(temporaryOverridePopupUrl, {"app": thermostatApp});
		qdialog.context.closeBtnForceShow = true;
	}

	function sendProgramState(state) {
		if (state === thermInfo["programState"])
			return;

		if (hasSmartHeat && state !== true) {
			// Toggle the program state to force the OnOffToggle to enabled
			programEnabled = false;
			programEnabled = true;

			showSmartHeatSchedulePopup();
			return;
		}

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, null, "ChangeSchemeState");
		msg.addArgument("state", state === true ? progStateBaseScheme : progStateManualControl);
		bxtClient.sendMsg(msg);
	}

	function updateTemperaturePreset(modeTemperatures, callback) {
		var updatedTemperatures = thermStates;
		for (var key in modeTemperatures) {
			updatedTemperatures[key].temperature = modeTemperatures[key];
		}
		thermStates = updatedTemperatures;
		sendTemperaturePreset(callback);
	}

	function sendTemperaturePreset(callback) {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("device", null, 0);
		node.addChild("package", "happ_thermstat", 0);
		node.addChild("type", "states", 0);
		node.addChild("name", "thermostatStates", 0);
		node.addChild("internalAddress", "thermostatStates", 0);
		node.addChild("visibility", "0", 0);

		node = node.addChild("states", null, 0);
		for (var i = 0; i < 5; i++) {
			var stateNode = node.addChild("state", null, 0);
			stateNode.addChild("id", i, 0);
			stateNode.addChild("tempValue", thermStates[thermStatesMap[i]].temperature ? thermStates[thermStatesMap[i]].temperature * 100 : 600, 0);
			stateNode.addChild("dhw", thermStates[thermStatesMap[i]].temperature ? 1 : 0, 0);
		}
		if (callback instanceof Function) {
			bxtClient.doAsyncBxtRequest(msg, callback, 10);
		} else {
			bxtClient.sendMsg(msg);
		}
	}

	function formatDateTime(datetime, isStart, isPopup) {
		var nowPlus3yrs = new Date();

		// nowPlus3yrs used as now here...
		if (isStart && ((nowPlus3yrs.getTime() >= datetime) || (datetime === 0)))
			return qsTr("now");

		nowPlus3yrs.setFullYear(nowPlus3yrs.getFullYear() + 3);
		var dateToFormat = new Date(datetime);

		if ((dateToFormat > nowPlus3yrs) || (datetime === 0)) return isPopup ? qsTr("I return", "popup") : qsTr("I return", "setScreen");

		var prefix = "";
		if (isPopup) {
			var untilPrep = qsTr("until_date_preposition");
			prefix = ((untilPrep !== " " && untilPrep !== "until_date_preposition") ?  untilPrep : "");
		}
		return prefix + "%1 <b>%2</b>".arg(i18n.dateTime(dateToFormat, i18n.date_yes)).arg(i18n.dateTime(dateToFormat, i18n.time_yes));
	}

	function storeThermostatProgram(program) {
		// Reset the configRandomId to make sure we don't request our own config
		currentConfigRandomId = 0;
		var storeMsg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		ThermostatUtils.addScheduleToBxtMsg(program, storeMsg);
		bxtClient.sendMsg(storeMsg);
	}

	function handleGetProgramResponse(resp) {
		if (resp)
		{
			var storeSchedule = false;
			var schedule = resp.getArgumentXml("Config").getChild("device").getChild("schedule");
			thermostatProgram = ThermostatUtils.parseSchedule(schedule);

			if (thermostatProgram.length == 0)
			{
				thermostatProgram = p.enableSME ? ThermostatUtils.getDefaultBusinessSchedule() : ThermostatUtils.getDefaultSchedule();
				storeSchedule = true;
			}

			if (thermostatProgram[7].length) {
				var newVacationData = vacationData;
				newVacationData['startTime'] = thermostatProgram[7][0].startTime.getTime();
				newVacationData['endTime'] = thermostatProgram[7][0].endTime.getTime();
				vacationData = newVacationData;
				hasVacation = true;
				// entryId is not in program, but it is used to update existing vacation - have to request it separately
				getVacationId();
			}
			else {
				clearVacationData();
			}

			if (storeSchedule) {
				storeThermostatProgram(thermostatProgram);
			}
			thermostatProgramLoaded();
			initVarDone(0);
		} else {
			console.log("timeout: request to retrieve ThermostatProgram (retrying...)");
			getThermostatProgram();
		}
	}

	function getThermostatProgram() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "happ_thermstat");
		msg.addArgument("internalAddress", "thermostatProgram");
		bxtClient.doAsyncBxtRequest(msg, handleGetProgramResponse, 30);
	}

	function startEditProgram(daySelected) {
		thermostatProgramEdited = ThermostatUtils.createProgramCopy(thermostatProgram);
		editDayScreen.daySelected(daySelected);
		programWasEdited = false;
		editDayScreen.show();
	}

	function saveEditedProgram() {
		storeThermostatProgram(thermostatProgramEdited);
		getThermostatProgram();
	}

	function mondayBaseToSundayBase(dayIdx) {
		var result = dayIdx + 1;
		return (result > 6) ? 0 : result;
	}

	function sundayBaseToMondayBase(index) {
		var result = index - 1;
		return result < 0 ? 6 : result
	}

	function copyProgramDay(copyFrom, copyToDays) {
		thermostatProgramEdited = ThermostatUtils.copyDayProgram(programWasEdited ? thermostatProgramEdited : thermostatProgram, copyFrom, copyToDays);
	}

	function saveCopyProgramDay(copyFrom, copyToDays) {
		copyProgramDay(copyFrom, copyToDays)
		storeThermostatProgram(thermostatProgramEdited);
		getThermostatProgram();
	}

	function programOutput(program, day) {
		for (var i = 0; i < program[day].length; i++) {
			console.log('Program block: ');
			console.log('\tstartTime: ', program[day][i].startHour, ":", program[day][i].startMin);
			console.log('\tendTime: ', program[day][i].endHour, ":", program[day][i].endMin);
			console.log('\tstartDayOfWeek: ',program[day][i].startDayOfWeek);
			console.log('\tendDayOfWeek: ',program[day][i].endDayOfWeek);
			console.log('\ttargetState: ',program[day][i].targetState);
		}
	}

	function checkForVacation() {
		if (vacationRunning) {
			var temperature = i18n.number(vacationData.temperature, 1) + '°';
			var title = qsTr("Vacation %1 is active").arg(temperature);
			var endTimeStr = formatDateTime(vacationData.endTime, false, true);
			var content = qsTr("The thermostat is set until %1 to %2").arg(endTimeStr).arg(temperature);
			qdialog.showDialog(qdialog.SizeSmall, title, content, qsTr("I'm back at home"), (function(){abortVacation();}), qsTr("Resume vacation"), p.unregisterHsPopup);
		} else {
			p.unregisterHsPopup();
		}
	}

	function abortVacation() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "AbortHoliday");
		bxtClient.sendMsg(msg);
		clearVacationData();
		p.unregisterHsPopup();
	}

	function updateVacationData(vacationChanged) {
		var updatedData = vacationData;
		for (var key in vacationChanged) {
			updatedData[key] = vacationChanged[key];
		}
		vacationData = updatedData;
		hasVacation = true;

		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "SetHoliday");
		if (vacationData.entryId && vacationData.entryId !== "")
			msg.addArgument("entryId", vacationData.entryId);
		msg.addArgument("startTimeT", vacationData.startTime / 1000);
		msg.addArgument("endTimeT", vacationData.endTime / 1000);
		msg.addArgument("setpoint", (vacationData.temperature * 100));
		bxtClient.sendMsg(msg);
		vacationSet();
	}

	function getVacationId() {
		//see parseGetVacationIdResponse() comment
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.thermostatUuid, "Thermostat", "GetHolidays");
		bxtClient.sendMsg(msg);
	}

	function parseGetVacationIdResponse(msg) {
		// this response contains all vacation data (start,end) but this is read during program parsing, but vacation entryId is not present in program vacation entry
		// entryId is used to update exisiting vacation data. Apart of entryId, "GetHolidays" boxtalk request is useless, since the vacation data is also present in program
		var vacationNode = msg.getArgumentXml("holiday");
		if (vacationNode) {
			var vacation = vacationData;
			vacation.entryId = vacationNode.getChildText("entryId");
			vacationData = vacation;
		}
		else {
			clearVacationData();
		}
	}

	function clearVacationData() {
		hasVacation = false;
		vacationRunning = false;
		var tmpVacationData = vacationData;
		tmpVacationData.startTime = 0;
		tmpVacationData.endTime = 0;
		tmpVacationData.entryId = "";
		vacationData = tmpVacationData;
	}

	function isUndef(variable) {
		return typeof variable === "undefined";
	}

	// 0=program, 1=thermostatInfo, 2=thermostatStates
	initVarCount: 3

	onThermInfoChanged: {
		var nextProgramStart = new Date(thermInfo['nextTime'] * 1000);
		var activeState = thermInfo['activeState'];
		var nextState = thermInfo['nextState'];
		var programState = thermInfo['programState'];
		var activeStateHasScreenOff = (activeState === thermStateAway) ||
				(activeState === thermStateSleep) ||
				(activeState === thermStateHoliday && !hasSmartHeat);
		var nextStateHasScreenOff = (nextState === thermStateAway) ||
				(nextState === thermStateSleep) ||
				(nextState === thermStateHoliday) ||
				(activeState === thermStateHoliday);
		var activeStateIsOverride = (programState === progStateTemperatureOverride &&
									 activeState !== thermStateUndef) ||
				programState === progStateManualControl ||
				programState === progStateHoliday;
		vacationRunning = (programState === progStateHoliday);

		setByLoadShifting = (thermInfo['setByLoadShifting'] === 1);
		var currentEcoState = thermInfo['preheating'] === 1 ? nextState : activeState;
		currentMaxEcoTemperature = thermStateMaxEcoTemperature[currentEcoState] || thermStateMaxEcoTemperature[thermStateActive];

		var nextProgramState = thermInfo['nextProgram'];
		switch (programState)
		{
			case progStateBaseScheme:
			case progStateLockedBaseScheme:
			case progStateTemperatureOverride:
				programEnabled = true;
				break;
			case progStateHoliday:
				if (hasSmartHeat)
					programEnabled = false;
				else if (nextProgramState > progStateUndefinedState)
					programEnabled = nextProgramState == progStateBaseScheme || nextProgramState == progStateLockedBaseScheme || nextProgramState == progStateTemperatureOverride;
				break;
			default:
				programEnabled = false;
				break;
		}

		screenStateController.setProgramBasedScreenOffParameters(activeStateHasScreenOff, nextStateHasScreenOff, nextProgramStart, activeStateIsOverride);

		var randomConfigId = thermInfo['randomConfigId'];
		if (randomConfigId !== 0)
		{
			// If we have a configId and it changed request the newest config from happ_thermstat
			if (currentConfigRandomId && (randomConfigId !== currentConfigRandomId)) {
				getThermostatProgram();
			}
			currentConfigRandomId = randomConfigId;
		}
	}

	onHasVacationChanged: {
		hcblog.logKpi("HolidayIconVisible", hasVacation);
	}

	function getThermostatAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "GetObjectConfig");
		msg.addArgument("package", "qt-gui");
		msg.addArgument("internalAddress", "thermostatApp");

		bxtClient.doAsyncBxtRequest(msg, getConfigCallback, 30);
	}

	BxtRequestCallback {
		id: getConfigCallback
		onMessageReceived: {
			var configNode = message.getArgumentXml("Config").getChild("thermostatApp");
			if (configNode) {
				var showProgramFirstUse = parseInt(configNode.getChildText("programFirstUse"));
				programFirstUse = (showProgramFirstUse === 1);
			} else {
				console.log("No ThermostatApp configuration available, creating defaults...");
				sendThermostatAppConfig();
			}
		}
	}

	function sendThermostatAppConfig() {
		var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p.hcbConfigUuid, "ConfigProvider", "SetObjectConfig");
		msg.addArgument("Config", null);

		var node = msg.getArgumentXml("Config");

		node = node.addChild("thermostatApp", null, 0);
		node.addChild("package", "qt-gui", 0);
		node.addChild("internalAddress", "thermostatApp", 0);

		node.addChild("programFirstUse", programFirstUse ? 1 : 0, 0);
		// If there are more configuration parameters that we need to save, add them here

		bxtClient.sendMsg(msg);
	}


	Connections {
		target: screenStateController
		onScreenStateChanged: {
			var screenState = screenStateController.screenState;
			if (vacationRunning && !hasSmartHeat && (screenState == ScreenStateController.ScreenColorDimmed || screenState == ScreenStateController.ScreenOff))
				stage.registerHomescreenPopup({priority: p.homescreenPopup.priority, 'uuid': p.homescreenPopup.uuid, callback: checkForVacation});
		}
	}

	BxtDiscoveryHandler {
		id: thermstatDiscoHandler
		deviceType: "happ_thermstat"
		onDiscoReceived: {
			p.thermostatUuid = deviceUuid;
		}
	}

	BxtDiscoveryHandler {
		id: hcbConfigDiscoHandler
		deviceType: "hcb_config"
		onDiscoReceived: {
			p.hcbConfigUuid = deviceUuid;
			getThermostatProgram();
			getThermostatAppConfig();
		}
	}

	BxtDiscoveryHandler {
		id: eventmgrDiscoHandler
		deviceType: "happ_eventmgr"
		onDiscoReceived: {
			p.eventmgrUuid = deviceUuid;
		}
	}

	BxtDatasetHandler {
		id: thermstatInfoDsHandler
		dataset: "thermostatInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: onThermostatInfoChanged(update)
	}

	BxtDatasetHandler {
		id: thermstatStatesDsHandler
		dataset: "thermostatStates"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: onThermostatStatesChanged(update)
	}

	BxtDatasetHandler {
		id: heatRecoveryInfoDataset
		dataset: "heatRecoveryInfo"
		discoHandler: thermstatDiscoHandler
		onDatasetUpdate: {
			p.parseHeatRecoveryInfo(update)
		}
	}

	BxtResponseHandler {
		id: getVacationResponseHandler
		response: "GetHolidaysResponse"
		serviceId: "Thermostat"
		onResponseReceived: parseGetVacationIdResponse(message)
	}
}
