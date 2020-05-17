import QtQuick 2.1
import qb.components 1.0

Screen {
	id: zoneTemperaturePresetScreen
	screenTitleIconUrl: "drawables/Temperature.svg"
	screenTitle: qsTr("Presets")

	QtObject {
		id: p
		property bool fromAddWizard: false
		property bool fromAddWizardIntroSeen: false
		property var zoneUuids
	}

	onShown: {
		if (args && args.fromAddWizard)
			p.fromAddWizard = true;
		if (args && args.zoneUuids)
			p.zoneUuids = args.zoneUuids;

		if (p.fromAddWizard && p.fromAddWizardIntroSeen)
			addCustomTopRightButton(qsTr("Continue"));
	}

	onCustomButtonClicked: {
		if (p.fromAddWizard)
			stage.openFullscreen(app.programScreenUrl, {"fromAddWizard": true, "resetNavigation": true});
	}

	Rectangle {
		id: firstTimeOverlay
		anchors.fill: parent
		visible: (app.presetsFirstUse && !p.fromAddWizard)
				 || (p.fromAddWizard && !p.fromAddWizardIntroSeen)
				 || !app.strvDevicesList.length
		color: colors.canvas
		z: 1

		Text {
			id: overlayTitleText
			font.family: qfont.semiBold.name
			font.pixelSize: qfont.primaryImportantBodyText
			lineHeight: 0.8
			wrapMode: Text.WordWrap
			text: qsTr("Adjusting the temperature in your home has never been easier.")

			anchors {
				top: parent.top
				topMargin: Math.round(35 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(80 * horizontalScaling)
				right: overlayImage.left
				rightMargin: designElements.hMargin20
			}
		}

		Text {
			id: overlayBodyText
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			wrapMode: Text.WordWrap
			text: qsTr("Presets help you to adjust the temperature of your home with one click of a button.\n\nThese presets can later be used for your week schedule.")

			anchors {
				top: overlayTitleText.bottom
				topMargin: designElements.vMargin20
				left: overlayTitleText.left
				right: overlayTitleText.right
			}
		}

		Image {
			id: overlayImage
			source: "image://scaled/apps/strvSettings/drawables/presets-illustration.svg"

			anchors {
				bottom: parent.bottom
				bottomMargin: - designElements.bottomBarHeight
				right: parent.right
				rightMargin: Math.round(40 * horizontalScaling)
			}
		}

		StandardButton {
			id: startButton
			minWidth: Math.round(100 * horizontalScaling)
			text: p.fromAddWizard ? qsTr("Continue") : qsTr("Start")
			primary: true

			anchors {
				top: overlayBodyText.bottom
				topMargin: Math.round(30 * verticalScaling)
				left: overlayTitleText.left
			}

			onClicked: {
				app.presetsFirstUse = false;
				app.sendStrvSettingsAppConfig();
				if (parent.state === "not-available") {
					stage.openFullscreen(app.strvInstallIntroScreenUrl, {"resetNavigation": true});
				} else if (p.fromAddWizard) {
					stage.openFullscreen(app.editZonePresetScreenUrl, {
											 "preset": presetModel.get(0).presetName,
											 "zoneUuids": p.zoneUuids,
											 "fromAddWizard": p.fromAddWizard
										 });
					p.fromAddWizardIntroSeen = true;
				}
			}
		}

		states: [
			State {
				name: "not-available"
				when: app.strvDevicesList.length === 0
				PropertyChanges { target: overlayTitleText; text: qsTr("Your presets are not available yet") }
				PropertyChanges { target: overlayBodyText; text: qsTr("presets-unavailable-body") }
				PropertyChanges { target: startButton; text: qsTranslate("StrvFrame", "Install") }
			}
		]
	}

	ListModel {
		id: presetModel

		Component.onCompleted: {
			presetModel.append({presetName: "away",    icon: "image://scaled/apps/strvSettings/drawables/awayIcon.svg"});
			presetModel.append({presetName: "home",    icon: "image://scaled/apps/strvSettings/drawables/homeIcon.svg"});
			presetModel.append({presetName: "sleep",   icon: "image://scaled/apps/strvSettings/drawables/sleepIcon.svg"});
			presetModel.append({presetName: "comfort", icon: "image://scaled/apps/strvSettings/drawables/comfortIcon.svg"});
		}
	}

	Component {
		id: presetListDelegate
		Row {
			spacing: designElements.spacing6

			SingleLabel {
				width: presetList.width
				height: Math.round(35 * verticalScaling)
				leftText: app.presetNameToString(presetName)
				iconSource: icon

				onClicked: editButton.clicked()
			}

			IconButton {
				id: editButton
				iconSource: "qrc:/images/edit.svg"
				onClicked: {
					stage.openFullscreen(app.editZonePresetScreenUrl, {
											 "preset": model.presetName,
											 "zoneUuids": p.zoneUuids,
											 "fromAddWizard": p.fromAddWizard
										 });
				}
			}
		}
	}

	Text {
		id: titleText
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.primaryImportantBodyText
		wrapMode: Text.WordWrap
		text: qsTr("Adjust your preset temperatures")

		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			left: presetList.left
			right: presetList.right
		}
	}

	ListView {
		id: presetList
		anchors.centerIn: parent
		width: Math.round(538 * horizontalScaling)
		height: Math.round(200 * verticalScaling)
		spacing: designElements.spacing6

		model: presetModel
		delegate: presetListDelegate
		enabled: ! firstTimeOverlay.visible
		interactive: false
	}
}
