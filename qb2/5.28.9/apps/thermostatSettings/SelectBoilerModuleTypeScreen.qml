import QtQuick 2.1
import qb.base 1.0
import BasicUIControls 1.0;
import qb.components 1.0

Screen {
	id: selectBoilerModuleTypeScreen

	screenTitleIconUrl: ""
	screenTitle: qsTr("Select boiler module type")
	isSaveCancelDialog: false
	inNavigationStack: false

	property ThermostatSettingsApp app
	property int prevBoilerType: -1

	property variant boilerTypeScreenData : [
		{
			'iconUnselected' : "drawables/BoilerModuleOption01.svg",
			'iconSelected' : "drawables/BoilerModuleOption01Selected.svg",
			'name' : qsTr("Wired"),
			'explanation' : qsTr("Module that is connected to $(display) through wires."),
			'optionVisible' : globals.thermostatFeatures["FF_BoilerControl_Edge_approve"]
		}
	]

	function init() {
		for (var i = 0; i < boilerTypeScreenData.length; ++i) {
			boilerTypeModel.append(boilerTypeScreenData[i]);
		}
	}

	onShown: {
		// args should always be provided and contain the 'state'
		state = args.state;
		if (typeof(args.prevType) !== "undefined") {
			prevBoilerType = args.prevType;
		}

		selectBoilerModuleTypeScreen.addCustomTopRightButton(qsTr("Next"));
		selectBoilerModuleTypeScreen.disableCustomTopRightButton();
	}

	onCustomButtonClicked: {
		if (boilerTypeGroup.currentControlId === 1) {
			// TODO: Store selection for wireless boiler module
			stage.openFullscreen(app.addDeviceScreenUrl, {state: "wirelessBoilerModule"});
		} else {
			// TODO: Store selection for wired boiler module
			app.boilerModuleType = 1;
			hide();
		}
	}

	states: [
		State {
			name: "add"
		},
		State {
			name: "edit"
		}
	]

	Text {
		id: explanationTitle
		text: qsTr("What type of boiler module do you want to connect?")

		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
	}

	ControlGroup {
		id: boilerTypeGroup
		exclusive: true

		onCurrentControlIdChanged: {
			if (currentControlId !== -1) {
				selectBoilerModuleTypeScreen.enableCustomTopRightButton();
			}
		}
	}

	Column {
		id: boilerTypeGrid

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(100 * verticalScaling)
		}
		spacing: designElements.vMargin6

		Repeater {
			id: boilerTypeRepeater

			model: boilerTypeModel

			delegate: Row {
				id: buttonContainer
				spacing: designElements.hMargin6
				visible: optionVisible

				StandardRadioButton {
					id: radioButton
					width: height
					controlGroupId: index
					controlGroup: boilerTypeGroup
				}

				Rectangle {
					id: buttonRectangle
					width: Math.round(380 * horizontalScaling)
					height: Math.round(85 * verticalScaling)
					radius: designElements.radius

					MouseArea {
						anchors.fill: parent
						onClicked: {
							if (! radioButton.selected)
								radioButton.toggleSelected();
						}
					}

					Image {
						id: optionImage
						source: model.iconSelected
						anchors {
							verticalCenter: parent.verticalCenter
							left: parent.left
							leftMargin: Math.round(24 * horizontalScaling)
						}
					}

					Text {
						id: optionTitle
						text: model.name
						anchors {
							left: parent.left
							leftMargin: Math.round(100 * horizontalScaling)
							right: parent.right
							rightMargin: Math.round(16 * horizontalScaling)
							top: parent.top
							topMargin: designElements.vMargin10
						}
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.titleText
						}
					}

					Text {
						id: optionExplanation
						text: model.explanation
						wrapMode: Text.WordWrap
						anchors {
							left: optionTitle.left
							right: optionTitle.right
							top: optionTitle.bottom
							bottom: parent.bottom
						}
						font {
							family: qfont.regular.name
							pixelSize: qfont.bodyText
						}
					}
				}

			}
		}
	}

	ListModel {
		id: boilerTypeModel
	}
}
