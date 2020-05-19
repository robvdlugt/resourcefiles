import QtQuick 2.1
import QtQuick.Layouts 1.11

import qb.components 1.0

/// Screen for setting vacation details.

Screen {
	id: vacationSetScreen
	screenTitle: qsTr("Vacation set")
	isSaveCancelDialog: true

	onSaved: {
		modeVacation.temperatureChanged();
		app.updateVacationData(app.tmpVacationData);
	}

	onShown: {
		if (args && args.newVacation) {
			var newVacationData = app.vacationData;
			var now = new Date();
			now.setMinutes(0, 0, 0);

			var vacationData = app.vacationData;
			newVacationData.startTime = now.getTime();
			btnStartDate.text = app.formatDateTime(now.getTime(), true);

			var future = new Date(now);
			future.setFullYear(future.getFullYear() + 5);
			newVacationData.endTime = future.getTime();
			btnEndDate.text = app.formatDateTime(future.getTime(), false);

			modeVacation.temperature = 6.0; // default vacation temperature
			app.tmpVacationData = newVacationData;
		} else {
			if (args && args.editVacation)
				app.tmpVacationData = app.vacationData;

			modeVacation.temperature = app.tmpVacationData.temperature;
			btnStartDate.text = app.formatDateTime(app.tmpVacationData['startTime'], true);
			btnEndDate.text = app.formatDateTime(app.tmpVacationData['endTime'], false);
		}
	}

	GridLayout {
		id: grid
		anchors {
			top: parent.top
			topMargin: Math.round(84 * horizontalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		flow: GridLayout.TopToBottom
		rows: 2
		columnSpacing: designElements.spacing10
		rowSpacing: designElements.spacing10

		// empty item to occupy cell
		Item {
			width: 1
			height: 1
		}

		TemperatureModeSet {
			id: modeVacation
			Layout.rightMargin: Math.round(64 * verticalScaling)
			label: qsTr("Temperature")
			color: colors.tpModeVacation
			temperature: 6
			maxEcoTemperature: app.thermStateMaxEcoTemperature[app.thermStateHoliday]

			onTemperatureChanged: {
				var vacData = app.tmpVacationData;
				vacData.temperature = temperature;
				app.tmpVacationData = vacData;
			}
		}

		Text {
			id: txtStartDate
			text: qsTr("Start date")
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.tpModeLabel
		}

		RichTextButton {
			id: btnStartDate
			text: qsTranslate("ThermostatApp", "now")
			Layout.preferredWidth: Math.round(165 * horizontalScaling)
			Layout.preferredHeight: Math.round(109 * verticalScaling)
			kpiPostfix: "startDate"
			colorUp: colors.tempTileBackgroundUp
			fontColorUp: colors.tempTileTextUp
			fontFamily: "Open Sans Regular"
			fontPixelSize: qfont.titleText

			onClicked: {
				// set the minimum start time to now at most recent full hour
				var minDt = new Date();
				minDt.setMinutes(0, 0, 0);

				// set the initial value to the starting time of the vacation
				var init = new Date(app.tmpVacationData['startTime']);

				// set the maximum start time to the minimum plus two years
				var maxDt = new Date(minDt);
				maxDt.setFullYear(maxDt.getFullYear() + 2);

				// if vacation already has an end and it is before the start maximum,
				// set the start maximum to the end minus 1 hour
				if (app.tmpVacationData['endTime'] < maxDt.getTime()) {
					maxDt.setTime(app.tmpVacationData['endTime']);
					maxDt.setHours(maxDt.getHours() - 1);
				}

				stage.openFullscreen(app.vacationDateScreenUrl, {dateToChange: "startTime", initDt: init, minDt: minDt, maxDt: maxDt});
			}
		}

		// empty item to occupy cell
		Item {
			width: 1
			height: 1
		}

		Text {
			id: txtTo
			text: qsTr("to")
			font {
				family: qfont.regular.name
				pixelSize: qfont.titleText
			}
			color: colors.tpInfoLabel
		}

		Text {
			id: txtEndDate
			text: qsTr("End date")
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.tpModeLabel
		}

		RichTextButton {
			id: btnEndDate
			Layout.preferredWidth: Math.round(165 * horizontalScaling)
			Layout.preferredHeight: Math.round(109 * verticalScaling)
			colorUp: colors.tempTileBackgroundUp
			fontColorUp: colors.tempTileTextUp
			text: qsTranslate("ThermostatApp", "I return", "setScreen")
			kpiPostfix: "endDate"
			fontFamily: "Open Sans Regular"
			fontPixelSize: qfont.titleText

			onClicked: {
				var now = new Date();
				// initialy set the end time to the start time's next full hour
				var init = new Date(app.tmpVacationData['startTime']);
				init.setHours(init.getHours() + 1);

				// if initial end time is in the past (because we are editing)
				// a previously created vacation, set initial end time to next full hour
				if (init.getTime() < now.getTime()) {
					init = now;
					init.setMinutes(0, 0, 0);
					init.setHours(init.getHours() + 1);
				}

				// minimum end time is also the initial date and time
				var minDt = new Date(init);
				// maximum end time is minimum plus two years
				var maxDt = new Date(minDt);
				maxDt.setFullYear(maxDt.getFullYear() + 2);

				// if vacation already has an end time and its smaller than
				// calculated maximum end time, set the initial end time to that
				if (app.tmpVacationData['endTime'] < maxDt.getTime()) {
					init.setTime(app.tmpVacationData['endTime']);
				}

				stage.openFullscreen(app.vacationDateScreenUrl, {dateToChange: "endTime", initDt: init, minDt: minDt, maxDt: maxDt});
			}
		}
	}
}
