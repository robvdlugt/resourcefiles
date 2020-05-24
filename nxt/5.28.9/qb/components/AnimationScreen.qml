import QtQuick 2.1
import qb.base 1.0

/**
 * The base class for any animation screen.
 * Provides default onShow & onHide transitions.
 */
Widget {
	id: animationScr
    property bool isBalloonMode: false
	property bool isVisibleinDimState: true
	property int animationInterval : 1000
	property string qmlAnimationURL

	Rectangle {
		id: spriteImage
		color: !dimState? "white" : "black"
		anchors.fill: parent 
		radius: 4
     		Text{
         		id: buttonLabel
         		anchors.centerIn: parent
			width: parent.width
			font.pixelSize:  isNxt ? 30 : 22
			font.family: qfont.regular.name
			font.bold: true
			color: !dimState? "black" : "white"
			wrapMode: Text.WordWrap
         		text: "Hello beta testers: click here to close"
     		}

    		MouseArea{
         		id: buttonMouseArea
         		anchors.fill: parent 
         		onClicked: {buttonLabel.text = "Clicked";this.close();}
     		}
		
	}
}
