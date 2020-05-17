import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: root

	screenTitle: qsTr("Copy")
	isSaveCancelDialog: true

	QtObject {
		id: p

		//monday based
		property int dayToCopyMB
		//sunday based
		property int dayToCopySB

		property bool shouldSave: true
	}

	function setDayToCopy(day) {
		p.dayToCopyMB = app.sundayBaseToMondayBase(day);
		p.dayToCopySB = day;
	}

	onSaved: {
		var copyToDaysMB = checkBoxGroup.getSelectedControls();
		var copyToDaysSB = [];
		for(var i = 0; i < copyToDaysMB.length; i++) {
			copyToDaysSB.push(app.mondayBaseToSundayBase(copyToDaysMB[i]));
		}

		if (p.shouldSave) {
			app.programScreen.saveProgram(2, {'fromDay': p.dayToCopySB, 'toDays': copyToDaysSB});
		} else {
			app.copyProgramDay(p.dayToCopySB, copyToDaysSB);
			app.programWasEdited = true;
		}
	}

	onShown: {
		if (args && args.shouldSave !== null && args.shouldSave !== undefined)
			p.shouldSave = args.shouldSave;

		if (args && (args.fromDay >= 0))
			setDayToCopy(args.fromDay);

		for (var i = 0; i < days.count; i++) {
			days.itemAt(i).enabled = true;
			checkBoxGroup.setControlSelectState(i, false);
		}
		days.itemAt(p.dayToCopyMB).enabled = false;
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

		text: qsTr("Copy %1").arg(i18n.daysFull[p.dayToCopySB])
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
				text: i18n.daysFull[app.mondayBaseToSundayBase(index)];
			}
		}
	}
}
