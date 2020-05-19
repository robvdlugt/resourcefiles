import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: hideToonLogoScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("Hide Toon Logo")

	onShown: {
			radioButtonList.currentIndex = globals.tsc["hideToonLogo"] 
			if (globals.tsc["showTime"] && globals.tsc["showDate"]) radioButtonList2.currentIndex = 3 
			if (!globals.tsc["showTime"] && globals.tsc["showDate"]) radioButtonList2.currentIndex = 2 
			if (globals.tsc["showTime"] && !globals.tsc["showDate"]) radioButtonList2.currentIndex = 1 
			if (!globals.tsc["showTime"] && !globals.tsc["showDate"]) radioButtonList2.currentIndex = 0
	}
	onSaved: {
			var myTsc = globals.tsc
			myTsc["hideToonLogo"] = radioButtonList.currentIndex
			myTsc["showTime"] = radioButtonList2.currentIndex === 1 || radioButtonList2.currentIndex === 3
			myTsc["showDate"] = radioButtonList2.currentIndex === 2 || radioButtonList2.currentIndex === 3
			globals.tsc = myTsc
			app.saveSettingsTsc();
	}

	RadioButtonList {
		id: radioButtonList
		width: isNxt ? Math.round(300 * 1.28) : Math.round(280 * 1.28)
		height: Math.round(250 * app.nxtScale)

        	anchors.horizontalCenterOffset: isNxt ? -250 : -205
        	anchors.verticalCenter: parent.verticalCenter
        	anchors.horizontalCenter: parent.horizontalCenter

		title: qsTr("Hide the Toon logo")

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Only during dim");
			addItem("Always");
			forceLayout();
                        currentIndex = 0;
		}
	}

	RadioButtonList {
		id: radioButtonList2
		width: isNxt ? Math.round(330 * 1.28) : Math.round(280 * 1.28)
		height: Math.round(250 * app.nxtScale)

        	anchors.horizontalCenterOffset: isNxt ? 250 : 205
        	anchors.verticalCenter: parent.verticalCenter
        	anchors.horizontalCenter: parent.horizontalCenter

		title: qsTr("Show date and time instead in dim")

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Only time");
			addItem("Only date");
			addItem("Both");
			forceLayout();
                        currentIndex = 0;
		}
	}

}
