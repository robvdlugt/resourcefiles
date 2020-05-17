import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;
import ThermostatUtils 1.0

Screen {
	id: root

	screenTitle: qsTr("Copy")
	isSaveCancelDialog: true

	QtObject {
		id: p

		//monday based
		property int dayToCopyMB
	}

	onShown: {
		if (args && (args.fromDay >= 0))
			// fromDay is monday-based
			p.dayToCopyMB = args.fromDay;

		for (var i = 0; i < days.count; i++) {
			days.itemAt(i).enabled = true;
			checkBoxGroup.setControlSelectState(i, false);
		}
		days.itemAt(p.dayToCopyMB).enabled = false;
	}

	onSaved: {
		var copyToDaysMB = checkBoxGroup.getSelectedControls();
		app.scheduleEdited = ThermostatUtils.copyDayProgram(app.scheduleEdited, p.dayToCopyMB, copyToDaysMB);
		app.saveEditedSchedule();
	}

	onHidden: {
		app.cancelEditedSchedule();
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

		text: qsTr("Copy %1").arg(i18n.daysFull[ThermostatUtils.mondayBaseToSundayBase(p.dayToCopyMB)])
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

		anchors.top: copyToDaysText.baseline
		anchors.topMargin: Math.round(21 * verticalScaling)
		anchors.horizontalCenter: parent.horizontalCenter
		spacing: designElements.spacing8

		Repeater {
			id: days

			model: 7
			delegate: StandardCheckBox {
				controlGroup: checkBoxGroup
				text: i18n.daysFull[ThermostatUtils.mondayBaseToSundayBase(index)];
			}
		}
	}
}
