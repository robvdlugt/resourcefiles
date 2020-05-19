import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;

DynamicTopTabButton {
	id: rootWidget

	property ThermostatApp app
	contentUrl: app.thermostatWeekProgramUrl

	iconSource: "drawables/icon_heating.svg"
	property string kpiPostfix: "thermostatWeekProgramButton"
}
