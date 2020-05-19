import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: hideErrorSystrayScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("Hide error systray icon")

	onShown: radioButtonList.currentIndex = globals.tsc["hideErrorSystray"] 
	onSaved: {
		var myTsc = globals.tsc
		myTsc["hideErrorSystray"] = radioButtonList.currentIndex
		globals.tsc = myTsc
		app.saveSettingsTsc();
	}

	Text {
		id: bodyText

		width: Math.round(600 * 1.28)
		wrapMode: Text.WordWrap

		text: "This option will allow you to hide the error systray icon which is normally shown if there is a issue with your Toon"
		color: "#000000"

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name

		anchors {
			top: parent.top
			topMargin: isNxt ? Math.round(60 * 1.28) : 10
			horizontalCenter: parent.horizontalCenter
		}
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(220 * 1.28)
		height: Math.round(250 * app.nxtScale)

		anchors {
			top: bodyText.baseline
			topMargin: Math.round(60 * app.nxtScale)
			left: parent.left
			leftMargin: isNxt ? 200 : 100

		}


		title: qsTr("Hide systray icon")

		Component.onCompleted: {
			addItem("Disabled - Show");
			addItem("Enabled - Hide");
                        forceLayout();
                        currentIndex = 0;
		}
	}

}
