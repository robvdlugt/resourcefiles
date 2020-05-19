import QtQuick 2.1

import qb.components 1.0

Screen {
	id: eMeterLowRateHoursScreen

	screenTitle: qsTr("Low rate hours on weekdays")
	isSaveCancelDialog: true
	anchors.fill: parent

	onShown: {
		app.getPeakPeriods(p.handlePeakPeriodsResponse);
	}

	onSaved: {
		var modelItem = rbList.getModelItem(rbList.currentIndex);
		if (typeof modelItem !== 'undefined' && typeof modelItem.itemId !== 'undefined') {
			console.log("Selecting ", modelItem.itemId, "as peak period.");
			app.setPeakPeriod(modelItem.itemId);
		} else {
			console.log("Error. Could not retrieve peakPeriodId from radiobutton list.");
		}
	}

	QtObject {
		id: p

		function handlePeakPeriodsResponse(peakPeriodRespone) {
			waitThrobber.visible = false;
			p.populatePeakPeriodsRButtons(app.parsePeakPeriodsResponse(peakPeriodRespone));
		}

		function populatePeakPeriodsRButtons(peakPeriodMap) {
			var id;
			var values;

			if (! peakPeriodMap) {
				return;
			}

			// First add (all) the default item(s)
			for (id in peakPeriodMap) {
				values = peakPeriodMap[id];
				if (values['default']) {
					rbList.addPeakItem(id, values);
				}
			}
			// Then add the non-default items
			for (id in peakPeriodMap) {
				values = peakPeriodMap[id];
				if (! values['default']) {
					rbList.addPeakItem(id, values);
				}
			}

		}
	}

	RadioButtonList {
		id: rbList

		width: Math.round(350 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			bottom: parent.bottom
			bottomMargin: Math.round(60 * verticalScaling)
		}

		title: qsTr("Low rate hours") + ":"

		function addPeakItem(id, values) {
			var dateLow = new Date(0);
			var dateHigh = new Date(0);
			dateLow.setHours(values.peakEndHour);
			dateLow.setMinutes(values.peakEndMinute);
			dateHigh.setHours(values.peakStartHour);
			dateHigh.setMinutes(values.peakStartMinute);

			var timeLowStr = i18n.dateTime(dateLow.getTime(), i18n.time_yes | i18n.leading_0_yes);
			var timeHighStr = i18n.dateTime(dateHigh.getTime(), i18n.time_yes | i18n.hour_str_yes | i18n.leading_0_yes);
			var txt;
			if (values['default']) {
				txt = qsTr("Standard low rate hours: %1 - %2").arg(timeLowStr).arg(timeHighStr);
			} else {
				txt = qsTr("Odd low rate hours: %1 - %2").arg(timeLowStr).arg(timeHighStr);
			}
			addCustomItem({"itemtext" : txt, "itemEnabled": true, "itemId" : id, "selected": values.active});
		}
	}

	Throbber {
		id: waitThrobber
		// Set to invisible when the getPeakPeriods callback is called

		anchors {
			horizontalCenter: rbList.horizontalCenter
			top: infoPopupBtn.bottom
			topMargin: designElements.vMargin10

		}
	}

	IconButton {
		id: infoPopupBtn
		iconSource: "qrc:/images/info.svg"
		width: Math.round(28 * horizontalScaling)
		height: Math.round(28 * verticalScaling)
		anchors {
			right: rbList.right
			top: rbList.top
		}

		bottomClickMargin: 0
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Low rate hours explanation"), app.eMeterLowRateHoursPopupUrl);
		}
	}
}
