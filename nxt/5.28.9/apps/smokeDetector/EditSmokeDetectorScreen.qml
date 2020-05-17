import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0

Screen {
	id: editSmokeDetectorScreen
	screenTitle: (currentSmokeDetector.name ? qtUtils.escapeHtml(currentSmokeDetector.name) : (currentSmokeDetector.type ? currentSmokeDetector.type : qsTr("Smoke detector")))

	property variant currentSmokeDetector: {"name": "", "type": ""}

	QtObject {
		id: p

		function keyboardSave(text) {
			if (text) {
				var temp = currentSmokeDetector;
				temp.name = text;

				app.currentSmokedetectorUuid = currentSmokeDetector.intAddr;
				app.setDeviceName(text);

				currentSmokeDetector = temp;

				// Reset vars
				app.currentSmokedetectorName = "";
				app.currentSmokedetectorUuid = "";
			}
		}

		function handleExcludeResponse(status, type, uuid) {
			qdialog.reset();
			if (status === "deleted") {
				// Retrieve smoke detector name from array to find the device that was actually removed
				// Prevent XSS/HTML injection by using qtUtils.escapeHtml
				var name = qtUtils.escapeHtml(app.getSmokedetectorName(uuid));
				qdialog.showDialog(qdialog.SizeLarge, qsTr("%1 decoupled").arg(name ? name : qsTr("Unknown device")),
								   app.restoreSmokedetectorPopupUrl,
								   qsTr("Ready"), p.exitScreen);
				qdialog.context.dynamicContent.state = name ? "DECOUPLE_SUCCESS" : "DECOUPLE_SUCCESS_UNKNOWN";
				qdialog.context.closeBtnForceShow = true;
				qdialog.setClosePopupCallback(p.exitScreen);
				app.removeDeviceFromScenario(uuid);
			} else if (status !== "canceled") {
				if (status !== "timeout")
					zWaveUtils.excludeDevice("stop");
				// Prevent XSS/HTML injection by using qtUtils.escapeHtml
				qdialog.showDialog(qdialog.SizeLarge, qtUtils.escapeHtml(currentSmokeDetector.name) + " " + qsTr("decoupling failed"),
								   app.restoreSmokedetectorPopupUrl,
								   qsTr("Retry"), p.deleteSmokeDetector,
								   qsTr("Force removal"), p.forceRemoveSmokeDetector);
				qdialog.context.dynamicContent.state = "DECOUPLE_FAIL";
				qdialog.context.closeBtnForceShow = true;
			}
		}

		function forceRemoveSmokeDetector() {
			qdialog.reset();
			// Prevent XSS/HTML injection by using qtUtils.escapeHtml
			qdialog.showDialog(qdialog.SizeLarge, qtUtils.escapeHtml(currentSmokeDetector.name) + " " + qsTr("removed"),
							   app.restoreSmokedetectorPopupUrl,
							   qsTr("Ready"), p.exitScreen);
			qdialog.context.dynamicContent.state = "DELETE_SUCCESS";
			qdialog.context.closeBtnForceShow = true;
			qdialog.setClosePopupCallback(p.exitScreen);
			app.forceRemoveDevice(currentSmokeDetector.intAddr);
			return true;
		}

		function deleteSmokeDetector() {
			zWaveUtils.excludeDevice("delete", p.handleExcludeResponse);
			qdialog.reset();
			// Prevent XSS/HTML injection by using qtUtils.escapeHtml
			qdialog.showDialog(qdialog.SizeLarge, qtUtils.escapeHtml(currentSmokeDetector.name) + " " + qsTr("decoupling"), app.restoreSmokedetectorPopupUrl);
			qdialog.context.dynamicContent.state = "DECOUPLE";
			qdialog.context.closeBtnForceShow = true;
			qdialog.setClosePopupCallback(p.cancelDelete);
			return true;
		}

		// cancel button clicked while waiting for smoke detector to be removed
		function cancelDelete() {
			zWaveUtils.excludeDevice("stop");
		}

		function exitScreen() {
			editSmokeDetectorScreen.hide();
			if (app.linkedSmokedetectors.length === 0)
				stage.openFullscreen(app.welcomeScreenUrl);
		}
	}

	onShown: {
		if (args && args.device) {
			currentSmokeDetector = args.device;
		}
	}

	onCurrentSmokeDetectorChanged: {
		var connected = currentSmokeDetector.connected;
		var batteryLevel = currentSmokeDetector.batteryLevel;
		if (!connected || connected === "0") {
			customRightText.text = qsTr("No connection");
			customRightText.font.family = qfont.italic.name;
			battIcon.source = "";
		} else if (batteryLevel >= 0) {
			customRightText.text = batteryLevel > 0 ? batteryLevel + "%" : "";
			customRightText.font.family = qfont.regular.name;
			if (batteryLevel >= 51) {
				battIcon.source = "image://scaled/images/battery-full.svg";
			} else if (batteryLevel >= 26) {
				battIcon.source = "image://scaled/images/battery-high.svg";
			} else if (batteryLevel >= 11) {
				battIcon.source = "image://scaled/images/battery-mid.svg";
			} else {
				battIcon.source = "image://scaled/images/battery-low.svg";
			}
		} else {
			customRightText.text = "";
			battIcon.source = "image://scaled/images/battery-unknown.svg";
		}
	}

	GridLayout {
		anchors {
			top: parent.top
			topMargin: Math.round(86 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(130 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		rowSpacing: designElements.vMargin6
		columnSpacing: rowSpacing
		columns: 2

		EditTextLabel {
			id: editNameLabel
			Layout.fillWidth: true
			Layout.columnSpan: 2
			labelText: qsTr("Name")
			prefilledText: currentSmokeDetector.name ? currentSmokeDetector.name : currentSmokeDetector.type
			maxLength: 20
			showAcceptButton: true
			validator: RegExpValidator { regExp: /^\S.*$/ } // empty name is not allowed

			onInputAccepted: p.keyboardSave(inputText)
		}

		SingleLabel {
			id: batteryLabel
			Layout.fillWidth: true
			leftText: qsTr("Battery")

			Row {
				anchors {
					right: parent.right
					rightMargin: designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}
				spacing: designElements.hMargin10
	
				Text {
					id: customRightText
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: qfont.titleText
					visible: text ? true: false
				}

				Image {
					id: battIcon
					anchors.verticalCenter: parent.verticalCenter
				}
			}
		}

		SingleLabel {
			id: sensitivityLabel
			Layout.fillWidth: true
			Layout.row: 2
			leftText: qsTr("Smoke detector sensitivity")
			visible: feature.featSmokeDetectorSensitivityEnabled()

			Text {
				anchors {
					right: parent.right
					rightMargin: designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.titleText
				}
				text: currentSmokeDetector.sensitivityLevel === "2" ? qsTr("Normal") : qsTr("Low")
			}

			onClicked: editSensitivityBtn.clicked()
		}

		IconButton {
			id: editSensitivityBtn
			Layout.preferredWidth: width
			iconSource: "qrc:/images/edit.svg"
			visible: sensitivityLabel.visible

			onClicked: {
				stage.openFullscreen(app.editSensitivityScreenUrl, {context: editSmokeDetectorScreen});
			}
		}

		Item {
			id: spacer
			Layout.columnSpan: 2
			Layout.preferredHeight: deleteSmokeDetectorLabel.height - (parent.rowSpacing * 2)
		}

		SingleLabel {
			id: deleteSmokeDetectorLabel
			Layout.fillWidth: true
			Layout.row: 4
			leftText: qsTr("Decouple smoke detector")

			onClicked: p.deleteSmokeDetector();
		}

		IconButton {
			id: deleteBtn
			Layout.preferredWidth: width
			iconSource: "qrc:/images/delete.svg"

			onClicked: p.deleteSmokeDetector()
		}
	}
}
