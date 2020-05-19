import QtQuick 2.1

import qb.components 1.0

Screen {
	id: eMeterAdvancedScreen

	screenTitle: qsTr("Energy meters advanced")
	isSaveCancelDialog: false
	anchors.fill: parent

	onShown: {
		app.requestLocalAccessState();
		app.requestZwaveControlState();
	}

	// Main container
	Column {
		id: centerContainer
		anchors {
			top: parent.top
			topMargin: Math.round(10 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(100 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		spacing: designElements.vMargin6

		Text {
			id: removeTitle
			text: qsTr("Remove meteradapter or repeaterconfiguration from Toon:")
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.rbTitle
			width: parent.width
			wrapMode: Text.WordWrap
		}

		Text {
			id: removeContext
			text: qsTr("Remove-Ma-Repeater-context")
			font.pixelSize: Math.round(14 * verticalScaling)
			font.family: qfont.regular.name
			color: colors.systemMenuUp
			wrapMode: Text.WordWrap
			width: parent.width
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: removeMaLabel
				leftText: qsTr("Meteradapter")
				anchors {
					left: parent.left
					right: removeMaButton.left
					rightMargin: designElements.hMargin6
				}
			}

			StandardButton {
				id: removeMaButton
				text: qsTr("Remove")
				anchors.right: parent.right
				width: Math.round(115 * horizontalScaling)
				bottomClickMargin: 3

				onClicked: {
					app.removeMeasureDevices();
					hide();
					qdialog.showDialog(qdialog.SizeMedium, qsTr("remove-ma-popup-title"), qsTr("remove-ma-popup-body"));
				}
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: removeRepeaterLabel
				leftText: qsTr("Repeater(s)")
				anchors {
					left: parent.left
					right: removeRepeaterButton.left
					rightMargin: designElements.hMargin6
				}
			}

			StandardButton {
				id: removeRepeaterButton
				text: qsTr("Remove")
				anchors.right: parent.right
				width: Math.round(115 * horizontalScaling)
				topClickMargin: 3

				onClicked: {
					app.removeAllRepeaters();
					hide();
					qdialog.showDialog(qdialog.SizeMedium, qsTr("remove-repeater-popup-title"), qsTr("remove-repeater-popup-body"));
				}
			}
		}

		Item {
			width: 1
			height: designElements.spacing6
		}

		Text {
			id: recoverTitle
			text: qsTr("Recover meteradapter or repeater:")
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
			color: colors.rbTitle
			width: parent.width
		}

		Text {
			id: recoverContext
			text: qsTr("Recover-Ma-Repeater-context")
			font.pixelSize: Math.round(14 * verticalScaling)
			font.family: qfont.regular.name
			color: colors.systemMenuUp
			wrapMode: Text.WordWrap
			width: parent.width
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: recoverMaLabel
				leftText: qsTr("Meteradapter")
				anchors {
					left: parent.left
					right: recoverMaButton.left
					rightMargin: designElements.hMargin6
				}
			}

			StandardButton {
				id: recoverMaButton
				text: qsTr("Recover")
				anchors.right: parent.right
				width: Math.round(115 * horizontalScaling)
				bottomClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.removeDeviceScreenUrl, {state: "meteradapter_recover"});
				}
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: recoverRepeaterLabel
				leftText: qsTr("Repeater(s)")
				anchors {
					left: parent.left
					right: recoverRepeaterButton.left
					rightMargin: designElements.hMargin6
				}
			}

			StandardButton {
				id: recoverRepeaterButton
				text: qsTr("Recover")
				anchors.right: parent.right
				width: Math.round(115 * horizontalScaling)
				topClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.removeDeviceScreenUrl, {state: "repeater_recover"});
				}
			}
		}
	}

	SingleLabel {
		id: zwaveControlLabel

		visible: app.localAccessEnabled
		leftText: qsTr("Z-Wave control")
		rightText: app.zwaveControlEnabled ? qsTr("On") : qsTr("Off")
		rightTextSize: qfont.bodyText

		anchors {
			left: centerContainer.left
			bottom: zwaveControlBtn.bottom
			right: zwaveControlBtn.left
			rightMargin: designElements.hMargin6
		}
	}

	IconButton {
		id: zwaveControlBtn

		width: designElements.buttonSize
		visible: app.localAccessEnabled
		iconSource: "qrc:/images/edit.svg"
		onClicked: stage.openFullscreen(app.zwaveControlScreenUrl);

		anchors {
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
			right: centerContainer.right
		}
	}
}
