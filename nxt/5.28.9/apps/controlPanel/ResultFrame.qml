import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	id: resultFrame

	property ControlPanelApp app

	function initWizardFrame() {
		editPlug.inSwitchAll = app.addToAllOnOff;
		editPlug.switchLocked = app.switchLocked
		editPlug.plugName = plugName;
	}

	function keyboardSave(text) {
		plugName = editPlug.plugName = text;
		setTitle(text);
	}

	title: editPlug.plugName

	EditPlugComponent {
		id: editPlug

		ctrlApp: app
		anchors {
			top: parent.top
			topMargin: Math.round(86 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		plugUuid: app && app.smartplugZwaveUuid ? app.smartplugZwaveUuid : ""
		signalStrength: app && app.smartplugZwaveUuid && zWaveUtils.devices[app.smartplugZwaveUuid].IsConnected === "1" ? Math.floor(parseInt(zWaveUtils.devices[app.smartplugZwaveUuid].HealthValue / 2)) : 0
		signalStrengthProgress: zWaveUtils.networkHealth.active ? zWaveUtils.networkHealth.progress : 0
		state: zWaveUtils.networkHealth.active ? (zWaveUtils.networkHealth.uuid === app.smartplugZwaveUuid ? "checking" : "disabled") : "normal"

		onInSwitchAllChanged: app.addToAllOnOff = inSwitchAll ? 1 : 0;
		onSwitchLockedChanged: app.switchLocked = switchLocked ? 1 : 0;
		onKeyboardSaved: keyboardSave(text);
		onUpdateSignalStrength: zWaveUtils.doNodeHealthTest(app.smartplugZwaveUuid)
	}
}
