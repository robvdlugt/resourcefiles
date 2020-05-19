import QtQuick 2.0
import QtQuick.Layouts 1.3

import qb.components 1.0

Item {
	anchors.fill: parent
	property StatusUsageApp app
	property var estimationData

	Component.onCompleted: {
		var energyList = {"elec": {}};
		if (app.secondaryEnergyType)
			energyList[app.secondaryEnergyType] = {};

		var totalCost = 0;
		for (var energy in energyList) {
			var values = {}
			values["usage"] = (app.billingInfos[energy].usage + app.billingInfos[energy].lowUsage) / 1000;
			values["cost"] = ((app.billingInfos[energy].usage / 1000) * app.billingInfos[energy].price) +
							 ((app.billingInfos[energy].lowUsage / 1000) * app.billingInfos[energy].lowPrice);
			totalCost += values["cost"];
			energyList[energy] = values;
		}
		energyList["total"] = {"cost": totalCost};
		estimationData = energyList;
	}

	GridLayout{
		anchors {
			left: parent.left
			right: parent.right
			leftMargin: Math.round(60 * verticalScaling)
			rightMargin: anchors.leftMargin
			verticalCenter: parent.verticalCenter
		}
		columns: 4
		columnSpacing: designElements.hMargin20
		rowSpacing: designElements.vMargin10

		Text {
			id: totalLabel
			Layout.columnSpan: 2
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: qsTr("Total")
		}

		Text {
			id: totalValue
			Layout.preferredWidth: Math.round(70 * horizontalScaling)
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			horizontalAlignment: Text.AlignRight
			color: colors.text
			text: i18n.currency(estimationData["total"].cost, i18n.curr_round)
		}

		Item {}

		Rectangle {
			id: divider1
			Layout.fillWidth: true
			Layout.columnSpan: 4
			color: colors._pressed
			height: 1
		}

		Image {
			id: elecIcon
			source: "image://scaled/apps/statusUsage/drawables/elec_badge.svg"
			sourceSize.height: Math.round(32 * verticalScaling)
		}

		Text {
			id: elecLabel
			Layout.preferredWidth: Math.round(220 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: app.energyNames.titles["elec"]
		}

		Text {
			id: elecCostValue
			Layout.preferredWidth: Math.round(70 * horizontalScaling)
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			horizontalAlignment: Text.AlignRight
			color: colors.text
			text: i18n.currency(estimationData["elec"].cost, i18n.curr_round);
		}

		Text {
			id: elecUsageValue
			Layout.fillWidth: true
			Layout.leftMargin: Math.round(25 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: i18n.number(estimationData["elec"].usage, 0) + " " + app.energyUnits["elec"]
		}

		Rectangle {
			id: divider2
			Layout.fillWidth: true
			Layout.columnSpan: 4
			color: colors._pressed
			height: 1
		}

		Image {
			id: secondaryIcon
			source: visible ? "image://scaled/apps/statusUsage/drawables/" + app.secondaryEnergyType +"_badge.svg" : ""
			sourceSize.height: Math.round(32 * verticalScaling)
			visible: app.secondaryEnergyType
		}

		Text {
			id: secondaryLabel
			Layout.preferredWidth: Math.round(220 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			visible: secondaryIcon.visible
			color: colors.text
			text: app.energyNames.titles[app.secondaryEnergyType]
		}

		Text {
			id: secondaryCostValue
			Layout.preferredWidth: Math.round(70 * horizontalScaling)
			font {
				family: qfont.bold.name
				pixelSize: qfont.bodyText
			}
			visible: secondaryIcon.visible
			horizontalAlignment: Text.AlignRight
			color: colors.text
			text: visible ? i18n.currency(estimationData[app.secondaryEnergyType].cost, i18n.curr_round) : ""
		}

		Text {
			id: secondaryUsageValue
			Layout.fillWidth: true
			Layout.leftMargin: Math.round(25 * horizontalScaling)
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			visible: secondaryIcon.visible
			color: colors.text
			text: visible ? i18n.number(estimationData[app.secondaryEnergyType].usage, 0) + " " + app.energyUnits[app.secondaryEnergyType] : ""
		}

		Rectangle {
			id: divider3
			Layout.fillWidth: true
			Layout.columnSpan: 4
			color: colors._pressed
			height: 1
			visible: secondaryIcon.visible
		}

		Text {
			id: updatedText
			Layout.fillWidth: true
			Layout.columnSpan: 4
			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
			}
			color: colors.text
			text: qsTr("Updated on: %1").arg(i18n.dateTime(1000 * parseInt(app.billingInfos["elec"]["changeDate"]), i18n.dom_no | i18n.mon_full | i18n.time_no))
		}

		WarningBox {
			Layout.fillWidth: true
			Layout.columnSpan: 4
			autoHeight: true
			warningIcon: "qrc:/images/info_warningbox.svg"
			warningText: qsTr("estimations-popup-warning")
		}
	}
}
