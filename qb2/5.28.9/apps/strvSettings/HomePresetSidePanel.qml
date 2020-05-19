import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0;

Widget {
	id: homePresetSidePanel

	property string kpiPrefix: "HomePresetSidePanel."
	property StrvSettingsApp app

	property url sourceUrl: app.homePresetSidePanelUrl

	width: Math.round(248 * horizontalScaling)
	height: parent !== null ? parent.height : 0

	visible: globals.heatingMode === "zone"

	function generateInfoString(scheduleEnabled, curPresetUuid, trajectoryInfo) {
		if (!scheduleEnabled) {
			return qsTr("Always on %1").arg(app.presetUuidToString(curPresetUuid));
		} else if (trajectoryInfo.length === 0) {
			return "";
		} else if (trajectoryInfo[0].overrideType === "indefinite") {
			// If schedule is enabled but we still have a (lagging) overrideType of indefinite,
			return "";
		} else {
			return qsTr("At %1 set to %2").arg(formatTime(trajectoryInfo[1].startTime)).arg(app.presetUuidToString(trajectoryInfo[1].presetUUID));
		}
	}

	function formatTime(timeString) {
		var now = new Date();
		// Now + 24 hours - 1 minute = the threshold from displaying date only to displaying the time
		var nowPlus24hrsTimestamp = now.getTime() + 24 * 60 * 60 * 1000 - 60000;

		var transitionTime = qtUtils.fromISOString(timeString);

		if (transitionTime.getTime() > nowPlus24hrsTimestamp) {
			return i18n.dateTime(transitionTime, i18n.time_no | i18n.date_yes | i18n.year_no | i18n.mon_short);
		} else {
			return i18n.dateTime(transitionTime, i18n.time_yes | i18n.secs_no | i18n.hour_str_yes);
		}
	}

	Timer {
		id: updateTimer
		interval: 60000
		running: true
		repeat: true
		// Trigger signal every minute to update time formatting through generateInfoString() on infoPanelItem
		onTriggered: toggle.isSwitchedOnChanged()
	}

	Column {
		id: contentColumn
		visible: (! canvas.dimState)

		anchors.fill: parent
		anchors.margins: designElements.spacing6

		spacing: designElements.spacing6

		property real itemHeight: Math.floor((height - (children.length - 1) * spacing) / children.length)

		Item {
			id: infoPanelItem

			height: parent.itemHeight
			width: parent.width

			Text {
				id: infoText
				text: generateInfoString(toggle.isSwitchedOn, app.activePresetUUID, app.trajectory)
				wrapMode: Text.WordWrap

				color: colors.spText
				font {
					family: qfont.regular.name
					pixelSize: qfont.programText
				}

				anchors {
					left: parent.left
					leftMargin: designElements.hMargin6
					right: toggle.left
					rightMargin: designElements.hMargin6
					verticalCenter: parent.verticalCenter
				}
			}

			OnOffToggle {
				id: toggle

				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: designElements.hMargin6
				}

				topSpacing: Math.round(8 * verticalScaling)

				isSwitchedOn: app.scheduleEnabled
				positionIsLeft: true
				leftIsSwitchedOn: false
				mouseIsActiveInDimState: true

				onSelectedChangedByUser: app.sendScheduleEnabled(isSwitchedOn)
			}

			MouseArea {
				id: shortcutClickArea
				onClicked: stage.openFullscreen(app.programScreenUrl)
				anchors {
					top: parent.top
					left: parent.left
					right: toggle.left
					bottom: parent.bottom
				}
			}
		}

		PresetButton {
			presetName: "away"
			height: parent.itemHeight
			width: parent.width

			topLeftRadiusRatio: 1
			topRightRadiusRatio: 1

			text: qsTr("Away")
		}

		PresetButton {
			presetName: "home"
			height: parent.itemHeight
			width: parent.width

			text: qsTr("Active")
		}

		PresetButton {
			presetName: "sleep"
			height: parent.itemHeight
			width: parent.width

			text: qsTr("Sleep")
		}

		PresetButton {
			presetName: "comfort"
			height: parent.itemHeight
			width: parent.width

			bottomLeftRadiusRatio: 1
			bottomRightRadiusRatio: 1

			text: qsTr("Comfort")
		}
	}

	Column {
		id: dimContentColumn
		visible: canvas.dimState

		anchors {
			fill: parent
			topMargin: Math.round(20 * verticalScaling)
			bottomMargin: designElements.vMargin6
			leftMargin: designElements.hMargin6
			rightMargin: designElements.hMargin6
		}

		spacing: designElements.spacing6

		Row {
			id: iconRow

			Image {
				id: flameIcon
				source: app.heatingState ? "image://scaled/apps/strvSettings/drawables/ts-dim-3.svg" : "image://scaled/apps/strvSettings/drawables/ts-dim-off.svg"
				anchors {
					verticalCenter:   parent.verticalCenter
				}
			}
		}

		Text {
			id: stateText

			text: activePresetToString(app.activePresetUUID)
			width: parent.width

			color: colors.white
			font.family: qfont.regular.name
			font.pixelSize: qfont.timeAndTemperatureText
			fontSizeMode: Text.HorizontalFit

			function activePresetToString(presetUuid) {
				var presetString = app.presetUuidToString(presetUuid);
				if (typeof(presetString) === "undefined")
					return "Unknown";
				else
					return presetString;
			}
		}
	}

	StyledRectangle {
		id: panelInstallSTRV
		color: canvas.dimState ? colors.black : colors.contrastBackground
		radius: 4
		visible: (app.strvDevicesList.length === 0)

		anchors {
			top: parent.top
			topMargin: Math.round(-44 * verticalScaling)
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Column {
			anchors.fill: parent
			anchors.margins: spacing
			spacing: designElements.vMargin20

			Image {
				id: panelInstallSTRVIcon
				anchors.horizontalCenter: parent.horizontalCenter
				source: panelInstallSTRV.visible ? "image://scaled/apps/strvSettings/drawables/panelInstallSTRV.svg" : ""
				opacity: !canvas.dimState ? 1 : 0
			}

			Text {
				id: panelInstallText
				width: parent.width
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.spText
				wrapMode: Text.WordWrap
				text: qsTr("$(display) can't wait to make heating control easy for you. Let's install some smart radiator valves.")
			}

			StandardButton {
				id: panelInstallButton
				width: parent.width
				primary: true
				mouseIsActiveInDimState: true
				text: qsTr("Install")

				onClicked: {
					// When the button is pressed during dim state, don't
					// forget to wake up the screen again, otherwise the
					// screen will end up in an inconsistent state.
					screenStateController.wakeup()
					stage.openFullscreen(app.strvInstallIntroScreenUrl);
				}
			}
		}
	}
}
