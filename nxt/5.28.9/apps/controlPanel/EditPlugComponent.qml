import QtQuick 2.1

import qb.components 1.0
import qb.utils 1.0

Item {
	id: root

	width: Math.round(533 * horizontalScaling)
	height: childrenRect.height

	property ControlPanelApp ctrlApp
	property alias plugName: editText.prefilledText
	property string plugUuid
	property bool switchLocked: false
	property alias inSwitchAll: allOnOffToggle.positionIsLeft
	property bool disableRename: false
	// plug signal strength 0..5
	property int signalStrength: 0
	// progress 0..100 %
	property int signalStrengthProgress: 0

	signal keyboardSaved(string text);
	signal updateSignalStrength();

	QtObject {
		id: p

		function editLock() {
			stage.openFullscreen(ctrlApp.switchLockScreenUrl, {context: root});
		}
	}

	EditTextLabel {
		id: editText
		width: parent.width
		labelText: qsTr("Name")
		readOnly: disableRename
		maxLength: 13
		showAcceptButton: true
		validator: RegExpValidator { regExp: /.+/ } // empty name is not allowed

		onInputAccepted: keyboardSaved(inputText)
	}

	SingleLabel {
		id: signalStrengthLabel

		leftText: qsTr("Connection quality")
		rightText: ""

		anchors {
			top: editText.bottom
			topMargin: designElements.vMargin6
			left: parent.left
			right: signalStrengthButton.left
			rightMargin: designElements.hMargin6
		}

		Row {
			id: signalStrengthRow

			spacing: Math.round(2 * horizontalScaling)
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			anchors.rightMargin: designElements.hMargin10
			Repeater {
				id: signalStrengthStars
				model: 5
				Image {
					source: "qrc:/images/star-" + (index < signalStrength ? "on" : "off") + ".svg";
				}
			}
		}
	}

	Throbber {
		id: signalStrengthThrobber

		width: signalStrengthButton.width
		height: width
		visible: false

		anchors {
			bottom: signalStrengthLabel.bottom
			right: parent.right
		}
	}

	IconButton {
		id: signalStrengthButton
		iconSource: "qrc:/images/refresh.svg"

		anchors {
			bottom: signalStrengthLabel.bottom
			left: signalStrengthThrobber.left
		}

		topClickMargin: 3
		bottomClickMargin: 3
		onClicked: updateSignalStrength();
	}

	ZWaveSecurityInfoButton {
		id: infoSecurityButton
		anchors {
			bottom: signalStrengthButton.bottom
			left: signalStrengthButton.right
			leftMargin: designElements.hMargin6
		}
		deviceUuid: plugUuid
	}

	SingleLabel {
		id: switchLockedLabel

		leftText: qsTr("Plug control")
		rightText: switchLocked ? qsTr("Locked") : qsTr("Operable")
		iconSource: "image://scaled/apps/controlPanel/drawables/" + (switchLocked ? "lock" : "lock-open") + ".svg"
		anchors {
			top: signalStrengthLabel.bottom
			topMargin: designElements.vMargin6
			left: parent.left
			right: switchLockButton.left
			rightMargin: designElements.hMargin6
		}
	}

	IconButton {
		id: switchLockButton

		anchors {
			right: parent.right
			top: switchLockedLabel.top
		}

		iconSource: "qrc:/images/edit.svg"
		topClickMargin: 3
		bottomClickMargin: 3
		onClicked: p.editLock();
	}

	SingleLabel {
		id: allOnOffLabel

		enabled: !switchLocked
		leftText: qsTr("add to Group")
		rightText: ""
		iconSource: "image://scaled/apps/controlPanel/drawables/group" + (!enabled ? "_disabled" : "") + ".svg"

		anchors {
			top: switchLockedLabel.bottom
			topMargin: designElements.vMargin6
			left: parent.left
			right: parent.right
		}

		OptionToggle {
			id: allOnOffToggle

			enabled: parent.enabled
			leftText: qsTr("Yes")
			rightText: qsTr("No")
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
				rightMargin: Math.round(13 * horizontalScaling)
			}
			positionIsLeft: false
		}
	}

	state: "normal"
	states: [
		State {
			name: "normal"
			PropertyChanges {target: signalStrengthRow; visible: true}
		},
		State {
			name: "checking"
			PropertyChanges {target: signalStrengthRow; visible: false}
			PropertyChanges {target: signalStrengthLabel; rightText: signalStrengthProgress + "%"}
			PropertyChanges {target: signalStrengthButton; visible: false}
			PropertyChanges {target: signalStrengthThrobber; visible: true}
		},
		State {
			name: "disabled"
			PropertyChanges {target: signalStrengthRow; visible: true}
			PropertyChanges {target: signalStrengthButton; enabled: false}
			PropertyChanges {target: signalStrengthThrobber; visible: false}
		}
	]
}
