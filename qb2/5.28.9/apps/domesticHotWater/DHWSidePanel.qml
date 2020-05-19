import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

Widget {
	id: dhwSidePanel

	property string kpiPrefix: "DhwSidePanel."
	property DomesticHotWaterApp app

	property url sourceUrl: app.sidePanelUrl

	property bool dhwNoError: (app.dhwState !== app._DHW_STATE_ERROR && app.dhwState !== app._DHW_STATE_UNKNOWN)

	width: Math.round(248 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	function init() {
	}

	Rectangle {
		id: stateRectangle

		height: Math.round(114 * verticalScaling)
		radius: designElements.radius

		anchors {
			top: parent.top
			topMargin: Math.round(8 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(8 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}

		Text {
			id: stateText
			text: valueToText(app.dhwState, dhwSidePanel.state)

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: Math.round(14 * verticalScaling)
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.spinnerText
			}
			color: colors.numberSpinnerNumber

			function valueToText(value) {
				switch (value) {
				case app._DHW_STATE_OFF:
				case app._DHW_STATE_ON:
					return app.stateName[value];
				case app._DHW_STATE_UNKNOWN:
					return qsTr("Unknown");
				case app._DHW_STATE_ERROR:
				default:
					return qsTr("Error");
				}
			}
		}

		Text {
			id: subText
			text: valueToText(app.dhwState, app.nextWeeklyScheduledOffString)

			function valueToText(dhwState, nextWeeklyScheduledOffString) {
				var retText = "";

				if (dhwState === app._DHW_STATE_ON) {
					if (app.curWeeklyScheduleState === 1) {
						retText = nextWeeklyScheduledOffString;
					}
					if (app.dhwAbsoluteEntries.length !== 0) {
						var curTime = (new Date).getTime();
						if (curTime < app.dhwAbsoluteEntries[0].startDateTime.getTime()) {
							var boostStartTime = app.formatTime(app.dhwAbsoluteEntries[0].startDateTime.getHours(),
																app.dhwAbsoluteEntries[0].startDateTime.getMinutes());
							var boostEndTime   = app.formatTime(app.dhwAbsoluteEntries[0].endDateTime.getHours(),
																app.dhwAbsoluteEntries[0].endDateTime.getMinutes());
							retText = qsTr("Boosting %1-%2").arg(boostStartTime).arg(boostEndTime);
						} else {
							boostEndTime = app.formatTime(app.dhwAbsoluteEntries[0].endDateTime.getHours(),
														  app.dhwAbsoluteEntries[0].endDateTime.getMinutes());
							retText = qsTr("Boosting until %1").arg(boostEndTime);
						}
					}
				}
				return retText;
			}

			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.spText
			wrapMode: Text.WordWrap
			maximumLineCount: 2
			horizontalAlignment: Text.AlignHCenter

			anchors {
				left: parent.left
				leftMargin: designElements.hMargin6
				right: parent.right
				rightMargin: designElements.hMargin6
				top: stateText.bottom
				topMargin: designElements.vMargin6
			}
		}
	}

	Item {
		id: rectStateInfo
		width: parent.width
		height: Math.round(56 * verticalScaling)
		anchors {
			top: stateRectangle.bottom
			topMargin: 4
			left: parent.left
			leftMargin: Math.round(8 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}

		MouseArea {
			property string kpiPostfix: "programLine." + rectStateInfo.state
			anchors.fill: parent
			enabled: dhwNoError
			onClicked: {
				// Open the thermostatProgramScreen with tab 1 (DHW) selected
				stage.openFullscreen(Qt.resolvedUrl("qrc:/apps/thermostat/ThermostatProgramScreen.qml"), {openTabIndex: 1});
			}
		}

		Text {
			id: dhwStateInfoText
			visible: dhwNoError
			anchors {
				left: parent.left
				leftMargin: Math.round(8 * verticalScaling)
				right: toggle.left
				rightMargin: anchors.leftMargin
				verticalCenter: parent.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.programText
			}
			color: colors.spText
			wrapMode: Text.WordWrap
			text: app.dhwProgramEnabled ? app.nextWeeklyScheduledOnString : qsTr("No program")
		}

		OnOffToggle {
			id: toggle
			visible: dhwNoError

			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right

			fontFamily: qfont.semiBold.name
			fontPixelSize: qfont.titleText
			fontColor: colors.spText
			topSpacing: Math.round(8 * verticalScaling)

			isSwitchedOn: app.dhwProgramEnabled
			positionIsLeft: true
			leftIsSwitchedOn: false
			mouseIsActiveInDimState: true

			onSelectedChangedByUser: {
				// Send DHW program state on switch and clear absolute (boost) entries
				app.patchDHWSchedule({active:isSwitchedOn, absoluteEntries: []});
			}
		}
	}

	StandardButton {
		id: addBoostButton
		height: Math.round(65 * verticalScaling)
		radius: designElements.radius
		enabled: dhwNoError

		colorUp: colors.tempTileBackgroundUp
		fontColorUp: colors.tempTileTextUp
		colorDisabled: colors.tempTileBackgroundDown

		anchors {
			top: rectStateInfo.bottom
			topMargin: 4
			left: parent.left
			leftMargin: Math.round(8 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}

		text: qsTr("Boost +1h")

		onClicked: {
			app.addBoostPeriod();
		}
	}

	StandardButton {
		id: cancelBoostButton
		height: Math.round(65 * verticalScaling)
		radius: designElements.radius
		enabled: (app.dhwAbsoluteEntries.length !== 0) && dhwNoError

		colorUp: colors.tempTileBackgroundUp
		fontColorUp: colors.tempTileTextUp
		colorDisabled: colors.tempTileBackgroundDown

		anchors {
			top: addBoostButton.bottom
			topMargin: 4
			left: parent.left
			leftMargin: Math.round(8 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}

		text: qsTr("Cancel boost")

		onClicked: {
			// Clear absolute (boost) entries
			app.patchDHWSchedule({absoluteEntries: []});
		}
	}
}
