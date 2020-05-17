import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: zonePresetItem
	width: Math.round(145 * horizontalScaling)
	height: Math.round(160 * verticalScaling)

	property string preset
	property string zoneUuid

	Component.onCompleted: {
		updateDetails();
	}

	onPresetChanged: {
		if (zoneUuid)
			updateDetails();
	}

	function updateDetails() {
		var zoneInfo = app.getZoneByUuid(zoneUuid);

		zoneName.text = zoneInfo.name;

		var presets = zoneInfo.presetSetpoints;
		for (var i = 0; i < presets.length; ++i) {
			var curPreset = presets[i];
			if (curPreset.preset.name === zonePresetItem.preset)
				break;
		}

		temperatureSpinner.value     = curPreset.setpoint;
		temperatureSpinner.rangeMin  = app.getMinimumZoneTemperature(zoneUuid);
		temperatureSpinner.rangeMax  = app.getMaximumZoneTemperature(zoneUuid);
		temperatureSpinner.increment = app.getZoneStepValue(zoneUuid);
	}

	function ensureValueCommitted() {
		if (temperatureSpinner && !temperatureSpinner.valueCommitted) {
			temperatureSpinner.commitValue();
		}
	}

	Text {
		id: zoneName
		width: parent.width
		anchors.top: parent.top
		text: "(unknown)"
		elide: Text.ElideRight
		font.family: qfont.semiBold.name
		font.pixelSize: qfont.programText
	}

	RoundedRectangle {
		id: spacer
		width: parent.width
		height: Math.round(15 * verticalScaling)
		color: app.presetNameToColor(preset)
		bottomLeftRadiusRatio: 0
		bottomRightRadiusRatio: 0

		anchors {
			bottom: temperatureSpinner.top
			bottomMargin: designElements.vMargin5
		}
	}

	NumberSpinner {
		id: temperatureSpinner
		width: parent.width
		height: Math.round(105 * verticalScaling)
		anchors.bottom: parent.bottom

		topLeftRadiusRatio: 0
		topRightRadiusRatio: 0

		// Delay before updated value is sent
		pressingEndTime: 1000

		property bool valueCommitted: true
		onValueChanged: {
			valueCommitted = false;
		}

		function commitValue() {
			app.setZonePresetSetpoint(zoneUuid, preset, temperatureSpinner.value);
			valueCommitted = true;
		}

		onButtonReleased: {
			commitValue();
		}

		Component.onDestruction: {
			if (! valueCommitted) {
				commitValue();
			}
		}
	}
}
