import QtQuick 2.1
import qb.components 1.0
import ThermostatUtils 1.0

/// Edit day screen for thermostat program. Shows blocks of the programs for selected day. Allows to add / remove program block;

Screen {
	id: editDayScreen

	screenTitle: qsTr("Edit")
	isSaveCancelDialog: true

	property ThermostatApp app

	QtObject {
		id: p
		// 0 == Sunday
		property int daySelected: -1
		property int editedBlockIdx: 0
		property bool addingNewBlock: false
		property int maxBlocksInDay : 6
		property string blockAction: qsTr('Add')
		property int blockAnimationDuration: 400

		function mapProgramIndex(idx) {
			switch (idx) {
			case 0: return app.thermStateAway;
			case 1: return app.thermStateSleep;
			case 2: return app.thermStateActive;
			case 3: return app.thermStateRelax;
			}
		}

		// Takes Sunday based indexes of days as input
		function isYesterday(todayIdx, compareIdx) {
			var diff = todayIdx  - compareIdx
			return  ((diff === 1) || (diff === -6));
		}

		function sundayBaseToMondayBase(dayIdx) {
			var result = dayIdx - 1;
			return (result >= 0) ? result : 6;
		}

		function mondayBaseToSundayBase(dayIdx) {
			var result = dayIdx + 1;
			return (result > 6) ? 0 : result;
		}

		// input is index from the day program
		function removeBlock(index) {
			app.thermostatProgramEdited = ThermostatUtils.deleteBlockFromSchedule(app.thermostatProgramEdited, p.daySelected, index);
			dayProgramModel.updateAddButtons();
			//programChanged();
		}

		// Argument is index in day program where new block should be added
		function addBlock(newBlockIdx) {
			p.editedBlockIdx = newBlockIdx;
			p.addingNewBlock = true;
			var tempItem = {'startMin': 0, 'startHour': 0};
			var block;
			// do not use start of previous block + 30 min as initial value because previous block not started today
			if (newBlockIdx > 1) {
				block = getBlock(0, p.editedBlockIdx - 1);
				tempItem['startMin'] = block['startMin'] + 30;
				tempItem['startHour'] = block['startHour'];
				block = getBlock(0, p.editedBlockIdx);
				if (block === null || block === undefined) {
					tempItem['endMin'] = 24;
					tempItem['endHour'] = 00;
				} else {
					tempItem['endMin'] = block['startMin'];
					tempItem['endHour'] = block['startHour'];
				}
				if (tempItem['startMin'] > 59) {
					tempItem['startHour'] += 1;
					tempItem['startMin'] -= 60;
				}
			}

			tempItem['targetState'] = getBlock(0, newBlockIdx - 1)['targetState']
			tempItem['addAboveVisible'] = false;
			tempItem['addUnderVisible'] = false;
			tempItem['addingBlockInProgress'] = true;
			dayProgramModel.insert(Math.max(newBlockIdx - 1, 0), tempItem);
			app.thermostatProgramEdited = ThermostatUtils.addBlockToSchedule(app.thermostatProgramEdited, p.daySelected, p.editedBlockIdx);
			var endHour = 24;
			var endMin = 0;
			block = undefined;
			if (p.editedBlockIdx + 1 < app.thermostatProgramEdited[p.daySelected].length) {
				block = getBlock(0, p.editedBlockIdx + 1);
				endHour = block.startHour;
				endMin = block.startMin;
			}
			else {
				block = getBlock(1, 0);
			}
			var endDayOfWeek = block.endDayOfWeek;

			app.thermostatProgramEdited = ThermostatUtils.editBlockInSchedule(app.thermostatProgramEdited,
																				  p.daySelected,
																				  p.editedBlockIdx,
																				  tempItem.startMin,
																				  tempItem.startHour,
																				  p.daySelected,
																				  endMin,
																				  endHour,
																				  endDayOfWeek,
																				  tempItem.targetState);
			p.blockAction = qsTr('Add');
			if (p.editedBlockIdx == dayProgramModel.count) {
				dayProgramModel.setProperty(p.editedBlockIdx - 1, 'addingBlockInProgress', false);
				if (p.editedBlockIdx > 1) {
					dayProgramModel.setProperty(p.editedBlockIdx - 2, 'addUnderVisible', false);
				}
				afterAnimationDelay.start();
			}
			else {
				addAnimationDelay.start();
			}
		}

		// Input argument is index in day program of block to be edited.
		function editBlock(blockIdx) {
			p.editedBlockIdx = blockIdx;
			stage.openFullscreen(app.editBlockScreenUrl, {day: p.daySelected, blockIdx: blockIdx, blockAction: p.blockAction});
		}

		function getBlock(dayDelta, blockIdx) {
			if ((p.daySelected < 0) || (app.thermostatProgramEdited.length < (p.daySelected + dayDelta) % 7))
				return null;
			return app.thermostatProgramEdited[(p.daySelected + dayDelta) % 7][blockIdx];
		}

		function yesterdayIdx(todayIdx) {
			return (todayIdx - 1) >= 0 ? todayIdx - 1 : 6;
		}

		function addPreviousVisible() {
			if (p.daySelected < 0) return false;
			return (1 === app.thermostatProgramEdited[p.daySelected].length);
		}

		function previousDayText() {
			var result = "";
			if (p.daySelected >= 0)
				result = i18n.daysFull[getBlock(0,0)['startDayOfWeek']]
			return result;
		}

		function previousStartTime() {
			var result = "";
			if (p.daySelected >= 0)
				result = p.getBlock(0,0)['startHour'] + ':' + (p.getBlock(0,0)['startMin'] < 10 ? '0' : '') + p.getBlock(0,0)['startMin']
			return result;
		}

		function previousProgramName() {
			var result = "";
			if (p.daySelected >= 0) result = app.thermStateName[getBlock(0,0)['targetState']];
			return result;
		}

		function previousTemperature() {
			var result = ""
			if (p.daySelected >= 0)
				result = i18n.number(app.thermStates[app.thermStatesMap[getBlock(0,0)['targetState']]]['temperature'], 1) + '°'
			return result;
		}

		function previousColor() {
			var result = "";
			if (p.daySelected >= 0) result = app.thermStateColor[getBlock(0,0)['targetState']];
			return result;
		}

	}

	// day parameter is Sunday based index of day
	signal daySelected(int day)

	function blockEditCancel() {
		if (p.addingNewBlock) {
			app.thermostatProgramEdited = ThermostatUtils.deleteBlockFromSchedule(app.thermostatProgramEdited, p.daySelected, p.editedBlockIdx);
			//dayProgramModel.remove(p.editedBlockIdx - 1);
			programChanged();
		};
		p.addingNewBlock = false;

	}

	function programChanged() {
		daySelected(p.daySelected);
	}

	function blockEdited(startHour, startMin, endHour, endMin, targetState) {
		app.programWasEdited = true;
		var previousBlock = p.getBlock(0, p.editedBlockIdx - 1);
		app.thermostatProgramEdited = ThermostatUtils.editBlockInSchedule(app.thermostatProgramEdited,
																			  p.daySelected,
																			  p.editedBlockIdx,
																			  startMin,
																			  startHour,
																			  p.daySelected,
																			  endMin,
																			  endHour,
																			  p.getBlock(0, p.editedBlockIdx).endDayOfWeek,
																			  targetState);
		app.thermostatProgramEdited = ThermostatUtils.editBlockInSchedule(app.thermostatProgramEdited,
																			  p.daySelected,
																			  p.editedBlockIdx - 1,
																			  previousBlock.startMin,
																			  previousBlock.startHour,
																			  previousBlock.startDayOfWeek,
																			  startMin,
																			  startHour,
																			  p.daySelected,
																			  previousBlock.targetState);
		//app.programOutput(app.thermostatProgramEdited, p.daySelected);
		// check if some shift of previous program needs to be done
		var blockToShift = p.editedBlockIdx;
		var shifting = blockToShift > 1;
		var newEndHour = 0;
		var newEndMin = 0;
		var newStartHour = 0;
		var newStartMin = 0;
		while (shifting) {
			shifting = false;
			blockToShift -= 1;
			if (p.getBlock(0, blockToShift).startHour * 60 + (p.getBlock(0,blockToShift).startMin) + 30 >
					p.getBlock(0, blockToShift + 1).startHour * 60 + (p.getBlock(0, blockToShift + 1).startMin)) {
				newEndHour = p.getBlock(0, blockToShift + 1).startHour;
				newEndMin = p.getBlock(0, blockToShift + 1).startMin;
				newStartHour = p.getBlock(0, blockToShift).startHour;
				newStartMin = p.getBlock(0, blockToShift).startMin;
				if ( (newEndHour * 60 + newEndMin) - (newStartHour * 60 + newStartMin) < 30) {
					var newStartTime = (newEndHour * 60 + newEndMin) - 30;
					newStartHour = Math.floor(newStartTime / 60);
					newStartMin = newStartTime % 60;
					shifting = blockToShift > 1;
				}
				app.thermostatProgramEdited = ThermostatUtils.editBlockInSchedule(app.thermostatProgramEdited,
																					  p.daySelected,
																					  blockToShift,
																					  newStartMin,
																					  newStartHour,
																					  p.daySelected,
																					  newEndMin,
																					  newEndHour,
																					  p.daySelected,
																					  p.getBlock(0, blockToShift).targetState);


			}
		}
		// check if some shift of next program needs to be done
		blockToShift = p.editedBlockIdx;
		shifting = blockToShift < app.thermostatProgramEdited[p.daySelected].length - 1;
		while (shifting) {
			shifting = false;
			blockToShift += 1;
			if (p.getBlock(0, blockToShift).startHour * 60 + (p.getBlock(0,blockToShift).startMin) <
					p.getBlock(0, blockToShift - 1).endHour * 60 + (p.getBlock(0, blockToShift - 1).endMin)) {
				newStartHour = p.getBlock(0, blockToShift - 1).endHour;
				newStartMin = p.getBlock(0, blockToShift - 1).endMin;
				newEndHour = p.getBlock(0, blockToShift).endHour;
				newEndMin = p.getBlock(0, blockToShift).endMin;
				if ( (newEndHour * 60 + newEndMin) - (newStartHour * 60 + newStartMin) < 30) {
					var newEndTime = (newStartHour * 60 + newStartMin) + 30;
					newEndHour = Math.floor(newEndTime / 60);
					newEndMin = newEndTime % 60;
					shifting = blockToShift < app.thermostatProgramEdited[p.daySelected].length - 1;
				}
				app.thermostatProgramEdited = ThermostatUtils.editBlockInSchedule(app.thermostatProgramEdited,
																					  p.daySelected,
																					  blockToShift,
																					  newStartMin,
																					  newStartHour,
																					  p.daySelected,
																					  newEndMin,
																					  newEndHour,
																					  p.daySelected,
																					  p.getBlock(0, blockToShift).targetState);


			}
		}
		programChanged();
		p.addingNewBlock = false;
	}

	onDaySelected: {
		if (p.daySelected >= 0)
			repeatDay.itemAt(p.sundayBaseToMondayBase(p.daySelected)).isDaySelected = false;
		p.daySelected = day;
		repeatDay.itemAt(p.sundayBaseToMondayBase(p.daySelected)).isDaySelected = true;

		dayProgramModel.clear()
		for (var program = 1; program < app.thermostatProgramEdited[p.daySelected].length; program++) {
			var tmpItem = app.thermostatProgramEdited[p.daySelected][program];
			tmpItem['addAboveVisible'] = false;
			tmpItem['addUnderVisible'] = false;
			tmpItem['addingBlockInProgress'] = false;
			dayProgramModel.append(tmpItem);
		}
		dayProgramModel.updateAddButtons();
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		addAnimationDelay.stop();
		afterAnimationDelay.stop();
	}

	onSaved: {
		// do this before the popup is shown because this state will be active again after popup
		screenStateController.screenColorDimmedIsReachable = true;
		if (app.programWasEdited) {
			app.programScreen.saveProgram(1);
		}
		app.programWasEdited = false;
	}

	onCanceled: {
		screenStateController.screenColorDimmedIsReachable = true;
		app.thermostatProgramEdited = app.thermostatProgram;
	}

	ListModel {
		id: dayProgramModel

		function updateAddButtons() {
			if (count === 0) return;
			var prevBlockLength = dayProgramModel.get(0).startHour * 60 + dayProgramModel.get(0).startMin;
			var aboveVisible = prevBlockLength >= 60 && (count < p.maxBlocksInDay);
			dayProgramModel.setProperty(0, 'addAboveVisible', aboveVisible);
			dayProgramModel.setProperty(0, 'addUnderVisible', false);
			for (var i = 1; i < count; i++)
			{
				if (count >= p.maxBlocksInDay)
					dayProgramModel.setProperty(i, 'addAboveVisible', false);
				else {
					prevBlockLength = dayProgramModel.get(i).startHour * 60 + dayProgramModel.get(i).startMin;
					prevBlockLength -= dayProgramModel.get(i - 1).startHour * 60 + dayProgramModel.get(i - 1).startMin;
					dayProgramModel.setProperty(i, 'addAboveVisible', prevBlockLength >= 60);
				}
				dayProgramModel.setProperty(0, 'addUnderVisible', false);
			}
			var lastBlockStart = (dayProgramModel.get(count - 1).startHour * 60) + dayProgramModel.get(count - 1).startMin;
			var addUnderVisible = count < p.maxBlocksInDay && lastBlockStart <= 1380;
			dayProgramModel.setProperty(count - 1, 'addUnderVisible', addUnderVisible);
		}

	}

	Component {
		id: programDelegate
		Item {
			id: programDelegateItem
			width: scheduleContainer.width
			height: Math.round(36 * verticalScaling)

			Rectangle {
				id: readyBlock
				anchors.fill: parent
				radius: designElements.radius
				visible: !addingBlockInProgress && index < p.maxBlocksInDay

				Rectangle {
					id: modeRect
					width: Math.round(14 * horizontalScaling)
					height: readyBlock.height
					color: app.thermStateColor[targetState]
					anchors {
						left: parent.left
						top: parent.top
					}
					radius: designElements.radius
				}

				Rectangle {
					id: modeRectSharpEdge // There is currently no way to only round the left corners of a Rectangle
					width: Math.round(10 * horizontalScaling)
					height: readyBlock.height
					anchors {
						left: parent.left
						leftMargin: Math.round(7 * horizontalScaling)
						top: parent.top
					}
				}

				Text {
					id: programName
					text: app.thermStateName[targetState]
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: parent.left
						leftMargin: Math.round(17 * horizontalScaling)
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.bodyText
					}
				}

				Text {
					id: programTemperature
					text: i18n.number(app.thermStates[app.thermStatesMap[targetState]]['temperature'], 1) + '°'
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: parent.left
						leftMargin: Math.round(126 * horizontalScaling)
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.bodyText
					}
				}

				Text {
					id: startTime
					text: startHour + ':' + (startMin < 10 ? '0' : '') + startMin
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: parent.left
						leftMargin: Math.round(301 * horizontalScaling)
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
				}

				MouseArea {
					id: maEdit
					anchors.left: parent.left
					anchors.right: editButton.right
					height: parent.height
					property string kpiPostfix: "editEntry"

					onClicked: editButton.clicked()
				}

				BarButton {
					id: binButton
					width: parent.height
					height: parent.height
					anchors {
						right: parent.right
						rightMargin: Math.round(10 * horizontalScaling)
					}
					imageUp: "image://scaled/apps/thermostat/drawables/delete-block.svg"
					imageDown: "image://scaled/apps/thermostat/drawables/delete-block-down.svg"

					onClicked: {
						// because index will become -1 after dayProgramModel.remove(index)
						// and this remove has to be called to get animation
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							var indexToDel = index;
							p.removeBlock(indexToDel + 1);
							app.programWasEdited = true;
							dayProgramModel.remove(index);
						}
					}
				}

				BarButton {
					id: editButton
					width: parent.height
					height: parent.height
					anchors {
						right: binButton.left
						rightMargin: Math.round(10 * horizontalScaling)
					}
					imageUp: "image://scaled/apps/thermostat/drawables/edit-block.svg"
					imageDown: "image://scaled/apps/thermostat/drawables/edit-block-down.svg"

					onClicked: {
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							p.blockAction = qsTr('Edit');
							p.editBlock(index + 1);
						}
					}
				}

				Rectangle {
					id: timeline
					width: Math.round(2 * horizontalScaling)
					color: colors._bg
					anchors {
						right: startTime.left
						rightMargin: Math.round(10 * horizontalScaling)
						top: parent.top
						topMargin: Math.round(-6 * verticalScaling)
						bottom: parent.bottom
						bottomMargin: Math.round(-6 * verticalScaling)
					}
				}

				Rectangle {
					id: timelineDot
					width: Math.round(6 * horizontalScaling)
					height: Math.round(6 * horizontalScaling)
					color: timeline.color
					anchors.centerIn: timeline
					radius: Math.round(3 * horizontalScaling)
				}

				// Add button above the block line
				BarButton {
					id: addTime
					width: Math.round(56 * horizontalScaling)
					height: Math.round(48 * verticalScaling)
					imageUp: "image://scaled/apps/thermostat/drawables/add-time.svg"
					imageDown: imageUp
					imageIsButton: true

					anchors {
						right: timeline.left
						rightMargin: Math.round(4 * horizontalScaling)
						verticalCenter: parent.top
						verticalCenterOffset: Math.round(-4 * verticalScaling)
					}
					//visible: p.addAboveVisible(index + 1)
					visible: addAboveVisible

					onClicked: {
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							p.addBlock(index + 1);
						}
					}
				}

				// Add button under the block line
				// visible only for last block in day
				BarButton {
					id: addTimeBellow
					width: Math.round(56 * horizontalScaling)
					height: Math.round(48 * verticalScaling)
					imageUp: "image://scaled/apps/thermostat/drawables/add-time.svg"
					imageDown: imageUp
					imageIsButton: true

					visible: addUnderVisible
					anchors {
						right: timeline.left
						rightMargin: Math.round(4 * horizontalScaling)
						verticalCenter: parent.bottom
						verticalCenterOffset: Math.round(4 * verticalScaling)
					}

					onClicked: {
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							p.addBlock(index + 2);
						}
					}
				}
			}

			Rectangle {
				id: blockToAdd
				anchors.fill: parent
				visible: addingBlockInProgress
				color: colors.esInvisibleBlock
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
				delegate: DayButton {
					property string kpiPrefix: "thermostat/EditDayScreen"
					invertBackgroundColor: true
					Component.onCompleted: {
						daySelected.connect(editDayScreen.daySelected);
					}
				}
			}
		}

		Rectangle {
			id: dayButtonTabConnect
			color: colors.contrastBackground
			height: Math.round(18 * verticalScaling)
			width: Math.round(88 * horizontalScaling)
			x: p.sundayBaseToMondayBase(p.daySelected) * Math.round(96 * horizontalScaling)

			anchors {
				top: dayBtnRow.bottom
				topMargin: Math.round(-5 * verticalScaling)
			}
		}

		Rectangle {
			color: colors.contrastBackground
			radius: designElements.radius

			anchors {
				left: parent.left
				right: parent.right
				top: dayBtnRow.bottom
				topMargin: dayBtnRow.spacing
				bottom: parent.bottom
			}

			Item {
				id: scheduleContainer
				width: Math.round(461 * horizontalScaling)
				anchors {
					top: parent.top
					topMargin: Math.round(20 * verticalScaling)
					left: parent.left
					leftMargin: Math.round(20 * horizontalScaling)
					bottom: parent.bottom
					bottomMargin: Math.round(20 * verticalScaling)
				}

				/**
				 * Some strange anchor items are used in this row. It is because position of the items in the row depends
				 * on positions and sizes of elements in row where program block is shown. But there are cases when no lines
				 * with blocks are visible and needs to be faked.
				 */
				Rectangle {
					id: previousProgram
					height: Math.round(22 * verticalScaling); width: parent.width
					radius: designElements.radius
					anchors {
						top: dayBtnRow.bottom
						topMargin: Math.round(16 * verticalScaling)
					}
					color: colors.white
					opacity: 0.4

					Rectangle {
						id: previousModeRect
						width: Math.round(7 * horizontalScaling)
						clip: true
						anchors {
							left: parent.left
							top: parent.top
							bottom: parent.bottom
						}
						Rectangle {
							width: Math.round(14 * horizontalScaling)
							color: p.previousColor()
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							radius: designElements.radius
						}
					}

					Text {
						id: previousProgramName
						text: p.previousProgramName()
						font {
							family: qfont.regular.name
							pixelSize: qfont.metaText
						}
						color: colors.esPreviousDay
						verticalAlignment: Text.AlignVCenter
						anchors {
							top: parent.top
							bottom: parent.bottom
							left: parent.left
							leftMargin: Math.round(17 * horizontalScaling)
						}
					}

					Text {
						id: previousTemperature
						text: p.previousTemperature()
						font {
							family: qfont.regular.name
							pixelSize: qfont.metaText
						}
						color: colors.esPreviousDay
						verticalAlignment: Text.AlignVCenter
						anchors {
							top: parent.top
							bottom: parent.bottom
							left: parent.left
							leftMargin: Math.round(126 * horizontalScaling)
						}
					}

					Text {
						id: previousStartTime
						text: p.previousStartTime()
						font {
							family: qfont.regular.name
							pixelSize: qfont.bodyText
						}
						color: colors.esPreviousDay
						verticalAlignment: Text.AlignVCenter
						anchors {
							top: parent.top
							bottom: parent.bottom
							left: parent.left
							leftMargin: Math.round(301 * horizontalScaling)
						}
					}

					Text {
						id: previousDay
						text: p.previousDayText()
						font {
							family: qfont.regular.name
							pixelSize: qfont.bodyText
						}
						color: colors.esPreviousDay
						verticalAlignment: Text.AlignVCenter
						anchors {
							top: parent.top
							bottom: parent.bottom
							left: parent.left
							leftMargin: Math.round(352 * horizontalScaling)
						}
					}
				}

				Rectangle {
					id: previousTimeline
					width: Math.round(2 * horizontalScaling)
					color: colors._bg
					anchors {
						left: previousProgram.left
						leftMargin: Math.round((301 - 10 - width) * horizontalScaling)
						top: previousProgram.top
						topMargin: Math.round(-6 * verticalScaling)
						bottom: previousProgram.bottom
						bottomMargin: Math.round(-6 * verticalScaling)
					}
				}

				Rectangle {
					id: previousTimelineDot
					width: Math.round(6 * horizontalScaling)
					height: Math.round(6 * horizontalScaling)
					color: previousTimeline.color
					anchors.centerIn: previousTimeline
					radius: Math.round(3 * horizontalScaling)
				}

				// Add block button under 'previous program' line
				// Visible only if there is no other block for the day
				BarButton {
					id: addTime
					width: Math.round(56 * horizontalScaling)
					height: Math.round(48 * verticalScaling)
					imageUp: "image://scaled/apps/thermostat/drawables/add-time.svg"
					imageDown: imageUp
					imageIsButton: true

					visible: p.addPreviousVisible()
					anchors {
						right: previousTimeline.left
						rightMargin: Math.round(4 * horizontalScaling)
						verticalCenter: previousProgram.bottom
						verticalCenterOffset: Math.round(4 * verticalScaling)
					}

					onClicked: {
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							p.addBlock(1);
						}
					}
				}

				Column {
					id: scheduleColumn
					width: parent.width
					height: Math.round(100 * verticalScaling)

					spacing: designElements.spacing10
					anchors.top: previousProgram.bottom
					anchors.topMargin: spacing
					move: Transition {
						id: blockTransition
						NumberAnimation {
							id: blockAnimation
							properties: "y"
							easing.type: Easing.Linear
							duration: p.blockAnimationDuration
						}
					}
					Repeater {
						id: repeatProgram
						model: dayProgramModel
						delegate: programDelegate
					}
				}
			}

			Text {
				text: qsTr("Copy this day")
				color: colors.esPreviousDay
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				anchors {
					verticalCenter: btnCopyProgram.verticalCenter
					right: btnCopyProgram.left
					rightMargin: Math.round(10 * horizontalScaling)
				}
			}

			IconButton {
				id: btnCopyProgram

				width: Math.round(36 * horizontalScaling)
				iconSource: "drawables/icon_copy.svg"
				leftClickMargin: Math.round(100 * horizontalScaling)
				overlayWhenUp: true

				anchors {
					bottom: parent.bottom
					bottomMargin: Math.round(20 * verticalScaling)
					right: parent.right
					rightMargin: Math.round(20 * horizontalScaling)
				}

				onClicked: {
					stage.openFullscreen(app.copyProgramDayScreenUrl, {fromDay: p.daySelected, shouldSave: false});
				}
			}
		}
	}

	Timer {
		id: addAnimationDelay
		interval: p.blockAnimationDuration
		running: false
		repeat: false
		onTriggered: {
			dayProgramModel.setProperty(p.editedBlockIdx - 1, 'addingBlockInProgress', false);
			afterAnimationDelay.start();
		}
	}

	Timer {
		id: afterAnimationDelay
		interval: 300
		running: false
		repeat: false
		onTriggered: {
			p.editBlock(p.editedBlockIdx);
		}
	}
}
