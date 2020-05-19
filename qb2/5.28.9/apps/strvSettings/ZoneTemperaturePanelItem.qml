import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

RoundedRectangle {
	id: zoneTemperaturePanelItem
	color: colors.white

	property string zoneUuid: uuid

	property string name: ""
	property string temperatureString: ""
	property string setpointString: ""

	property real currentPresetTemperature: 0
	property bool notConnected: false
	property bool hasLowBattery: false

	Component.onCompleted: {
		init();
		updateDetails(true);
	}

	// Note: this function will not be called implicitely on Item instantiation. That's
	// why it needs to be called from Component.onCompleted().
	function init() {
		zoneTempSpinner.rangeMin = app.getMinimumZoneTemperature(zoneUuid);
		zoneTempSpinner.rangeMax = app.getMaximumZoneTemperature(zoneUuid);
		zoneTempSpinner.increment = app.getZoneStepValue(zoneUuid);

		zoneTempSpinner.buttonReleased.connect(onSetpointChanged);
	}

	function onSetpointChanged() {
		app.setZoneSetpoint(zoneUuid, zoneTempSpinner.value);
	}

	Connections {
		target: app
		onZoneListChanged: updateDetails()
		onActivePresetUUIDChanged: updateDetails()
		onStrvDevicesListChanged: updateDetails(true)
	}

	function updateDetails(devicesUpdated) {
		var curZone = app.getZoneByUuid(zoneUuid);
		if (typeof(curZone) !== "undefined") {
			// Update name, temperature and setpoint.
			name = curZone.name;

			// If we haven't received a temperature yet (due to reboot), then
			// show a '-' until we do.
			var temperature = curZone.temperature;
			if (typeof(temperature) === "undefined" || temperature === null) {
				temperatureString = "-";
			} else {
				temperatureString = i18n.number(temperature, 1) + "°";
			}

			var setpoint = curZone.setpoint;
			if (typeof(setpoint) === "undefined" || setpoint === null) {
				zoneTempSpinner.value = NaN;
				zoneTempSpinner.enabled = false;
			} else if (! zoneTempSpinner.inProgress) {
				zoneTempSpinner.value = setpoint;
				zoneTempSpinner.enabled = true;
			}

			if (devicesUpdated) {
				var device, _hasLowBattery = false, _notConnected = false;
				for(var devIdx in curZone.devices) {
					if((device = app.getDeviceByUuid(curZone.devices[devIdx].uuid)) !== undefined) {
						if (device.batteryLevel !== null && device.batteryLevel <= app._STRV_LOW_BATTERY_THRESHOLD) {
							_hasLowBattery = true;
						}
						// for now only one device per zone is supported
						if (device.hasCommunicationError) {
							_notConnected = true;
							_hasLowBattery = false;
						}
					}
				}
				notConnected = _notConnected;
				hasLowBattery = _hasLowBattery;
			}
		}

		var tmpCurrentPresetTemperature = app.getCurrentPresetTemperatureForZone(zoneUuid);
		if (tmpCurrentPresetTemperature !== undefined) {
			currentPresetTemperature = tmpCurrentPresetTemperature;
		}
	}

	Image {
		id: batteryIcon
		anchors {
			left: parent.left
			leftMargin: designElements.hMargin6
			verticalCenter: nameText.verticalCenter
		}
		sourceSize.height: Math.round(16 * verticalScaling)
		source: "image://scaled/images/battery-"
				+ (hasLowBattery ? "low" : "unknown") +".svg"
		visible: hasLowBattery || notConnected

		MouseArea {
			id: batteryIconMouseArea
			enabled: notConnected
			anchors {
				fill: parent
				margins: Math.round(-10 * horizontalScaling)
			}
			onClicked: {
				stage.openFullscreen(app.overviewHeatingScreenUrl);
			}
		}
	}

	Text {
		id: nameText
		text: name
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.bodyText
		color: notConnected ? colors.spTextDisabled : colors.spText
		textFormat: Text.PlainText
		elide: Text.ElideRight

		anchors {
			left: batteryIcon.visible ? batteryIcon.right : parent.left
			leftMargin: designElements.hMargin6
			baseline: parent.top
			baselineOffset: Math.round(32 * verticalScaling)
			right: parent.right
			rightMargin: zoneTempSpinner.buttonWidth + designElements.hMargin15
		}
	}

	Text {
		id: nameSuffixText
		text: "*"
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.bodyText
		color: colors.strvOverrideNotifyColor
		visible: currentPresetTemperature !== zoneTempSpinner.value

		anchors {
			left: nameText.left
			leftMargin: nameText.paintedWidth
			verticalCenter: nameText.verticalCenter
		}
	}

	Text {
		id: temperatureText
		text: temperatureString

		font.family: qfont.semiBold.name
		font.pixelSize: qfont.titleText
		color: colors._pressed

		anchors {
			left: batteryIcon.left
			baseline: zoneTempSpinner.top
			baselineOffset: zoneTempSpinner.textBaseline
		}
	}

	NumberSpinner {
		id: zoneTempSpinner

		width: Math.round(132 * horizontalScaling)
		// Make sure we have visually square buttons
		buttonWidth: (upField.height * designElements.pixelAspectRatio)

		rangeMin: 6.0
		rangeMax: 30.0
		increment: 0.5
		valueSuffix: "°"

		textBaseline: Math.round(77 * verticalScaling)

		upIconSource: "qrc:/images/numberSpinner_plus.svg"
		downIconSource: "qrc:/images/numberSpinner_minus.svg"

		upField.topLeftRadiusRatio: 1.0
		downField.bottomLeftRadiusRatio: 1.0

		backgroundColor: colors.none
		backgroundColorButtonsUp: colors.contrastBackground
		backgroundColorButtonsDown: colors._pressed
		overlayColorButtonsDown: colors.white

		disableButtonAtMaximum: true
		disableButtonAtMinimum: true

		// Delay before updated value is sent
		pressingEndTime: 1000

		anchors {
			right: parent.right
			rightMargin: designElements.hMargin6
			top: parent.top
			topMargin: designElements.vMargin6
			bottom: parent.bottom
			bottomMargin: designElements.vMargin6
		}
	}

	Image {
		id: setPointIcon
		source: getTriangleIcon(zoneTempSpinner.value, app.zoneList)

		function getTriangleIcon(spinnerValue, zoneList) {
			var curZone = app.getZoneByUuid(zoneUuid);
			if (typeof(zoneList) === "undefined" ||
				typeof(curZone) === "undefined" ||
				typeof(curZone.temperature) === "undefined") {
				return "image://scaled/images/triangle_right.svg";
			}

			// The stepsize for the setpoint is by 0.5 degrees.
			// Let's round here to the nearest 0.5 degrees to indicate
			// when the setpoint and temperature are about equal.
			if (Math.abs(spinnerValue - curZone.temperature) < 0.24) {
				return "image://scaled/images/triangle_right.svg"
			} else if (spinnerValue < curZone.temperature) {
				return "image://scaled/images/triangle_down.svg";
			} else {
				return "image://scaled/images/triangle_up.svg";
			}
		}

		anchors {
			top: zoneTempSpinner.top
			topMargin: Math.round(60 * verticalScaling)
			right: zoneTempSpinner.left
			rightMargin: designElements.hMargin6
		}
	}

	states: [
		State {
			name: "collapsed"
			when: !selected
			PropertyChanges { target: nameText; anchors.rightMargin: designElements.hMargin15 }
			AnchorChanges{ target: nameText; anchors.right: setPointIcon.left }
			PropertyChanges { target: zoneTemperaturePanelItem; height: Math.round(52 * verticalScaling) }
			PropertyChanges { target: zoneTempSpinner; visible: false }
			PropertyChanges {
				target: temperatureText
				text: zoneTempSpinner.valueToText(zoneTempSpinner.value)
				color: colors.spText
				font.pixelSize: qfont.navigationTitle
				anchors.rightMargin: nameText.anchors.leftMargin
			}
			AnchorChanges {
				target: temperatureText
				anchors.left: undefined
				anchors.right: parent.right
				anchors.baseline: undefined
				anchors.verticalCenter: parent.verticalCenter
			}
			PropertyChanges {
				target: setPointIcon
				anchors.rightMargin: Math.round(55 * horizontalScaling)
			}
			AnchorChanges {
				target: setPointIcon
				anchors.top: undefined
				anchors.right: temperatureText.right
				anchors.verticalCenter: parent.verticalCenter
			}
		},
		State {
			name: "expanded"
			when: selected
			PropertyChanges { target: zoneTempSpinner; visible: true }
		}

	]
}
