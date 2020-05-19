import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

App {
	id: settingsApp
	property url settingsScreenUrl: "SettingsScreen.qml"
	property url menuImageUrl: "drawables/SettingsMenuIcon.svg"

	function init() {
		registry.registerWidget("screen", settingsScreenUrl, settingsApp);
		registry.registerWidget("menuItem", null, settingsApp, null, {objectName: "settingsMenuItem", label: qsTr("Settings"), image: menuImageUrl, screenUrl: settingsScreenUrl, args:{showDefault: true}, weight: 130});

		notifications.registerType("settings", notifications.prio_NORMAL, Qt.resolvedUrl("drawables/notification-settings.svg"),
								   settingsScreenUrl, {"showDefault": true}, qsTr("notification-settings-grouped") );
	}
}
