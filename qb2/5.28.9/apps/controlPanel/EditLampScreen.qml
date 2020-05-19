import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root

	screenTitle: qtUtils.escapeHtml(currentLamp.Name) // Prevent XSS/HTML injection by using qtUtils.escapeHtml

	property ControlPanelApp app

	property variant currentLamp: {"Name": "", "InSwitchAll": 0}

	QtObject {
		id: p
		property bool saveChanges: false

		function setName(text) {
			var lamp = currentLamp;
			lamp.Name = text;
			currentLamp = lamp;
			app.setDeviceName(currentLamp.DevUUID, text);
		}

		function changeInSwitchAll(newVal) {
			if (newVal !== (currentLamp.InSwitchAll === "1")) {
				app.setInSwitchAll(currentLamp.DevUUID, newVal);
			}
		}

		//when some request to change the lamp is done, search the lamp in dataset to update the currentLamp reference
		function updateCurrentLamp() {
			for (var i = 0; i < app.devLamps.length; i++) {
				if (currentLamp.DevUUID === app.devLamps[i].DevUUID) {
					currentLamp = app.devLamps[i];
					break;
				}
			}
		}
	}

	function init() {
		app.devLampsChanged.connect(p.updateCurrentLamp);
	}

	Component.onDestruction: {
		app.devLampsChanged.disconnect(p.updateCurrentLamp);
	}

	onShown: {
		if (args && args.lampUuid) {
			currentLamp = app.getLampByUuid(args.lampUuid);
		}
	}

	Column {
		id: editLampComponent
		width: Math.round(533 * horizontalScaling)
		anchors {
			top: parent.top
			topMargin: parent.height * 0.2
			horizontalCenter: parent.horizontalCenter
		}
		spacing: designElements.vMargin6

		EditTextLabel {
			id: nameLabel
			width: parent.width
			labelText: qsTr("Name")
			prefilledText: currentLamp.Name
			readOnly: feature.appControlPanelLampRenameDisabled()
			maxLength: 13
			showAcceptButton: true
			validator: RegExpValidator { regExp: /.+/ } // empty name is not allowed

			onInputAccepted: p.setName(nameLabel.inputText)
		}

		SingleLabel {
			id: linkLabel
			width: parent.width
			leftText: qsTr("add to Group")
			iconSource: "image://scaled/apps/controlPanel/drawables/group" + (!enabled ? "_disabled" : "") + ".svg"

			OptionToggle {
				id: isLinkedToggle

				enabled: parent.enabled
				rightText: qsTr("No")
				leftText: qsTr("Yes")
				anchors {
					right: parent.right
					rightMargin: Math.round(13 * horizontalScaling)
					verticalCenter: parent.verticalCenter
				}
				positionIsLeft: currentLamp.InSwitchAll === "1"
				onPositionIsLeftChanged: p.changeInSwitchAll(positionIsLeft)
			}
		}
	}
}
