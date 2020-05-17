import QtQuick 2.1
import QtQuick.Layouts 1.3
import qb.components 1.0

ContentScreen {
	id: connQualityScreen
	hasCancelButton: true
	inNavigationStack: false
	imageSource: "drawables/quality-smart-heat-module.svg"
	imagePosition: "center"

	property ThermostatSettingsApp app
	property string deviceUuid: ""

	onCustomButtonClicked: {
		hide();
	}

	onShown: {
		if (args && args.state && args.uuid) {
			state = args.state;
			deviceUuid = args.uuid;
		}

		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"));

		progressLayout.state = "checkingSearching";
		zWaveUtils.doNodeHealthTest(deviceUuid, checkHealthResponse);
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	function checkHealthResponse(success, health) {
		if (success && health >= 3) {
			progressLayout.state = "success";
		} else {
			progressLayout.state = "failed";
		}
	}

	GridLayout {
		id: progressLayout
		width: parent.width
		columns: 2
		columnSpacing: designElements.hMargin20
		rowSpacing: designElements.vMargin15

		Item {
			Layout.preferredWidth: linkThrobber.width
			Layout.preferredHeight: linkThrobber.height

			Throbber {
				id: linkThrobber
				anchors.centerIn: parent
				visible: false
				height: Math.round(32 * verticalScaling)
			}

			Image {
				id: linkImage
				anchors.centerIn: parent
				visible: false
				source: "qrc:/images/good.svg"
			}
		}

		Text {
			id: linkText
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			wrapMode: Text.WordWrap
			color: colors.text
		}

		Item {
			id: placeholder
			Layout.minimumWidth: 1
			Layout.rowSpan: 2
		}

		Text {
			id: errorText
			Layout.fillWidth: true
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.bodyText
			}
			visible: false
			color: colors._marypoppins
			wrapMode: Text.WordWrap
		}

		Row {
			spacing: designElements.hMargin10
			visible: errorText.visible

			StandardButton {
				id: retryButton
				text: qsTr("Retry")

				onClicked: {
					progressLayout.state = "checkingSearching";
					zWaveUtils.doNodeHealthTest(deviceUuid, checkHealthResponse);
				}
			}

			StandardButton {
				id: linkRepeaterButton
				text: qsTr("Link repeater")

				onClicked: {
					stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/eMetersSettings/AddDeviceScreen.qml"), {state: "repeater"});
				}
			}
		}

		states: [
			State {
				name: "checkingSearching"
				PropertyChanges { target: linkThrobber; visible: true }
				PropertyChanges { target: linkText; text: qsTr("Checking your connection quality...") }
				PropertyChanges { target: connQualityScreen; customButtonEnabled: false; cancelEnabled: true }
			},
			State {
				name: "success"
				PropertyChanges { target: linkImage; visible: true	}
				PropertyChanges { target: linkText; text: qsTr("Connection is good.") }
				PropertyChanges { target: connQualityScreen; customButtonEnabled: true; cancelEnabled: false }
			},
			State {
				name: "failed"
				PropertyChanges { target: linkImage; visible: true; source: "qrc:/images/bad.svg" }
				PropertyChanges { target: linkText; text: qsTr("The wireless connection is weak.") }
				PropertyChanges { target: errorText; visible: true }
				PropertyChanges { target: connQualityScreen; customButtonEnabled: false; cancelEnabled: true }
			}
		]
	}

	state: "wirelessBoilerModule"
	states: [
		State {
			name: "wirelessBoilerModule"
			PropertyChanges {
				target: connQualityScreen
				title: qsTr("Connection check with the wireless boiler module")
				screenTitle: qsTr("Install wireless boiler module")
			}
			PropertyChanges {
				target: errorText
				text: qsTr("The wireless connection is not strong enough. The distance between $(display) and the wireless boiler module is too big.")
			}
		},
		State {
			name: "smartHeatModule"
			PropertyChanges {
				target: connQualityScreen
				title: qsTr("Connection check with the Smart Heat module")
				screenTitle: qsTranslate("AddDeviceScreen", "Install Smart Heat module") }
			PropertyChanges {
				target: errorText
				text: qsTr("The distance between $(display) and the Smart Heat module is probably too large.")
			}
		}
	]
}
