import QtQuick 2.1
import qb.components 1.0

/// Main screen of the Thermostat application showing thermostat modes and set values.

Screen {
	id: thermostatScreen

	screenTitleIconUrl: "drawables/Temperature.svg"
	screenTitle: qsTr("Temperature presets")

	onHidden: {
		app.updateTemperaturePreset({'thermStateRelax': modeComfort.temperature,
									 'thermStateActive': modeHome.temperature,
									 'thermStateSleep': modeSleep.temperature,
									 'thermStateAway': modeAway.temperature
									});
	}

	onShown: {
		modeComfort.temperature = app.thermStates.thermStateRelax.temperature;
		modeHome.temperature = app.thermStates.thermStateActive.temperature;
		modeSleep.temperature = app.thermStates.thermStateSleep.temperature;
		modeAway.temperature = app.thermStates.thermStateAway.temperature;
	}

	Grid {
		id: modesWrap
		anchors {
			top: parent.top
			topMargin: Math.round(54 * horizontalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		columns: 2
		spacing: designElements.hMargin20

		TemperatureModeSet {
			id: modeAway
			label: app.thermStateName[app.thermStateAway]
			color: app.thermStateColor[app.thermStateAway]
			temperature: app.thermStates.thermStateAway.temperature
			maxEcoTemperature: app.thermStateMaxEcoTemperature[app.thermStateAway]
		}

		TemperatureModeSet {
			id: modeHome
			label: app.thermStateName[app.thermStateActive]
			color: app.thermStateColor[app.thermStateActive]
			temperature: app.thermStates.thermStateActive.temperature
			maxEcoTemperature: app.thermStateMaxEcoTemperature[app.thermStateActive]
		}

		TemperatureModeSet {
			id: modeSleep
			label: app.thermStateName[app.thermStateSleep]
			color: app.thermStateColor[app.thermStateSleep]
			temperature: app.thermStates.thermStateSleep.temperature
			maxEcoTemperature: app.thermStateMaxEcoTemperature[app.thermStateSleep]
		}

		TemperatureModeSet {
			id: modeComfort
			label: app.thermStateName[app.thermStateRelax]
			color: app.thermStateColor[app.thermStateRelax]
			temperature: app.thermStates.thermStateRelax.temperature
			maxEcoTemperature: app.thermStateMaxEcoTemperature[app.thermStateRelax]
		}
	}



	Text {
		id: infoText
		anchors {
			top: modesWrap.bottom
			topMargin: modesWrap.spacing
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family:qfont.regular.name
			pixelSize: qfont.metaText
		}
		color: colors.tpInfoLabel
		horizontalAlignment: Text.AlignHCenter
		text: qsTr("You can set four temperature settings.<br>If you change the temperature, it also changes in the weekly program.")
	}
}
