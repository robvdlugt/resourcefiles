import QtQuick 2.1

import qb.components 1.0
import ThermostatUtils 1.0

Screen {
	id: programScreen
	screenTitleIconUrl: "drawables/program.svg"
	screenTitle: qsTr("Program")
	property int selectedDay : -1

	QtObject {
		id: p
		property bool fromAddWizard
	}

	onShown: {
		if (args && typeof(args.fromAddWizard) !== "undefined") {
			p.fromAddWizard = args.fromAddWizard;
		}
		app.scheduleChanged.connect(populate);
		populate();
		app.getSchedules();

		selectDay(ThermostatUtils.weekdayTodayMB());
	}

	onHidden: {
		app.scheduleChanged.disconnect(populate);
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.strvInstallDoneScreenUrl, {"resetNavigation": true});
	}

	function populate() {
		var daysInProgram = Math.min(7, app.schedule.length)
		for (var i = 0; i < daysInProgram; i++) {
			dayRepeater.itemAt(i).populateDayProgram(app.schedule[i]);
		}
	}

	function selectDay(dayToSelect) {
		if (selectedDay === dayToSelect)
			return;
		else if (selectedDay >= 0)
			dayRepeater.itemAt(selectedDay).isDaySelected = false;

		selectedDay = dayToSelect;
		dayRepeater.itemAt(dayToSelect).isDaySelected = true;

		if (selectedDay >= 0 && selectedDay < app.schedule.length) {
			var dayProgram = app.schedule[selectedDay];
			timeScale.populateModel(dayProgram);
		}
	}

	Rectangle {
		id: introOverlay
		anchors.fill: parent
		visible: p.fromAddWizard
		color: colors.canvas
		z: 2

		Text {
			id: introTitle
			anchors {
				top: parent.top
				topMargin: Math.round(35 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
				right: introImage.left
				rightMargin: designElements.hMargin20
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
			lineHeight: 0.8
			wrapMode: Text.WordWrap
			text: qsTr("program-intro-title")
		}

		Text {
			id: introBodyText
			anchors {
				top: introTitle.bottom
				topMargin: designElements.vMargin20
				left: introTitle.left
				right: introTitle.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			wrapMode: Text.WordWrap
			text: qsTr("program-intro-body")
		}

		StandardButton {
			id: introButton
			anchors {
				top: introBodyText.bottom
				topMargin: Math.round(30 * verticalScaling)
				left: introTitle.left
			}
			text: qsTr("intro-button-text")
			primary: true

			onClicked: {
				introOverlay.visible = false;
				addCustomTopRightButton(qsTr("Continue"));
				ProgramTips.show(false);
			}
		}

		Image {
			id: introImage
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Math.round(30 * horizontalScaling)
			}
			source: "image://scaled/apps/strvSettings/drawables/program-intro.svg"
		}
	}

	Rectangle {
		id: notAvailableOverlay
		anchors.fill: parent
		visible: !app.strvDevicesList.length
		color: colors.canvas
		z: 1

		Text {
			id: overlayTitleText
			font.family: qfont.semiBold.name
			font.pixelSize: qfont.primaryImportantBodyText
			lineHeight: 0.8
			wrapMode: Text.WordWrap
			text: qsTr("Your program is not available yet")

			anchors {
				top: parent.top
				topMargin: Math.round(35 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
				right: overlayImage.left
				rightMargin: designElements.hMargin20
			}
		}

		Text {
			id: overlayBodyText
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			wrapMode: Text.WordWrap
			text: qsTr("program-unavailable-body")

			anchors {
				top: overlayTitleText.bottom
				topMargin: Math.round(20 * verticalScaling)
				left: overlayTitleText.left
				right: overlayTitleText.right
			}
		}

		Image {
			id: overlayImage
			source: "image://scaled/apps/strvSettings/drawables/presets-illustration.svg"

			anchors {
				bottom: parent.bottom
				bottomMargin: - designElements.bottomBarHeight
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
			}
		}

		StandardButton {
			id: installButton
			minWidth: Math.round(100 * horizontalScaling)
			text: qsTranslate("StrvFrame", "Install")
			primary: true

			anchors {
				top: overlayBodyText.bottom
				topMargin: Math.round(30 * verticalScaling)
				left: overlayTitleText.left
			}

			onClicked: {
				stage.openFullscreen(app.strvInstallIntroScreenUrl, {"resetNavigation": true});
			}
		}
	}

	Row {
		id: tabsContainer
		anchors {
			top: parent.top
			topMargin: Math.round(16 * verticalScaling)
			left: contentContainerPanel.left
		}
		spacing: Math.round(4 * horizontalScaling)

		TopTabButton {
			minWidth: Math.round(76 * horizontalScaling)
			iconSource: "drawables/schedule-heating.svg"
			iconOverlayWhenUp: true
			iconOverlayWhenSelected: true
			selected: true
		}
	}

	Rectangle {
		id: contentContainerPanel
		anchors {
			top: tabsContainer.bottom
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
			bottomMargin: tabsContainer.anchors.topMargin
		}
		color: colors.contentBackground

		Row {
			id: scheduleRow
			property int programDisplayHeight: isNxt ? 240 : 192
			anchors {
				top: parent.top
				topMargin: Math.round(30 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
			}
			spacing: designElements.spacing8

			Repeater {
				id: dayRepeater
				model: 7
				delegate: ThermostatDayProgram {
					stateNames: app.presetNames
					stateColors: app.presetColors
					programDisplayHeight: scheduleRow.programDisplayHeight
					onDaySelected: selectDay(dayToSelect)
					dayEnabled: app.scheduleEnabled
				}
			}
		}

		TimeScale {
			id: timeScale
			anchors {
				bottom: scheduleRow.bottom
				right: scheduleRow.left
				rightMargin: Math.round(7 * horizontalScaling)
			}
			programDayHeight: scheduleRow.programDisplayHeight
			programWidth: scheduleRow.width

			timeEnabled: true
		}

		Text {
			id: programText
			text: qsTr("Program")
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.bodyText
			}
			color: colors.tpModeLabel

			anchors {
				top: scheduleRow.top
				left: scheduleRow.right
				leftMargin: designElements.hMargin15
			}
		}

		OnOffToggle {
			id: programToggle
			height: Math.round(36 * verticalScaling)

			fontColor: colors.spText
			isSwitchedOn: app.scheduleEnabled
			leftIsSwitchedOn: false
			onSelectedChangedByUser: app.sendScheduleEnabled(isSwitchedOn);

			anchors {
				top: programText.bottom
				topMargin: designElements.vMargin6
				left: programText.left
			}
		}

		Column {
			anchors {
				left: scheduleRow.right
				leftMargin: designElements.hMargin15
				bottom: scheduleRow.bottom
			}
			spacing: Math.round(12 * verticalScaling)


			Repeater {
				id: legendRepeater
				model: 4
				delegate: Row {
					spacing: designElements.hMargin10

					Rectangle {
						id: modeColorRectangle
						objectName: "modeColorRec" + index
						width: Math.round(8 * horizontalScaling)
						height: Math.round(28 * verticalScaling)
						radius: 2
						color: app.presetColors[legendRepeater.count - index - 1]
					}

					Text {
						id: modeNameText
						objectName: "modeNameText" + index
						anchors.verticalCenter: parent.verticalCenter
						font {
							family: qfont.bold.name
							pixelSize: qfont.bodyText
						}
						color: colors.text
						text: app.presetNames[legendRepeater.count - index - 1]

						MouseArea {
							anchors.fill: parent
							onClicked: stage.openFullscreen(app.zoneTemperaturePresetScreenUrl);
						}
					}
				}
			}
		}

		StandardButton {
			id: setPresetButton
			text: qsTr("Set")

			anchors {
				top: scheduleRow.bottom
				topMargin: Math.round(8 * verticalScaling)
				left: programText.left
				right: parent.right
				rightMargin: designElements.hMargin15
			}
			onClicked: stage.openFullscreen(app.zoneTemperaturePresetScreenUrl);
		}

		property int dayColumnWidth: 75 * horizontalScaling
		/// buttons to "Copy" and "Modify" currently selected day program. Move with the selection of the day. Hidden when program disabled
		Item {
			id: modifyButtons

			// Sunday is index 0, for the left margin calculation it has to be converted
			//property int selectedDay: programScreen.selectedDay

			width: parent.dayColumnWidth * 7 + designElements.spacing8 * 6 + 2 * 10 // dayColumnWidth*7 -> program width, 8*6 -> program spacing, 2*10 -> border
			height: 8 * 3 + btnCopyProgram.height * 2 //8*3 -> spacing, 36*2 -> button heignt
			anchors.top: scheduleRow.bottom
			anchors.topMargin: Math.round(8 * verticalScaling)
			anchors.left: scheduleRow.left
			anchors.leftMargin: selectedDay * (designElements.spacing8 + parent.dayColumnWidth)

			visible: app.scheduleEnabled

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
					app.startEditSchedule();
					stage.openFullscreen(app.editDayScreenUrl, {fromDay: selectedDay});
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
					app.startEditSchedule();
					stage.openFullscreen(app.copyProgramDayScreenUrl, {fromDay: selectedDay});
				}
			}
		}
	}

	IconButton {
		id: infoButton
		anchors {
			right: contentContainerPanel.right
			verticalCenter: tabsContainer.verticalCenter
		}
		iconSource: "qrc:/images/info.svg"
		onClicked: {
			ProgramTips.show(false);
		}
	}

	Text {
		id: infoText
		anchors {
			right: infoButton.left
			rightMargin: Math.round(8 * horizontalScaling)
			verticalCenter: infoButton.verticalCenter
		}
		font {
			pixelSize: qfont.metaText
			family: qfont.regular.name
		}
		color: colors.foreground
		text: qsTr("programPopupTeaser")
	}
}
