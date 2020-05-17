import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root

	screenTitle: qtUtils.escapeHtml(currentPlug.Name) // Prevent XSS/HTML injection by using qtUtils.escapeHtml

	property ControlPanelApp app

	property bool disableHardRemove: feature.appControlPanelSmartplugHardRemoveDisabled()
	property variant currentPlug: {"Name": "", "ZWUuid": "", "InSwitchAll": 0, "SwitchLocked": 0}
	property variant currentPlugStatus: app.deviceStatusInfo[currentPlug.DevUUID]

	QtObject {
		id: p

		function gotoPlugTab() {
			hide();
		}

		function handleRemoveResponse(status, type, uuid) {
			qdialog.reset();
			if (status === "deleted") {
				var name = app.getPlugDeviceName(uuid);
				if (!name)
					name = qsTr("Unknown device");
				else
					name = qtUtils.escapeHtml(name); // Prevent XSS/HTML injection by using qtUtils.escapeHtml
				qdialog.showDialog(qdialog.SizeLarge, qsTr("%1 disconnected").arg(name), app.restoreDecouplePlugPopupUrl, qsTr("Continue"), gotoPlugTab);
				qdialog.context.dynamicContent.state = "DECOUPLE_SUCCESS";
				qdialog.context.dynamicContent.plugName = name;
				qdialog.context.closeBtnForceShow = true;
				qdialog.setClosePopupCallback(gotoPlugTab);
			} else if (status !== "canceled") {
				if (status !== "timeout")
					zWaveUtils.excludeDevice("stop");
				// Prevent XSS/HTML injection by using qtUtils.escapeHtml
				qdialog.showDialog(qdialog.SizeLarge, qsTr("%1 disconnect failed").arg(qtUtils.escapeHtml(currentPlug.Name)), app.restoreDecouplePlugPopupUrl, qsTr("Retry"), deletePlug, qsTr("delete_from_config"), deletePlugFromConfig);
				if (disableHardRemove)
					qdialog.context.button2.enabled = false;
				qdialog.context.dynamicContent.state = "DECOUPLE_FAIL";
				qdialog.context.closeBtnForceShow = true;
			}
		}

		//remove plug flow entry point
		function deletePlug() {
			zWaveUtils.excludeDevice("delete", handleRemoveResponse);
			qdialog.reset();
			// Prevent XSS/HTML injection by using qtUtils.escapeHtml
			qdialog.showDialog(qdialog.SizeLarge, qsTr("%1 disconnecting").arg(qtUtils.escapeHtml(currentPlug.Name)), app.restoreDecouplePlugPopupUrl);
			qdialog.context.dynamicContent.state = "DECOUPLE";
			qdialog.setClosePopupCallback(p.cancelDeletePlug);
			return true;
		}

		//"cross" cancel button clicked while waiting for plug to be removed
		function cancelDeletePlug() {
			zWaveUtils.excludeDevice("stop");
		}

		//delete plug with zwave "RemoveDevice" request. From "Remove plug failed" popup
		function deletePlugFromConfig() {
			var name = qtUtils.escapeHtml(currentPlug.Name); // Prevent XSS/HTML injection by using qtUtils.escapeHtml
			qdialog.reset();
			qdialog.showDialog(qdialog.SizeLarge, qsTr("%1 deleted").arg(name), app.restoreDecouplePlugPopupUrl, qsTr("Continue"), gotoPlugTab);
			qdialog.context.dynamicContent.plugName = name;
			qdialog.context.dynamicContent.state = "DELETE_SUCCESS";
			qdialog.context.closeBtnForceShow = true;
			qdialog.setClosePopupCallback(gotoPlugTab);
			app.sendZwaveRemove(currentPlug.ZWUuid);
			return true;
		}

		function keyboardSave(text) {
			var plug = currentPlug;
			plug.Name = text;
			currentPlug = plug;
			app.setDeviceName(currentPlug.DevUUID, text);
		}

		function changeInSwitchAll(newVal) {
			if (newVal !== (currentPlug.InSwitchAll === "1")) {
				app.setInSwitchAll(currentPlug.DevUUID, newVal);
			}
		}

		function changeSwitchLocked(newVal) {
			if (newVal !== (currentPlug.SwitchLocked === "1")) {
				app.setSwitchLocked(currentPlug.DevUUID, newVal);
			}
		}

		//when some request to change the plug is done, search the plug in dataset to update the root.currentPlug reference
		function updateCurrentPlug() {
			for (var i = 0; i < app.devPlugs.length; i++) {
				if (currentPlug.DevUUID === app.devPlugs[i].DevUUID) {
					currentPlug = app.devPlugs[i];
					break;
				}
			}
		}
	}

	function init() {
		app.devPlugsChanged.connect(p.updateCurrentPlug);
	}

	Component.onDestruction: {
		app.devPlugsChanged.disconnect(p.updateCurrentPlug);
	}

	onShown: {
		if (args && args.plugUuid) {
			currentPlug = app.plugsTable[args.plugUuid]
		}
	}

	Item {
		width: childrenRect.width
		height: childrenRect.height
		anchors.centerIn: parent

		EditPlugComponent {
			id: editPlug

			disableRename: feature.appControlPanelPlugRenameDisabled()
			ctrlApp: root.app

			plugName: currentPlug.Name
			plugUuid: currentPlug.ZWUuid
			inSwitchAll: currentPlug.InSwitchAll === "1"
			switchLocked: currentPlug.SwitchLocked === "1"
			signalStrength: currentPlug.ZWUuid && zWaveUtils.devices[currentPlug.ZWUuid].IsConnected === "1" ? Math.floor(parseInt(zWaveUtils.devices[currentPlug.ZWUuid].HealthValue / 2)) : 0
			signalStrengthProgress: zWaveUtils.networkHealth.active ? zWaveUtils.networkHealth.progress : 0
			state: zWaveUtils.networkHealth.active ? (zWaveUtils.networkHealth.uuid === currentPlug.ZWUuid ? "checking" : "disabled") : "normal"

			onInSwitchAllChanged: p.changeInSwitchAll(inSwitchAll);
			onSwitchLockedChanged: p.changeSwitchLocked(switchLocked);
			onKeyboardSaved: p.keyboardSave(text);
			onUpdateSignalStrength: zWaveUtils.doNodeHealthTest(currentPlug.ZWUuid)
		}

		SingleLabel {
			id: deletePlugLabel
			anchors {
				top: editPlug.bottom
				topMargin: Math.round(40 * verticalScaling)
				left: editPlug.left
				right: deleteBtn.left
				rightMargin: designElements.hMargin6
			}

			leftText: qsTr("Delete plug")
		}


		IconButton {
			id: deleteBtn
			iconSource: "qrc:/images/delete.svg"
			anchors {
				top: deletePlugLabel.top
				right: editPlug.right
			}
			height: deletePlugLabel.height
			width: height
			onClicked: p.deletePlug()
		}
	}
}
