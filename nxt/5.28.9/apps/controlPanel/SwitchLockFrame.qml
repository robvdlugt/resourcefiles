import QtQuick 2.1
import qb.components 1.0

WizardFrame {

	function initWizardFrame() {
		screenElements.plugName = plugName;
		screenElements.radioGroup.currentControlId = app.switchLocked;
	}

	title: qsTr("Plug control")
	nextPage: 3

	SwitchLockScreenElements {
		id: screenElements
		anchors {
			top: parent.top
			topMargin: Math.round(39 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(131 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
	}

	Connections {
		target: screenElements.radioGroup
		onCurrentControlIdChanged: {
			app.switchLocked = screenElements.radioGroup.currentControlId;
			nextPage = app.switchLocked ? 4 : 3;
		}
	}
}
