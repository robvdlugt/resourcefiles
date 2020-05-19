import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

Widget {
	id: zoneTempSidePanel

	property string kpiPrefix: "ZoneTemperatureSidePanel."
	property StrvSettingsApp app

	property url sourceUrl: app.zoneTempSidePanelUrl

	width: Math.round(248 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	visible: (! canvas.dimState && globals.heatingMode === "zone")

	Connections {
		target: app
		onZoneListChanged: checkZoneListModel();
		onZoneRenamed: {
			// If a zone is renamed, clear the list so we reinitialize with the correct (new) order
			zoneListModel.clear();
		}
	}

	function init() {
		checkZoneListModel();
	}

	function checkZoneListModel() {
		if (zoneListModel.count === app.zoneList.length) {
			// Nothing to do
			return;
		}

		zoneListModel.clear();
		for (var i = 0; i < app.zoneList.length; ++i) {
			zoneListModel.append({"uuid": app.zoneList[i].uuid});
		}
	}

	ListModel {
		id: zoneListModel
	}

	Component {
		id: zoneListDelegate

		ZoneTemperaturePanelItem {
			width: zoneList.width - (zoneList.buttonsVisible ? Math.round(10 * horizontalScaling) : 0)
			height: Math.round(108 * verticalScaling)
			zoneUuid: uuid
			selected: ListView.isCurrentItem
			mouseEnabled: true

			onClicked: ListView.view.currentIndex = index
		}
	}

	SimpleList {
		id: zoneList

		itemsPerPage: 4
		itemHeight: Math.round(108 * verticalScaling)
		itemSpacing: Math.round(4 * verticalScaling)

		delegate: zoneListDelegate
		dataModel: zoneListModel

		buttonsHeight: Math.round(40 * verticalScaling)

		buttonUpStateBackground: "transparent"
		scrollLaneColor: colors._bg

		anchors {
			fill: parent
			topMargin: designElements.spacing6
			leftMargin: designElements.spacing6
			rightMargin: designElements.spacing6
		}
	}
}
