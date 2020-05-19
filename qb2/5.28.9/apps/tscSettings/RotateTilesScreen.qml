import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: rotateTilesScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("Rotating tiles")

	property bool firstShown: true;  // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again


	onShown: {
		if (firstShown) {
			radioButtonList.currentIndex = globals.tsc["rotateTiles"] 
			radioButtonList2.currentIndex = globals.tsc["rotateTilesDim"] 
			rotateTimerLabel.rightText = globals.tsc["rotateTilesSeconds"] 
			firstShown=false;
		}
	}
	onSaved: {
                 var myTsc = globals.tsc
                 myTsc["rotateTiles"] = radioButtonList.currentIndex
                 myTsc["rotateTilesDim"] = radioButtonList2.currentIndex
                 myTsc["rotateTilesSeconds"] = rotateTimerLabel.rightText 
                 globals.tsc = myTsc
                 app.saveSettingsTsc();
	}

        function updateRotateTimerLabel(text) {
                if (text) {
                        // need to check if contains only numbers (seconds)
                        if (text.match(/^[0-9]*$/)) {
                                rotateTimerLabel.rightText = text;
                        }
                }
        }

	Text {
		id: bodyText

		width: Math.round(650 * app.nxtScale)
		wrapMode: Text.WordWrap

		text: "Mode 1: only right bottom tile. Mode 2: Both bottom tiles. Mode 3: Rotate all tiles. Change will only be visible after previous interval elapsed."
		color: "#000000"

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name

		anchors {
			top: parent.top
			topMargin: isNxt ? Math.round(30 * 1.28) : 10
			horizontalCenter: parent.horizontalCenter
		}
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(220 * 1.28)
		height: Math.round(200 * app.nxtScale)

		anchors {
			top: bodyText.baseline
			topMargin: Math.round(60 * app.nxtScale)
			left: parent.left
			leftMargin: isNxt ? 200 : 100
		}

		title: qsTr("Mode")

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Mode 1");
			addItem("Mode 2");
			addItem("Mode 3");
                        forceLayout();
                        currentIndex = 0;
		}
	}

	RadioButtonList {
		id: radioButtonList2
		width: Math.round(220 * 1.28)
		height: Math.round(200 * app.nxtScale)

		anchors {
			top: bodyText.baseline
			topMargin: Math.round(60 * app.nxtScale)
			left: radioButtonList.right
			leftMargin: 10 
		}

		title: qsTr("Only during dim")

		Component.onCompleted: {
			addItem("Disabled");
			addItem("Enabled");
                        forceLayout();
                        currentIndex = 0;
		}
	}

	SingleLabel {
		id: rotateTimerLabel
		width: isNxt ? 600 : 350
		height: 35
		leftText: "Rotating interval"

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: radioButtonList.bottom
			topMargin: isNxt ? 5 : 10
		}

	}

        IconButton {
                id: rotateTimerButton
                width: 45
                height: rotateTimerLabel.height
                        iconSource: "qrc:/images/edit.svg"
                        anchors {
                        top: rotateTimerLabel.top
                        left: rotateTimerLabel.right
                        leftMargin: 10
                }
                topClickMargin: 3
                onClicked: {
			qnumKeyboard.open("Tile rotation interval", rotateTimerLabel.rightText, "Seconds", "s" , updateRotateTimerLabel);
                }
        }



}
