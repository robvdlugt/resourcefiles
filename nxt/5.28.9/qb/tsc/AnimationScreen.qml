import QtQuick 2.1
import qb.base 1.0

/**
 * The base class for any animation screen.
 * Provides default onShow & onHide transitions.
 */
Widget {

    property bool animationRunning: false
	property bool isVisibleinDimState: true
	property int animationInterval : 1000
	property string qmlAnimationURL
	property string qmlAnimationText : "Animation Mode"
	

	Rectangle {
		id: someText
		color: "transparent"
		width: isNxt? 1024 : 800
		height: isNxt? 600 : 480
		radius: 4
     		Text{
         		id: buttonLabel
         		anchors{
					top: parent.top
					topMargin: 2
					left: isNxt ? 512 : 400
				}
				width: parent.width
				font.pixelSize:  isNxt ? 20 : 14
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
        width: isNxt? 1024 : 800
		height: isNxt? 600 : 480
		Timer {
			interval : animationInterval
			repeat: true
			triggeredOnStart: true
			running: animationRunning
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
