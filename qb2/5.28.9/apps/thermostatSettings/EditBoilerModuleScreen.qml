import QtQuick 2.1
import qb.components 1.0

Screen {
	id: editBoilerModuleScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Edit boiler module")
	isSaveCancelDialog: false

	property ThermostatSettingsApp app

	QtObject {
		id: p
		property string deviceUuid

		function healthValueToString(health) {
			if (health >= 3) {
				return qsTr("Good")
			} else if (health > 0) {
				return qsTr("Poor")
			} else {
				return qsTr("Very poor");
			}
		}

		property variant boilerModuleTypeStrings: [
			qsTr("None"),
			qsTr("Wired"),
			qsTr("Wireless")
		]
	}

	onShown: {
		if (app.boilerModuleInfos.length)
			p.deviceUuid = app.boilerModuleInfos[0].uuid;
	}

	Column {
		id: contentColumn
		anchors {
			top: parent.top
			topMargin: Math.round(100 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		spacing: designElements.vMargin6
		Row {
			id: boilerModuleRow
			spacing: designElements.hMargin6
			SingleLabel {
				leftText: qsTr("Boiler module")
				rightText: qsTr("Connected")
			}

			IconButton {
				id: deleteButton
				iconSource: "qrc:/images/delete.svg"
				onClicked: {
					editBoilerModuleScreen.inNavigationStack = false;

					if (app.boilerModuleType === 2) {
						app.openRemoveWirelessBoilerModuleScreen();
					} else {
						hide();
						// TODO Actually remove the wired boiler module from the configuration
						app.boilerModuleType = 0;
					}
				}
			}
		}

		SingleLabel {
			leftText: qsTr("Connection type")
			rightText: p.boilerModuleTypeStrings[app.boilerModuleType]
		}

		Row {
			id: connectionQualityRow
			spacing: boilerModuleRow.spacing
			visible: app.boilerModuleType === 2
			SingleLabel {
				id: connectionQualityLabel
				leftText: qsTr("Connection quality")
				rightText: app.boilerModuleInfos.length >= 1 ? p.healthValueToString(app.boilerModuleInfos[0].HealthValue) : "";
			}

			IconButton {
				id: refreshButton
				iconSource: "qrc:/images/refresh.svg"

				onClicked: zWaveUtils.doNodeHealthTest(p.deviceUuid);
			}

			Throbber {
				id: refreshThrobber
				width: refreshButton.width
				height: refreshButton.height
				visible: false
			}

			states: [
				State {
					name: "HEALTHTEST_BUSY"
					when: (zWaveUtils.networkHealth.active && (zWaveUtils.networkHealth.uuid === p.deviceUuid))
					PropertyChanges {target: connectionQualityLabel; rightText: zWaveUtils.networkHealth.progress + "%"}
					PropertyChanges {target: refreshThrobber; visible: true}
					PropertyChanges {target: refreshButton; visible: false}
				},
				State {
					when: (zWaveUtils.networkHealth.active && (zWaveUtils.networkHealth.uuid !== p.deviceUuid))
					name: "HEALTHTEST_DISABLED"
					PropertyChanges {target: connectionQualityLabel; rightText: ""}
					PropertyChanges {target: refreshThrobber; visible: false}
					PropertyChanges {target: refreshButton; enabled: false}
				}
			]
		}
	}

	StandardButton {
		id: advancedButton
		anchors {
			right: parent.right
			rightMargin: designElements.hMargin6
			bottom: parent.bottom
			bottomMargin: designElements.vMargin6
		}
		text: qsTr("Advanced")
		onClicked: stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/eMetersSettings/RemoveDeviceScreen.qml"), {state: "wirelessBoilerModule" })
		visible: false // TODO: Re-enable when we create the "advanced remove" screen.
	}
}
