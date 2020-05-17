import QtQuick 2.1

import qb.components 1.0
import qb.energyinsights 1.0 as EnergyInsights

import BasicUIControls 1.0
import GraphUtils 1.0

Screen {
	id: solarScreen

	screenTitleIconUrl: "drawables/SolarAppMenu.svg"
	screenTitle: qsTr("Solar panels")

	function init() {
		bottomTabBar.addItem(qsTr("Total"));
		bottomTabBar.addItem(qsTr("Months"));
		bottomTabBar.addItem(qsTr("Years"));
	}

	QtObject {
		id: p

		function selectTabs(isYield, isUsage, periodIdx) {
			topLeftTabBarControlGroup.currentControlId = isYield ? yieldTabButton.controlGroupId : performanceTabButton.controlGroupId;
			topRightTabBarControlGroup.currentControlId = isUsage ? energyButton.controlGroupId : currencyButton.controlGroupId;
			bottomTabBar.currentIndex = periodIdx;
			dateSelector.periodStart = new Date();
		}

		function sinceText() {
			var sinceDate = app.billingInfos['elec_produ'] ? new Date(app.billingInfos['elec_produ'].installedDate * 1000) : new Date();
			var day = sinceDate.getDate();
			var month = i18n.monthsFull[sinceDate.getMonth()];
			var year = sinceDate.getFullYear();
			return qsTr('Since %1 %2 %3').arg(sinceDate.getDate())
			.arg(i18n.monthsFull[sinceDate.getMonth()])
			.arg(sinceDate.getFullYear());
		}

		function selectionChanged() {
			var argumentList = [];
			var args1 = new EnergyInsights.Definitions.RequestArgs("electricity", "production", "quantity");
			var args2;
			var now = new Date();
			now.setHours(0, 0, 0, 0);

			var period = ""
			var daysLeft = 0;
			var daysTotal = 0;
			var installDate = new Date(app.billingInfos['elec_produ'].installedDate * 1000);
			var daysInFirstMonth = 0;
			var fullMonth = 0;
			var daysInstalled = 0;

			app.requestDataThrobber.show();
			performanceItem.expectedProduction = 0;

			switch (dateSelector.mode) {
			case DateSelectorComponent.MODE_MONTH:
				period = i18n.monthsShort[dateSelector.periodEnd.getMonth()];
				daysInFirstMonth = new Date(dateSelector.periodEnd.getFullYear(), dateSelector.periodEnd.getMonth() + 1, 0).getDate();

				if (installDate.getFullYear() === dateSelector.periodEnd.getFullYear() && installDate.getMonth() === dateSelector.periodEnd.getMonth()) {
					daysInstalled = daysInFirstMonth - installDate.getDate() + 1;
				} else {
					daysInstalled = daysInFirstMonth;
				}

				if (dateSelector.periodEnd >= now) {
					daysLeft = daysInFirstMonth - now.getDate() + 1;
				}

				daysInstalled -= daysLeft;
				performanceItem.expectedProduction = (daysInstalled / daysInFirstMonth) * app.monthExpectedProduction(dateSelector.periodEnd.getFullYear(), dateSelector.periodEnd.getMonth()) / 1000;
				performanceItem.periodFull = i18n.monthsFull[dateSelector.periodEnd.getMonth()];
				break;
			case DateSelectorComponent.MODE_YEAR:
				period = dateSelector.periodEnd.getFullYear();
				var year = now.getFullYear();
				var isLeap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
				var date2 = new Date(year,11,31);
				var diff = Date.UTC(date2.getYear(),date2.getMonth(),date2.getDate(),0,0,0)
						- Date.UTC(now.getYear(),now.getMonth(),now.getDate(),0,0,0);
				if (dateSelector.periodEnd.getFullYear() === year) {
					daysLeft = diff/1000/60/60/24;
				}
				else {
					daysLeft = 0;
				}

				daysTotal = isLeap ? 366 : 365

				var firstFullMonth = 0;
				var lastFullMonth = 11;
				if (dateSelector.periodStart < installDate) {
					firstFullMonth = installDate.getMonth() + 1;
				}
				if (dateSelector.periodEnd >= now) {
					lastFullMonth = now.getMonth() - 1;
				}
				if (dateSelector.periodEnd >= now && installDate.getFullYear() === now.getFullYear() && installDate.getMonth() == now.getMonth()) {
					daysInFirstMonth = new Date(dateSelector.periodEnd.getFullYear(), now.getMonth() + 1, 0).getDate();
					daysInstalled = now.getDate();
					daysInstalled -= installDate.getDate();
					performanceItem.expectedProduction = (daysInstalled / daysInFirstMonth) * app.monthExpectedProduction(now.getFullYear(), now.getMonth()) / 1000;
				} else {
					if (firstFullMonth > 0) {
						daysInFirstMonth = new Date(installDate.getFullYear(), firstFullMonth, 0).getDate();
						daysInstalled = daysInFirstMonth - installDate.getDate() + 1;
						performanceItem.expectedProduction += (daysInstalled / daysInFirstMonth) * app.monthExpectedProduction(installDate.getFullYear(), installDate.getMonth()) / 1000;
					}
					if (lastFullMonth < 11) {
						daysInFirstMonth = new Date(dateSelector.periodEnd.getFullYear(), lastFullMonth + 2, 0).getDate();
						daysInstalled = now.getDate() - 1;
						performanceItem.expectedProduction += (daysInstalled / daysInFirstMonth) * app.monthExpectedProduction(dateSelector.periodEnd.getFullYear(), lastFullMonth + 1) / 1000;
					}
					fullMonth = 0;
					for(fullMonth = firstFullMonth; fullMonth <= lastFullMonth; fullMonth++) {
						performanceItem.expectedProduction += (app.monthExpectedProduction(dateSelector.periodEnd.getFullYear(), fullMonth) / 1000);
					}
				}

				performanceItem.periodFull = period;
			}

			dateSelector.periodMinimum = new Date(app.billingInfos['elec_produ'].installedDate * 1000)
			performanceItem.period = period;
			performanceItem.daysLeft = daysLeft;

			var periodEnd;
			switch (bottomTabBar.currentIndex) {
			case 0:
				args1.from = graphUtils.dateToISOString(installDate);
				args1.to = graphUtils.dateToISOString(new Date()); // don't use now var as that is passed midnight, excluding today
				args1.interval = undefined;
				break;
			case 1:
				args1.from = graphUtils.dateToISOString(dateSelector.periodStart);
				periodEnd = dateSelector.periodEnd;
				periodEnd.setDate(periodEnd.getDate() + 1);
				args1.to = graphUtils.dateToISOString(periodEnd);
				args1.interval = "months";
				break;
			case 2:
				args1.from = graphUtils.dateToISOString(dateSelector.periodStart);
				periodEnd = dateSelector.periodEnd;
				periodEnd.setDate(periodEnd.getDate() + 1);
				args1.to = graphUtils.dateToISOString(periodEnd);
				args1.interval = "years";
				break;
			default:
				return;
			}

			switch (topRightTabBarControlGroup.currentControlId) {
			case currencyButton.controlGroupId:
				performanceItem.displayMoneyWise = true;
				performanceItem.expectedProduction *= app.produPrice;
				args1.isCost = true;
				break;
			case energyButton.controlGroupId:
				performanceItem.displayMoneyWise = false;
				args1.isCost = false;
				break;
			default:
				return;
			}

			argumentList.push(args1);

			switch (topLeftTabBarControlGroup.currentControlId) {
			case yieldTabButton.controlGroupId:
				args2 = Object.create(args1);
				args2.origin = "export";
				argumentList.push(args2);
				break;
			case performanceTabButton.controlGroupId:
				break;
			default:
				break;
			}

			var data = [];
			EnergyInsights.Functions.requestBatchData(argumentList, util.partialFn(requestBatchDataCallback, data))
		}
	}

	function requestBatchDataCallback(data, success, response, batchDone) {
		if (success)
			data.push(response);
		if (batchDone)
			handleDataReceived(data.length ? true : false, data);
	}

	function handleDataReceived(success, rrdData) {
		if (success) {
			switch (topLeftTabBarControlGroup.currentControlId) {
			case yieldTabButton.controlGroupId:
				if (rrdData[0] && rrdData[0].data.length && rrdData[1] && rrdData[1].data.length) {
					var totalProduction = Math.round(rrdData[0].data[0].value);
					if (isNaN(totalProduction))
						totalProduction = 0;
					var returnedToGrid = Math.round(rrdData[1].data[0].value);
					if (isNaN(returnedToGrid))
						returnedToGrid = 0;
					if (topRightTabBarControlGroup.currentControlId === energyButton.controlGroupId) {
						// for energy, convert Wh to kWh
						totalProduction = Math.round(totalProduction / 1000);
						returnedToGrid = Math.round(returnedToGrid  / 1000);
						revenueItem.totalYield = totalProduction + ' kWh';
						revenueItem.selfUsageYield = (totalProduction - returnedToGrid) + ' kWh';
						revenueItem.returnedYield = returnedToGrid + ' kWh';
					} else {
						revenueItem.totalYield = i18n.currency(totalProduction, i18n.curr_round);
						revenueItem.selfUsageYield = i18n.currency(totalProduction - returnedToGrid, i18n.curr_round);
						revenueItem.returnedYield = i18n.currency(returnedToGrid, i18n.curr_round);
					}
				}
				break;
			case performanceTabButton.controlGroupId:
				if (rrdData[0] && rrdData[0].data.length) {
					var production = rrdData[0].data[0].value;
					if (topRightTabBarControlGroup.currentControlId === energyButton.controlGroupId) {
						production /= 1000;
					}
					performanceItem.realProduction = i18n.number(production, 0);
				}
				break;
			}
		}
		app.requestDataThrobber.hide();
	}

	onShown: {
		if (args)
			p.selectTabs(args.isYield, args.isUsage, args.intervalType);
		p.selectionChanged();
	}

	ControlGroup {
		id: topLeftTabBarControlGroup
		exclusive: true
		onCurrentControlIdChangedByUser: p.selectionChanged()
		onCurrentControlIdChanged: bottomTabBar.setItemVisible(0, currentControlId === yieldTabButton.controlGroupId)
	}

	Flow {
		id: topLeftTabBar
		anchors {
			left: mainRect.left
			top: parent.top
			topMargin: designElements.vMargin20
		}
		spacing: Math.round(4 * horizontalScaling)

		TopTabButton {
			id: yieldTabButton
			text: qsTr("Yield")
			controlGroup: topLeftTabBarControlGroup
		}
		TopTabButton {
			id: performanceTabButton
			text: qsTr("Performance")
			controlGroup: topLeftTabBarControlGroup
			rightClickMargin: 10
		}
	}


	Text {
		id: withoutVatText
		visible: globals.productOptions["SME"] === "1"
		anchors {
			baseline: topLeftTabBar.bottom
			baselineOffset: Math.round(-5 * verticalScaling)
			left: topLeftTabBar.right
			leftMargin: Math.round(16 * horizontalScaling)
		}
		font {
			family: qfont.italic.name
			pixelSize: qfont.bodyText
		}
		color: colors.solarAppText
		text: qsTr("Amounts excl. VAT")
	}

	ControlGroup {
		id: topRightTabBarControlGroup
		exclusive: true
		onCurrentControlIdChangedByUser: p.selectionChanged()
	}

	Flow {
		id: topRightTabBar
		anchors {
			bottom: mainRect.top
			bottomMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			right: mainRect.right
		}
		spacing: Math.round(4 * horizontalScaling)

		TopTabButton {
			id: currencyButton
			text: i18n.currency()
			controlGroup: topRightTabBarControlGroup
			leftClickMargin: 10
		}

		TopTabButton {
			id: energyButton
			controlGroup: topRightTabBarControlGroup
			text: qsTr("kWh")
		}

	}

	Rectangle {
		id: mainRect
		anchors {
			top: topLeftTabBar.bottom
			topMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			bottom: bottomTabBar.top
			bottomMargin: anchors.topMargin
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		color: colors.solarAppScreenBackground

		PerformanceTabContent {
			id: performanceItem
			anchors.fill: parent
			visible: performanceTabButton.selected
		}

		RevenueTabContent {
			id: revenueItem
			anchors.fill: parent
			visible: yieldTabButton.selected
		}
	}

	Rectangle {
		id: dateSelectorRect
		height: dateSelector.height
		width: dateSelector.width
		x: dateSelector.x
		y: dateSelector.y
		color: colors.solarAppScreenBackground
	}

	DateSelector {
		id: dateSelector
		anchors {
			top: mainRect.bottom
			right: mainRect.right
		}
		mode: DateSelectorComponent.MODE_MONTH
		periodStart: new Date()
		visible: bottomTabBar.currentIndex > 0
		periodMaximum: new Date()
		periodMinimum: app.billingInfos['elec_produ'] ? new Date(app.billingInfos['elec_produ'].installedDate * 1000) : new Date()

		onPeriodChanged: p.selectionChanged();
		onModeChanged: {
			periodMaximum = periodStart = new Date()
		}
	}

	Text {
		id: dateFrom
		anchors {
			centerIn: dateSelectorRect
		}
		visible: !dateSelector.visible
		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.solarAppText
		text: p.sinceText();
	}

	BottomTabBar {
		id: bottomTabBar
		anchors {
			left: mainRect.left
			bottom: parent.bottom
		}

		onCurrentControlIdChangedByUser: p.selectionChanged()
		onCurrentIndexChanged: {
			switch (currentIndex) {
			case 1:
				dateSelector.mode = DateSelectorComponent.MODE_MONTH;
				break;
			case 2:
				dateSelector.mode = DateSelectorComponent.MODE_YEAR;
				break;
			default:
				break;
			}
		}
	}
}
