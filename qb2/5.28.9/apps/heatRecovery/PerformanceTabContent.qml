import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: root

	Item {
		id: heatProfit
		width: childrenRect.width
		height: childrenRect.height
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(55 * verticalScaling)
		}

		Image {
			id: heatRecoveryLeaf
			source: "image://scaled/apps/heatRecovery/drawables/heatrec_device_leaf.svg"
			sourceSize.height: Math.round(122 * verticalScaling)
		}

		Text {
			id: heatProfitTitle

			anchors {
				horizontalCenter: calculationButton.horizontalCenter
				top: parent.top
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.titleText
			color: colors.heatRecoveryAppText

			text: qsTr("Heat Profit")
		}

		Text {
			id: heatProfitValue

			anchors {
				horizontalCenter: calculationButton.horizontalCenter
				baseline: heatProfitTitle.baseline
				baselineOffset: Math.round(40 * verticalScaling)
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.primaryImportantBodyText
			color: colors.heatRecoveryAppAltText

			text: "± " + i18n.currency(app.heatRecoveryUsageInfo["currentEstimatedSavings"])
		}

		StandardButton {
			id: calculationButton

			anchors {
				left: heatRecoveryLeaf.right
				leftMargin: Math.round(38 * horizontalScaling)
				top: heatProfitValue.baseline
				topMargin: Math.round(21 * verticalScaling)
			}

			text: qsTr("The calculation")
			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl);
				qdialog.context.dynamicContent.tips = [
					{title: qsTr("calculation_popup_title"), text: qsTr("calculation_popup_text_page1")},
					{title: qsTr("calculation_popup_title"), text: qsTr("calculation_popup_text_page2"), textFormat: Text.RichText}
				];
			}
		}
	}

	Rectangle {
		id: informationTextRect
		radius: designElements.radius
		width: Math.round(687 * horizontalScaling)
		height: Math.round(74 * verticalScaling)
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(22 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(50 * horizontalScaling)
		}
		color: colors.heatRecoveryAppInfoBox

		Image {
			id: heatInfoImage
			anchors {
				left: parent.left
				leftMargin: Math.round(24 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			source: "image://scaled/apps/heatRecovery/drawables/heat_info.svg"
		}

		Text {
			id: heatInfoText

			anchors {
				verticalCenter: parent.verticalCenter
				left: heatInfoImage.right
				leftMargin: Math.round(11 * horizontalScaling)
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			color: colors.heatRecoveryAppInfoBoxText

			text: qsTr("Delivered %1 for heating\n(comparable to %2 m³ of gas)")
				.arg(app.getCurrentEnergyQuantityString())
				.arg(i18n.number(app.heatRecoveryUsageInfo["gasEquivalentCurrentEnergyQuantity"] / 1000, 1))
		}

		Image {
			id: elecInfoImage
			anchors {
				left: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
			}
			source: "image://scaled/apps/heatRecovery/drawables/elec_info.svg"
		}
		Text {
			id: elecInfoText

			anchors {
				verticalCenter: parent.verticalCenter
				left: elecInfoImage.right
				leftMargin: Math.round(24 * horizontalScaling)
			}

			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			color: colors.heatRecoveryAppInfoBoxText

			text: {
				var elecQuantity = app.heatRecoveryUsageInfo["CurrentElectricityQuantity"] / 1000;
				qsTr("Was %1 active\nand used %2 kWh.")
				.arg(qsTr("%n hour(s)", "", Math.round(app.heatRecoveryUsageInfo["ActiveElectricityHours"])))
				.arg(i18n.number(elecQuantity, elecQuantity > 1 ? 0 : 3))
			}
		}
	}
}
