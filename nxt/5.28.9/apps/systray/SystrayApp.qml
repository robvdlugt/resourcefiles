import QtQuick 2.1
import qb.base 1.0;

App {
	id: systrayApp
	property url containerUrl : "SystrayContainer.qml"
	function init() {
		registry.registerWidget("topRight", containerUrl, systrayApp, "");
	}
}
