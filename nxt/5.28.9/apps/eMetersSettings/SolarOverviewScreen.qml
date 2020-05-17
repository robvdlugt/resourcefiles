import QtQuick 2.1

import QtQuick 2.1

import BasicUIControls 1.0;
import qb.components 1.0

import "Constants.js" as Constants

Screen {
	id: selectSolarEMeterScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Overview Solar")
	isSaveCancelDialog: false
	anchors.fill: parent

	hasBackButton: false
	hasHomeButton: false
	hasCancelButton: true
	inNavigationStack: true

	property EMetersSettingsApp app

	onShown: {
		p.deviceUuid = (app.solarWizardUuid !== undefined) ? (app.solarWizardUuid) : "";

		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Save"));
		// Disable if we don't have the right details filled in...
		if (p.deviceUuid === "") {
			disableCustomTopRightButton();
		}
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCustomButtonClicked: {
		// Open the screen that will write the configuration
		stage.openFullscreenInner(app.solarWriteConfigurationScreenUrl, null, false);
	}

	QtObject {
		id: p

		property string deviceUuid: ""
	}


	Text {
		id: explanationText
		text: qsTr("Overview of the solar configuration")

		wrapMode: Text.WordWrap

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(130 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(160 * horizontalScaling)
		}
	}

	Text {
		id: energyMeterTitle
		text: qsTr("Energy meter %1").arg(1)

		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}

		anchors {
			top: explanationText.bottom
			topMargin: designElements.vMargin20
			left:  explanationText.left
			right: explanationText.right
		}
	}

	SingleLabel {
		id: energyMeterDetails
		leftText: app.getDeviceSerialNumber(p.deviceUuid)
		// Perform an OR with the Int for device info, to indicate that solar is installed
		// E.g. 00000111b = 7 -> gas and electricity and solar

		// Added condition on p.deviceUuid, to prevent warning message during construction.
		// (No uuid -> no status int -> no status string)
		rightText: (p.deviceUuid == "") ? "" : app.getMaConfigurationStatusString(Constants.CONFIG_STATUS.SOLAR | app.getInformationSourceStatusInt(p.deviceUuid))
		rightTextFont: qfont.light.name
		rightTextSize: qfont.bodyText

		anchors {
			top: energyMeterTitle.baseline
			topMargin: designElements.vMargin10
			left:  explanationText.left
			right: explanationText.right
		}
	}

	Text {
		id: sensorDetailsTitle
		text: qsTr("Solar meter")

		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}

		anchors {
			top: energyMeterDetails.bottom
			topMargin: Math.round(40 * verticalScaling)
			left:  explanationText.left
			right: explanationText.right
		}
	}

	Column {
		anchors {
			top: sensorDetailsTitle.baseline
			topMargin: designElements.vMargin10
			left:  explanationText.left
			right: explanationText.right
		}
		spacing: designElements.vMargin6

		SingleLabel {
			id: sensorDetailsType
			width: parent.width
			leftText: qsTr("Solar kWh meter")
			rightText: qsTr("Pulse")
			rightTextFont: qfont.light.name
			rightTextSize: qfont.bodyText
		}

		Item {
			width: parent.width
			height: childrenRect.height
			visible: sensorDetailsCValue.rightText.length ? true : false

			SingleLabel {
				id: sensorDetailsCValue
				anchors {
					left: parent.left
					right: sensorDetailsCValueButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Value")
				rightText: app.solarWizardDividerType >= 0 ? app.getDividerString("solar", app.solarWizardDividerType, app.solarWizardDivider, true) : ""
				rightTextFont: qfont.light.name
				rightTextSize: qfont.bodyText
			}

			IconButton {
				id: sensorDetailsCValueButton
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"

				onClicked: {
					stage.openFullscreen(app.eMeterIndicationScreenUrl, {from: "solarwizard", resource: "solar", uuid: p.deviceUuid, editing: true});
				}
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: sensorDetailsEstimate
				anchors {
					left: parent.left
					right: sensorDetailsEstimateButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Estimated generation")
				rightText: "%1 %2".arg(app.solarWizardEstimatedGeneration).arg(qsTranslate("EMeterFrame", "kWh per year"))
				rightTextFont: qfont.light.name
				rightTextSize: qfont.bodyText
			}

			IconButton {
				id: sensorDetailsEstimateButton
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"

				onClicked: {
					stage.openFullscreen(app.estimatedGenerationScreenUrl, {from: "solarwizard", editing: true});
				}
			}
		}
	}
}
