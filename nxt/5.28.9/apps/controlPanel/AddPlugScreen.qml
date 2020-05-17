import QtQuick 2.1
import qb.components 1.0

Screen {
	property ControlPanelApp app

	QtObject {
		id: p

		property url maximumPowerPopupUrl: "MaximumPowerPopup.qml"

		function plugAdded() {
			if (backgroundRect.state === "linking") {
				backgroundRect.state = "linked";
				app.newPlugChanged.disconnect(plugAdded);
			}
		}
	}

	function handleIncludeResponse(status, type, uuid) {
		if (status === "added") {
			app.smartplugZwaveUuid = uuid;
			app.newPlugChanged.connect(p.plugAdded);
			app.devPlugsChanged.connect(app.getPlugDeviceUuid);
			zwaveSmartplugEnableDelay.start();
		} else if (status !== "canceled") {
			stage.openFullscreen(app.plugWizardErrorScreenUrl);
		}
	}

	screenTitle: qsTr("Add plug")
	inNavigationStack: false
	hasCancelButton: true

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Continue"));
		disableCustomTopRightButton();
		backgroundRect.state = "notLinked"
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	// will first be enabled when successfully added plug
	onCustomButtonClicked: {
		stage.openFullscreen(app.wizardScreenUrl, {reset:true});
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Maximum power"), p.maximumPowerPopupUrl, qsTr("Resume"));
	}

	onCanceled: {
		if (backgroundRect.state === "linking") {
			zWaveUtils.includeDevice("stop");
		}
	}

	Text {
		id: linkSmartplugText
		anchors {
			left: backgroundRect.left
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.controlPanelAddDeviceTitle
		text: qsTr("Link Smartplug")
	}

	Rectangle {
		id: backgroundRect
		height: Math.round(270 * verticalScaling)
		width: Math.round(755 * horizontalScaling)
		anchors {
			top: linkSmartplugText.baseline
			topMargin: Math.round(20 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		radius: designElements.radius
		color: colors.controlPanelBackgroundRectangle

		state: "notLinked"

		states: [
			State {
				name: "notLinked"
				PropertyChanges { target: plugImage; overlayColor: colors.plugIconDisabled }
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: greenCheck; visible: false }
				PropertyChanges { target: oneText; color: colors.plugTabText; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.plugTabText; restoreEntryValues: false }
				PropertyChanges { target: threeText1; color: colors.plugTabText; restoreEntryValues: false }
				PropertyChanges { target: threeText2; color: colors.plugTabText; restoreEntryValues: false }
				PropertyChanges { target: linkButton; enabled: true; state: "up" }
				StateChangeScript { script: {
					disableCustomTopRightButton();
					enableCancelButton();
				}}
			},
			State {
				name: "linking"
				PropertyChanges { target: plugImage; overlayColor: colors.plugIconLinking }
				PropertyChanges { target: linkButton; state: "down" }
				PropertyChanges { target: linkThrobber; visible: true }
			},
			State {
				name: "linked"
				PropertyChanges { target: plugImage; overlayColor: colors.plugIconLinked }
				PropertyChanges { target: linkThrobber; visible: false }
				PropertyChanges { target: greenCheck; visible: true	}
				PropertyChanges { target: oneText; color: colors.controlPanelTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: twoText; color: colors.controlPanelTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: threeText1; color: colors.controlPanelTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: threeText2; color: colors.controlPanelTextDisabled; restoreEntryValues: false }
				PropertyChanges { target: bulletOne; enabled: false }
				PropertyChanges { target: bulletTwo; enabled: false }
				PropertyChanges { target: bulletThree; enabled: false }
				PropertyChanges { target: linkButton; state: "disabled" }
				StateChangeScript { script: {
					enableCustomTopRightButton();
					disableCancelButton();
				}}
			}
		]

		NumberBullet {
			id: bulletOne
			anchors {
				left: parent.left
				leftMargin: designElements.hMargin10
				top: parent.top
				topMargin: Math.round(35 * verticalScaling)
			}
			text: "1"
		}

		Text {
			id: oneText
			anchors {
				left: bulletOne.right
				leftMargin: designElements.hMargin10
				verticalCenter: bulletOne.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.plugTabText
			text: qsTr("Plug the smartplug into the electrical outlet.")
		}

		NumberBullet {
			id: bulletTwo
			anchors {
				left: bulletOne.left
				top: bulletOne.bottom
				topMargin: Math.round(35 * verticalScaling)
			}
			text: "2"
		}

		Text {
			id: twoText
			anchors {
				left: bulletTwo.right
				leftMargin: designElements.hMargin10
				verticalCenter: bulletTwo.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.plugTabText
			text: qsTr("Press \"Link\".")
		}

		StandardButton {
			id: linkButton
			anchors {
				top: bulletTwo.bottom
				topMargin: Math.round(18 * verticalScaling)
				left: twoText.left
			}
			text: qsTr("Link")
			onClicked: {
				if (backgroundRect.state === "notLinked") {
					backgroundRect.state = "linking";
					zWaveUtils.includeDevice("add", handleIncludeResponse);
				} else if (backgroundRect.state === "linking") {
					state = "down"
				} else if (backgroundRect.state === "linked") {
					state = "disabled"
				}
			}
		}

		Throbber {
			id: linkThrobber
			anchors {
				left: linkButton.right
				leftMargin: Math.round(17 * horizontalScaling)
				verticalCenter: linkButton.verticalCenter
			}
			visible: false
		}

		Image {
			id: greenCheck
			anchors {
				verticalCenter: linkButton.verticalCenter
				left: linkButton.right
				leftMargin: Math.round(8 * horizontalScaling)
			}
			visible: false
			source: "qrc:/images/good.svg"
			height: Math.round(24 * verticalScaling)
			sourceSize {
				width: 0
				height: height
			}
		}

		NumberBullet {
			id: bulletThree
			anchors {
				left: bulletOne.left
				top: linkButton.bottom
				topMargin: Math.round(18 * verticalScaling)
			}
			text: "3"
		}

		Text {
			id: threeText1
			anchors {
				left: bulletTwo.right
				leftMargin: designElements.hMargin10
				verticalCenter: bulletThree.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.plugTabText
			text: qsTr("three_text1")
		}

		Text {
			id: threeText2
			anchors {
				left: threeText1.left
				baseline: threeText1.baseline
				baselineOffset: 23
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.plugTabText
			text: qsTr("three_text2")
		}

		Image {
			id: plugImage
			anchors {
				right: parent.right
				rightMargin: Math.round(30 * horizontalScaling)
				bottom: threeText2.baseline
			}
			source: "image://colorized/" + overlayColor.toString() + "/apps/controlPanel/drawables/smartplug.svg"
			property color overlayColor: colors.plugIconDisabled
		}
	}

	Timer {
		id: zwaveSmartplugEnableDelay
		interval: 1000
		onTriggered: {
			app.enableSmartplug();
		}
	}
}
