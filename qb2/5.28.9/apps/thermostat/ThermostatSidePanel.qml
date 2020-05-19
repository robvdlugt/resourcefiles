import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

import Feedback 1.0

Widget {
	id: thermostatSidePanel

	property string kpiPrefix: "ThermostatSidePanel."
	property ThermostatApp app
	property alias stateInfoText: thermostatStateInfoText.text
	property alias programOn: toggle.isSwitchedOn

	property url sourceUrl: app.sidePanelUrl

	width: Math.round(248 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	QtObject {
		id: p

		property bool setpointInProgress: false
		property real currentTemperature : 6
		property real currentSetpoint : 6
		property string errMsg: ''
		property int spinnerAnimDuration: 500

		// when one of the buttons (setPointSpinner) is pressed
		function onTemperatureButtonPressed() {
			if (setpointInProgress === false) {
				setPointSpinner.value = currentSetpoint;
			}
			setPointSpinner.state = 'pressed';
			setpointInProgress = true;
			updateSetpointStatus();
		}

		// when one of the buttons (setPointSpinner) is released
		function onTemperatureButtonReleased() {
			var spChanged = (currentSetpoint != setPointSpinner.value);
			currentSetpoint = setPointSpinner.value;
			setpointInProgress = false;
			setPointSpinner.state = '';
			updateSetpointStatus();
			if (spChanged) {
				app.setByLoadShifting = false;
				app.sendSetPoint(currentSetpoint);
				FeedbackManager.actionTriggered("changeSetpoint");
			} else {
				// so the status goes back to what it was
				onThermostatDatasetsChanged();
			}
		}

		function activeTemperaturePreset(id) {
			// If the wizard state is not completed, we disable the temperature preset buttons.
			// This means that we shouldn't overwrite their state here.
			if (canvas.isNormalMode) {
				tempTileAway.state = (id === tempTileAway.stateId) ? "down" : "up";
				tempTileSleep.state = (id === tempTileSleep.stateId) ? "down" : "up";
				tempTileHome.state = (id === tempTileHome.stateId) ? "down" : "up";
				tempTileComfort.state = (id === tempTileComfort.stateId) ? "down" : "up";
			}
		}

		function onTemperaturePresetChanged(id) {
			activeTemperaturePreset(id);
			app.sendTempState(id);
			FeedbackManager.actionTriggered("changeSetpoint");
		}

		function onThermostatDatasetsChanged() {
//TSC mod start
//			currentTemperature = app.thermInfo['currentDisplayTemp'] / 100.0;
			currentTemperature = app.thermInfo['currentTemp'] / 100.0;
//TSC mod end
			currentSetpoint = app.thermInfo['currentSetpoint'] / 100.0;
			activeTemperaturePreset(app.thermInfo['activeState']);

			if (app.thermInfo.boilerModuleConnected === 0) {
				setPointError.text = qsTr("Error");
				setPointSpinner.state = 'error';
				errMsg = qsTr("Boiler adapter not connected.");
				rectStateInfo.state = 'error';
			} else if (app.thermInfo.haveOTBoiler === 1 && app.thermInfo.otCommError === 1) {
				setPointError.text = qsTr("Error");
				setPointSpinner.state = 'error';
				errMsg = qsTr("Boiler not connected.");
				rectStateInfo.state = 'error';
			} else if (app.thermInfo.haveOTBoiler === 1 && app.thermInfo.hasBoilerFault === 1) {
				setPointError.text = qsTr("Errorcode: %1").arg(app.thermInfo.errorFound);
				setPointSpinner.state = 'error';
				errMsg = qsTr("Boiler error see manual.");
				rectStateInfo.state = 'error';
			} else {
				setThermostatState();
			}
			updateSetpointStatus();
			// Override the box beneath the temperature in case we're in the installation wizard.
			if (canvas.isWizardMode) {
				rectStateInfo.state = 'wizard'
			}
		}

		function updateSetpointStatus()	{
			if (setpointInProgress != true) {
				setPointSpinner.value = currentSetpoint;
			}

			if (setPointSpinner.state !== 'error') {
				if (setPointSpinner.value === currentTemperature) {
					setPointIcon.source = "image://scaled/images/triangle_right.svg";
					setPointIconDim.source = "image://scaled/images/triangle_right_dim.svg"
				} else if (setPointSpinner.value < currentTemperature) {
					setPointIcon.source = "image://scaled/images/triangle_down.svg";
					setPointIconDim.source = "image://scaled/images/triangle_down_dim.svg"
				} else {
					setPointIcon.source = "image://scaled/images/triangle_up.svg";
					setPointIconDim.source = "image://scaled/images/triangle_up_dim.svg"
				}
			}
		}

		function isStateSameAsCurrentOrNextProgramState(state) {
			if (state === app.thermStateUndef)
				return false;
			var now = new Date();
			var nowDayOfWeek = now.getDay();
			var nowTime = (now.getHours() * 60) + now.getMinutes();
			var dayOfWeekIdx = nowDayOfWeek;
			for (var i = 0; i < app.thermostatProgram[dayOfWeekIdx].length; i++) {
				// calculate the day offset between this program's start day and dayOfWeekIdx
				// negative days means it starts before dayOfWeekIdx
				var startDaysOffset = app.thermostatProgram[dayOfWeekIdx][i].startDayOfWeek - dayOfWeekIdx;
				// if we get a positive value, it means the start days is in the previous week, so we
				// adjust
				if (startDaysOffset > 0)
					startDaysOffset -= 7;
				// calculate the relative start time based on dayOfWeekIdx's midnight
				var startTime = 0;
				if (startDaysOffset < 0)
					startTime -= 1440;
				startTime += (app.thermostatProgram[dayOfWeekIdx][i].startHour * 60) + app.thermostatProgram[dayOfWeekIdx][i].startMin;
				startTime += (startDaysOffset < 0 ? startDaysOffset + 1 : startDaysOffset) * 1440;

				// calculate how many days ahead of dayOfWeekIdxthis program ends
				var endDaysOffset = app.thermostatProgram[dayOfWeekIdx][i].endDayOfWeek - dayOfWeekIdx;
				// if we get a negative value, it means the end day is in the next week, so we
				// "add" 7 days
				if (endDaysOffset < 0)
					endDaysOffset += 7;
				// calculate the relative end time based on dayOfWeekIdx's midnight
				var endTime = 0;
				if (endDaysOffset < 0)
					endTime -= 1440;
				endTime += (app.thermostatProgram[dayOfWeekIdx][i].endHour * 60) + app.thermostatProgram[dayOfWeekIdx][i].endMin;
				endTime += endDaysOffset * 1440;

				// add an offset to adjust the times according to today's midnight
				var nowOffset = dayOfWeekIdx - nowDayOfWeek;
				if (nowOffset < 0)
					nowOffset += 7
				startTime += nowOffset * 1440;
				endTime += nowOffset * 1440;

				if (startTime <= nowTime && endTime > nowTime) {
					// here we are looking at the current program

					// when states match, we know its an override of the current program with the same state
					if (app.thermostatProgram[dayOfWeekIdx][i].targetState === state) {
						return true;
					// if we are at a program that only ends at a later day, restart loop with that day and second program
					} else if (endTime >= 1440) {
						dayOfWeekIdx = (dayOfWeekIdx + Math.floor(endTime / 1440)) % 7;
						i = 0;
					}
				} else if (startTime > nowTime) {
					// here we are at the next program (after current one)

					// when the next state is the same as the current state, we got blended
					return (app.thermostatProgram[dayOfWeekIdx][i].targetState === state);
				}
			}

			return false;
		}

		function setThermostatState() {
			var thermostatStateString = '';
			setPointSpinner.state = '';
			rectStateInfo.state = 'normal';
			toggle.visible = true;

			switch(app.thermInfo['programState']) {

			case app.progStateBaseScheme:
				// when tapping hot water, keep the same text as it was before
				if (app.thermInfo['burnerInfo'] === app.burnerDhw && thermostatStateInfoText.text.length > 0) {
					thermostatStateString = thermostatStateInfoText.text;
					break;
				}

				if (app.thermInfo['burnerInfo'] === app.burnerPreheat) {
					thermostatStateString = nextBlockPreheating();
				} else {
					thermostatStateString = nextBlock();
				}
				break;

			case app.progStateTemperatureOverride:

				if (app.thermInfo['burnerInfo'] === app.burnerPreheat || app.setByLoadShifting) {
					thermostatStateString = nextBlockPreheating();
				} else if (currentSetpoint > currentTemperature && isStateSameAsCurrentOrNextProgramState(app.thermInfo['activeState']) === false) {
					thermostatStateString = qsTr("Temporarily to %1°").arg(i18n.number(currentSetpoint, 1));
				} else {
					thermostatStateString = nextBlock();
				}
				break;

			case app.progStateManualControl:
				thermostatStateString = qsTr("Program Off");
				break;
			case app.progStateLockedBaseScheme:
				if (app.thermInfo['currentSetpoint'] > app.thermInfo['currentDisplayTemp']) {
					thermostatStateString = qsTr("To %1°").arg(i18n.number(currentSetpoint, 1));
				} else {
					thermostatStateString = qsTr("On %1°").arg(i18n.number(currentSetpoint, 1));
				}
				break;

			case app.progStateHoliday:
				if (app.hasSmartHeat) {
					if (app.thermInfo['burnerInfo'] === app.burnerPreheat)
						thermostatStateString = nextBlockPreheating();
					else
						thermostatStateString = qsTr("At %1° until %2").arg(i18n.number(currentSetpoint, 1)).arg(vacationEnd());
					break;
				}

				thermostatStateString = qsTr("Vacation until %1").arg(vacationEnd());
				toggle.visible = false;
				break;

			default:
				break;
			}

			updateSetpointStatus();
			thermostatStateInfoText.text = thermostatStateString;
		}

		function nextBlockPreheating() {
			var nextProgramStart = new Date(app.thermInfo['nextTime'] * 1000);
			var now = new Date();
			var diff = nextProgramStart - now; // milliseconds
			diff = Math.floor((diff/1000)/60); // minutes
			diff = Math.max(Math.round(diff / 5) * 5, 5); // 5 minutes block
			return qsTr("To %1° in %2")
						.arg(i18n.number(app.thermInfo['nextSetpoint'] / 100, 1))
						.arg(i18n.duration(diff * 60, true));
		}

		function nextBlock() {
			return qsTr("At %1 set to %2").arg(dateOrTime(app.thermInfo['nextTime'] * 1000))
			.arg(app.thermStateName[app.thermInfo['nextState']]);
		}

		function isDiffMoreThan24Hrs(compareTime) {
			var nowPlus24hrs = new Date();
			nowPlus24hrs.setDate(nowPlus24hrs.getDate() + 1);
			return compareTime > nowPlus24hrs.getTime();
		}

		function dateOrTime(time) {
			var dateOrTimeStr = ""
			var jsTime = new Date(time);

			if (isDiffMoreThan24Hrs(time)) {
				dateOrTimeStr = i18n.dateTime(jsTime, i18n.time_no | i18n.date_yes | i18n.year_no | i18n.mon_short);
			} else {
				dateOrTimeStr = i18n.dateTime(jsTime, i18n.time_yes | i18n.secs_no | i18n.hour_str_yes);
			}
			return dateOrTimeStr;
		}

		function vacationEnd() {
			var nowPlus3Years = new Date();
			nowPlus3Years.setFullYear(nowPlus3Years.getFullYear() + 3);
			var vacationEnd = new Date(app.thermInfo['nextTime'] * 1000)
			if (nowPlus3Years < vacationEnd) {
				return qsTr("I return");
			} else {
				var prefix = "";
				var untilPrep = qsTranslate("ThermostatApp", "until_date_preposition");
				prefix = ((untilPrep !== " " && untilPrep !== "until_date_preposition") ?  untilPrep : "");
				return prefix + dateOrTime(app.thermInfo['nextTime'] * 1000);
			}
		}

		onCurrentTemperatureChanged: {
			if (setpointInProgress === false) {
				currentTempDisplay.text = i18n.number(currentTemperature, 1) + "°";
			}
		}
	}

	function showSmartHeatPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("smartHeatPopup-Title"), qsTr("smartHeatPopup-Content"));
	}

	function init() {
		app.thermInfoChanged.connect(p.onThermostatDatasetsChanged);
		app.heatRecoveryInfoChanged.connect(p.onThermostatDatasetsChanged);
		setPointSpinner.buttonPressed.connect(p.onTemperatureButtonPressed);
		setPointSpinner.buttonReleased.connect(p.onTemperatureButtonReleased);
		p.updateSetpointStatus();
	}

	Rectangle {
		id: normalSidePanelDisableOverlay
		anchors.fill: normalSidePanel
		visible: normalSidePanel.visible && !globals.thermostatFeatures["FF_BoilerControl_reveal"]
		color: colors.contrastBackground
		z: 1

		MouseArea {
			anchors.fill: parent
			enabled: parent.visible
		}

		Text {
			id: tmpError
			text: setPointError.text
			font.family: qfont.regular.name
			font.pixelSize: qfont.tileTitle
			color: dimmableColors.spErrorText
			wrapMode: Text.WordWrap
			anchors {
				top: parent.top
				topMargin: Math.round(20 * verticalScaling)
				left: parent.left
				right: parent.right
			}
		}

		Text {
			id: tmpErrorText
			text: p.errMsg
			wrapMode: Text.WordWrap
			font.family: qfont.regular.name
			font.pixelSize: qfont.programText
			color: dimmableColors.spText
			anchors {
				top: tmpError.bottom
				topMargin: designElements.vMargin6
				left: parent.left
				right: parent.right
			}
		}
	}

	Item {
		id: normalSidePanel
		height: parent.height
		visible: !dimState
		clip: true
		anchors {
			fill: parent
			margins: Math.round(8 * verticalScaling)
		}

		NumberSpinner {
			id: setPointSpinner

			width: parent.width
			height: Math.round(114 * verticalScaling)
			spacing: Math.round(4 * horizontalScaling)
			radius: designElements.radius
			buttonWidth: Math.round(74 * horizontalScaling)

			fontFamily: qfont.regular.name
			fontColor: colors.spText
			fontPixelSize: qfont.tileTitle
			textBaseline: Math.round(90 * verticalScaling)
			alignment: StyledValueLabel.AlignmentLeft
			leftMargin: Math.round(34 * horizontalScaling)

			backgroundColor:            colors.spBackgroundValue
			backgroundColorButtonsUp:   colors.spBackgroundButtonsUp
			backgroundColorButtonsDown: colors.spBackgroundButtonsDown
			backgroundColorButtonsDisabled: colors.spBackgroundButtonsDisabled
			overlayButtonWhenUp:        false
			overlayColorButtonsDown:    colors.spOverlayButtonsDown

			disableButtonAtMaximum: true
			disableButtonAtMinimum: true

			downButtonBottomClickMargin: 2

			pressingEndTime: 3000

			rangeMin: 6.0
			rangeMax: 30.0
			increment: 0.5
			valueSuffix: "°"

			mouseIsActiveInDimState: true

			upIconSource: "qrc:/images/numberSpinner_plus.svg"
			downIconSource: "qrc:/images/numberSpinner_minus.svg"

			Behavior on valueField.fontPixelSize {
				SmoothedAnimation {
					id: spinnerAnimation
					duration: p.spinnerAnimDuration
					velocity: -1
				}
			}

			state: ''
			states: [
				State {
					name: 'pressed'
					PropertyChanges {target: setPointIcon; anchors.topMargin: Math.round(68 * verticalScaling)}
					PropertyChanges {target: setPointRightIcon; anchors.leftMargin: Math.round(131 * horizontalScaling)}
					PropertyChanges {target: setPointRightIcon; anchors.verticalCenterOffset: Math.round(10 * verticalScaling)}
					PropertyChanges {target: setPointSpinner; valueField.fontPixelSize: qfont.timeAndTemperatureText}
					PropertyChanges {target: currentTempDisplay; anchors.topMargin: Math.round(24 * verticalScaling)}
					PropertyChanges {target: currentTempDisplay; font.pixelSize: qfont.tileTitle}
				},
				State {
					name: 'error'
					PropertyChanges {target: setPointError; visible: true}
					PropertyChanges {target: setPointSpinner; fontColor: colors.spBackgroundValue}
					PropertyChanges {target: setPointIcon; source: "image://scaled/apps/thermostat/drawables/icon_error.svg"}
					PropertyChanges {target: setPointIconDim; source: "image://scaled/apps/thermostat/drawables/icon_error_dim.svg"}
					PropertyChanges {target: setPointIcon; anchors.bottomMargin: -2; anchors.rightMargin: Math.round(4 * horizontalScaling) }
					AnchorChanges   {
						target: setPointIcon
						anchors.top: undefined
						anchors.bottom: setPointError.baseline
						anchors.left: undefined
						anchors.right: setPointError.left
					}
				}
			]

			Image {
				id: setPointIcon

				anchors {
					top: parent.top
					topMargin: Math.round(81 * verticalScaling)
					left: parent.left
					leftMargin: Math.round(20 * horizontalScaling)
				}

				source: "image://scaled/images/triangle_down.svg"

				Behavior on anchors.topMargin {
					SmoothedAnimation {
						duration: p.spinnerAnimDuration
						velocity: -1
					}
				}
			}

			Text {
				id: currentTempDisplay
				anchors {
					top: parent.top
					left: parent.left
					topMargin: Math.round(12 * verticalScaling)
					leftMargin: Math.round(18 * horizontalScaling)
				}
				font.family: qfont.regular.name
				font.pixelSize: qfont.timeAndTemperatureText
				color: colors.spText
				text: "19,0"

				Behavior on font.pixelSize {
					SmoothedAnimation {
						duration: p.spinnerAnimDuration
						velocity: -1
					}
				}

				Behavior on anchors.topMargin {
					NumberAnimation {
						duration: p.spinnerAnimDuration
					}
				}
			}

			Item {
				id: setPointRightIcon
				anchors {
					verticalCenter: setPointIcon.verticalCenter
					verticalCenterOffset: 0
					left: parent.left
					leftMargin: Math.round(76 * horizontalScaling)
				}

				Behavior on anchors.leftMargin {
					SmoothedAnimation {
						duration: p.spinnerAnimDuration
						velocity: -1
					}
				}

				Behavior on anchors.verticalCenterOffset {
					SmoothedAnimation {
						duration: p.spinnerAnimDuration
						velocity: -1
					}
				}

				states: [
					State {
						name: "error"; when: setPointSpinner.state === "error"
					},
					State {
						name: "load-shifting"; when: app.setByLoadShifting
						PropertyChanges {target: setPointRightIconImage; source: "image://scaled/apps/thermostat/drawables/load-shifting-icon.svg"}
						PropertyChanges {target: setPointRightIconDim; source: "image://scaled/apps/thermostat/drawables/load-shifting-icon-dim.svg"}
						PropertyChanges {target: loadShiftClick; enabled: true}
						PropertyChanges {target: loadShiftClickDim; mouseEnabled: true}
					},
					State {
						name: "eco"; when: setPointSpinner.value <= app.currentMaxEcoTemperature
						PropertyChanges {target: setPointRightIconImage; source: "image://scaled/apps/thermostat/drawables/leaf.svg"}
						PropertyChanges {target: setPointRightIconDim; source: "image://colorized/white/apps/thermostat/drawables/leaf.svg"}
					},
					State {
						name: "eco-editing"; when: setPointSpinner.state === "pressed" && setPointSpinner.value <= app.thermStateMaxEcoTemperature[app.thermStateActive]
						extend: "eco"
					}
				]

				Image {
					id: setPointRightIconImage
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			MouseArea {
				id: loadShiftClick
				enabled: false
				anchors {
					top: parent.verticalCenter
					bottom: parent.bottom
					left: parent.left
					right: parent.right
					rightMargin: parent.buttonWidth + parent.spacing
				}
				onClicked: showSmartHeatPopup()
			}

			Text {
				id: setPointError
				anchors {
					top: parent.top
					topMargin: Math.round(74 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
					horizontalCenterOffset: -(parent.buttonWidth + parent.spacing - setPointIcon.width - setPointIcon.anchors.rightMargin) / 2
				}
				font.family: qfont.regular.name
				font.pixelSize: qfont.tileTitle
				color: colors.spErrorText
				text: ""
				visible: false
			}
		}

		Item {
			id: rectStateInfo
			width: parent.width
			height: Math.round(56 * verticalScaling)
			anchors.top: setPointSpinner.bottom
			anchors.topMargin: Math.round(4 * verticalScaling)

			Item {
				id: normalState
				anchors.fill: parent
				visible: false
				MouseArea {
					property string kpiPostfix: "programLine." + rectStateInfo.state
					anchors.fill: parent
					onClicked: {
						if (app && app.programScreen) {
							app.programScreen.show();
						}
					}
				}

				Text {
					id: thermostatStateInfoText
					anchors {
						left: parent.left
						leftMargin: Math.round(8 * verticalScaling)
						right: toggle.left
						rightMargin: anchors.leftMargin
						verticalCenter: parent.verticalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.programText
					}
					color: colors.spText
					wrapMode: Text.WordWrap
					text: "Continue on 19,0"
				}

				OnOffToggle {
					id: toggle

					anchors.verticalCenter: parent.verticalCenter
					anchors.right: parent.right

					fontFamily: qfont.semiBold.name
					fontPixelSize: qfont.titleText
					fontColor: colors.spText
					topSpacing: Math.round(8 * verticalScaling)

					isSwitchedOn: app.programEnabled
					positionIsLeft: true
					leftIsSwitchedOn: false
					mouseIsActiveInDimState: true

					onSelectedChangedByUser: {
						if (app.hasSmartHeat)
							setPointSpinner.forceCommit(); // Force commiting the spinner value before the popup
						app.sendProgramState(isSwitchedOn);
						FeedbackManager.actionTriggered("changeSetpoint");
					}
				}
			}
			Item {
				id: errorState
				anchors.fill: parent
				visible: false
				Text {
					id: errorMsg
					anchors.fill: parent
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignHCenter
					wrapMode: Text.WordWrap
					elide: Text.ElideRight
					maximumLineCount: 3
					text: p.errMsg
					font.family: qfont.regular.name
					font.pixelSize: qfont.programText
					color: colors.spText
				}
			}
			Item {
				id: wizardState
				anchors.fill: parent
				visible: false
				Text {
					id: wizardMsg
					anchors.fill: parent
					wrapMode: Text.WordWrap
					font.family: qfont.regular.name
					font.pixelSize: qfont.titleText
					color: colors.spText
					text: qsTr("Here you can set the temperature")
				}
			}

			// This state determines the visibility of the 'normalState', 'errorState' and 'wizardState' Items above.
			state: "normal"
			states: [
				State {
					name: "normal"
					PropertyChanges { target: normalState; visible: true }
				},
				State {
					name: "error"
					PropertyChanges { target: errorState; visible: true }
				},
				State {
					name: "wizard"
					PropertyChanges { target: wizardState; visible: true }
				}
			]
		}

		Grid {
			id: tempGrid
			anchors {
				top: rectStateInfo.bottom
				topMargin: Math.round(4 * verticalScaling)
			}
			width: parent.width
			rows: 2
			columns: 2
			spacing: Math.round(4 * verticalScaling)

			TemperatureRectangle {
				id: tempTileAway

				topLeftRadiusRatio: 1

				subLabelText: app.thermStateName[app.thermStateAway]
				temperature: app.thermStates.thermStateAway.temperature
				stateId: app.thermStates.thermStateAway.index

				onPressed: p.onTemperaturePresetChanged(tempTileAway.stateId)
				enabled: isNormalMode
			}

			TemperatureRectangle {
				id: tempTileHome

				topRightRadiusRatio: 1

				subLabelText: app.thermStateName[app.thermStateActive]
				temperature: app.thermStates.thermStateActive.temperature
				stateId: app.thermStates.thermStateActive.index

				onPressed: p.onTemperaturePresetChanged(tempTileHome.stateId)
				enabled: isNormalMode
			}

			TemperatureRectangle {
				id: tempTileSleep

				bottomLeftRadiusRatio: 1

				subLabelText: app.thermStateName[app.thermStateSleep]
				temperature: app.thermStates.thermStateSleep.temperature
				stateId: app.thermStates.thermStateSleep.index

				onPressed: p.onTemperaturePresetChanged(tempTileSleep.stateId)
				enabled: isNormalMode
			}

			TemperatureRectangle {
				id: tempTileComfort

				bottomRightRadiusRatio: 1

				subLabelText: app.thermStateName[app.thermStateRelax]
				temperature: app.thermStates.thermStateRelax.temperature
				stateId: app.thermStates.thermStateRelax.index

				onPressed: p.onTemperaturePresetChanged(tempTileComfort.stateId)
				enabled: isNormalMode
			}
		}

		Rectangle {
			id: blockingBanner
			anchors.fill: tempGrid
			radius: designElements.radius
			color: "#99FFFFFF" // 60% white
			visible: isNormalMode && !app.thermostatStatesSaved

			MouseArea {
				id: maPresetBlocker
				anchors.fill: parent
			}

			StandardButton {
				text: qsTr("Set")
				anchors.centerIn: parent
				onClicked: {
					stage.openFullscreen(app.temperaturePresetScreenUrl);
				}
			}
		}
	}

	Item {
		id: dimSidePanel
		visible: !normalSidePanel.visible && globals.thermostatFeatures["FF_BoilerControl_reveal"]
		height: parent.height
		width: parent.width

		Text {
			id: currentTempDisplayDim
			anchors {
				verticalCenter: parent.top
// waste mod start
//                            verticalCenterOffset: Math.round(114 * verticalScaling)
                              verticalCenterOffset: (app.wasteIconShow || app.wasteIcon2Show) ? Math.round(134 * verticalScaling) : Math.round(114 * verticalScaling)

// waste mod end
				left: parent.left
				leftMargin: Math.round(8 * horizontalScaling)
			}
			font.family: qfont.regular.name
			font.pixelSize: qfont.temperatureTextDim
			color: dimColors.spText
			text: currentTempDisplay.text
		}

		Image {
			id: setPointIconDim
			anchors {
				bottom: setPointTextDim.baseline
				bottomMargin: -1
				left: currentTempDisplayDim.left
			}
		}

		Text {
			id: setPointTextDim
			anchors {
				baseline: currentTempDisplayDim.baseline
				baselineOffset: Math.round(40 * verticalScaling)
				left: setPointIconDim.right
				leftMargin: Math.round(8 * horizontalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: dimColors.spText
			text: rectStateInfo.state === "error" ? setPointError.text : setPointSpinner.valueField.text
		}

		Image {
			id: setPointRightIconDim
			anchors {
				left: setPointTextDim.right
				leftMargin: Math.round(8 * horizontalScaling)
				verticalCenter: setPointTextDim.verticalCenter
			}
			sourceSize.width: Math.round(32 * horizontalScaling)

			StyledRectangle {
				id: loadShiftClickDim
				width: parent.width + designElements.spacing10
				height: parent.height + designElements.spacing10
				color: colors.none
				mouseEnabled: false
				mouseIsActiveInDimState: true

				onClicked: {
					screenStateController.wakeup();
					showSmartHeatPopup();
				}
			}
		}

		Text {
			id: infoTextDim
			anchors {
				baseline: setPointTextDim.baseline
				baselineOffset: Math.round(45 * verticalScaling)
				left: currentTempDisplayDim.left
				right: parent.right
			}
			font {
				family: rectStateInfo.state === "error" ? qfont.regular.name : qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			wrapMode: Text.WordWrap
			color: dimColors.spText
			elide: Text.ElideRight
			maximumLineCount: 3
			text: rectStateInfo.state === "error" ? errorMsg.text : thermostatStateInfoText.text
		}

//TSC waste display start

		Image {
			id: twasteIconzzBig
			source: app.wasteIcon
			height: isNxt ? 125 : 100
			width: isNxt ? 128 : 100
			anchors {
				left: currentTempDisplayDim.left
				leftMargin: 100
				top: parent.top
			}
			cache: false
			visible: dimState ? app.wasteIconShow : false		// only show if one icon
		}			

		Image {
			id: twasteIconzzBigBack
			source: "file:///qmf/qml/apps/wastecollection/drawables/collectContainerDim.png"
			height: isNxt ? 125 : 100
			width: isNxt ? 128 : 100
			anchors {
				left: currentTempDisplayDim.left
				leftMargin: 100
				top: parent.top
			}
			cache: false
			visible: dimState ? app.wasteIconBackShow : false	// only show if one icon and container needs to be collected
		}

		Image {
			id: twasteIconzzSmall1
			source: app.wasteIcon
			height: isNxt ? 110 : 88
			width: isNxt ? 113 : 88
			anchors {
				left: currentTempDisplayDim.left
				leftMargin: 55
				top: parent.top
			}
			cache: false
		 	visible: dimState ? app.wasteIcon2Show : false		// only show if two icons
		}

		Image {
			id: twasteIconzzSmall2
			source: app.wasteIcon2
			height: isNxt ? 110 : 88
			width: isNxt ? 113 : 88
			anchors {
				right: parent.right
				rightMargin: 5
				top: parent.top
			}
			cache: false
  		   	visible: dimState ? app.wasteIcon2Show : false		// only show if two icons
		}

		Image {
			id: wasteIconzzSmall1Back
			source: "file:///qmf/qml/apps/wastecollection/drawables/collectContainerDim.png"
			height: isNxt ? 110 : 88
			width: isNxt ? 113 : 88
			anchors {
				left: currentTempDisplayDim.left
				leftMargin: 55
				top: parent.top
			}
			cache: false
			visible: dimState ? app.wasteIcon2BackShow : false	// only show if one icon and two containers needs to be collected
		}

		Image {
			id: wasteIconzzSmall2Back
			height: isNxt ? 110 : 88
			width: isNxt ? 113 : 88
			source: "file:///qmf/qml/apps/wastecollection/drawables/collectContainerDim.png"
			anchors {
				right: parent.right
				rightMargin: 5
				top: parent.top
			}
			cache: false
   			visible: dimState ? app.wasteIcon2BackShow : false	// only show if one icon and two containers needs to be collected
		}
//TSC waste display end

	}
}
