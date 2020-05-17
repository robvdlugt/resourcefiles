import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: root

	screenTitle: qsTr("Copy")
	isSaveCancelDialog: true

	property DomesticHotWaterApp app

	QtObject {
		id: p

		// Sunday based
		property int daySelected
	}

	onSaved: {
		var tmpProgram = app.cloneProgram(app.dhwProgram);

		// Monday based
		var targetDaysList = checkBoxGroup.getSelectedControls();
		// Move to Sunday based
		for (var i = 0; i < targetDaysList.length; ++i) {
			targetDaysList[i] = app.mondayBaseToSundayBase(targetDaysList[i]);
		}

		tmpProgram = app.copyDayToDays(tmpProgram, p.daySelected, targetDaysList);

		if (tmpProgram !== undefined) {
			app.updateDHWSchedule(tmpProgram);
			// app.dhwProgram will be updated by the reply for the updateDHWSchedule call.
		}
	}

	onShown: {
		if (args && args.curDay >= 0) {
			p.daySelected = args.curDay;
		}

		for (var i = 0; i < days.count; i++) {
			days.itemAt(i).enabled = true;
			checkBoxGroup.setControlSelectState(i, false);
		}
		days.itemAt(app.sundayBaseToMondayBase(p.daySelected)).enabled = false;
	}

	Text {
		id: copyDayLabel

		anchors {
			baseline: parent.top
			baselineOffset: 58
			left: copyToDaysText.left
		}
		color: colors.copyDayLabel
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}

		text: qsTr("Copy %1").arg(i18n.daysFull[p.daySelected])
	}

	Text {
		id: copyToDaysText

		anchors {
			left: daysColumn.left
			baseline: copyDayLabel.baseline
			baselineOffset: 23
		}
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.copyDayDayText
		text: qsTr("To day(s):")
	}

	ControlGroup {
		id: checkBoxGroup
		exclusive: false
	}

	Column {
		id: daysColumn

		anchors {
			top: copyToDaysText.baseline
			topMargin: Math.round(21 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		spacing: designElements.spacing8

		Repeater {
			id: days

			model: 7
			delegate: StandardCheckBox {
				controlGroup: checkBoxGroup
				text: i18n.daysFull[app.mondayBaseToSundayBase(index)];
			}
		}
	}
}
