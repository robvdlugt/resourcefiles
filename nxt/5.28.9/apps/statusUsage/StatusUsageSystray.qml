import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: statusUsageSystrayIcon

	visible: false
	posIndex: 300
	objectName: "usageSystrayIcon"

	property bool statusUsageGood: true
	property variant totalDiff: app.totalDiffValues

	onTotalDiffChanged: updateSystrayAppearance()
	onStatusUsageGoodChanged: {
		hcblog.logKpi("EnStatusState", statusUsageGood ? "_good" : "_info");
	}

	onClicked: {
		stage.openFullscreen(app.statusUsageScreenUrl, {type:"total", unit:"money"});
	}

	function init() {
		app.dataAvailableChanged.connect(updateSystrayAppearance);
		app.billingInfosChanged.connect(updateSystrayAppearance);
	}

	function updateSystrayStatus() {
		if (totalDiff.costDiff < 0) {
			statusUsageGood = false;
			statusUsageSystrayIcon.image= "drawables/systray_bad.svg";
		} else {
			statusUsageGood = true;
			statusUsageSystrayIcon.image = "drawables/systray_good.svg";
		}
	}

	function updateSystrayAppearance() {
		var d = new Date();
		var fullMonth = d.getDate() === 1;
		if (app.dataAvailable.isAvailable && app.getBillingInfoValue("total", "haveSJV", "and") &&
				totalDiff.validUsageData && totalDiff.targetCost && (!fullMonth || (fullMonth && totalDiff.realCost))) {
			updateSystrayStatus();
			visible = true;
		} else {
			hcblog.logKpi("EnStatusState", false);
			visible = false;
		}
	}
}
