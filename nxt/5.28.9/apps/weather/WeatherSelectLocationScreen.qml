import QtQuick 2.11
import QtQuick.Layouts 1.3
import Weather 1.0
import qb.components 1.0

Screen {
	id: weatherSelectLocationScreen
	hasCancelButton: true
	isSaveCancelDialog: true
	saveEnabled: false
	screenTitle: qsTr("Edit Location")

	property string cityName: Weather.cityName
	property string cityId: Weather.cityId

	function selectCity(model) {
		cityField.inputText = model.name;
		cityId = model.id;
		cityName = model.name;
		saveEnabled = true;
		citiesSearchModel.clear();
	}

	onSaved: {
		Weather.cityName = cityName;
		Weather.cityId = cityId;
		app.saveWeatherConfig();
		saveEnabled = false;
	}

	onShown: {
		cityField.prefilledText = Weather.cityName;
		cityField.selectFocusAll();
		citiesSearchModel.clear();
	}

	WeatherCitySelectionModel {
		id: citiesSearchModel
		locale: canvas.locale
	}

	Item {
		id: citySelection
		implicitWidth: cityField.width

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: designElements.vMargin15
		}

		EditTextLabel {
			id: cityField
			labelText: qsTr("City")
			placeholder: qsTr("Please type at least 3 characters")
			onInputEdited: {
				saveEnabled = false;
				citiesSearchModel.query = inputText;
			}
		}

		ListView {
			id: citiesListView
			property int itemHeight: Math.round(36 * verticalScaling)
			height: (itemHeight + spacing) * 3
			spacing: Math.round(2 * verticalScaling)
			boundsBehavior: ListView.StopAtBounds
			clip: true
			model: citiesSearchModel

			anchors {
				right: cityField.right
				left: cityField.left
				top: cityField.bottom
				topMargin: spacing
			}

			delegate: Rectangle {
				width: citiesListView.width
				height: citiesListView.itemHeight
				color: colors.weatherLocationBoxBackground
				radius: designElements.radius

				Text {
					text: model.name + (model.area ? " (" + model.area + ")" : "")
					font.pixelSize: qfont.metaText
					font.family: qfont.regular.name

					anchors {
						left: parent.left
						verticalCenter: parent.verticalCenter
						leftMargin: designElements.hMargin10
					}
				}

				MouseArea {
					anchors.fill: parent
					onClicked: selectCity(model)
				}
			}
		}
		ScrollBar {
			container: citiesListView
			laneColor: colors.white
			alwaysShow: false

			property int scrollSkip: citiesListView.itemHeight + citiesListView.spacing
			onNext:     citiesListView.contentY = Math.min(citiesListView.contentY + scrollSkip, citiesListView.contentHeight - citiesListView.height)
			onPrevious: citiesListView.contentY = Math.max(citiesListView.contentY - scrollSkip, 0)

			anchors {
				top: cityField.top
				bottom: citiesListView.bottom
				left: citiesListView.right
			}
		}
	}
}
