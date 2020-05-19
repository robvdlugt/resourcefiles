import QtQuick 2.1

import qb.components 1.0

Screen {
	id: maUpdateScreen

	screenTitle: qsTr("Software Update")
	anchors.fill: parent
	hasCancelButton: true
	hasSaveButton: false
	inNavigationStack: false

	property string deviceUuid: ""

	onCustomButtonClicked: {
		app.maUpdateInProgressPopup.uuid = deviceUuid;
		app.maUpdateInProgressPopup.show();
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onShown: {
		if (args && args.uuid) {
			deviceUuid = args.uuid;
		}
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Update"));
	}

	Text {
		id: updateScreenText

		anchors {
			top: parent.top
			left: parent.left
			topMargin: Math.round(55 * verticalScaling)
			leftMargin: Math.round(67 * horizontalScaling)
		}

		width: Math.round(500 * horizontalScaling)

		wrapMode: Text.WordWrap
		text: qsTr("update_meter_adapter_instruction")
		color: colors.updateSoftwareText
		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}
}
