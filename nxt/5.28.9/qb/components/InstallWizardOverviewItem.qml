import QtQuick 2.1

import qb.base 1.0;
import qb.components 1.0

/**
 * And overview item consists of two parts: the always visibile "big" block,
 * and a smaller secondary block. Both blocks can have an icon and an
 * optional button.
 */
Widget {

	id: overviewItem

	property int weight

	height: childrenRect.height
	width: childrenRect.width

	property string buttonText: primaryCompleted ? qsTr("Change") : qsTr("Start")
	property bool primaryCompleted: false
	property bool primaryButtonEnabled: true
	property bool primaryButtonVisible: true
	property bool primaryContainerVisible: true
	property url  primaryContainerIcon: primaryWarningVisible ?"qrc:/images/bad.svg"  : "qrc:/images/good.svg"
	property bool primaryIconVisible: primaryCompleted || primaryWarningVisible
	property bool primaryWarningVisible: false

	property string title: "Placeholder"
	property string extra: "Placeholder"
	property string secondary: "Placeholder"

	property url wizardUrl: ""
	property url secondaryWizardUrl: ""

	property color mainColor: "white"
	property color secondaryColor: "white"

	property string secondaryButtonText: secondaryCompleted ? qsTr("Change") : qsTr("Start")
	property bool secondaryCompleted: false
	property bool secondaryContainerVisible: primaryCompleted
	property bool secondaryButtonVisible: ! secondaryCompleted
	property bool secondaryButtonEnabled: true
	property url  secondaryContainerIcon: secondaryWarningVisible ?"qrc:/images/bad.svg"  : "qrc:/images/good.svg"
	property bool secondaryIconVisible: secondaryCompleted || secondaryWarningVisible
	property bool secondaryWarningVisible: false

	property variant detailsList: []

	property string primaryFeature: ""
	property string secondaryFeature: ""
	property bool skipButtonVisibility: !isNxt

	signal wizardStateUpdated

	signal beforePrimaryWizardOpened
	signal primaryWizardOpened
	signal beforeSecondaryWizardOpened
	signal secondaryWizardOpened

	Connections {
		target: wizardstate
		onStageCompletedChanged: {
			updateStageCompleted();
		}
	}

	function updateStageCompleted() {
		if (primaryCompleted !== wizardstate.stageCompleted(primaryFeature)) {
			primaryCompleted = wizardstate.stageCompleted(primaryFeature)
		}

		if (secondaryCompleted !== wizardstate.stageCompleted(secondaryFeature)) {
			secondaryCompleted = wizardstate.stageCompleted(secondaryFeature)
		}
		// Emit signal so derived classes can react to the update as well
		wizardStateUpdated();
	}

	onPrimaryFeatureChanged:   { updateStageCompleted() }
	onSecondaryFeatureChanged: { updateStageCompleted() }

	Column {

		spacing: designElements.vMargin5

		Rectangle {
			id: container
			property double titleHeight:       (! titleText.visible)   ? 0 :   titleText.height +   titleText.anchors.topMargin +   titleText.anchors.bottomMargin
			property double statusTableHeight: (! statusTable.visible) ? 0 : statusTable.height + statusTable.anchors.topMargin + statusTable.anchors.bottomMargin
			property double extraTextHeight:   (! extraText.visible)   ? 0 :   extraText.height +   extraText.anchors.topMargin +   extraText.anchors.bottomMargin
			property double combinedTextHeight: titleHeight + statusTableHeight + extraTextHeight

			// Start button is top aligned with titleText, so we use its topmargin (with regard to the container)
			property double startButtonHeight: (! start.visible) ? 0 : start.height + (2 * titleText.anchors.topMargin)

			height: Math.max(combinedTextHeight, startButtonHeight)
			width: 620 * horizontalScaling
			radius: designElements.radius
			color: mainColor
			visible: primaryContainerVisible


			Image {
				id: icon
				anchors {
					left: parent.left
					leftMargin: designElements.hMargin20
					top: titleText.top
				}
				source: primaryContainerIcon
				width: designElements.statusIconSize
				visible: primaryIconVisible
				fillMode: Image.PreserveAspectFit
			}

			Text {
				id: titleText
				color: "white"
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.bodyText
				}

				anchors {
					left: icon.right
					leftMargin: designElements.hMargin20
					top: parent.top
					topMargin: designElements.vMargin10
					bottomMargin: designElements.vMargin10
				}

				text: title
			}

			Component {
				id: dataRowDelegate
				Row {
					spacing: designElements.hMargin5
					Text {
						text: modelData[0]
						width: 150 * horizontalScaling
						color: "white"
						font {
							family: qfont.regular.name
							pixelSize: qfont.metaText
						}
					}
					Text {
						text: modelData[1]
						color: "white"
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.metaText
						}
						elide: Text.ElideRight
					}
				}
			}

			Column {
				id: statusTable
				anchors {
					left: titleText.left
					right: parent.right
					top: titleText.bottom
				}

				Repeater {
					model: overviewItem.detailsList
					delegate: dataRowDelegate
				}
				visible: (overviewItem.detailsList.length !== 0)
			}

			Text {
				id: extraText
				color: "white"
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				elide: Text.ElideRight

				anchors {
					top: statusTable.bottom
					//topMargin: designElements.vMargin5
					left: titleText.left
					//bottomMargin: designElements.vMargin5
				}
				text: extra
				visible: (text !== "")
			}

			StandardButton {
				id: start
				text: buttonText
				anchors.top: titleText.top
				anchors.right: parent.right
				anchors.rightMargin: designElements.hMargin10
				visible: primaryButtonVisible
				enabled: primaryButtonEnabled
				onClicked: {
					beforePrimaryWizardOpened();
					stage.colorizeTopBar(mainColor, "white");
					stage.openFullscreen(wizardUrl);
					primaryWizardOpened();
				}
			}
		}

		Rectangle {

			id: secondaryContainer
			height: (!visible) ? 0 : designElements.vMargin24 + secondaryContainerText.height
			radius: designElements.radius
			color: secondaryColor
			anchors.left: container.left
			anchors.leftMargin: 50
			anchors.right: container.right
			visible: secondaryContainerVisible

			Image {
				id: secondaryIcon
				anchors {
					left: parent.left
					leftMargin: designElements.hMargin20
					top: parent.top
					topMargin: designElements.vMargin5
				}
				source: secondaryContainerIcon
				width: designElements.statusIconSize
				visible: secondaryIconVisible
				fillMode: Image.PreserveAspectFit
			}

			Text {
				id: secondaryContainerText
				color: "white"
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				elide: Text.ElideRight

				anchors {
					left: secondaryIcon.right
					leftMargin: designElements.hMargin20
					right: secondaryButton.left
					rightMargin: designElements.hMargin10
					top: parent.top
					topMargin: designElements.vMargin10
				}

				text: secondary
			}

			StandardButton {
				id: secondaryButton
				text: secondaryButtonText
				anchors.verticalCenter: parent.verticalCenter
				anchors.right: parent.right
				anchors.rightMargin: designElements.hMargin10
				visible: secondaryButtonVisible
				enabled: secondaryButtonEnabled
				onClicked: {
					beforeSecondaryWizardOpened();
					stage.colorizeTopBar(mainColor, "white");
					stage.openFullscreen(secondaryWizardUrl);
					secondaryWizardOpened();
				}
			}
		}
	}
}
