import QtQuick 2.1
import Weather 1.0
import qb.components 1.0

Screen {
	id: weatherScreen
	screenTitleIconUrl: "drawables/weather.svg"
	screenTitle: qsTr("Weather")

	property int currentDay: 0

	function updateCurrentDay() {
		currentDay = new Date().getDay();
	}

	onShown: updateCurrentDay()

	Connections {
		target: Weather
		onForecastChanged: updateCurrentDay()
	}

	Item {
		anchors {
			fill: parent
			topMargin: Math.round(24 * verticalScaling)
			rightMargin: Math.round(32 * horizontalScaling)
			bottomMargin: Math.round(36 * verticalScaling)
			leftMargin: Math.round(32 * horizontalScaling)
		}

		Rectangle {
			id: currentCard
			height: parent.height
			radius: designElements.radius
			color: colors.white

			anchors {
				top: parent.top
				left: parent.left
				right: parent.horizontalCenter
				rightMargin: Math.round(12 * horizontalScaling)
			}

			WeatherIcon {
				id: currentCardImage
				card: true
				sourceSize.width: parent.width

				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
				}

				WeatherIcon {
					id: currentCardIcon
					whiteOverlay: true
					sourceSize.width: Math.round(80 * horizontalScaling)

					anchors {
						left: parent.left
						leftMargin: Math.round(38 * horizontalScaling)
						bottom: parent.bottom
						bottomMargin: Math.round(30 * verticalScaling)
					}
				}
			}

			RadarImage {
				id: radarImage
				visible: globals.tenant === "Eneco"
				width: parent.width
				height: currentCardImage.height

				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
				}
			}

			Text {
				id: location
				text: Weather.cityName
				font.family: qfont.bold.name
				font.pixelSize: qfont.tileText
				color: colors.white

				anchors {
					left: parent.left
					leftMargin: radarImage.visible ? Math.round(10 * horizontalScaling) : Math.round(24 * horizontalScaling)
					top: parent.top
					topMargin: radarImage.visible ? Math.round(32 * verticalScaling) : Math.round(16 * verticalScaling)
				}
			}
			Image {
				id: editLocation
				source: "qrc:/images/edit"
				anchors.verticalCenter: location.verticalCenter
				anchors.left: location.right
				anchors.leftMargin: Math.round(18 * horizontalScaling)
			}
			MouseArea {
				onClicked: stage.openFullscreen(app.weatherSelectLocationScreenUrl)

				anchors {
					top: location.top
					right: editLocation.right
					bottom: location.bottom
					left: location.left
					margins: -Math.round(24 * horizontalScaling)
				}
			}

			Item {
				id: currentCardContent

				anchors {
					top: currentCardImage.bottom
					topMargin: Math.round(8 * verticalScaling)
					right: parent.right
					rightMargin: Math.round(24 * horizontalScaling)
					bottom: parent.bottom
					bottomMargin: anchors.topMargin
					left: parent.left
					leftMargin: anchors.rightMargin
				}

				Text {
					id: currentTemperature
					text: app.roundToHalf(Weather.temperature) + "°"
					font.family: qfont.regular.name
					font.pixelSize: qfont.timeAndTemperatureText

					anchors {
						left: parent.left
						verticalCenter: parent.verticalCenter
					}
				}

				Text {
					id: feelsLikeTemperature
					text: qsTr("Feels like") + "<br>" + app.roundToHalf(Weather.perceivedTemperature) + "°"
					font.family: qfont.semiBold.name
					font.pixelSize: qfont.bodyText
					color: colors._fantasia

					anchors {
						left: currentTemperature.right
						leftMargin: Math.round(12 * horizontalScaling)
						verticalCenter: parent.verticalCenter
					}
				}

				StandardButton {
					id: detailsButton
					text: qsTr("Details")
                    onClicked: stage.openFullscreen(app.weatherDetailsScreenUrl)

					anchors {
						right: parent.right
						verticalCenter: parent.verticalCenter
					}
				}
			}
		} // currentCard



		Rectangle {
			id: forecastCard
			height: parent.height
			radius: designElements.radius
			color: colors.white

			anchors {
				top: parent.top
				left: parent.horizontalCenter
				leftMargin: currentCard.anchors.rightMargin
				right: parent.right
			}

			Image {
				id: forecastPrecipitationIcon
				source: "image://scaled/apps/weather/drawables/Icon-Precipitation"
				sourceSize.width: Math.round(24 * horizontalScaling)
				anchors.top: parent.top
				anchors.topMargin: Math.round(14 * verticalScaling)
				anchors.horizontalCenter: parent.right
				anchors.horizontalCenterOffset: -Math.round(121 * horizontalScaling)
			}
			Image {
				id: forecastTempMinIcon
				source: "image://scaled/apps/weather/drawables/Icon-TempMin"
				sourceSize.width: Math.round(24 * horizontalScaling)
				anchors.verticalCenter: forecastPrecipitationIcon.verticalCenter
				anchors.horizontalCenter: parent.right
				anchors.horizontalCenterOffset: -Math.round(74 * horizontalScaling)
			}
			Image {
				id: forecastTempMaxIcon
				source: "image://scaled/apps/weather/drawables/Icon-TempMax"
				sourceSize.width: Math.round(24 * horizontalScaling)
				anchors.verticalCenter: forecastPrecipitationIcon.verticalCenter
				anchors.horizontalCenter: parent.right
				anchors.horizontalCenterOffset: -Math.round(27 * horizontalScaling)
			}

			ListView {
				id: forecastView
				spacing: Math.round(8 * verticalScaling)
				boundsBehavior: ListView.StopAtBounds
				anchors.fill: parent
				anchors.topMargin: Math.round(40 * verticalScaling)

				Component {
					id: forecastDelegate

					Item {
						width: forecastView.width
						height: Math.round(36 * verticalScaling)

						property int dayIndex: new Date(modelData.day * 1000).getDay()
						property string fontFamily: dayIndex == currentDay ? qfont.bold.name : qfont.semiBold.name
						property string fontColor: dayIndex == currentDay ? colors.black : colors._fantasia

						WeatherIcon {
							iconName: modelData.icon
							sourceSize.height: parent.height
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: Math.round(16 * horizontalScaling)
						}

						Text {
							text: dayIndex == currentDay ? qsTr("Today") : i18n.daysFull[dayIndex % 7]
							font.family: fontFamily
							font.pixelSize: qfont.bodyText
							color: fontColor
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: Math.round(64 * horizontalScaling)
						}

						Text {
							text: i18n.number(modelData.rainChance, 0) + "%"
							font.family: fontFamily
							font.pixelSize: qfont.bodyText
							color: fontColor
							anchors.verticalCenter: parent.verticalCenter
							anchors.horizontalCenter: parent.right
							anchors.horizontalCenterOffset: -Math.round(121 * horizontalScaling)
						}
						Text {
							text: i18n.number(modelData.minTemperature, 0) + "°"
							font.family: fontFamily
							font.pixelSize: qfont.bodyText
							color: fontColor
							anchors.verticalCenter: parent.verticalCenter
							anchors.horizontalCenter: parent.right
							anchors.horizontalCenterOffset: -Math.round(74 * horizontalScaling)
						}
						Text {
							text: i18n.number(modelData.maxTemperature, 0) + "°"
							font.family: fontFamily
							font.pixelSize: qfont.bodyText
							color: fontColor
							anchors.verticalCenter: parent.verticalCenter
							anchors.horizontalCenter: parent.right
							anchors.horizontalCenterOffset: -Math.round(27 * horizontalScaling)
						}
					}
				} // forecastDelegate

				model: Weather.forecast
				delegate: forecastDelegate
			}
		} // forecastCard
	}
}
