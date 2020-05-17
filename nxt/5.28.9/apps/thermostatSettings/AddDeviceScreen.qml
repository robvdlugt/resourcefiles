import QtQuick 2.1
import QtQuick.Layouts 1.3
import qb.components 1.0

ContentScreen {
	id: addDeviceScreen

	property string newDeviceUuid

	hasCancelButton: true
	inNavigationStack: false
	imagePosition: "center"
	cancelEnabled: true
	customButtonEnabled: false

	property ThermostatSettingsApp app

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onShown: {
		if (args && args.state) {
			state = args.state;
		}
		
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Continue"));
		linkButtonRow.state = "notlinked";
	}

	onCustomButtonClicked: {
		if (state === "wirelessBoilerModule") {
			app.boilerModuleType = 2;
		}
		stage.openFullscreen(app.connectionQualityScreenUrl, {state: state, uuid: newDeviceUuid});
	}

	onCanceled: {
		if (linkButtonRow.state === "linking") {
			zWaveUtils.includeDevice("stop");
		}
	}

	function handleIncludeResponse(status, type, uuid) {
		if (typeof addDeviceScreen !== 'undefined') {
			// TODO Can we make the type generic, but still only support WBC's here?
			var recognizedWBCDevice = (type !== undefined && (
										   type.indexOf("SSR") !== -1 ||
										   type.indexOf("RXZ") !== -1));

			if (status === "added" && (state === "smartHeatModule" || recognizedWBCDevice) ) {
				newDeviceUuid = uuid;
				linkButtonRow.state = "linked";
			} else if (status === "timeout") {
				// Automatically retry
				console.log("Link failed, retrying automatically.");
				linkButtonRow.state = "linking";
				zWaveUtils.includeDevice("add", handleIncludeResponse);
			} else {
				linkButtonRow.state = "failed";
			}
		}
	}

	Timer {
		id: showAddRepeaterTimer
		interval: 60000
		onTriggered: {
			addRepeaterButton.visible = true;
		}
	}

	Column {
		id: stepsList
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			right: parent.right
		}
		spacing: designElements.vMargin15

		Repeater {
			id: stepsRepeater

			RowLayout {
				width: parent.width
				spacing: designElements.hMargin15

				NumberBullet {
					id: stepNumber
					Layout.preferredWidth: width
					text: index + 1
					color: colors.black
				}

				Text {
					id: stepText
					Layout.fillWidth: true
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.text
					wrapMode: Text.WordWrap
					text: modelData
				}
			}
		}
	}

	RowLayout {
		id: linkButtonRow
		state: "notlinked"
		states: [
			State {
				name: "notlinked"
				PropertyChanges { target: linkButton; enabled: true}
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: linkIcon; visible: false }
			},
			State {
				name: "linking"
				StateChangeScript { script: showAddRepeaterTimer.restart() }
				PropertyChanges { target: linkButton; enabled: false }
				PropertyChanges { target: linkThrobber; visible: true }
				PropertyChanges { target: linkIcon; visible: false }
			},
			State {
				name: "linked"
				StateChangeScript { script: showAddRepeaterTimer.stop() }
				PropertyChanges { target: addDeviceScreen; customButtonEnabled: true; cancelEnabled: false }
				PropertyChanges { target: linkButton; enabled: false }
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: linkIcon; visible: true }
				PropertyChanges { target: addRepeaterButton; visible: false }

			},
			State {
				name: "failed"
				PropertyChanges { target: linkButton; enabled: true; text: qsTr("Retry") }
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: linkIcon; visible: true; source: "image://scaled/images/bad.svg" }
				PropertyChanges { target: linkErrorText; visible: true }
				PropertyChanges { target: addRepeaterButton; visible: true }
			}
		]
		anchors {
			top: stepsList.bottom
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: parent.right
		}
		spacing: designElements.hMargin15

		StandardButton {
			id: linkButton
			Layout.preferredWidth: width
			minWidth: Math.round(100 * horizontalScaling)
			primary: true
			text: qsTr("Link")

			onClicked: {
				if (linkButtonRow.state === "notlinked" || linkButtonRow.state === "failed") {
					linkButtonRow.state = "linking";
					zWaveUtils.includeDevice("add", handleIncludeResponse);
				}
			}
		}

		Throbber {
			id: linkThrobber
			Layout.preferredWidth: width
			height: linkButton.height
			visible: false
		}

		Image {
			id: linkIcon
			Layout.preferredWidth: width
			source: "image://scaled/images/good.svg"
			visible: false
		}

		Text {
			id: linkErrorText
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._marypoppins
			text: qsTr("linking-failed")
			wrapMode: Text.WordWrap
			visible: false
		}

		Item {
			id: placeholder
			Layout.minimumWidth: 1
			Layout.fillWidth: true
			visible: !linkErrorText.visible
		}
	}

	StandardButton {
		id: addRepeaterButton
		anchors {
			top: linkButtonRow.bottom
			topMargin: designElements.vMargin10
			left: linkButtonRow.left
		}
		text: qsTr("Add repeater")
		visible: false

		onClicked: {
			if (linkButtonRow.state === "linking") {
				zWaveUtils.includeDevice("stop");
			}
			stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/eMetersSettings/AddDeviceScreen.qml"), {state: "repeater"})
		}
	}

	states: [
		State {
			name: "wirelessBoilerModule"
			PropertyChanges { target: addDeviceScreen; screenTitle: qsTr("Install wireless boiler module"); title: qsTr("Connect the boiler module to $(display)") }
			PropertyChanges { target: stepsRepeater; model: [
				qsTr("Install the wireless boiler module at the right location near the boiler."),
				qsTr("Press <b>Link</b>."),
				qsTr("Link the module to $(display).<br>Follow the instructions that were provided to you specific for your wireless boiler module.")
			]}
		},
		State {
			name: "smartHeatModule"
			PropertyChanges { target: addDeviceScreen
				screenTitle: qsTr("Install Smart Heat module")
				title: qsTr("Connecting the smart heat module")
				imageSource: "drawables/link-smart-heat-module.svg"
			}
			PropertyChanges { target: stepsRepeater; model: [
				qsTr("Place the Smart Heat module in the right location."),
				qsTr("Press <b>Link</b>."),
				qsTr("Press and hold the button on the Smart Heat module for at least 2 seconds.")
			]}
		}
	]
}
