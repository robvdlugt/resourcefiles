import QtQuick 2.1
import qb.components 1.0

Screen {
	id: heatingWizardsScreen
	screenTitle: qsTr("Heating")
	property ThermostatSettingsApp app

	HeatingFrame {
		id: heatingFrame
		anchors.fill: parent
		app: heatingWizardsScreen.app
	}

	onShown: {
		heatingFrame.shown(null)
	}
}
