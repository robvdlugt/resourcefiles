import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: heatRecoveryScreen

	screenTitleIconUrl: "drawables/heatrec_device.svg"
	screenTitle: qsTr("HeatWinner")

	function init() {
		bottomTabBar.addItem(qsTr("Total"));
		bottomTabBar.addItem(qsTr("Month"));
		bottomTabBar.addItem(qsTr("Year"));
		bottomTabBar.setItemEnabled(1, false);
		bottomTabBar.setItemEnabled(2, false);
	}

	QtObject {
		id: p

		function selectTabs(periodIdx) {
			topLeftTabBarControlGroup.currentControlId = 0;
			bottomTabBar.setSelectedItem(periodIdx);
			dateSelector.periodStart = new Date();
		}

		function sinceText() {
			var sinceDate = new Date(app.heatRecoveryInfo["deviceCreatedTime"] * 1000);
			var day = sinceDate.getDate();
			var month = i18n.monthsFull[sinceDate.getMonth()];
			var year = sinceDate.getFullYear();
			return qsTr('Since %1 %2 %3').arg(sinceDate.getDate())
			.arg(i18n.monthsFull[sinceDate.getMonth()])
			.arg(sinceDate.getFullYear());
		}

		function selectionChanged() {

		}
	}

	onShown: {
		if (args)
			p.selectTabs(args.intervalType);
		else
			p.selectTabs(0);
	}

	ControlGroup {
		id: topLeftTabBarControlGroup
		exclusive: true
		onCurrentControlIdChangedByUser: p.selectionChanged()
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
			id: performanceTabButton
			text: qsTr("Performance")
			controlGroup: topLeftTabBarControlGroup
		}
	}

	Text {
		id: withoutVatText
		visible: globals.productOptions["SME"] === "1"
		anchors {
			verticalCenter: topLeftTabBar.verticalCenter
			left: topLeftTabBar.right
			leftMargin: designElements.hMargin15
		}
		font {
			family: qfont.italic.name
			pixelSize: qfont.metaText
		}
		color: colors.heatRecoveryAppText
		text: qsTr("Amounts excl. VAT")
	}

	Text {
		id: tipsText
		anchors {
			verticalCenter: tipsButton.verticalCenter
			right: tipsButton.left
			rightMargin: designElements.hMargin15
		}
		font {
			family: qfont.italic.name
			pixelSize: qfont.metaText
		}
		color: colors.heatRecoveryAppText
		text: qsTr("Make the most of your HeatWinner!")
	}

	StandardButton {
		id: tipsButton

		anchors {
			verticalCenter: topLeftTabBar.verticalCenter
			right: mainRect.right
		}
		colorUp: colors.heatRecoveryAppTipsButton
		fontColorUp: colors.heatRecoveryAppTipsButtonText

		text: qsTr("See tips")

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, "", app.tipsPopupUrl);
			qdialog.context.dynamicContent.tips = [
				// Tip1 was removed in WTF-1363(https://wecreate.toon.eu/jira/browse/WTF-1363)
				{
					title: qsTr("tip2_title"),
					text: qsTr("tip2_text"),
					image: Qt.resolvedUrl("image://scaled/apps/heatRecovery/drawables/tip_compare.svg"),
					align: "left",
					buttonText: qsTr("tip2_button"),
					buttonTargetScreen: Qt.resolvedUrl("qrc:/apps/benchmark/BenchmarkScreen.qml"),
					buttonTargetArgs: {"type": "gas"}
				},
				{
					title: qsTr("tip3_title"),
					text: qsTr("tip3_text"),
					image: Qt.resolvedUrl("image://scaled/apps/heatRecovery/drawables/tip_ventilation.svg"),
					align: "right",
				},
				{
					title: qsTr("tip4_title"),
					text: qsTr("tip4_text"),
					image: Qt.resolvedUrl("image://scaled/apps/heatRecovery/drawables/tip_shower.svg"),
					align: "right",
				}
			];
			qdialog.context.dynamicContent.showSeparator = true;
			qdialog.context.dynamicContent.imageContainerWidth = 190;
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
		color: colors.heatRecoveryAppScreenBackground

		PerformanceTabContent {
			id: performanceItem
			anchors.fill: parent
			visible: performanceTabButton.selected && !noConnectionItem.visible
		}

		Item {
			id: noConnectionItem
			width: parent.width
			height: childrenRect.height
			anchors.verticalCenter: parent.verticalCenter
			visible: (!app.hasDevice || !app.heatRecoveryInfo["IsConnected"]) && bottomTabBar.currentIndex === 0

			Image {
				id: noConnectionImage
				anchors {
					top: parent.top
					horizontalCenter: parent.horizontalCenter
				}
				source: "image://scaled/apps/heatRecovery/drawables/warning.svg"
			}

			Text {
				id: noConnectionText
				anchors {
					baseline: noConnectionImage.bottom
					baselineOffset: Math.round(35 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
				}
				font.family: qfont.regular.name
				font.pixelSize: qfont.bodyText
				color: colors.heatRecoveryAppText

				text: qsTr("Quby doesn't receive any information from your HeatWinner at the moment.")
			}
		}
	}

	Rectangle {
		id: dateSelectorRect
		height: dateSelector.height
		width: dateSelector.width
		x: dateSelector.x
		y: dateSelector.y
		color: colors.heatRecoveryAppScreenBackground
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
		periodMinimum: new Date()

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
		color: colors.heatRecoveryAppText
		text: p.sinceText();
	}

	BottomTabBar {
		id: bottomTabBar
		anchors {
			left: mainRect.left
			bottom: parent.bottom
		}
	}
}
