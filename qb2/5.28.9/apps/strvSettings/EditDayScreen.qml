import QtQuick 2.1
import qb.components 1.0
import ThermostatUtils 1.0

Screen {
	id: editDayScreen
	screenTitle: qsTr("Edit")
	isSaveCancelDialog: true

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (args && (args.fromDay >= 0)) {
			// fromDay is monday-based
			daySelected(args.fromDay);
		} else {
			daySelected(app.scheduleEditingDay);
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onSaved: {
		p.daySelected = -1;
		app.saveEditedSchedule();
	}

	onCanceled: {
		p.daySelected = -1;
		app.cancelEditedSchedule();
	}

	QtObject {
		id: p
		// 0 == Monday
		property int daySelected: -1;
		property int editedBlockIdx: 0;
		property bool addingNewBlock: false;
		property int maxBlocksInDay : 6
		property string blockAction: qsTr('Add');
		property int blockAnimationDuration: 400

		property int scheduleLength: ThermostatUtils.programLength(app.scheduleEdited)

		function mapProgramIndex(idx) {
			switch (idx) {
			case 0: return app.thermStateAway;
			case 1: return app.thermStateSleep;
			case 2: return app.thermStateActive;
			case 3: return app.thermStateRelax;
			}
		}

		// Takes Monday based indexes of days as input
		function isYesterday(todayIdx, compareIdx) {
			var diff = todayIdx  - compareIdx
			return  ((diff === 1) || (diff == -6));
		}

		function sundayBaseToMondayBase(dayIdx) {
			var result = dayIdx - 1;
			return (result >= 0) ? result : 6;
		}

		// input is index from the day program
		function removeBlock(index) {
			app.scheduleEdited = ThermostatUtils.deleteBlockFromSchedule(app.scheduleEdited, p.daySelected, index);
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

			tempItem['targetState'] = getBlock(0, newBlockIdx - 1)['targetState'];
			tempItem['presetUuid'] = getBlock(0, newBlockIdx - 1)['presetUuid'];
			tempItem['addAboveVisible'] = false;
			tempItem['addUnderVisible'] = false;
			tempItem['addingBlockInProgress'] = true;
			dayProgramModel.insert(Math.max(newBlockIdx - 1, 0), tempItem);
			app.scheduleEdited = ThermostatUtils.addBlockToSchedule(app.scheduleEdited, p.daySelected, p.editedBlockIdx);
			var endHour = 24;
			var endMin = 0;
			block = undefined;
			if (p.editedBlockIdx + 1 < app.scheduleEdited[p.daySelected].length) {
				block = getBlock(0, p.editedBlockIdx + 1);
				endHour = block.startHour;
				endMin = block.startMin;
			}
			else {
				block = getBlock(1, 0);
			}
			var endDayOfWeek = block.endDayOfWeek;

			app.scheduleEdited = ThermostatUtils.editBlockInSchedule(app.scheduleEdited,
																				  p.daySelected,
																				  p.editedBlockIdx,
																				  tempItem.startMin,
																				  tempItem.startHour,
																				  p.daySelected,
																				  endMin,
																				  endHour,
																				  endDayOfWeek,
																				  tempItem.targetState,
																				  tempItem.presetUuid);
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
		function editBlock(blockIdx, action) {
			p.editedBlockIdx = blockIdx;
			stage.openFullscreen(app.editBlockScreenUrl, {day: p.daySelected, blockIdx: blockIdx, blockAction: action});
		}

		function getBlock(dayDelta, blockIdx) {
			if ((p.daySelected < 0) || (app.scheduleEdited.length < (p.daySelected + dayDelta) % 7))
				return null;
			return app.scheduleEdited[(p.daySelected + dayDelta) % 7][blockIdx];
		}

		function yesterdayIdx(todayIdx) {
			return (todayIdx - 1) >= 0 ? todayIdx - 1 : 6;
		}

		function addPreviousVisible() {
			if (p.daySelected < 0) return false;
			return (1 === app.scheduleEdited[p.daySelected].length);
		}

		function previousDayText() {
			var result = "";
			if (p.daySelected >= 0) {
				if (p.isYesterday(p.daySelected, p.getBlock(0,0)['startDayOfWeek'])) {
					result = qsTr('Yesterday');
				} else {
					result = i18n.daysFull[ThermostatUtils.mondayBaseToSundayBase(getBlock(0,0)['startDayOfWeek'])];
				}
			}
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
			if (p.daySelected >= 0) result = app.presetUuidToString(getBlock(0,0)['presetUuid']);
			return result;
		}

		function previousTemperatures() {
			var result = "";
			if (p.daySelected >= 0)
				result = formatMinMaxTemperature(app.presetUuidToMinMaxTemperature(getBlock(0,0)['presetUuid']));
			return result;
		}

		function formatMinMaxTemperature(minMaxTemp) {
			var minTemp = minMaxTemp.min;
			var maxTemp = minMaxTemp.max;

			if (Math.abs(minTemp - maxTemp) < Number.EPSILON)
				return qsTr("%1°").arg(minTemp);
			else
				return qsTr("%1°-%2°").arg(minTemp).arg(maxTemp);
		}
	}

	// day parameter is Sunday based index of day
	signal daySelected(int day)

	function programChanged() {
		daySelected(p.daySelected);
	}

	onDaySelected: {
		if (p.daySelected >= 0)
			repeatDay.itemAt(p.daySelected).isDaySelected = false;
		app.scheduleEditingDay = p.daySelected = day;
		repeatDay.itemAt(p.daySelected).isDaySelected = true;

		dayProgramModel.repopulateModel(p.daySelected);
	}

	ListModel {
		id: dayProgramModel

		// Added this wrapper function for remove(), because calling it would render
		// the item temporarily inaccessible from the outside. (Don't ask me how or why.)
		function removeItem(idx) {
			remove(idx);
			updateAddButtons();
		}

		function repopulateModel(day) {
			dayProgramModel.clear();
			for (var program = 1; program < app.scheduleEdited[day].length; program++) {
				var tmpItem = app.scheduleEdited[day][program];
				tmpItem['addAboveVisible'] = false;
				tmpItem['addUnderVisible'] = false;
				tmpItem['addingBlockInProgress'] = false;
				dayProgramModel.append(tmpItem);
			}
			dayProgramModel.updateAddButtons();
		}

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
			}
			var lastBlockStart = (dayProgramModel.get(count - 1).startHour * 60) + dayProgramModel.get(count - 1).startMin;
			var addUnderVisible = count < p.maxBlocksInDay && lastBlockStart <= 1380;
			dayProgramModel.setProperty(count - 1, 'addUnderVisible', addUnderVisible);
		}
	}

	Component {
		id: programDelegate
		Item {
			width: Math.round(664 * horizontalScaling)
			height: Math.round(41 * verticalScaling)

			Rectangle {
				id: readyBlock
				anchors.fill: parent
				radius: designElements.radius
				visible: !addingBlockInProgress && index < p.maxBlocksInDay

				Rectangle {
					id: modeRect
					width: Math.round(21 * horizontalScaling)
					height: Math.round(21 * verticalScaling)
					color: app.presetNameToColor(app.presetUuidToName(presetUuid))
					anchors {
						left: parent.left
						leftMargin: designElements.hMargin10
						top: parent.top
						topMargin: designElements.vMargin10
					}
				}

				Text {
					id: txtFrom
					text: qsTr('From')
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: parent.left
						leftMargin: Math.round(57 * horizontalScaling)
					}
					color: colors.esLabel
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.titleText
					}
					verticalAlignment: Text.AlignVCenter

				}

				Text {
					id: startTime
					text: startHour + ':' + (startMin < 10 ? '0' : '') + startMin
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						// Right-align start times
						right: parent.left
						rightMargin: Math.round(-284 * horizontalScaling)
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
					}
				}

				Text {
					id: programName
					text: presetUuid ? app.presetUuidToString(presetUuid) : ""
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: parent.left
						leftMargin: Math.round(322 * horizontalScaling)
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.titleText
					}
				}

				Text {
					id: programTemperature
					text: p.formatMinMaxTemperature(app.presetUuidToMinMaxTemperature(presetUuid))
					color: colors.esLabel
					verticalAlignment: Text.AlignVCenter
					anchors {
						top: parent.top
						bottom: parent.bottom
						left: programName.left
						leftMargin: Math.round(140 * horizontalScaling)
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.titleText
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

				IconButton {
					id: binButton
					anchors {
						right: parent.right
						rightMargin: Math.round(13 * horizontalScaling)
						verticalCenter: parent.verticalCenter
					}
					iconSource: "qrc:/apps/thermostat/drawables/delete-block.svg"

					colorDown: colors.barButtonBckgDown
					colorUp: colors.barButtonBckgUp

					enabled: p.scheduleLength > 1

					onClicked: {
						// because index will become -1 after dayProgramModel.remove(index)
						// and this remove has to be called to get animation
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							var indexToDel = index;
							p.removeBlock(indexToDel + 1);
							dayProgramModel.removeItem(indexToDel);
						}
					}
				}

				IconButton {
					id: editButton
					anchors {
						right: binButton.left
						rightMargin: Math.round(13 * horizontalScaling)
						verticalCenter: parent.verticalCenter
					}
					iconSource: "qrc:/apps/thermostat/drawables/edit-block.svg"

					colorDown: colors.barButtonBckgDown
					colorUp: colors.barButtonBckgUp

					onClicked: {
						if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
							p.blockAction = qsTr('Edit');
							p.editBlock(index + 1, app._BLOCK_ACTION_EDIT);
						}
					}
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
						left: txtFrom.right
						leftMargin: Math.round(39.5 * horizontalScaling)
						verticalCenter: parent.top
						verticalCenterOffset: Math.round(-4 * verticalScaling)
					}
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
					id: addTimeBelow
					width: Math.round(56 * horizontalScaling)
					height: Math.round(48 * verticalScaling)
					imageUp: "image://scaled/apps/thermostat/drawables/add-time.svg"
					imageDown: imageUp
					imageIsButton: true

					visible: addUnderVisible
					anchors {
						left: txtFrom.right
						leftMargin: Math.round(39.5 * horizontalScaling)
						verticalCenter: parent.bottom
						verticalCenterOffset: 4
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
					onDaySelected: {
						// Fix sunday based day value
						editDayScreen.daySelected(ThermostatUtils.sundayBaseToMondayBase(day));
					}
				}
			}
		}

		/**
		 * Some strange anchor items are used in this row. It is because position of the items in the row depends
		 * on positions and sizes of elements in row where program block is shown. But there are cases when no lines
		 * with blocks are visible and needs to be faked.
		 */
		Rectangle {
			id: previousProgram
			height: 31; width: parent.width
			radius: designElements.radius
			anchors {
				top: dayBtnRow.bottom
				topMargin: Math.round(16 * verticalScaling)
			}
			color: colors.white
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
					leftMargin: Math.round(8 * horizontalScaling)
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
					right: parent.left
					rightMargin: Math.round(-284 * horizontalScaling)
				}
			}
			Text {
				id: previousProgramName
				text: p.previousProgramName()
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
					leftMargin: Math.round(322 * horizontalScaling)
				}
			}
			Text {
				id: previousTemperature
				text: p.previousTemperatures()
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.esPreviousDay
				verticalAlignment: Text.AlignVCenter
				anchors {
					top: parent.top
					bottom: parent.bottom
					left: previousProgramName.left
					leftMargin: Math.round(140 * horizontalScaling)
				}
			}
			Text {
				id: anchorText
				visible: false
				text: qsTr('From')
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.titleText
				}
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
					left: parent.left
					leftMargin: 57 + anchorText.paintedWidth + 39.5
					verticalCenter: parent.bottom
					verticalCenterOffset: 4
				}

				onClicked: {
					if (!(addAnimationDelay.running || afterAnimationDelay.running)) {
						p.addBlock(1);
					}
				}
			}
		}
		Column {
			width: Math.round(664 * horizontalScaling)
			height: Math.round(100 * verticalScaling)

			spacing: designElements.spacing8
			anchors.top: previousProgram.bottom
			anchors.topMargin: Math.round(8 * verticalScaling)
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
			p.editBlock(p.editedBlockIdx, app._BLOCK_ACTION_ADD);
		}
	}
}
