import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

import Feedback 1.0

Widget {
	id: screenFrame
	anchors.fill: parent

	onShown: {
		languageLabel.rightText = p.getLanguageName(canvas.locale);
	}

	QtObject {
		id: p

		function getTimeBerforeDimmingString() {
			var dimmingString;
			var timeBeforeDimmingInMinutes = screenStateController.timeBeforeDimmingInSec / 60;
			var timeBeforeDimmingInMinutesStr = i18n.number(timeBeforeDimmingInMinutes, 1, i18n.omit_trail_zeros);

			dimmingString = timeBeforeDimmingInMinutesStr + " " + ((timeBeforeDimmingInMinutes > 1.5) ? qsTr("minutes") : qsTr("minute"));
			return dimmingString;
		}

		function getScreenOffState() {
			if (screenStateController.screenOffIsProgramBased) {
				return app.enableSME ? qsTr("when closed or away") : qsTr("when sleeping or away");
			} else if (screenStateController.timeBeforeScreenOffInMin < 0) {
				return qsTr("never")
			} else if (screenStateController.timeBeforeScreenOffInMin > 0) {
				return qsTr("after one hour");
			} else {
				return qsTr("instead of dim");
			}
		}

		function getLanguageName(){
			return globals.languageList[canvas.locale];
		}
	}

	Column {
		id: labelsContainer
		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		Item {
			id: languageSettings
			width: parent.width
			height: childrenRect.height
			visible: feature.i18nLocales().length > 1

			SingleLabel {
				id: languageLabel
				anchors {
					left: parent.left
					right: languageButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Language")
			}

			IconButton {
				id: languageButton
				anchors.right: parent.right
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"

				onClicked: {
					stage.openFullscreen(app.languageScreenUrl);
				}
			}
		}

		Item {
			id: spacer
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: languageSettings.visible
		}

		Item {
			id: brightness
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: brightnessLabel
				leftText: qsTr("Brightness");
				rightText: (screenStateController.autoBrightnessControl ? qsTr("Automatic") : screenStateController.backLightValueScreenActive + "%") +
						   ", " + qsTr("dim mode after") + " "
						   + p.getTimeBerforeDimmingString();

				anchors {
					left: parent.left
					right: brightnessButton.left
					rightMargin: designElements.hMargin6
				}
			}

			IconButton {
				id: brightnessButton
				anchors.right: parent.right
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				bottomClickMargin: 2

				onClicked: {
					stage.openFullscreen(app.brightnessSetScrUrl);
				}
			}
		}

		Item {
			id: screenOff
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: screenOffLabel
				anchors {
					left: parent.left
					right: screenOffButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Screen off");
				rightText: p.getScreenOffState();
			}

			IconButton {
				id: screenOffButton
				anchors.right: parent.right
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				topClickMargin: 4
				bottomClickMargin: 4

				onClicked: {
					stage.openFullscreen(app.scrOffSettingScreenUrl);
				}
			}
		}

		Item {
			id: parentalControlItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: parentalControlLabel
				anchors {
					left: parent.left
					right: parentalControlBtn.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Parental Control")
				rightText: parentalControl.enabled ? qsTr("On") : qsTr("Off")
			}

			IconButton {
				id: parentalControlBtn
				width: designElements.buttonSize
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"
				topClickMargin: 4
				bottomClickMargin: 4

				onClicked: {
					stage.openFullscreen(app.parentalControlScreenUrl);
				}
			}
		}

		Item {
			id: spacer2
			width: parent.width
			height: Math.round(18 * verticalScaling)
		}

		Item {
			id: cleaningItem
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: cleaningLabel
				anchors {
					left: parent.left
					right: cleaningButton.left
					rightMargin: designElements.hMargin6
				}
				leftText: qsTr("Cleaning")
			}

			StandardButton {
				id: cleaningButton
				anchors.right: parent.right
				text: qsTr("Start")
				height: cleaningLabel.height
				topClickMargin: 2

				onClicked: {
					app.cleanLoadingPopup.show();
				}
			}
		}

		Item {
			id: spacer3
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: thermostatPanelLabel.visible
		}

		SingleLabel {
			id: thermostatPanelLabel
			width: parent.width
			leftText: qsTr("Thermostat panel")
			visible: (registry.getRegisteredWidgets("prominent").length > 0)

			OptionToggle {
				id: thermostatToggle
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
				}
				leftText: qsTr("Left")
				rightText: qsTr("Right")
				positionIsLeft: screenStateController.prominentWidgetLeft
				property bool isComplete : false

				onPositionIsLeftChanged: {
					screenStateController.prominentWidgetLeft = positionIsLeft;
					if (isComplete) {
						screenStateController.notifyChangeOfSettings();
					}
				}

				Component.onCompleted: {
					isComplete = true;
				}
			}
		}

		SingleLabel {
			id: feedbackLabel
			width: parent.width
			leftText: qsTr("Ask for my opinion")
			iconSource: "image://scaled/images/feedback-label.svg"

			OnOffToggle {
				id: feedbackToggle
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
				}
				useOnOffTexts: false
				leftText: qsTr("Never")
				rightText: qsTr("Please")
				isSwitchedOn: !FeedbackManager.optOut
				useBoldChangeForLeftRight: true

				onSelectedChangedByUser: {
					FeedbackManager.optOut = positionIsLeft;
					countly.sendEvent("Feedback.OptOut", null, null, -1, {"optOut": FeedbackManager.optOut});
				}
			}
		}

		Item {
			id: spacer4
			width: parent.width
			height: Math.round(18 * verticalScaling)
			visible: smeItem.visible
		}

		Item {
			id: smeItem
			width: parent.width
			height: childrenRect.height
			visible: feature.featSMEEnabled()

			SingleLabel {
				id: smeLabel
				anchors {
					left: parent.left
					right: smeButton.left
					rightMargin: Math.round(6 * horizontalScaling)
				}
				leftText: qsTr("Environment");
				rightText: app.enableSME ? qsTr("Business") : qsTr("Home")
			}

			IconButton {
				id: smeButton
				width: designElements.buttonSize
				iconSource: "qrc:/images/edit.svg"
				anchors.right: parent.right
				topClickMargin: 4
				bottomClickMargin: 4

				onClicked: {
					stage.openFullscreen(app.smeSetScreenUrl);
				}
			}
		}
	}
}
