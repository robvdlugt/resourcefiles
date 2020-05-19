import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;

DynamicTopTabButton {
	id: rootWidget

	property DomesticHotWaterApp app
	contentUrl: app.weekProgramUrl

	iconSource: "drawables/hw-active-on.svg"
	property string kpiPostfix: "dhwWeekProgramButton"
}
