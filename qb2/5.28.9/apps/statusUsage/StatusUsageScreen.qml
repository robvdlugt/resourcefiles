import QtQuick 2.1
import QtQuick.Layouts 1.3

import GraphUtils 1.0
import qb.components 1.0
import BasicUIControls 1.0

import apps.eMetersSettings 1.0 as EMetersSettings

Screen {
	id: statusUsageScreen

	screenTitleIconUrl: "drawables/menuIcon.svg"
	screenTitle: qsTr("Status usage")

	property StatusUsageApp app

	// less is +1, more is -1 and same is 0
	property int moreOrLessLeft
	property int moreOrLessRight
	property string moreOrLessLeftString
	property string moreOrLessRightString
	property string valueLeft
	property string valueRight
	property bool missingDataLeft
	property bool missingDataRight
	property bool estimatedGenerationValid
	property bool hasException: false
	property int completeEstimatedCost
	// for unit tests, only
	property double statusAreaReal: monthOverview.statusArea.real
	property double statusAreaTarget: monthOverview.statusArea.target

	QtObject {
		id: p;

		property string type
		property variant units: ({elec:"kWh", gas:"m³", heat:"GJ", elec_produ:"kWh"})
		property variant agreementType: ["total", "elec", "gas", "heat"]
		property variant unitType: ["energy", "money"]
	}

	onShown: {
		estimatedGenerationValid = app.billingInfos["elec_produ"].usage > 0;
		updateMonthSpinner();
		if (args && args.period) {
			var matches = args.period.match(/^(\d+)-(\d+)$/);
			if (matches) {
				var year = matches[2];
				var month = parseInt(matches[1], 10) - 1;
				var d = new Date(year, month, 1, 0, 0, 0, 0);
				if (d && d >= dateSelector.periodMinimum && d <= dateSelector.periodMaximum)
					dateSelector.periodStart = d;
			}
		}
		updateStatusUsage();
		showPopups();
	}

	Component.onDestruction: {
		monthOverview.statusArea.deinit();
		app.monthChanged.disconnect(updateMonthSpinner);
		app.monthChanged.disconnect(updateStatusUsage);
		app.dataAvailableChanged.disconnect(updateStatusUsage);
		app.billingInfosChanged.disconnect(updateStatusUsage);
		app.eMetersSettingsApp.overallStatusChanged.disconnect(updateStatusUsage);
	}

	/**	calculate real and target cost and usage and store them to statusArea properties
		@param leftDiff : real may hold power, gas or heat values
		@param rightDiff : real may hold gas or heat values
	*/
	function calculateDisplayedValues(leftDiff, rightDiff) {
		var iblv = 0, ibrv = 0;

		iblv = app.roundCostDiff(leftDiff);
		ibrv = app.roundCostDiff(rightDiff);

		monthOverview.statusArea.real = leftDiff.realCost + rightDiff.realCost;
		monthOverview.statusArea.target = leftDiff.targetCost + rightDiff.targetCost;
		monthOverview.statusArea.diff = iblv + ibrv;

		valueLeft = app.formatCostDiff(iblv);
		valueRight = app.formatCostDiff(ibrv);

		missingDataLeft = !leftDiff.validUsageData;
		missingDataRight = !rightDiff.validUsageData;
		monthOverview.statusArea.missingData = missingDataLeft || missingDataRight;

		moreOrLessLeft = (iblv > 0) - (iblv < 0);
		moreOrLessRight = (ibrv > 0) - (ibrv < 0);
		moreOrLessLeftString = app.getDiffText(iblv);
		moreOrLessRightString = app.getDiffText(ibrv);

		completeEstimatedCost = leftDiff.targetCostComplete + rightDiff.targetCostComplete;

		var detailsModel = [];
		detailsModel.push({
			resource: "elec",
			isGood: moreOrLessLeft >= 0,
			estimationCost: i18n.currency(leftDiff.targetCostComplete, i18n.curr_round),
			estimationUsage: i18n.number(leftDiff.targetUsageComplete) + " " + app.energyUnits["elec"],
			actualCost: i18n.currency(leftDiff.realCost, i18n.curr_round),
			actualUsage: i18n.number(leftDiff.realUsage) + " " + app.energyUnits["elec"]
		});
		if (app.secondaryEnergyType) {
			var unit = app.energyUnits[app.secondaryEnergyType];
			var decimals = app.secondaryEnergyType === "heat" ? 2 : 0;
			detailsModel.push({
				resource: app.secondaryEnergyType,
				isGood: moreOrLessRight >= 0,
				estimationCost: i18n.currency(rightDiff.targetCostComplete, i18n.curr_round),
				estimationUsage: i18n.number(rightDiff.targetUsageComplete, decimals) + " " + unit,
				actualCost: i18n.currency(rightDiff.realCost, i18n.curr_round),
				actualUsage: i18n.number(rightDiff.realUsage, decimals)  + " " + unit
			});
		}
		monthDetails.model = detailsModel;
	}

	/** set actual usage data (realCost/realUsage) and estimations (targetCost/targetUsage) according to
		the agreement that is selected (total/power/gas/heat).
	*/
	function updateUsage() {

		function dataCallback(success, data) {
			if (success) {
				var leftDiff = null, rightDiff = null, decimals;

				leftDiff = app.calculateDiffValues(data[app.apiResourceNameMap["elec"]], 0);

				decimals = app.secondaryEnergyType === "heat" ? 2 : 0
				var secondaryData = data[app.apiResourceNameMap[app.secondaryEnergyType]];
				if (!secondaryData)
					secondaryData = app.emptyMonth();
				rightDiff = app.calculateDiffValues(secondaryData, decimals);

				calculateDisplayedValues(leftDiff, rightDiff);

				if (monthOverview.statusArea.real === 0 && !monthOverview.isCurrentMonth) {
					monthException.text = qsTr("There is no consumption data for this month...");
					hasException = true;
				} else if (monthOverview.statusArea.target === 0) {
					monthException.text = qsTr("There is no estimation for this month...");
					hasException = true;
				} else {
					hasException = false;
				}
				updateInfoBox();
				monthOverview.statusArea.update();
			} else {
				hasException = true;
				monthException.text = qsTr("Toon couldn't get the data for this month.");
			}
			monthException.loading = false;
		}

		var date = dateSelector.periodStart;
		var month = date.getMonth() + 1;
		var year = date.getFullYear();
		app.getMonthData(month, year, dataCallback);
		hasException = true;
		monthException.loading = true;
	}

	function disableStatusUsage() {
		var haveSJV = app.getBillingInfoValue("total", "haveSJV", "and");
		var estimationValid = app.billingInfos["elec_produ"].usage > 0 || !app.agreementDetailsSolar;

		statusUsage.visible = false;
		intro.visible = false;
		noEstimation.visible = false;
		comingSoon.visible = false;
		noEstimatedProduction.visible = false;

		if (!estimationValid) {
			noEstimatedProduction.visible = true;
		} else if (!haveSJV) {
			noEstimation.visible = true;
		} else {
			var d = new Date();
			if (d.getDate() > 1)
				d.setMonth(d.getMonth() + 1);
			d.setDate(2);
			comingSoon.dateString = i18n.dateTime(d, i18n.time_no | i18n.mon_full | i18n.year_no);
			comingSoon.daysLeft = Math.floor((d.getTime() - Date.now()) / 86400000);
			comingSoon.visible = true;
		}
	}

	function enableStatusUsage() {
		if (app.firstUse) {
			intro.visible = true;
			statusUsage.visible = false;
		} else {
			intro.visible = false;
			statusUsage.visible = true;
		}
		noEstimation.visible = false;
		comingSoon.visible = false;
		noEstimatedProduction.visible = false;
	}

	function updateInfoBox() {
		var d = new Date(dateSelector.periodStart);
		var monthName = i18n.monthsFull[d.getMonth()];
		var isCurrentMonth = monthOverview.isCurrentMonth;

		var elecProblem = (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType['elec'] + 1)));
		var statusIcon;
		if ((elecProblem && isCurrentMonth) || missingDataLeft) {
			statusIcon = "off";
		} else {
			statusIcon = (moreOrLessLeft >= 0 ? "good" : "bad");
		}
		monthOverview.infoBox.leftIconSource = "image://scaled/apps/statusUsage/drawables/elec_" + statusIcon + ".svg";

		if (missingDataLeft) {
			monthOverview.infoBox.leftText = (elecProblem && isCurrentMonth) ? qsTr("No measurement") : qsTr("Incomplete data");
		} else {
			if (moreOrLessLeft) {
				monthOverview.infoBox.leftText = qsTr("<b>%1 %2</b> %3 consumed").arg(valueLeft).arg(moreOrLessLeftString).arg(app.energyNames.nouns["elec"]);
			} else {
				monthOverview.infoBox.leftText = i18n.capitalizeFirstChar(qsTr("%1 consumption <b>%2</b>").arg(app.energyNames.nouns["elec"]).arg(moreOrLessLeftString));
			}
		}

		if (app.secondaryEnergyType) {
			var mediumRight = app.energyNames.nouns[app.secondaryEnergyType];
			var secTypeProblem = (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType[app.secondaryEnergyType] + 1)));
			if ((secTypeProblem && isCurrentMonth) || missingDataRight) {
				statusIcon = "off";
			} else {
				statusIcon = (moreOrLessRight >= 0 ? "good" : "bad");
			}
			monthOverview.infoBox.rightIconSource = "image://scaled/apps/statusUsage/drawables/" + app.secondaryEnergyType + "_" + statusIcon + ".svg";
			monthOverview.infoBox.rightType = app.secondaryEnergyType;

			if (missingDataRight) {
				monthOverview.infoBox.rightText = (secTypeProblem && isCurrentMonth) ? qsTr("No measurement") : qsTr("Incomplete data");
			} else {
				if (moreOrLessRight) {
					monthOverview.infoBox.rightText = qsTr("<b>%1 %2</b> %3 consumed").arg(valueRight).arg(moreOrLessRightString).arg(mediumRight);
				} else {
					monthOverview.infoBox.rightText = i18n.capitalizeFirstChar(qsTr("%1 consumption <b>%2</b>").arg(mediumRight).arg(moreOrLessRightString));
				}
			}
			monthOverview.infoBox.rightVisible = true;
		} else {
			monthOverview.infoBox.rightVisible = false;
		}

		monthOverview.infoBox.year = d.getFullYear();
	}

	function updateStatusUsage() {
		if (!app.doneLoading)
			return;

		estimatedGenerationValid = app.billingInfos["elec_produ"].usage > 0;

		if (app.dataAvailable.isAvailable && app.getBillingInfoValue("total", "haveSJV", "and") &&
				(!app.agreementDetailsSolar || estimatedGenerationValid)) {
			enableStatusUsage();
			updateUsage();
		} else {
			disableStatusUsage();
		}
	}

	function init() {
		app.monthChanged.connect(updateMonthSpinner);
		app.monthChanged.connect(updateStatusUsage);
		app.dataAvailableChanged.connect(updateStatusUsage);
		app.billingInfosChanged.connect(updateStatusUsage);
		app.eMetersSettingsApp.overallStatusChanged.connect(updateStatusUsage);
		monthOverview.statusArea.init();
	}

	function updateMonthSpinner() {
		var d = new Date();
		if (d.getDate() === 1) {
			d.setMonth(d.getMonth() - 1);
		}
		dateSelector.periodMaximum = d;
		dateSelector.periodStart = d;
		var firstAvailableMonth = new Date(app.dataAvailable.firstAvailableMonth);
		if (!isNaN(firstAvailableMonth)) {
			dateSelector.periodMinimum = firstAvailableMonth;
		} else {
			d.setMonth(d.getMonth() - 12);
			dateSelector.periodMinimum = d;
		}

	}

	function showExplanationPopup() {
		qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl);
		qdialog.context.titleFontPixelSize = qfont.navigationTitle;
		var tips = [
			{
				title: qsTr("explanation_estimation_title"),
				text: qsTr("explanation_estimation_text")
					.arg(app.secondaryEnergyType ? app.energyNames.nouns[app.secondaryEnergyType] : "") +
					(statusUsage.visible && monthOverview.isCurrentMonth ? qsTr("explanation_estimation_month")
					.arg(i18n.dateTime(new Date(dateSelector.periodStart), i18n.time_no | i18n.dom_no | i18n.mon_full | i18n.year_no))
					.arg(i18n.currency(completeEstimatedCost, i18n.curr_round)) +
					(globals.productOptions["SME"] === "1" ? " <i>" + qsTr("(excl. VAT)") + "</i>" : "") : ""),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/explanation_estimation.svg")
			},
			{
				title: qsTr("explanation_bill_title"),
				text: qsTr("explanation_bill_text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/explanation_bill.svg")
			},
			{
				title: qsTr("explanation_behaviour_title"),
				text: qsTr("explanation_behaviour_text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/explanation_behaviour.svg")
			}
		];
		if (app.agreementDetailsSolar && estimatedGenerationValid)
			tips.push({
						title: qsTr("explanation_solar_title"),
						text: qsTr("explanation_solar_text").arg(app.billingInfos["elec_produ"].usage / 1000),
						textFormat: Text.RichText,
						image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/explanation_solar.svg")
					  });
		qdialog.context.dynamicContent.showSeparator = false;
		qdialog.context.dynamicContent.carousel = false;
		qdialog.context.dynamicContent.imageContainerWidth = 230;
		qdialog.context.dynamicContent.tips = tips;
	}

	function showPopups() {
		// show no measurement popup if:
		// measuring device is not OK and error indication is shown OR
		// one or more usages (sensors) are not OK
		// AND current month is being shown

		// Show new estimations popup if no measurement popup is not
		// shown or dismissed.
		var popupTitle, popupText;
		var isCurrentMonth = monthOverview.isCurrentMonth;
		if (app.eMetersSettingsApp.overallStatus && isCurrentMonth) {
			popupTitle = qsTr("popup_no_measurement_title");
			popupText = qsTr("popup_no_measurement_text");
		} else if ((missingDataLeft || missingDataRight) &&
				   (isCurrentMonth || (!isCurrentMonth && monthOverview.statusArea.real !== 0))) {
			popupTitle = qsTr("popup_missing_data_title");
			popupText = qsTr("popup_missing_data_text");
		}

		if (statusUsage.visible) {
			if (popupTitle && popupText) {
				qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl, qsTr("OK"), showNewEstimationsPopup);
				qdialog.context.titleFontPixelSize = qfont.navigationTitle;
				var tips = [{
					title: popupTitle,
					text: popupText,
					textFormat: Text.RichText,
					image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/popup_no_measurement.svg")
				}];
				qdialog.context.dynamicContent.imageContainerWidth = 260;
				qdialog.context.dynamicContent.tips = tips;
			} else {
				showNewEstimationsPopup();
			}
		}
	}

	function showNewEstimationsPopup() {
		function saveElecBillingInfoChangeDate() {
			app.saveConfig("elecBillingInfoChangeDate", app.billingInfos["elec"]["changeDate"]);
		}

		// first time don't show popup but save for next time
		if (typeof app.configParams["elecBillingInfoChangeDate"] === "string") {
			var savedChangeDate = parseInt(app.configParams["elecBillingInfoChangeDate"]);
		} else {
			saveElecBillingInfoChangeDate();
			savedChangeDate = 0;
		}

		if (savedChangeDate && app.billingInfos["elec"]["changeDate"] > savedChangeDate) {
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl, qsTr("OK"), saveElecBillingInfoChangeDate);
			qdialog.context.titleFontPixelSize = qfont.navigationTitle;
			var tips = [{
				title: qsTr("new_estimation_popup_title"),
				text: qsTr("new_estimation_popup_text").arg(i18n.dateTime(1000 * parseInt(app.billingInfos["elec"]["changeDate"]), i18n.dom_no | i18n.mon_full | i18n.time_no)),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/apps/statusUsage/drawables/new_estimation_popup.svg")
			}];
			qdialog.context.dynamicContent.imageContainerWidth = 260;
			qdialog.context.dynamicContent.tips = tips;
			// if caller of showNewEstimationsPopup is button handler of no
			// measurement popup, prevent from being reset (see
			// button[12]Clicked in dialogpopup.cpp)
			return true;
		}
		// if new estimations popup is not shown, DO reset no measurement
		// popup after it was dismissed
		return false;
	}

	function isCurrentMonthSelected(start, end) {
		var d = new Date();
		d.setHours(0);
		d.setMinutes(0);
		d.setSeconds(0);
		d.setMilliseconds(0);
		return (d >= start && d <= end);
	}

	ControlGroup {
		id: topLeftTabBarGroup
		exclusive: true
	}

	Item {
		id: statusUsage
		anchors.fill: parent

		Flow {
			id: topLeftTabBar
			anchors {
				left: contentRect.left
				top: parent.top
				topMargin: designElements.vMargin20
			}
			spacing: Math.round(4 * horizontalScaling)

			TopTabButton {
				id: overviewTab
				text: qsTr("Month Overview")
				controlGroupId: 0
				controlGroup: topLeftTabBarGroup
				selected: true
			}

			TopTabButton {
				id: detailsTab
				text: qsTr("Details")
				controlGroupId: 1
				controlGroup: topLeftTabBarGroup
			}
		}

		Text {
			id: explanationText
			anchors {
				verticalCenter: infoPopupButton.verticalCenter
				right: infoPopupButton.left
				rightMargin: designElements.hMargin15
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
			}
			color: colors.statusUsageBodyAlt
			text: qsTr("Do you want to know more about your status usage?")
		}

		StandardButton {
			id: infoPopupButton
			anchors {
				verticalCenter: topLeftTabBar.verticalCenter
				right: contentRect.right
			}
			text: qsTr("See explanation")
			onClicked: showExplanationPopup()
		}

		Text {
			id: withoutVatText
			visible: globals.productOptions["SME"] === "1"
			anchors {
				verticalCenter: dateSelector.verticalCenter
				left: contentRect.left
				leftMargin: designElements.hMargin10
			}
			font {
				family: qfont.italic.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageBodyAlt
			text: qsTr("Amounts excl. VAT")
		}

		Rectangle {
			id: contentRect
			anchors {
				top: topLeftTabBar.bottom
				topMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
				bottom: dateSelector.top
				left: parent.left
				right: parent.right
				leftMargin: Math.round(16 * horizontalScaling)
				rightMargin: anchors.leftMargin
			}
			color: colors.statusUsageBackgroundRectangle

			StackLayout {
				anchors.fill: parent
				currentIndex: hasException ? 2 : topLeftTabBarGroup.currentControlId

				StatusUsageMonthOverview {
					id: monthOverview
					isCurrentMonth: isCurrentMonthSelected(dateSelector.periodStart, dateSelector.periodEnd)
					periodStart: dateSelector.periodStart
					periodEnd: dateSelector.periodEnd

					onHelpButtonClicked: showPopups()
				}

				StatusUsageMonthDetails {
					id: monthDetails
					isCurrentMonth: monthOverview.isCurrentMonth
				}

				StatusUsageException {
					id: monthException
					year: dateSelector.periodStart.getFullYear()
				}
			}
		}

		Rectangle {
			anchors.fill: dateSelector
			color: colors.graphScreenBackground
		}

		DateSelector {
			id: dateSelector
			anchors {
				bottom: parent.bottom
				right: contentRect.right
			}
			mode: DateSelectorComponent.MODE_MONTH

			Component.onCompleted: {
				periodStart = new Date();
				periodChanged.connect(updateStatusUsage);
			}
		}
	}

	Item {
		id: intro
		anchors.fill: parent
		visible: false

		Text {
			id: introTitle
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(53 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(71 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.statusUsageTitle
			text: qsTr("Are you doing better than estimated by QB_BV?")
		}

		Text {
			id: introText
			anchors {
				baseline: introTitle.baseline
				baselineOffset: Math.round(53 * verticalScaling)
				left: introTitle.left
			}
			width: Math.round(360 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageTitle
			wrapMode: Text.WordWrap
			text: qsTr("intro-text")
		}

		StandardButton {
			anchors {
				top: introText.bottom
				topMargin: designElements.vMargin15
				left: introText.left
			}
			text: qsTr("Let's start")
			onClicked: {
				// clear first use flag
				app.setStatusUsageFirstUse(false);
				intro.visible = false;
				statusUsage.visible = true;
			}
		}

		Image {
			id: introImg
			source: visible ? "image://scaled/apps/statusUsage/drawables/icons_illustration.svg" : ""
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(60 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
			}
		}
	}

	Item {
		id: noEstimation
		anchors.fill: parent
		visible: false

		Text {
			id: noEstimationTitle
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(53 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(71 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.statusUsageTitle
			text: qsTr("Available soon")
		}

		Text {
			id: noEstimationText
			anchors {
				baseline: noEstimationTitle.baseline
				baselineOffset: Math.round(53 * verticalScaling)
				left: noEstimationTitle.left
			}
			width: Math.round(310 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageTitle
			wrapMode: Text.WordWrap
			text: qsTr("no-estimation-text")
		}

		StandardButton {
			anchors {
				top: noEstimationText.bottom
				topMargin: designElements.vMargin15
				left: noEstimationText.left
			}
			text: qsTr("See explanation")
			onClicked: showExplanationPopup();
		}

		Image {
			id: noEstimationImg
			source: visible ? "image://scaled/apps/statusUsage/drawables/graphs_illustration.svg" : ""
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(60 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
			}
		}
	}

	Item {
		id: comingSoon
		anchors.fill: parent
		visible: false
		property string dateString
		property int daysLeft

		Text {
			id: comingSoonTitle
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(53 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(71 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.statusUsageTitle
			text: qsTr("Available starting %1").arg(comingSoon.dateString)
		}

		Text {
			id: comingSoonText
			anchors {
				baseline: comingSoonTitle.baseline
				baselineOffset: Math.round(53 * verticalScaling)
				left: comingSoonTitle.left
			}
			width: Math.round(310 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageTitle
			wrapMode: Text.WordWrap
			text: qsTr("coming-soon-text")
		}

		StandardButton {
			anchors {
				top: comingSoonText.bottom
				topMargin: designElements.vMargin15
				left: comingSoonText.left
			}
			text: qsTr("See explanation")
			onClicked: showExplanationPopup();
		}

		Image {
			id: comingSoonCalendar
			source: visible ? "image://scaled/apps/statusUsage/drawables/calendar_illustration.svg" : ""
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(40 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(60 * horizontalScaling)
			}

			Text {
				id: daysLeftTopText
				anchors {
					baseline: parent.top
					baselineOffset: Math.round(70 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
					horizontalCenterOffset: -8
				}
				font {
					family: qfont.regular.name
					pixelSize: 24
				}
				color: colors.statusUsageCalendarText
				text: qsTr("Still")
			}

			Text {
				id: daysLeftValue
				anchors {
					baseline: daysLeftTopText.baseline
					baselineOffset: Math.round(60 * verticalScaling)
					horizontalCenter: daysLeftTopText.horizontalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: 60
				}
				color: colors.statusUsageCalendarText
				text: comingSoon.daysLeft
			}

			Text {
				id: daysLeftBottomText
				anchors {
					baseline: daysLeftTopText.baseline
					baselineOffset: Math.round(90 * verticalScaling)
					horizontalCenter: daysLeftTopText.horizontalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: 24
				}
				color: colors.statusUsageCalendarText
				text: qsTr("day(s)", "", comingSoon.daysLeft)
			}
		}
	}

	Item {
		id: noEstimatedProduction
		anchors.fill: parent
		visible: false

		Text {
			id: noEstimatedProductionTitle
			anchors {
				baseline: parent.top
				baselineOffset: Math.round(53 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(71 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			color: colors.statusUsageTitle
			text: qsTr("Quby needs your estimated production")
		}

		Text {
			id: noEstimatedProductionText
			anchors {
				baseline: noEstimatedProductionTitle.baseline
				baselineOffset: Math.round(53 * verticalScaling)
				left: noEstimatedProductionTitle.left
			}
			width: Math.round(310 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.statusUsageTitle
			wrapMode: Text.WordWrap
			text: qsTr("no-estimated-production-text")
		}

		StandardButton {
			anchors {
				top: noEstimatedProductionText.bottom
				topMargin: designElements.vMargin15
				left: noEstimatedProductionText.left
			}
			text: qsTr("Fill out estimation")
			onClicked: {
				if (globals.enabledApps.indexOf("eMetersSettings") > -1)
					stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/eMetersSettings/EstimatedGenerationScreen.qml"), {from: "statusUsage"});
			}
		}

		Image {
			id: noEstimatedProductionImg
			source: visible ? "image://scaled/apps/statusUsage/drawables/production_illustration.svg" : ""
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(60 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(50 * horizontalScaling)
			}
		}
	}
}
