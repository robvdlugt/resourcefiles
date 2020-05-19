import QtQuick 2.1

import qb.components 1.0;
import qb.base 1.0;

import "HomeApp.js" as AppJs;

App {
	id: homescreenApp
	property url dimIconUrl : "DimIcon.qml"
	property url homeScreenUrl : "Homescreen.qml"
	property url menuScreenUrl : "MenuScreen.qml"
	property url chooseTileScreenUrl : "ChooseTileScreen.qml"
	property url addTileMenuItemUrl : "AddTileMenuItem.qml"
	property url removeTilePopupUrl : "RemoveTilePopup.qml"

	property Screen menuScreen
	property Screen homeScreen
	property ChooseTileScreen chooseTileScreen
	property Popup removeTilePopup

	property int isDimmed: 0

	function init() {
		registry.registerWidget("systrayIcon", dimIconUrl, homescreenApp);
		registry.registerWidget("screen", chooseTileScreenUrl, homescreenApp, "chooseTileScreen");
		registry.registerWidget("screen", homeScreenUrl, homescreenApp, "homeScreen");
		registry.registerWidget("screen", menuScreenUrl, homescreenApp, "menuScreen");
		registry.registerWidget("menuItem", addTileMenuItemUrl, homescreenApp, null, {weight: 145});
		registry.registerWidget("popup", removeTilePopupUrl, homescreenApp, "removeTilePopup");

		stage.homeScreenUrl = homeScreenUrl;
		stage.menuScreenUrl = menuScreenUrl;

		notifications.registerType("feature", notifications.prio_LOW, Qt.resolvedUrl("drawables/notification-add-icon.svg"),
								   "", {}, qsTr("notification-feature-grouped") );
		notifications.registerSubtype("feature", "newTile", chooseTileScreenUrl, {category: "category"});
	}
}
