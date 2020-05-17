import QtQuick 2.0
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0

ContentScreen {
	screenTitle: qsTranslate("AddStrvWizardScreen", "Install smart radiator valves")
	title: qsTr("Mounting the valves to the radiator")
	imageSource: "drawables/add-mounting.svg"
	hasHomeButton: false

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Done"))
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.zoneTemperaturePresetScreenUrl, {"fromAddWizard": true, "zoneUuids": app.getZoneUuidsWithDevices(app.strvJustAddedUuids), "resetNavigation": true});
		app.strvJustAddedUuids = [];
	}

	GridLayout {
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		columns: 2
		rowSpacing: designElements.vMargin15
		columnSpacing: designElements.hMargin15

		Text {
			id: generalText
			Layout.columnSpan: 2
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.text
			text: qsTr("Check the  manual of the new valve or press <b>i</b>, for help.")
		}

		NumberBullet {
			color: "black"
			text: "1"
		}

		Text {
			id: stepOneText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.text
			text: qsTr("Remove the current radiator valve.")
		}

		NumberBullet {
			color: "black"
			text: "2"
		}

		Text {
			id: stepTwoText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.text
			text: qsTr("Choose the adapter that fits your radiator.")
		}

		NumberBullet {
			color: "black"
			text: "3"
		}

		Text {
			id: stepThreeText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.text
			text: qsTr("Mount the new valve on the radiator.")
		}

		NumberBullet {
			color: "black"
			text: "4"
		}

		Text {
			id: stepFourText
			Layout.fillWidth: true
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			wrapMode: Text.WordWrap
			color: colors.text
			text: qsTr("Repeat for all your valves.")
		}
	}

	IconButton {
		id: infoButton
		anchors {
			left: parent.left
			bottom: parent.bottom
		}
		iconSource: "qrc:/images/info.svg"

		onClicked: app.showMountInstructionsPopup()
	}

	Text {
		anchors {
			left: infoButton.right
			leftMargin: designElements.hMargin15
			verticalCenter: infoButton.verticalCenter
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.text
		text: qsTr("Need help? Check out these tips.")
	}
}
