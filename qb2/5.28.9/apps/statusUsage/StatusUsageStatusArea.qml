import QtQuick 2.1
import qb.components 1.0

import apps.eMetersSettings 1.0 as EMetersSettings

Item {
	id: root
	property double real
	property double target
	property double diff
	property int usageDecimals: 0
	property bool missingData: false
	property alias statusBar: statusBar

	function init() {
		app.dayChanged.connect(update)
	}

	function deinit() {
		app.dayChanged.disconnect(update)
	}

	function update() {
		statusBar.consumption = real;
		statusBar.estimation = target;
		statusBar.progressionRatio = isCurrentMonth ? (app.dayOfMonth - 1) / app.daysInMonth : 1;

		var moreLessString = (diff !== 0 && !missingData ? i18n.currency(Math.abs(diff), i18n.curr_round) + " " : "");
		moreLessString += app.getDiffText(diff, true);

		var d;
		if (isCurrentMonth) {
			var noMeasureString = ""

			if (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType['elec'] + 1)))
				noMeasureString = app.energyNames.nouns["elec"];
			if (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType['gas'] + 1)))
				noMeasureString = noMeasureString.length ? qsTr("any") : app.energyNames.nouns["gas"];
			if (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType['heat'] + 1)))
				noMeasureString = noMeasureString.length ? qsTr("any") : app.energyNames.nouns["heat"];

			if (noMeasureString) {
				statusText.text = qsTr("Toon is not measuring %1 consumption").arg(noMeasureString);
				estimatedByText.text = "";
			} else {
				d = new Date();
				var currentDateString = i18n.dateTime(d, i18n.time_no | i18n.mon_full | i18n.year_no);
				statusText.text = qsTr("Until %1 you consumed %2").arg(currentDateString).arg(moreLessString);
				estimatedByText.text = qsTr("%1 estimated by QB_BV").arg(diff ? qsTr("than") : qsTr("as"));
			}
		} else {
			d = new Date(periodStart);
			var monthString = i18n.dateTime(d, i18n.time_no | i18n.dom_no | i18n.mon_full | i18n.year_no);
			statusText.text = qsTr("In %1 you consumed %2").arg(monthString).arg(moreLessString);
			estimatedByText.text = qsTr("%1 estimated by QB_BV").arg(diff ? qsTr("than") : qsTr("as"));
		}
	}

	Text {
		id: statusText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round((estimatedByText.visible ? 30 : 40) * verticalScaling)
			left: parent.left
			right: parent.right
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.statusUsageStatusText
		text: " "
	}

	Text {
		id: estimatedByText
		anchors {
			baseline: statusText.baseline
			baselineOffset: Math.round(25 * verticalScaling)
			left: parent.left
			right: parent.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.statusUsageStatusText
		visible: text !== ""
		text: " "
	}

	StatusUsageStatusBar {
		id: statusBar
		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Math.round(60 * verticalScaling)
		}
		missingData: root.missingData
	}
}
