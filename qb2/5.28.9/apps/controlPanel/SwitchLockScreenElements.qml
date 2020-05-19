import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

Item {
	property alias radioGroup: radioGroup
	property string plugName: ""
	anchors.fill: parent

	Text {
		id: titleText

		wrapMode: Text.WordWrap
		color: colors.foreground
		font {
			pixelSize: qfont.navigationTitle
			family: qfont.semiBold.name
		}

		anchors {
			left: parent.left
			right: parent.right
		}

		text: qsTr("plug-lock-title").arg(qtUtils.escapeHtml(plugName)) // Prevent XSS/HTML injection by using qtUtils.escapeHtml
	}

	Text {
		id: bodyText

		wrapMode: Text.WordWrap
		color: colors.foreground
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}

		anchors {
			left: titleText.left
			right: titleText.right
			baseline: titleText.baseline
			baselineOffset: Math.round(40 * verticalScaling)
		}

		text: qsTr("plug-lock-text")
	}

	ControlGroup {
		id: radioGroup
		exclusive: true
	}

	StandardRadioButton {
		id: radioButtonUnlocked
		controlGroupId: 0
		controlGroup: radioGroup
		property string kpiId: "SwitchLockScreen."+text
		anchors {
			top: bodyText.bottom
			topMargin: Math.round(40 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(250 * horizontalScaling)
		text: qsTr("Operable")

		Image {
			id: unlockedIcon
			source: "image://scaled/apps/controlPanel/drawables/lock-open.svg"
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: designElements.hMargin10
			}
		}
	}

	StandardRadioButton {
		id: radioButtonLocked
		controlGroupId: 1
		controlGroup: radioGroup
		property string kpiId: "SwitchLockScreen." + text
		anchors {
			top: radioButtonUnlocked.bottom
			topMargin: designElements.vMargin6
			horizontalCenter: parent.horizontalCenter
		}
		width: radioButtonUnlocked.width
		text: qsTr("Locked")

		Image {
			id: lockedIcon
			source: "image://scaled/apps/controlPanel/drawables/lock.svg"
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Math.round(12 * horizontalScaling)
			}
		}
	}
}
