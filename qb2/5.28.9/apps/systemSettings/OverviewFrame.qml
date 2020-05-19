import QtQuick 2.1

import qb.base 1.0;
import qb.components 1.0

Widget {
	id: overviewFrame
	anchors.fill: parent

	function init(context) {
		registry.registerWidgetContainer("statusButton", overviewFrame);
	}

	function onWidgetRegistered(widgetInfo) {
		var button = util.loadComponent(widgetInfo.url, null, {app: widgetInfo.context, weight: widgetInfo.args.weight, kpiPrefix: "/apps/systemSettings/OverviewFrame."});
		util.insertItem(button, overviewButtonsRow, "weight");
		button.app.errorsChanged.connect(errorCountChanged);
		button.app.systrayErrorsChanged.connect(systrayErrorCountChanged);
		button.initWidget(widgetInfo);
		errorCountChanged();
		systrayErrorCountChanged();
	}

	function errorCountChanged() {
		var count = 0;
		var list = overviewButtonsRow.children;
		var len = list.length;
		for (var i = 0; i < len; i++) {
			if (list[i].app.errors > 0)
				count += list[i].app.errors;
		}
		app.errorCount = count;
	}

	function systrayErrorCountChanged() {
		var count = 0;
		var list = overviewButtonsRow.children;
		var len = list.length;
		for (var i = 0; i < len; i++) {
			count += list[i].app.systrayErrors;
		}
		// Log KPI event only when error count has actually changed
		// and incurs a change in the visibility of icon
		if (app.systrayErrorCount > 0 && count == 0) {
			hcblog.logKpi("ErrorIconVisible", false);
		} else if (app.systrayErrorCount === 0 && count > 0) {
			hcblog.logKpi("ErrorIconVisible", true);
		}
		app.systrayErrorCount = count;
	}

	Row {
		id: overviewButtonsRow
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		spacing: designElements.vMargin15
	}

	SingleLabel {
		id: activationLabel
		anchors {
			top: overviewButtonsRow.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(34 * horizontalScaling)
			right: activationButton.left
			rightMargin: designElements.hMargin6
		}
		leftText: qsTr("activate-label-text")
		leftTextSize: qfont.bodyText
		visible: globals.productOptions.activated === 0
	}

	StandardButton {
		id: activationButton
		anchors {
			top: activationLabel.top
			right: parent.right
			rightMargin: activationLabel.anchors.leftMargin
		}
		text: qsTr("Activate")
		visible: activationLabel.visible

		onClicked: stage.openFullscreen(app.activationScreenUrl)
	}
}
