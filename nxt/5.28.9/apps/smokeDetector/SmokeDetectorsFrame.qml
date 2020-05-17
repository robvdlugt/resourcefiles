import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Widget {
	id: smokeDetectorsFrame
	anchors.fill: parent

	QtObject {
		id: p

		function editDevice(device) {
			stage.openFullscreen(app.editSmokeDetectorScreenUrl, {device: device});
		}
	}

	function init() {
		app.linkedSmokedetectorsChanged.connect(refreshList);
	}
	Component.onDestruction: {
		app.linkedSmokedetectorsChanged.disconnect(refreshList);
	}

	function refreshList() {
		smokedetectorList.removeAll();

		var showPage = -1;
		var showPopupIcon = false;
		for (var idx = 0; idx < app.linkedSmokedetectors.length; idx++) {
			smokedetectorList.addDevice({"device": app.linkedSmokedetectors[idx]});
			var battLevel = parseInt(app.linkedSmokedetectors[idx].batteryLevel);
			if (!app.linkedSmokedetectors[idx].connected ||
					app.linkedSmokedetectors[idx].connected === "0" || battLevel <=10) {
				showPopupIcon = true;
				if (showPage === -1) {
					showPage = smokedetectorList.getPageForDataIdx(idx);
				}
			}
		}

		smokedetectorList.refreshView();
		infoButton.visible = showPopupIcon;

		// Jump to the right page
		if (showPage === -1)
			showPage = 0;
		smokedetectorList.goToPage(showPage);
	}

	onShown: {
		refreshList();
	}

	onHidden: {
		smokedetectorList.removeAll();
	}

	Text {
		id: titleLabel

		anchors {
			baseline: smokeDetectorsFrame.top
			baselineOffset: Math.round(50 * verticalScaling)
			left: smokeDetectorsFrame.left
			leftMargin: Math.round(50 * horizontalScaling)
			right: smokeDetectorsFrame.right
			rightMargin: anchors.leftMargin
		}
		color: colors.smokedetectorTitle
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
		text: qsTr("title_text")
	}

	IconButton {
		id: infoButton

		anchors {
			top: titleLabel.top
			right: titleLabel.right
		}

		iconSource: "qrc:/images/info.svg"
		visible: false

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("smokedetector_popup_title"), app.statusExplanationPopupUrl);
		}
	}

	Text {
		id: bodyLabel

		anchors {
			baseline: titleLabel.baseline
			baselineOffset: Math.round(33 * verticalScaling)
			left: titleLabel.left
			right: titleLabel.right
		}
		wrapMode: Text.WordWrap
		color: colors.smokedetectorBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTr("body_text")
	}

	Component {
		id: deviceListDelegate
		DeviceListDelegate {

			property string kpiPrefix: "/apps/smokeDetector/AddSmokeDetectorScreen."

			onEditDeviceClicked:{
				if (smokedetectorList.getDevice(index).device) {
					p.editDevice(smokedetectorList.getDevice(index).device);
				}
			}
		}
	}

	SmartDeviceList {
		id: smokedetectorList
		anchors {
			left: titleLabel.left
			top: bodyLabel.bottom
			topMargin: Math.round(30 * verticalScaling)
			right: titleLabel.right
			bottom: smokeDetectorsFrame.bottom
		}
		maxItems: 8

		delegate: deviceListDelegate
		addDeviceText: qsTr("Add smokedetector")

		onAddDeviceClicked: stage.openFullscreen(app.addSmokeDetectorScreenUrl)
	}
}
