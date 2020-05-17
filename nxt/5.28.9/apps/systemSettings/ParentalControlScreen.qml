import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Screen {
	id: parentalControlScreen
	screenTitle: qsTr("Parental Control")
	anchors.fill: parent

	onShown: {
		toggle.selected = parentalControl.enabled;
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		spacing: designElements.vMargin6

		SingleLabel {
			id: parentalControlLabel
			width: parent.width
			leftText: qsTr("Parental Lock")

			OnOffToggle {
				id: toggle
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
				}
				rightTextOn: qsTranslate("ScreenFrame", "On")
				leftTextOff: qsTranslate("ScreenFrame", "Off")
				onSelectedChangedByUser: {
					if (selected && !parentalControl.hasPin) {
						stage.openFullscreen(app.parentalControlEditPinScreenUrl);
					} else {
						parentalControl.enabled = selected;
						countly.sendEvent("ParentalControl.ToggleState", null, null, -1, {"enabled": parentalControl.enabled});
					}
				}
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: pinLabel
				anchors {
					left: parent.left
					right: editPinBtn.left
					rightMargin: designElements.vMargin6
				}
				leftText: qsTr("PIN code")
				rightText: parentalControl.hasPin ? "****" : qsTr("Not set")
			}

			IconButton {
				id: editPinBtn
				width: designElements.buttonSize
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"
				enabled: parentalControl.hasPin

				onClicked: {
					countly.sendEvent("ParentalControl.EditPin", null, null, -1, null);
					stage.openFullscreen(app.parentalControlEditPinScreenUrl)
				}
			}
		}
	}
}
