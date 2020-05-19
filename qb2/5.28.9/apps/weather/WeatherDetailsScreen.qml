import QtQuick 2.11
import QtQuick.Layouts 1.3
import Weather 1.0
import qb.components 1.0
import qb.base 1.0

Screen {
    id: weatherDetailsScreen
	hasBackButton: true
    screenTitle: qsTr("Details about %1").arg(Weather.cityName)

	onShown: {
		updateWeatherDescription();
		updateWindDirection();
	}

	Connections {
		target: Weather
		onForecastChanged: updateWeatherDescription()
		onWindDirectionChanged: updateWindDirection()
	}

	function updateWeatherDescription() {
		weatherDescription.text = app.weatherDescriptions.hasOwnProperty(Weather.icon) ? app.weatherDescriptions[Weather.icon] : Weather.icon;
	}

	function updateWindDirection() {
		windDirection.text = app.windDirectionAbbreviations.hasOwnProperty(Weather.windDirection) ? app.windDirectionAbbreviations[Weather.windDirection] : Weather.windDirection;
	}

	Column {
		spacing: Math.round(8 * verticalScaling)

        anchors {
            fill: parent
            topMargin: Math.round(24 * verticalScaling)
			rightMargin: Math.round(42 * horizontalScaling)
			leftMargin: Math.round(42 * horizontalScaling)
        }

		Rectangle {
			id: weatherRow
            radius: designElements.radius
            color: colors._middlegrey
			width: parent.width
			height: Math.round(84 * verticalScaling)

			Row {
				spacing: Math.round(30 * horizontalScaling)
				anchors.fill: parent
				anchors.margins: Math.round(14 * horizontalScaling)

				Image {
					source: "image://scaled/apps/weather/drawables/Icon-Weather"
					sourceSize.height: parent.height
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Weather")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						id: weatherDescription
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("UV index")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: i18n.number(Weather.uvIndex, 0)
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Humidity")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: i18n.number(Weather.humidity, 0) + "%"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}
			}
		} // weatherRow

		Rectangle {
			id: temperatureRow
			radius: designElements.radius
			color: colors._middlegrey
			width: parent.width
			height: Math.round(84 * verticalScaling)

			Row {
				spacing: Math.round(30 * horizontalScaling)
				anchors.fill: parent
				anchors.margins: Math.round(14 * horizontalScaling)

				Image {
					source: "image://scaled/apps/weather/drawables/Icon-Temperature"
					sourceSize.height: parent.height
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Temperature")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: app.roundToHalf(Weather.temperature) + "°"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Perceived")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: app.roundToHalf(Weather.perceivedTemperature) + "°"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Minimum")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: app.roundToHalf(Weather.forecast[0].minTemperature) + "°"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Maximum")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: app.roundToHalf(Weather.forecast[0].maxTemperature) + "°"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}
			}
		} // temperatureRow

		Rectangle {
			id: windRow
			radius: designElements.radius
			color: colors._middlegrey
			width: parent.width
			height: Math.round(84 * verticalScaling)

			Row {
				spacing: Math.round(30 * horizontalScaling)
				anchors.fill: parent
				anchors.margins: Math.round(14 * horizontalScaling)

				Image {
					source: "image://scaled/apps/weather/drawables/Icon-Wind"
					sourceSize.height: parent.height
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Wind speed")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: qsTr("%1 km/h").arg(i18n.number(Weather.windSpeed, 0))
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Wind direction")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						id: windDirection
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}
			}
		} // windRow

		Rectangle {
			id: rainRow
			radius: designElements.radius
			color: colors._middlegrey
			width: parent.width
			height: Math.round(84 * verticalScaling)

			Row {
				spacing: Math.round(30 * horizontalScaling)
				anchors.fill: parent
				anchors.margins: Math.round(14 * horizontalScaling)

				Image {
					source: "image://scaled/apps/weather/drawables/Icon-Precipitation"
					sourceSize.height: parent.height
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Chance of rain")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: i18n.number(Weather.forecast[0].rainChance, 0) + "%"
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}

				Column {
					anchors.verticalCenter: parent.verticalCenter
					width: Math.round(120 * horizontalScaling)

					Text {
						text: qsTr("Precipitation")
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.titleText
					}

					Text {
						text: qsTr("%1 mm").arg(i18n.number(Weather.precipitation))
						font.family: qfont.semiBold.name
						font.pixelSize: qfont.titleText
						color: colors.black
					}
				}
			}
		} // rainRow
    }
}
