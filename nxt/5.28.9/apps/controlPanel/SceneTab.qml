import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Widget {
	id: root
	anchors.fill: parent
	property url url

	onShown: {
		state = "normal";
		radioGroup.currentControlId = 0;
	}

	function init() {}

	function sceneSaved() {
		root.state = "saved";
		app.saveSceneResponseReceived.disconnect(sceneSaved);
	}

	Text {
		id: title
		text: qsTr("Change scenes")
		font {
			pixelSize: qfont.titleText
			family: qfont.semiBold.name
		}
		color: colors.plugTabTitle
		anchors {
			left: parent.left
			leftMargin: Math.round(56 * horizontalScaling)
			baseline: parent.top
			baselineOffset: Math.round(42 * verticalScaling)
		}
	}

	Text {
		id: infoLine1Text
		text: qsTr("Please choose the scene that you'd like to change.")
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		anchors {
			left: title.left
			baseline: title.baseline
			baselineOffset: Math.round(34 * verticalScaling)
		}
	}

	ControlGroup {
		id: radioGroup
		exclusive: true
	}

	Grid {
		id: radioGrid
		columns: 2

		anchors {
			top: infoLine1Text.baseline
			topMargin: Math.round(35 * verticalScaling)
			left: infoLine1Text.left
		}

		spacing: Math.round(20 * horizontalScaling)

		Repeater {
			model: 4
			Item {
				width: radioButton.width + Math.round(70 * horizontalScaling) + sceneRect.width
				height: sceneRect.height
				property string kpiPostfix: "scene" + index
				StandardRadioButton {
					id: radioButton
					controlGroupId: index
					controlGroup: radioGroup
					width: height
					anchors {
						left: parent.left
						verticalCenter: parent.verticalCenter
					}
				}
				StyledRectangle {
					id: sceneRect
					height: Math.round(50 * verticalScaling)
					width: Math.round(50 * horizontalScaling)
					anchors {
						left: radioButton.right
						leftMargin: designElements.hMargin15
						verticalCenter: radioButton.verticalCenter
					}
					radius: designElements.radius
					gradientStyle: StyledRectangle.TopLeftToBottomRight
					gradientColors: [app.gradientColorTL[index], app.gradientColorMiddle[index], app.gradientColorBR[index]]
					Text {
						id: sceneText
						anchors.centerIn: parent
						font {
							family: qfont.bold.name
							pixelSize: qfont.primaryImportantBodyText
						}
						color: colors.white
						text: index + 1
					}
				}
				MouseArea {
					anchors {
						left: radioButton.left
						leftMargin: Math.round(-10 * horizontalScaling)
						right: sceneRect.right
						rightMargin: anchors.leftMargin
						top: sceneRect.top
						topMargin: Math.round(-9 * verticalScaling)
						bottom: sceneRect.bottom
						bottomMargin: Math.round(-10 * verticalScaling)
					}
					onClicked: radioGroup.currentControlId = index
				}
			}
		}
	}

	Text {
		id: infoLine2Text
		text: qsTr("Change your lamps settings using your favorite Hue-app.")
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		anchors {
			left: title.left
			baseline: radioGrid.bottom
			baselineOffset: Math.round(60 * verticalScaling)
		}
	}
	Text {
		id: infoLine3Text
		text: qsTr("Then press Save.")
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		anchors {
			left: title.left
			baseline: infoLine2Text.baseline
			baselineOffset: Math.round(23 * verticalScaling)
		}
	}

	StandardButton {
		id: saveButton
		enabled: !feature.appControlPanelHueSceneSaveDisabled()
		text: qsTr("Save")
		anchors {
			left: title.left
			top: infoLine3Text.baseline
			topMargin: Math.round(25 * verticalScaling)
		}
		onClicked: {
			root.state = "saving";
			app.saveSceneResponseReceived.connect(sceneSaved);
			app.saveScene(radioGroup.currentControlId);
		}
	}

	Image {
		id: checkIcon
		anchors {
			verticalCenter: saveButton.verticalCenter
			left: saveButton.right
			leftMargin: designElements.hMargin15
		}
		visible: false
		source: "qrc:/images/good.svg"
		height: Math.round(24 * verticalScaling)
		sourceSize {
			width: 0
			height: height
		}
	}

	Throbber {
		id: throbber
		anchors {
			left: checkIcon.left
			verticalCenter: saveButton.verticalCenter
		}
		visible: false
	}

	Text {
		id: changeSucceededText
		anchors {
			left: throbber.right
			leftMargin: designElements.hMargin15
			verticalCenter: saveButton.verticalCenter
		}
		font {
			family: qfont.italic.name
			pixelSize: qfont.bodyText
		}
	}

	state: "normal"
	states: [
		State {
			name: "normal"
			PropertyChanges {
				target: throbber
				visible: false
			}
			PropertyChanges {
				target: changeSucceededText
				visible: false
			}
			PropertyChanges {
				target: checkIcon
				visible: false
			}
		},
		State {
			name: "saving"
			PropertyChanges {
				target: throbber
				visible: true
			}
			PropertyChanges {
				target: changeSucceededText
				visible: true
				anchors.left: throbber.right
			}
			PropertyChanges {
				target: checkIcon
				visible: false
			}
			StateChangeScript {
				name: "setTextOnSaving"
				script: changeSucceededText.text = qsTr("Scene %1 is being saved.").arg(radioGroup.currentControlId + 1)
			}
		},
		State {
			name: "saved"
			PropertyChanges {
				target: throbber
				visible: false
			}
			PropertyChanges {
				target: changeSucceededText
				visible: true
				anchors.left: checkIcon.right
			}
			PropertyChanges {
				target: checkIcon
				visible: true
			}
			StateChangeScript {
				name: "setTextOnSaved"
				script: changeSucceededText.text = qsTr("Saved scene %1.").arg(radioGroup.currentControlId + 1);
			}
		}
	]
}
