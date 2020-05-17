import QtQuick 2.1

import Feedback 1.0
import qb.components 1.0
import qb.energyinsights 1.0 as EnergyInsights

import BasicUIControls 1.0
import GraphUtils 1.0;

import "BarGraphObjects.js" as BarGraph

Screen {
	id: graphScreen

	screenTitleIconUrl: "drawables/graphs.svg"
	screenTitle: qsTr("Graphs")
	disableAutoPageViewLogging: true

	/*readonly*/ property int _BAR_CONS: 0
	/*readonly*/ property int _BAR_PROD: 1

	function init() {
		app.isHolidayOrWeekendResponse.connect(p.isHolidayOrWeekendResponse);

		powerTabButton.visible = app.hasElectricity;
		gasTabButton.visible = app.hasGas;
		heatTabButton.visible = app.hasDistrictHeating;

		bottomTabBar.addItem(qsTr("Hours"), "Hours");
		bottomTabBar.addItem(qsTr("Days"), "Days");
		bottomTabBar.addItem(qsTr("Weeks"), "Weeks");
		bottomTabBar.addItem(qsTr("Months"), "Months");
		bottomTabBar.addItem(qsTr("Years"), "Years");
	}

	function getLastUpdateTime() {
		var changeDate;
		if (gasTabButton.selected) {
			changeDate = app.billingInfoGas['changeDate'];
		} else if (heatTabButton.selected) {
			changeDate = app.billingInfoHeat['changeDate'];
		} else if (powerTabButton.selected) {
			changeDate = app.billingInfoElec['changeDate'];
		}
		var returnString = qsTr("not available");
		if (!isNaN(changeDate)) {
			returnString = i18n.dateTime(changeDate * 1000, i18n.mon_full | i18n.date_no | i18n.time_no | i18n.dom_no);
		}
		return returnString;
	}

	QtObject {
		id: p
		property variant agreementTypeMap: {"electricity" : powerTabButton, "gas": gasTabButton, "heat": heatTabButton, "heatingTime": heatingTabButton, "water": waterTabButton}
		property variant unitTypeMap: {"money": currencyButton, "energy": energyButton}
		property variant intervalType: ["hours", "days", "weeks", "months", "years"]
		// flag if there is an ongoing request. Resetted when response is received or on response timeout
		property bool canRequestData: false
		// flag to indicate if a change on the tab should result in a new data request, used when changing tabs programatically
		property bool requestOnGraphChange: false

		// predefined scales for hour graph for electicity. see @selectYScaleMaxValue()
		property variant elec_day_scale: [250, 500, 750, 1000, 1250, 1500, 2000, 2500, 3750, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 37500, 50000]
		// predefined scales for hour graph for gas and heat. see @selectYScaleMaxValue()
		property variant gas_day_scale: [5, 7.5, 10, 12.5, 15, 20, 25, 37.5, 50, 75, 100, 125, 150, 200, 375, 500, 750, 1000, 1250, 1500, 2000, 2500, 3750, 5000, 7500, 10000, 12500, 15000, 20000, 25000, 37500, 50000]

		property url meterReadPopupUrl: "MeterReadDialog.qml"
		property bool meterReadButtonVisible: false

		// when switching the period type, data has to be requested when DateSelector mode and startPeriod is changed
		// this flag suppress data request in the middle of this 'transaction'
		property bool periodTypeSelectionComplete: true

		property bool consumptionSelected: true
		property bool productionSelected: app.hasSolar

		function getPopoutDecimals(value, type, unit) {
			if (type === "cost") {
				return 2;
			} else if (type === "heat") {
				if (unit === "MJ")
					return 0
				else
					return 3;
			} else {
				if (value >= 10) {
					return 0;
				} else if (value >= 1) {
					return 1;
				} else {
					return 2;
				}
			}
		}

		function formatValue(value, type, unit) {
			if (isNaN(value))
				value = 0;

			switch(type) {
			case "cost":
				return i18n.currency(value);
			case "heating":
				var multiplier = 3600; // seconds in an hour
				var isMins = false
				if (unit === qsTr("minutes")) {
					multiplier = 60; // seconds in a minute
					isMins = true;
				}
				return i18n.duration(Math.floor(value) * multiplier + Math.round((value % 1) * multiplier), false, false, false, isMins);
			default:
				return i18n.number(value, getPopoutDecimals(value, type, unit)) + " " + unit;
			}
		}

		function roundToDecimals(value, decimals) {
			var multiplicator = Math.pow(10, decimals);
			value *= multiplicator;
			value = Math.round(value);
			return value / multiplicator;
		}

		/*
		 * Populate bar graph with data received from backend.
		 */
		function populateBarGraph(response) {
			if (!Array.isArray(response))
				return;

			areaGraph.visible = false;

			var graphData = new BarGraph.GraphData();
			var i;
			var divisor = heatingTabButton.selected ? 60 : 1000;
			var scaleType;
			var hatchedIndex = -1;
			var now = new Date();
			//not intereseted in time for bar graphs (the dateSelector.periodEnd is also at 0:00:00 time at given day
			now.setHours(0, 0, 0, 0);
			var isCost = topRightTabBarControlGroup.currentControlId === currencyButton.controlGroupId;
			var fixedCost = false;
			var otherProvider = false;
			var unit, utility, type, dataset;

			var dstChangeSecs, dstChangeIdx;
			dstChangeSecs = response[0]["dstChangeSecs"];
			dstChangeIdx = response[0]["dstChangeIdx"];

			// for costs, data is already in the right currency granularity
			if (isCost)
				divisor = 1;

			switch (bottomTabBar.currentIndex) {
			case 0:
				divisor = 1;
				adjustGraphForDST(dstChangeSecs, dstChangeIdx, 24);
				var timeNow = new Date();
				var endPeriod = new Date(dateSelector.periodEnd);
				endPeriod.setDate(endPeriod.getDate() + 1);
				if (timeNow >= dateSelector.periodStart && timeNow < endPeriod) {
					hatchedIndex = timeNow.getHours();
					// because the first bucket of the hour is only created 5 minutes in, select previous bar in this case
					if (timeNow.getMinutes() < 5 && hatchedIndex > 0)
						hatchedIndex--;
					// during DST change, there will be more/less data points, so adjust accordingly
					if (dstChangeSecs)
						hatchedIndex -= Math.round(dstChangeSecs / 3600);
				}
				for (i = getHourExpectedValuesCount(dstChangeSecs, 24); i > 0; i--) {
					graphData.data.push([new BarGraph.BarData()]);
				}
				break;
			case 1:
				if (dateSelector.periodStart <= now && dateSelector.periodEnd >= now) {
					hatchedIndex = (now.getDay() - 1 + 7) % 7; // convert sunday 0-based to monday 0-based index
				}
				for (i = 1; i < 8; i++) {
					graphData.data.push([new BarGraph.BarData()]);
					graphData.axisLabels.push(i18n.daysFull[i % 7]);
				}
				break;
			case 2:
				var weekDate = new Date(dateSelector.periodEnd);
				var currentWeek = graphUtils.weekNumber(now);
				for (i = 5; i >= 0; i--) {
					var weekNumb = graphUtils.weekNumber(weekDate);
					graphData.axisLabels.push(qsTr("Week") + " " + weekNumb);
					graphData.data.push([new BarGraph.BarData()]);
					weekDate.setDate(weekDate.getDate() - 7);
					if (dateSelector.periodStart <= now && dateSelector.periodEnd >= now && weekNumb === currentWeek) {
						hatchedIndex = i;
					}
				}
				graphData.data.reverse();
				graphData.axisLabels.reverse();
				break;
			case 3:
				for (i = 0; i < 12; i++) {
					graphData.data.push([new BarGraph.BarData()]);
					graphData.axisLabels.push(i18n.monthsShort[i]);
				}
				if (now <= dateSelector.periodEnd) {
					hatchedIndex = now.getMonth();
				}
				break;
			case 4:
				var year = now.getFullYear();

				for (i = 6; i > 0; i--) {
					graphData.data.push([new BarGraph.BarData()]);
					graphData.axisLabels.push(year);
					year--;
				}
				graphData.data.reverse();
				graphData.axisLabels.reverse();
				// current year is always last shown
				hatchedIndex = 5;
				break;
			}

			var hasLowHigh = false, vatRate = 0, prodVatRate = 0, billDate = 0;
			switch(topLeftTabBarControlGroup.currentControlId) {
			case powerTabButton.controlGroupId:
				utility = "elec";
				dataset = app.monthDataDataset.getMonths("elec");
				hasLowHigh = app.billingInfoElec.rate === 1;
				scaleType = barGraph.scaleTypeElectricity;
				vatRate = app.billingInfoElec.vat;
				prodVatRate = app.billingInfoElecProdu.vat;
				billDate = app.billingInfoElec.nextBillingDate;
				otherProvider = parseInt(globals.productOptions["other_provider_elec"]);
				break;
			case gasTabButton.controlGroupId:
				utility = "gas";
				dataset = app.monthDataDataset.getMonths("gas");
				scaleType = barGraph.scaleTypeGasWater;
				vatRate = app.billingInfoGas.vat;
				billDate = app.billingInfoGas.nextBillingDate;
				otherProvider = parseInt(globals.productOptions["other_provider_gas"]);
				break;
			case heatTabButton.controlGroupId:
				utility = "heat";
				dataset = app.monthDataDataset.getMonths("heat");
				scaleType = barGraph.scaleTypeHeat;
				vatRate = app.billingInfoHeat.vat;
				billDate = app.billingInfoHeat.nextBillingDate;
				break;
			case heatingTabButton.controlGroupId:
				utility = "heating";
				scaleType = bottomTabBar.currentIndex === 0 ? barGraph.scaleTypeHeatingHour : barGraph.scaleTypeHeat;
				break;
			case waterTabButton.controlGroupId:
				utility = "water";
				scaleType = barGraph.scaleTypeGasWater;
				vatRate = 19;//app.billingInfoWater.vat; // TODO: fix this
				otherProvider = true;
				break;
			default:
				utility = "elec";
				scaleType = barGraph.scaleTypeElectricity;
				vatRate = app.billingInfoElec.vat;
				break;
			}

			if (isCost) {
				type = "cost";
				barGraph.showVAT = app.enableSME;
				scaleType += barGraph.scaleTypeCost;
				fixedCost = feature.featElecFixedDayCostEnabled();
			} else {
				type = utility;
				unit = energyButton.text;
				barGraph.showVAT = false;
				scaleType += barGraph.scaleTypeConsumption;
			}

			var rraIdx = 0;
			var value;
			for (i = 0; i < response[rraIdx].data.length; i++) {
				value = response[rraIdx].data[i].value / divisor;
				graphData.data[i][_BAR_CONS].values.push(value);
				graphData.data[i][_BAR_CONS].valuesFormatted.push(formatValue(value, type, unit));
			}
			addConsumptionBarInfo(graphData, utility, hasLowHigh, fixedCost);

			if (topLeftTabBarControlGroup.currentControlId === powerTabButton.controlGroupId) {
				if (hasLowHigh) {
					rraIdx++;
					for (i = 0; i < response[rraIdx].data.length; i++) {
						// add low amount to beginning so its rendered on top
						value = response[rraIdx].data[i].value / divisor;
						if (isNaN(value) || !isFinite(value))
							value = 0;
						graphData.data[i][_BAR_CONS].values.unshift(value);
						graphData.data[i][_BAR_CONS].valuesFormatted.unshift(formatValue(value, type, unit));
					}
				}

				if (fixedCost) {
					rraIdx++;
					for (i = 0; i < response[rraIdx].data.length; i++) {
						value = response[rraIdx].data[i].value;
						if (!isNaN(value) && isFinite(value) && value > 0) {
							graphData.data[i][_BAR_CONS].values.push(value);
							graphData.data[i][_BAR_CONS].valuesFormatted.push(formatValue(value, type, unit));
						}
					}
				}

				if (app.hasSolar) {
					rraIdx++;
					for (i = 0; i < graphData.data.length; i++) {
						graphData.data[i][_BAR_PROD] = new BarGraph.BarData();
						if (response[rraIdx] && response[rraIdx].data[i])
							value = response[rraIdx].data[i].value / divisor;
						else
							value = 0;
						if (isNaN(value) || !isFinite(value))
							value = 0;
						graphData.data[i][_BAR_PROD].values.push(value);
						graphData.data[i][_BAR_PROD].valuesFormatted.push(formatValue(value, type, unit));
					}
					addProductionBarInfo(graphData);
				}
			}

			var showTitle = false;
			if (bottomTabBar.currentIndex === 3) { // months
				var yearToShow = dateSelector.periodStart.getYear();
				if (!otherProvider) {
					if (dataset) {
						for (i = 0; i < dataset.length; i++) {
							if (dataset[i].year === yearToShow) {
								var month = dataset[i].month;
								if (isCost) {
									graphData.data[month][_BAR_CONS].estimation = (dataset[i].targetCost + dataset[i].targetLowCost);
								} else {
									graphData.data[month][_BAR_CONS].estimation = (dataset[i].targetUsage + dataset[i].targetLowUsage)  / 1000;
								}
							}
						}
					}
					if ((yearToShow + 1900) === now.getFullYear() && billDate > 0) {
						var nbDate = new Date(0);
						nbDate.setUTCSeconds(billDate);
						showTitle = true;
						barGraph.title = qsTr('Next bill date: %1 %2').arg(i18n.monthsFull[nbDate.getMonth()]).arg(nbDate.getFullYear());
					}
					legend.dlgLastUpdate = getLastUpdateTime();
				}
				// Solar estimations come from the user so this also works for otherProvider
				if (utility === "elec" && app.hasSolar) {
					var solarMonths = app.monthDataDataset.getMonths("solar");
					for (i = 0; i < solarMonths.length; i++) {
						var solarMonth = solarMonths[i].month;
						if (solarMonths[i].year === yearToShow) {
							graphData.data[solarMonth][_BAR_PROD].estimation = isCost ? solarMonths[i].targetCost : (solarMonths[i].targetUsage / 1000);
						}
					}
				}
			}

			var elecSolar = (topLeftTabBarControlGroup.currentControlId === powerTabButton.controlGroupId && app.hasSolar);
			calculateGraphDataSums(graphData, elecSolar, type, unit);

			if (isCost && app.enableSME) {
				calculateGraphDataVAT(graphData, vatRate, prodVatRate, type, unit);
			}

			var selectedTypes = [];
			if (p.consumptionSelected)
				selectedTypes.push(_BAR_CONS);
			if (p.productionSelected && elecSolar)
				selectedTypes.push(_BAR_PROD);
			if (!selectedTypes.length)
				selectedTypes.push(_BAR_CONS);

			barGraph.visible = false;
			barGraph.hatchedBarIndex = hatchedIndex;
			barGraph.showTitle = showTitle;
			barGraph.populate(graphData, scaleType, selectedTypes);
			barGraph.visible = true;
			setBarGraphLegend(otherProvider, isCost);
		}

		function calculateGraphDataSums(graphData, hasProduction, type, unit) {
			// calculate sum of all bar values from all bars
			for (var i = 0; i < graphData.data.length; i++) {
				for (var j = 0; j< graphData.data[i].length; j++) {
					var roundedSum = util.arraySum(graphData.data[i][j].values.map(function (val) {
						return roundToDecimals(val, getPopoutDecimals(val, type, unit));
					}));
					graphData.data[i][j].sum = roundedSum;
					graphData.data[i][j].sumFormatted = formatValue(roundedSum, type, unit);
				}

				if (hasProduction) {
					var combinedIdx = _BAR_CONS+"-"+_BAR_PROD;
					graphData.combinedData.push({});
					graphData.combinedData[i][combinedIdx] = new BarGraph.BarData();
					graphData.combinedData[i][combinedIdx].valuesFormatted = [graphData.data[i][_BAR_CONS].sumFormatted, graphData.data[i][_BAR_PROD].sumFormatted];
					var consVal = graphData.data[i][_BAR_CONS].sum;
					var prodVal = graphData.data[i][_BAR_PROD].sum;
					var roundedTotal = roundToDecimals(consVal, getPopoutDecimals(consVal, type, unit)) - roundToDecimals(prodVal, getPopoutDecimals(prodVal, type, unit));

					graphData.combinedData[i][combinedIdx].sum = roundedTotal;
					graphData.combinedData[i][combinedIdx].sumFormatted = formatValue(Math.abs(roundedTotal), type, unit);
					graphData.combinedData[i][combinedIdx].totalText = roundedTotal < 0 ? qsTr("Profit") : qsTr("Loss");
				}
			}
		}

		function calculateGraphDataVAT(graphData, consVatRate, prodVatRate, type, unit) {
			for (var i = 0; i < graphData.data.length; i++) {
				for (var j = 0; j < graphData.data[i].length; j++) {
					var vatRate = (j === _BAR_PROD ? prodVatRate : consVatRate);
					graphData.data[i][j].vat = (graphData.data[i][j].sum) * vatRate / 100;
					graphData.data[i][j].vatFormatted = formatValue(graphData.data[i][j].vat, type, unit);
				}
			}
			var combinedIdx = _BAR_CONS+"-"+_BAR_PROD;
			for (i = 0; i < graphData.combinedData.length; i++) {
				vatRate = (graphData.combinedData[i][combinedIdx].sum >= 0 ? prodVatRate : consVatRate);
				graphData.combinedData[i][combinedIdx].vat = Math.abs(graphData.combinedData[i][combinedIdx].sum) * vatRate / 100;
				graphData.combinedData[i][combinedIdx].vatFormatted = formatValue(graphData.combinedData[i][combinedIdx].vat, type, unit);
			}
		}

		function addConsumptionBarInfo(graphData, utility, dualTariff, fixedCost) {
			graphData.barInfo[_BAR_CONS].name = qsTr("Consumption");

			var color, colorSelected;
			switch(utility) {
			case "gas":
			case "heat":
				color = colors.graphGasDistrictHeat.toString();
				colorSelected = colors.graphGasDistrictHeatSelected.toString();
				break;
			case "heating":
				color= colors.graphHeating.toString();
				colorSelected = colors.graphHeatingSelected.toString();
				break;
			case "water":
				color = colors.graphWater.toString();
				colorSelected = colors.graphWaterSelected.toString();
				break;
			default:
				color = colors.graphElecSingleOrLowTariff.toString();
				colorSelected = colors.graphElecSingleOrLowTariffSelected.toString();
			}

			graphData.barInfo[_BAR_CONS].color = color;
			graphData.barInfo[_BAR_CONS].estimationColor = colors.barGraphEstimationLine.toString();
			graphData.barInfo[_BAR_CONS].icon = "image://scaled/apps/graph/drawables/popoutConsumption.svg";
			graphData.barInfo[_BAR_CONS].totalText = qsTr("Total");
			// set first stack item to low tariff
			graphData.barInfo[_BAR_CONS].stackItems[0] = new BarGraph.StackItem(dualTariff ? qsTr("Low") : qsTr("Single"),
																			   color,
																			   colorSelected);

			// only elec supported for now
			if (dualTariff) {
				graphData.barInfo[_BAR_CONS].stackItems.push(new BarGraph.StackItem(qsTr("High"),
																				   colors.graphElecHighTariff.toString(),
																				   colors.graphElecHighTariffSelected.toString()));
			}

			if (fixedCost) {
				graphData.barInfo[_BAR_CONS].stackItems.push(new BarGraph.StackItem(qsTr("Fixed cost"),
																				   colors.graphFixedCosts.toString(),
																				   colors.graphFixedCostsSelected.toString()));
			}
		}

		function addProductionBarInfo(graphData) {
			graphData.barInfo[_BAR_PROD] = new BarGraph.BarInfo();
			graphData.barInfo[_BAR_PROD].name = qsTr("Production");
			graphData.barInfo[_BAR_PROD].color = colors.graphSolar.toString();
			graphData.barInfo[_BAR_PROD].estimationColor = colors.barGraphEstimationLineProduction.toString();
			graphData.barInfo[_BAR_PROD].icon = "image://scaled/apps/graph/drawables/popoutProduction.svg";
			graphData.barInfo[_BAR_PROD].totalText = qsTr("Total");
			graphData.barInfo[_BAR_PROD].stackItems[0] = new BarGraph.StackItem(qsTr("Production"),
																			   colors.graphSolar.toString(),
																			   colors.graphSolarSelected.toString());
		}

		function setBarGraphLegend(otherProvider, isCost) {
			var legendType = legend.lt_EMPTY;

			if (topLeftTabBarControlGroup.currentControlId === powerTabButton.controlGroupId) {
				if (bottomTabBar.currentIndex === 3) {
					if (p.consumptionSelected && !p.productionSelected) {
						if (app.billingInfoElec.rate === 1) {
							legendType = legend.lt_MONTH_DT;
						} else {
							legendType = legend.lt_MONTH;
						}
					} else if (!p.consumptionSelected && p.productionSelected) {
						legendType = legend.lt_PRODUCTION;
					}
				} else {
					if (p.consumptionSelected && !p.productionSelected) {
						if (app.billingInfoElec.rate === 1) {
							legendType = legend.lt_COMMON_DT;
						} else {
							legendType = legend.lt_COMMON;
						}
					}
				}
			} else if (topLeftTabBarControlGroup.currentControlId === heatingTabButton.controlGroupId) {
				legendType = legend.lt_HEATING_BEAT;
			} else {
				if (bottomTabBar.currentIndex === 3) {
					legendType = legend.lt_MONTH;
				}
			}
			legend.setType(legendType, otherProvider, isCost)
		}

		// search the predefined scales which first fits the maximum value. This is then used as maximum value for y legend in graphs (both bar and area graphs)
		function selectYScaleMaxValue(scale, maxValue) {
			for (var i = 0; i < scale.length; i++) {
				if (maxValue < scale[i])
					return scale[i];
			}
			return scale[scale.length - 1];
		}

		// create arguments for rrd request based on currently selected type/period/dateTime/usage/costs
		function requestData() {
			if (!p.canRequestData)
				return;

			var restArgs = new EnergyInsights.Definitions.RequestArgs(undefined, "consumption", "quantity");
			var restExtraArgs = [];

			restArgs.isCost = topRightTabBarControlGroup.currentControlId === currencyButton.controlGroupId;

			var periodTypeIdx = bottomTabBar.currentIndex;
			var periodType;
			var dateTime = dateSelector.periodStart;
			switch (periodTypeIdx) {
			case 0:
				periodType = GraphUtils.PERIOD_HOURS;
				if (bottomTabBar.currentIndex === 0 &&
						(topLeftTabBarControlGroup.currentControlId === powerTabButton.controlGroupId ||
						 topLeftTabBarControlGroup.currentControlId === waterTabButton.controlGroupId  ||
						(topLeftTabBarControlGroup.currentControlId === gasTabButton.controlGroupId && app.connectedInfo.gas_smartMeter === 0))) {
					restArgs.type = "flow";
				} else {
					restArgs.interval = "hours";
				}
				break;
			case 1:
				periodType = GraphUtils.PERIOD_DAYS;
				restArgs.interval = "days"
				break;
			case 2:
				periodType = GraphUtils.PERIOD_WEEKS;
				restArgs.interval = "weeks"
				break;
			case 3:
				periodType = GraphUtils.PERIOD_MONTHS;
				restArgs.interval = "months"
				break;
			case 4:
				periodType = GraphUtils.PERIOD_YEARS;
				restArgs.interval = "years"
				dateTime = new Date();
				break;
			default:
				console.log("invalid/no period type for graphs selected");
				return;
			}

			var fromTo = graphUtils.getFromToISODate(periodType, dateTime);
			restArgs.from = fromTo.startDate;
			restArgs.to = fromTo.endDate;

			var elecDoubleTariff = app.billingInfoElec.rate === 1;
			switch (topLeftTabBarControlGroup.currentControlId) {
			case powerTabButton.controlGroupId:
				restArgs.utility = "electricity";
				if (periodType !== GraphUtils.PERIOD_HOURS) {
					if (elecDoubleTariff) {
						var argsLowTariff = Object.create(restArgs);
						argsLowTariff.tariff = "low-tariff";
						restExtraArgs.push(argsLowTariff);
						restArgs.tariff = "normal-tariff";
					}
					if (feature.featElecFixedDayCostEnabled() && topRightTabBarControlGroup.currentControlId === currencyButton.controlGroupId) {
						var argsFixedCosts = Object.create(restArgs);
						argsFixedCosts.origin = "fixed-costs";
						argsFixedCosts.type = undefined;
						argsFixedCosts.tariff = undefined;
						restExtraArgs.push(argsFixedCosts);
					}
				}
				if (app.hasSolar) {
					var argsSolar = Object.create(restArgs);
					argsSolar.origin = "production";
					restExtraArgs.push(argsSolar);
				}
				break;
			case gasTabButton.controlGroupId:
				restArgs.utility = "gas";
				break;
			case heatTabButton.controlGroupId:
				restArgs.utility = "district-heat";
				break;
			case heatingTabButton.controlGroupId:
				restArgs.utility = "heating";
				restArgs.origin = "on-time";
				restArgs.type = undefined;
				break;
			case waterTabButton.controlGroupId:
				restArgs.utility = "water";
				break;
			default:
				console.log("invalid/no data type for graphs selected");
				return;
			}

			if (periodType === GraphUtils.PERIOD_HOURS && elecDoubleTariff) {
				app.isHolidayOrWeekend(dateTime);
			}

			areaGraph.graphValues = [];
			areaGraph.graph2Values = [];

			p.canRequestData = false;
			app.requestDataThrobber.show();
			var batchArgs = [restArgs].concat(restExtraArgs);
			var data = [];
			EnergyInsights.Functions.requestBatchData(batchArgs, util.partialFn(requestBatchDataCallback, data));
		}

		function requestBatchDataCallback(data, success, response, batchDone) {
			if (success)
				data.push(response);
			if (batchDone)
				requestDataCallback(data.length ? true : false, data);
		}

		function requestDataCallback(success, response) {
			if (success) {
				if (bottomTabBar.currentIndex === 0 &&
						(powerTabButton.selected ||
						 waterTabButton.selected ||
						(gasTabButton.selected && app.connectedInfo.gas_smartMeter === 0))) {
					p.populateAreaGraph(response);
				} else {
					p.populateBarGraph(response);
				}
			} else {
				//TODO: what to do?
				areaGraph.visible = false;
				areaGraph.graphValues = [];
				areaGraph.graph2Values = [];
				barGraph.visible = false;
			}
			app.requestDataThrobber.hide();
			p.canRequestData = true;
		}

		function findMaxMinAvg(data) {
			// copied from graphutils
			var response = {"max": 0, "min": 0, "maxIdx": -1, "minIdx": -1, "avg": 0};
			var sum = 0, nonZeroCount = 0;
			if (Array.isArray(data)) {
				for (var i = 0; i < data.length; i++) {
					if (data[i] === null || data[i] === undefined) {
						data[i] = NaN;
					} else {
						if (response.min === 0 || (data[i] > 0 && response.min > data[i]) ) {
							response.min = data[i];
							response.minIdx = i;
						}
						if (response.max < data[i]) {
							response.max = data[i];
							response.maxIdx = i;
						}
						if (data[i] !== 0)
							nonZeroCount++;
						sum += data[i];
					}
				}
				response.avg = sum / nonZeroCount;
			}
			return response;
		}

		function populateAreaGraph(response) {
			barGraph.visible = false;

			var dstChangeSecs, dstChangeIdx;
			dstChangeSecs = response[0]["dstChangeSecs"];
			dstChangeIdx = response[0]["dstChangeIdx"];

			// append the data with zeros if expected count is less - in case "current "today" is selected only values till "now" are provided
			var samplesPerDay = heatTabButton.selected || (gasTabButton.selected && app.connectedInfo.gas_smartMeter === 1) ? 24 : 288;
			var expectedValuesCount = getHourExpectedValuesCount(dstChangeSecs, samplesPerDay);
			// map REST response format to a simple array of values
			var data = response[0].data.map(function(x) { return x.value });
			if (data.length > expectedValuesCount)
				data.splice(expectedValuesCount, data.length);
			var maxMinAvg = findMaxMinAvg(data);
			while (data.length < expectedValuesCount)
				data.push(0.0);

			areaGraph.maxConsumption = maxMinAvg.max;
			areaGraph.avgValue = maxMinAvg.avg;
			areaGraph.minimumIndex = maxMinAvg.minIdx;
			areaGraph.graphValues = data;

			if (app.hasSolar && response[1] && response[1].data) {
				var dataSolar = response[1].data.map(function(x) { return x.value });
				if (dataSolar) {
					if (dataSolar.length > expectedValuesCount)
						dataSolar.splice(expectedValuesCount, dataSolar.length);
					var maxSolar = findMaxMinAvg(dataSolar);
					while (dataSolar.length < expectedValuesCount)
						dataSolar.push(0.0);
					areaGraph.maximumIndex = maxSolar.maxIdx;
					areaGraph.graph2Values = dataSolar;
				}
			}

			setAreaGraphLegend();
			adjustGraphForDST(dstChangeSecs, dstChangeIdx, samplesPerDay);
			areaGraph.visible = true;
			areaGraph.popoutVisible = popupDot.visible;
		}

		function getHourExpectedValuesCount(dstChangeSecs, samplesPerDay) {
			var samplesPerHour = samplesPerDay / 24;
			var expectedCount = samplesPerDay;

			// dstChangeSecs contains the number of seconds added or removed to that day due to DST
			// e.g.: -3600 indicatest that the clock will go back 3600 secs. (one hour),
			// thus adding 1h to the total amount of day hours
			if (dstChangeSecs)
				expectedCount = samplesPerDay + Math.floor(-(dstChangeSecs / 3600) * samplesPerHour);

			return expectedCount;
		}

		function adjustGraphForDST(dstChangeSecs, dstChangeIdx, samplesPerDay) {
			if (typeof dstChangeSecs === "undefined") {
				graphRect.dstStart = false;
				graphRect.dstEnd = false;
				graphRect.dstHourChange = 0;
			} else {
				// dstChangeIdx contains the index of the sample at which the DST starts/ends
				// so to calculate the hour associated to that point in time
				// we use the number of samples per hour
				var hourChange = (dstChangeIdx + 1) / (samplesPerDay / 24)
				if (dstChangeSecs > 0) {
					graphRect.dstStart = true;
					graphRect.dstEnd = false;
					graphRect.dstHourChange = hourChange;
				} else if (dstChangeSecs < 0) {
					graphRect.dstStart = false;
					graphRect.dstEnd = true;
					graphRect.dstHourChange = hourChange;
				}
			}
		}

		function setAreaGraphLegend() {
			var legendType = legend.lt_EMPTY;

			if (powerTabButton.selected)
			{
				//in areaGraph, popout/average line/legend is only visible for power tab (not shown for gas/heat)
				if (p.consumptionSelected && !p.productionSelected) {
					if (areaGraph.showHighLowRate) {
						legendType = legend.lt_AREA_CONSUMPTION_DT;
					} else {
						legendType = legend.lt_AREA_CONSUMPTION;
					}
				} else if (!p.consumptionSelected && p.productionSelected) {
					legendType = legend.lt_AREA_PRODUCTION;
				}
			}
			else {
				legendType = legend.lt_EMPTY;
			}

			legend.setType(legendType, false, false)
		}

		function usageDatasetChanged() {
			if ((app.powerUsageDataRead && app.powerUsageData.isSmart === 1) ||
					(app.gasUsageDataRead && app.gasUsageData.isSmart === 1) ||
					(app.heatUsageDataRead && app.heatUsageData.isSmart === 1)) {
				p.meterReadButtonVisible = true;
			} else {
				p.meterReadButtonVisible = false;
			}
		}

		function setPeriodMaxAndMin() {
			var periodMinimum = new Date();

			if (bottomTabBar.currentIndex == 0)
				periodMinimum.setDate(periodMinimum.getDate() - 30);
			else
				periodMinimum.setFullYear(periodMinimum.getFullYear() - 5);

			dateSelector.periodMinimum = periodMinimum;
			dateSelector.periodMaximum = new Date();
			dateSelector.periodStart = dateSelector.periodMaximum;
		}

		function selectGraph(at, ut, it, consumption, production, period) {
			var tabIndexAgrmnt = agreementTypeMap[at].controlGroupId;
			topLeftTabBarControlGroup.setControlSelectState(tabIndexAgrmnt, true);

			var tabIndexInterval = intervalType.indexOf(it);
			if (bottomTabBar.currentIndex != tabIndexInterval)
				bottomTabBar.currentIndex = tabIndexInterval;
			else
				setPeriodMaxAndMin();

			if(it === "months" && period) {
				if (typeof period === "number") {
					var d = new Date(period, 1, 1, 0, 0, 0, 0);
					if (d >= dateSelector.periodMinimum && d <= dateSelector.periodMaximum)
						dateSelector.periodStart = d;
				}
			}

			var tabIndexUnit = unitTypeMap[ut].controlGroupId;
			topRightTabBarControlGroup.setControlSelectState(tabIndexUnit, true);

			p.consumptionSelected = consumption !== undefined ? consumption : true;
			p.productionSelected = production !== undefined ? production : false;
		}

		function isHolidayOrWeekendResponse(isLow) {
			areaGraph.isHolidayOrWeekend = isLow;
		}

		function popupCanBeVisible() {
			//in areaGraph, popout/average line/legend is only visible for power tab (not shown for gas/heat)
			return powerTabButton.selected && (p.consumptionSelected ? !p.productionSelected : p.productionSelected);
		}

		function logGraphSectionView() {
			var selectedTopLeftTab = topLeftTabBarControlGroup.getSelectedControl();
			var customElements = {};
			if (selectedTopLeftTab) {
				customElements["resource"] = selectedTopLeftTab.kpiId;
			}
			var selectedBottomTab = bottomTabBar.controlGroup.getSelectedControl();
			if (selectedBottomTab) {
				customElements["period"] = selectedBottomTab.kpiId;
			}
			var selectedTopRightTab = topRightTabBarControlGroup.getSelectedControl();
			if (selectedTopRightTab) {
				customElements["unit"] = selectedTopRightTab.kpiId;
			}

			countly.sendPageViewEvent(util.absoluteToRelativePath(identifier), customElements)
		}
	}

	onShown: {
		p.requestOnGraphChange = false;
		if (args)
			p.selectGraph(args.agreementType, args.unitType, args.intervalType, args.consumption, args.production, args.period);
		p.logGraphSectionView();
		p.canRequestData = true;
		p.requestOnGraphChange = true;
		p.requestData();

		if (p.meterReadButtonVisible) {
			addCustomTopRightButton(qsTr("Meter reading"));
		} else {
			clearTopRightButtons();
		}

		// Show water feedback button if the graphs are enabled
		if (waterTabButton.visible)
			FeedbackManager.actionTriggered("graph/GraphScreen/water");
	}

	onHidden: {
		p.canRequestData = false;
	}

	Component.onCompleted: {
		app.usageDatasetChanged.connect(p.usageDatasetChanged);
	}

	onCustomButtonClicked: {
		var tmpMeters = [];
		if (app.powerUsageData.isSmart === 1) {
			var titlePowerLow;
			var titlePowerNormal;
			if (app.hasSolar) {
				titlePowerLow = qsTr("Power consumption low");
				titlePowerNormal = qsTr("Power consumption normal");
			} else {
				titlePowerLow = qsTr("Power meter reading low");
				titlePowerNormal = qsTr("Power meter reading normal");
			}

			tmpMeters.push({'title': titlePowerLow, 'value': Math.floor(app.powerUsageData.meterReadingLow / 1000), 'unit': "kWh"});
			tmpMeters.push({'title': titlePowerNormal, 'value': Math.floor(app.powerUsageData.meterReading / 1000), 'unit': "kWh"});
			if (app.hasSolar) {
				tmpMeters.push({'title': qsTr("Power feed-in low"), 'value': Math.floor(app.powerUsageData.meterReadingLowProdu / 1000), 'unit': "kWh"});
				tmpMeters.push({'title': qsTr("Power feed-in normal"), 'value': Math.floor(app.powerUsageData.meterReadingProdu / 1000), 'unit': "kWh"});
			}
		}
		if (app.gasUsageData.isSmart === 1) {
			tmpMeters.push({'title': qsTr("Gas meter reading"), 'value': Math.floor(app.gasUsageData.meterReading / 1000), 'unit': "m³"});
		}
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Meter reading title"), p.meterReadPopupUrl);
		qdialog.context.dynamicContent.populate(tmpMeters);
	}

	ControlGroup {
		id: topLeftTabBarControlGroup
		exclusive: true
		onCurrentControlIdChanged: if(p.requestOnGraphChange) p.requestData();
		onCurrentControlIdChangedByUser: p.logGraphSectionView()
	}

	Flow {
		id: topLeftTabBar
		anchors {
			left: graphRect.left
			bottom: graphRect.top
			bottomMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
		}
		spacing: Math.round(4 * horizontalScaling)

		TopTabButton {
			id: powerTabButton
			text: qsTr("Power")
			controlGroup: topLeftTabBarControlGroup
			kpiId: "Power"

			onSelectedChanged: {
				if (selected) {
					if (bottomTabBar.currentIndex === 0) {
						energyButton.text = qsTr("Watt");
					} else {
						energyButton.text = "kWh";
					}
				}
			}
		}
		TopTabButton {
			id: gasTabButton
			text: qsTr("Gas")
			controlGroup: topLeftTabBarControlGroup
			kpiId: "Gas"

			onSelectedChanged: {
				if (selected) {
					if (bottomTabBar.currentIndex === 0) {
						energyButton.text =  app.connectedInfo.gas_smartMeter === 1 ? qsTr("Liters") : qsTr("Liters/hour");
					} else {
						energyButton.text = "m³";
					}
				}
			}
			rightClickMargin: 10
		}
		TopTabButton {
			id: heatTabButton
			text: qsTr("Heat")
			controlGroup: topLeftTabBarControlGroup
			kpiId: "Heat"

			onSelectedChanged: {
				if (selected) {
					if (bottomTabBar.currentIndex === 0) {
						energyButton.text = "MJ";
					} else {
						energyButton.text = "GJ";
					}
				}
			}
			rightClickMargin: 10
		}
		TopTabButton {
			id: heatingTabButton
			text: qsTr("Heating")
			visible: globals.thermostatFeatures["FF_HeatingBeat_UiElements"] && globals.heatingMode !== "none"
			controlGroup: topLeftTabBarControlGroup
			kpiId: "HeatingBeat"

			onSelectedChanged: {
				if (selected) {
					if (bottomTabBar.currentIndex === 0) {
						energyButton.text = qsTr("minutes");
					} else {
						energyButton.text = qsTr("hours");
					}
				}
			}
			rightClickMargin: 10
		}
		TopTabButton {
			id: waterTabButton
			text: qsTr("Water")
			visible: app.hasWater
			controlGroup: topLeftTabBarControlGroup
			kpiId: "Water"

			onSelectedChanged: {
				if (selected) {
					if (bottomTabBar.currentIndex === 0) {
						energyButton.text = qsTr("Liters/hour");
					} else {
						energyButton.text = "m³";
					}
				}
			}
			rightClickMargin: 10
		}
	}

	ControlGroup {
		id: topRightTabBarControlGroup
		exclusive: true
		onCurrentControlIdChanged: if(p.requestOnGraphChange) p.requestData();
		onCurrentControlIdChangedByUser: p.logGraphSectionView()
	}

	Flow {
		id: topRightTabBar
		anchors {
			right: graphRect.right
			top: parent.top
			topMargin: designElements.vMargin20
		}
		spacing: Math.round(4 * horizontalScaling)

		TopTabButton {
			id: currencyButton
			text: i18n.currency()
			visible: topLeftTabBarControlGroup.currentControlId !== heatingTabButton.controlGroupId && bottomTabBar.currentIndex !== 0
			controlGroup: topRightTabBarControlGroup
			leftClickMargin: 10
			kpiId: "Costs"

			onVisibleChanged: {
				if (!visible) {
					p.requestOnGraphChange = false;
					energyButton.selected = true;
					p.requestOnGraphChange = true;
				}
			}
		}

		TopTabButton {
			id: energyButton
			controlGroup: topRightTabBarControlGroup
			kpiId: "Unit"
		}
	}

	Rectangle {
		id: graphRect

		property bool dstStart: false
		property bool dstEnd: false
		property int dstHourChange: 0

		anchors {
			top: topRightTabBar.bottom
			topMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			bottom: bottomTabBar.top
			bottomMargin: anchors.topMargin
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
		}
		color: colors.graphScreenBackground

		BarGraph {
			id: barGraph
			width: parent.width
			height: parent.height

			dstEnd: graphRect.dstEnd
			dstStart: graphRect.dstStart
			dstHourChange: graphRect.dstHourChange

			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter:  parent.verticalCenter
			}
			hourAxisVisible: bottomTabBar.currentIndex === 0

			onSelectedBoxesChanged: {
				p.consumptionSelected = (selectedBoxes.indexOf(0) >= 0);
				p.productionSelected = (selectedBoxes.indexOf(1) >= 0);
			}
		}

		AreaGraph {
			id: areaGraph

			property bool showHighLowRate: powerTabButton.selected && app.billingInfoElec.rate === 1 && p.consumptionSelected && !p.productionSelected
			property int lowRateStartHour: app.connectedInfo.lowRateStartHour
			property int highRateStartHour: app.connectedInfo.highRateStartHour
			property bool isHolidayOrWeekend: false
			property int minimumIndex: -1
			property int maximumIndex: -1
			property real minConsumption: graphValues.length > 0 && minimumIndex >= 0 ? graphValues[minimumIndex] : 0
			property real maxConsumption: 0
			property real maxProduction: graph2Values.length > 0 && maximumIndex >= 0 ? graph2Values[maximumIndex] : 0
			property variant popoutPos: p.consumptionSelected || !powerTabButton.selected ? getValuePos(minimumIndex, graphValues) : getValuePos(maximumIndex, graph2Values)
			property bool popoutVisible: true

			width: graphRect.width
			height: graphRect.height
			visible: false
			anchors {
				top: graphRect.top
				left: graphRect.left
			}

			graphColor: {
				if (p.consumptionSelected && p.productionSelected && powerTabButton.selected) {
					// only in combi with elec
					colors.graphElecSingleOrLowTariff
				} else {
					if (gasTabButton.selected || heatTabButton.selected)
						colors.graphGasDistrictHeat
					else if (waterTabButton.selected)
						colors.graphWater
					else
						colors.graphElecSingleOrLowTariff
				}
			}
			graph2ndRateColor: colors.graphElecHighTariff
			graph2Color: p.consumptionSelected && p.productionSelected ? colors.graphSolarTransparent : colors.graphSolar
			//if the low rate starts before high rate, the graph starts with high rate color, than low rate and again high rate - put 0 as the first color change index
			colorChangeIndexes: showHighLowRate && !isHolidayOrWeekend ? (highRateStartHour < lowRateStartHour ? [highRateStartHour*12, lowRateStartHour*12] : [0, lowRateStartHour*12, highRateStartHour*12]) : []
			showNaN: true
			warningIconSource: "qrc:/images/bad.svg"
			warningIconVisible: false

			graph2Values: []

			graph1Visible: p.consumptionSelected || !powerTabButton.selected
			graph2Visible: p.productionSelected && powerTabButton.selected
			//average line is only visible for power tab and only for consumption
			avgLineVisible: avgValue > 0 && powerTabButton.selected && !p.productionSelected;
			maxValue: powerTabButton.selected ? p.selectYScaleMaxValue(p.elec_day_scale, Math.max(p.consumptionSelected ? maxConsumption : 0, p.productionSelected ? maxProduction : 0)) : p.selectYScaleMaxValue(p.gas_day_scale, maxConsumption)

			onGraphClicked: showHidePopout();

			dstEnd: graphRect.dstEnd
			dstStart: graphRect.dstStart
			dstHourChange: graphRect.dstHourChange

			function showHidePopout() {
				popoutVisible = !popoutVisible;
			}

			Rectangle {
				id: popupDot
				width: Math.round(8 * horizontalScaling)
				height: width
				radius: width / 2
				color: !powerTabButton.selected || p.consumptionSelected ? colors.graphElecSingleOrLowTariffSelected : colors.graphSolarSelected
				visible: p.popupCanBeVisible() && areaGraph.popoutPos.valid
				anchors {
					top: parent.top
					left: parent.left
					topMargin: areaGraph.popoutPos.valid ? areaGraph.popoutPos.y - (width / 2) : 0
					leftMargin: areaGraph.popoutPos.valid ? areaGraph.popoutPos.x - (width / 2) : 0
				}
			}

			StyledRectangle {
				id: areaPopout
				color: colors.white
				visible: popupDot.visible && areaGraph.popoutVisible
				width: 15 + areaPopupTxt.width + 15 + horArrowSize
				height: 44 + verArrowSize
				anchors {
					left: popupDot.horizontalCenter
					leftMargin: bottomLeftArrowVisible ? popupDot.width : (- width) - popupDot.width
					bottom: popupDot.top
					bottomMargin: borderWidth / 2
				}
				borderColor: colors._bg
				borderWidth: 2
				borderStyle: Qt.SolidLine
				radius: designElements.radius

				bottomLeftArrowVisible: popupLeftArrowVisible()
				bottomRightArrowVisible: !bottomLeftArrowVisible
				horArrowSize: 4
				verArrowSize: 4
				onClicked: areaGraph.showHidePopout()
				property string kpiPostfix: "areaGraphPopout"

				function popupLeftArrowVisible() {
					if (!powerTabButton.selected || p.consumptionSelected)
						return areaGraph.minimumIndex <= areaGraph.graphValues.length / 2;
					else
						return areaGraph.maximumIndex <= areaGraph.graph2Values.length / 2;
				}

				Text {
					id: areaPopupTxt
					text: Math.round(p.consumptionSelected ? areaGraph.minConsumption : areaGraph.maxProduction) + " " + energyButton.text
					anchors {
						left: parent.left
						leftMargin: areaPopout.bottomLeftArrowVisible ? areaPopout.horArrowSize + 15 : 15
						verticalCenter: parent.top
						verticalCenterOffset: (areaPopout.height - areaPopout.verArrowSize) / 2
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.bodyText
					}
					color: popupDot.color
				}
			}
		}

		SolarPowerCheckbox {
			id: powerCheckBox

			text: qsTr("Consumption")
			anchors {
				top: areaGraph.top
				topMargin: designElements.vMargin10
				left: areaGraph.left
				leftMargin: Math.round(16 * horizontalScaling)
			}

			visible: areaGraph.visible && powerTabButton.selected && app.hasSolar
			checkMarkColor: areaGraph.graphColor
			selected: p.consumptionSelected
			onSelectedChanged: {
				p.consumptionSelected = powerCheckBox.selected;
				if (p.consumptionSelected == false)
					p.productionSelected = true;
				areaGraph.popoutVisible = p.popupCanBeVisible();
				if (barGraph.visible) {
					var otherProvider = parseInt(globals.productOptions["other_provider_elec"]);
					var isCost = topRightTabBarControlGroup.currentControlId === currencyButton.controlGroupId;
					p.setBarGraphLegend(otherProvider, isCost);
				} else {
					p.setAreaGraphLegend();
				}
			}
		}

		SolarPowerCheckbox {
			id: solarCheckBox

			text: qsTr("Production")
			anchors {
				top: powerCheckBox.top
				left: powerCheckBox.right
				leftMargin: Math.round(20 * horizontalScaling)
			}

			visible: areaGraph.visible && powerCheckBox.visible
			checkMarkColor: areaGraph.graph2Color
			selected: p.productionSelected
			onSelectedChanged: {
				p.productionSelected = solarCheckBox.selected;
				if (p.productionSelected == false)
					p.consumptionSelected = true;
				areaGraph.popoutVisible = p.popupCanBeVisible();
				if (barGraph.visible) {
					var otherProvider = parseInt(globals.productOptions["other_provider_elec"]);
					var isCost = topRightTabBarControlGroup.currentControlId === currencyButton.controlGroupId;
					p.setBarGraphLegend(otherProvider, isCost);
				} else {
					p.setAreaGraphLegend();
				}
			}
		}
	}

	Rectangle {
		height: dateSelector.height
		width: dateSelector.width
		x: dateSelector.x
		y: dateSelector.y
		color: colors.graphScreenBackground
		visible: dateSelector.visible
	}

	DateSelector {
		id: dateSelector
		anchors {
			right: graphRect.right
			top: graphRect.bottom
		}
		mode: DateSelectorComponent.MODE_DAY
		periodStart: new Date()
		onPeriodChanged: {
			if (p.periodTypeSelectionComplete)
				p.requestData();
		}
		visible: bottomTabBar.currentIndex != 4
	}

	BottomTabBar {
		id: bottomTabBar
		anchors {
			left: graphRect.left
			bottom: parent.bottom
		}
        onCurrentControlIdChangedByUser: p.logGraphSectionView();
		onCurrentIndexChanged: {
			p.periodTypeSelectionComplete = false;
			switch (currentIndex) {
			case 0:
				dateSelector.mode = DateSelectorComponent.MODE_DAY;
				p.requestOnGraphChange = false
				topRightTabBarControlGroup.currentControlId = energyButton.controlGroupId;
				p.requestOnGraphChange = true;
				if ((gasTabButton.selected && app.connectedInfo.gas_smartMeter === 0) ||
						waterTabButton.selected) {
					energyButton.text = qsTr("Liters/hour");
				} else if (gasTabButton.selected && app.connectedInfo.gas_smartMeter === 1) {
					energyButton.text = qsTr("Liters");
				} else if (heatTabButton.selected) {
					energyButton.text = "MJ";
				} else if (heatingTabButton.selected) {
					energyButton.text = qsTr("minutes");
				} else {
					energyButton.text = qsTr("Watt");
				}
				break;
			case 1:
				dateSelector.mode = DateSelectorComponent.MODE_WEEK;
				if (gasTabButton.selected || waterTabButton.selected) {
					energyButton.text = "m³";
				} else if (heatTabButton.selected) {
					energyButton.text = "GJ";
				} else if (heatingTabButton.selected) {
					energyButton.text = qsTr("hours");
				} else {
					energyButton.text = "kWh";
				}
				break;
			case 2:
				dateSelector.mode = DateSelectorComponent.MODE_MONTH;
				if (gasTabButton.selected || waterTabButton.selected) {
					energyButton.text = "m³";
				} else if (heatTabButton.selected) {
					energyButton.text = "GJ";
				} else if (heatingTabButton.selected) {
					energyButton.text = qsTr("hours");
				} else {
					energyButton.text = "kWh";
				}
				break;
			case 3:
			case 4:
				dateSelector.mode = DateSelectorComponent.MODE_YEAR;
				if (gasTabButton.selected || waterTabButton.selected) {
					energyButton.text = "m³";
				} else if (heatTabButton.selected) {
					energyButton.text = "GJ";
				} else if (heatingTabButton.selected) {
					energyButton.text = qsTr("hours");
				} else {
					energyButton.text = "kWh";
				}
				break;
			}
			p.setPeriodMaxAndMin();
			p.periodTypeSelectionComplete = true;
			if(p.requestOnGraphChange)
				p.requestData();
		}
	}

	GraphLegend {
		id: legend
		anchors {
			left: topLeftTabBar.right
			right: topRightTabBar.left
			rightMargin: designElements.hMargin10
			verticalCenter: topRightTabBar.verticalCenter
		}
	}
}
