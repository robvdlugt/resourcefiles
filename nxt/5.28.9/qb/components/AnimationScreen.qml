import QtQuick 2.1
import qb.base 1.0

/**
 * The base class for any animation screen.
 * Provides default onShow & onHide transitions.
 */
Widget {

    property bool isBalloonMode: false
	property bool isVisibleinDimState: true
	property int animationInterval : 1000
	property string qmlAnimationURL
	property string qmlAnimationText : "Animation Test for beta testing"
	

	Rectangle {
		id: spriteImage
		color: "transparent"
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
         		text: qmlAnimationText
     		}
     }


	Rectangle {
        	id: balloonScreen
        	color: "transparent"
        	anchors.fill: parent
		Timer {
			interval : animationInterval
			repeat: true
			triggeredOnStart: true
			running: isBalloonMode
			onTriggered: {
				var component = Qt.createComponent(qmlAnimationURL);
				if (component.status ===  Component.Ready){
					finishCreation();
				}
				 else{
        				component.statusChanged.connect(finishCreation);
				}
				function finishCreation() {
    					if (component.status == Component.Ready) {
        					var balloon = component.createObject(balloonScreen);
        					if (balloon == null) {
        					}
    					} else{
        					if (component.status === Component.Error) {
        					}else{
        					}
    					}
				}	
			}
		}
		visible: (isVisibleinDimState || !dimState)
    	}


}
