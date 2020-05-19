import QtQuick 2.1
import qb.components 1.0

import apps.eMetersSettings 1.0 as EMetersSettings

Tile {
	property string type: "total"
	property bool unitMoney: true
	property int usageDecimals: 0

	property variant diffValues: app.totalDiffValues


	QtObject {
		id: p
		property bool missingData: !diffValues.validUsageData
		property url imageSource
		property bool showOnDim: false
	}

	onDiffValuesChanged: updateTile()

	onClicked: {
		stage.openFullscreen(app.statusUsageScreenUrl, {type:type, unit:unitMoney ? "money" : "energy"});
	}

	Component.onDestruction: {
		app.billingInfosChanged.disconnect(updateTile);
		app.dataAvailableChanged.disconnect(updateTile);
		app.eMetersSettingsApp.overallStatusChanged.disconnect(updateTile);
	}

	function init() {
		app.billingInfosChanged.connect(updateTile);
		app.dataAvailableChanged.connect(updateTile);
		app.eMetersSettingsApp.overallStatusChanged.connect(updateTile);
		updateTile();
	}

	function updateTile() {
		var haveSJV = app.getBillingInfoValue(type, "haveSJV", "and");
		var estimationValid = app.billingInfos["elec_produ"] && app.billingInfos["elec_produ"].usage > 0 || !app.agreementDetailsSolar

		if (app.dataAvailable.isAvailable && haveSJV && estimationValid) {
			var usage;
			if (unitMoney) {
				usage = {target: diffValues.targetCost, real: diffValues.realCost, diff: diffValues.costDiff};
			} else {
				usage = {target: diffValues.targetUsage, real: diffValues.realUsage, diff: diffValues.usageDiff};
			}
			var d = new Date();
			var extraOptions = 0, fullMonth = false;
			if (d.getDate() === 1) {
				d.setMonth(d.getMonth() - 1);
				extraOptions |= i18n.dom_no;
				fullMonth = true;
			}
			var currentDateString = i18n.dateTime(d, i18n.time_no | i18n.mon_full | i18n.year_no | extraOptions);
			if (fullMonth) {
				headText.text = qsTr("%1 in %2").arg(app.energyNames.titles[type]).arg(currentDateString);
			} else {
				headText.text = qsTr("%1 until %2").arg(app.energyNames.titles[type]).arg(currentDateString);
			}

			var value = usage.diff;
			var measureProblem = false;

			if (usage.target === 0) {
				bottomText.text = qsTr("No estimation");
				p.imageSource = "drawables/graphs_tile.svg"
				p.showOnDim = false;
			} else if (usage.real === 0 && fullMonth) {
				bottomText.text = qsTr("No usage");
				p.imageSource = "drawables/graphs_tile.svg"
				p.showOnDim = false;
			} else {
				if (type === "total") {
					measureProblem = Boolean(app.eMetersSettingsApp.overallStatus) && !fullMonth;
					if (p.missingData && measureProblem) {
						bottomText.text = qsTr("No measurement");
					} else {
						setTileText(value, unitMoney, app.energyUnits[type]);
					}
				} else {
					measureProblem = (app.eMetersSettingsApp.overallStatus & (1 << (EMetersSettings.Constants.meterType[type] + 1)))  && !fullMonth;
					if (p.missingData) {
						bottomText.text = measureProblem ? qsTr("No measurement") : qsTr("Incomplete data");
					} else {
						setTileText(value, unitMoney, app.energyUnits[type]);
					}
				}

				var statusIcon;
				if (p.missingData) {
					statusIcon = measureProblem ? "off" : "missing";
				} else {
					statusIcon = (measureProblem && type !== "total") ? "off" : (value >= 0 ? "good" : "bad");
				}
				p.imageSource = "drawables/tile_" + type + "_" + statusIcon + ".svg";
				p.showOnDim = true;
			}
		} else {
			if (!estimationValid) {
				headText.text = qsTr("Status usage");
				bottomText.text = qsTr("Enter your production");
				p.imageSource = "drawables/production_tile.svg"
			} else if (!haveSJV) {
				headText.text = qsTr("Estimation");
				bottomText.text = qsTr("Not received yet");
				p.imageSource = "drawables/graphs_tile.svg"
			} else {
				var date = new Date();
				if (date.getDate() > 1)
					date.setMonth(date.getMonth() + 1);
				headText.text = qsTr("Available from");
				bottomText.text = i18n.dateTime(date, i18n.time_no | i18n.dom_no | i18n.mon_full | i18n.year_yes);
				p.imageSource = "drawables/calendar_tile.svg"
			}
			p.showOnDim = false;
		}

	}

	function setTileText(diff, isCosts, usageUnit) {
		bottomText.text = "";
		if (diff !== 0) {
			if (!p.missingData) {
				bottomText.text = isCosts ? app.formatCostDiff(diff) + " " : i18n.number(Math.abs(diff), usageDecimals) + " " + usageUnit + " ";
				bottomText.text += app.getDiffText(diff);
			} else {
				var diffText = app.getDiffText(diff);
				var diffTextCapt =  i18n.capitalizeFirstChar(diffText);
				bottomText.text = qsTr("%1 consumed").arg(diffTextCapt);
			}
		} else {
			bottomText.text += app.getDiffText(diff);
		}
	}

	Text {
		id: headText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Image {
		id: image
		anchors.centerIn: parent
		source: p.imageSource ? (p.showOnDim && dimState ? "image://colorized/white" : "image://scaled") + qtUtils.urlPath(p.imageSource) : ""
		visible: !p.showOnDim && dimState ? false : true
	}

	Text {
		id: bottomText
		anchors {
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileText
		}
		color: dimmableColors.tileTextColor
		visible: !p.showOnDim && dimState ? false : true
	}
}
