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
	property string staticImageT1
        property string staticImageT2
	property bool animationSendSignal1: false
	property bool animationSendSignal2: false
	property bool animationSendSignal3: false
	
	signal animationSignal1()
	signal animationSignal2()
	signal animationSignal3()
	
	
	Component.onCompleted: {
		if (animationSendSignal1) {animationSignal1(); animationSendSignal1 = false} 
		if (animationSendSignal2) {animationSignal2(); animationSendSignal2 = false} 
		if (animationSendSignal3) {animationSignal3(); animationSendSignal3 = false} 
	}


	Rectangle {
            id: staticoverlay
            color: "transparent"
            width: isNxt? 1024 : 800
            height: isNxt? 600 : 480
            Image {
                    id: webimage
                    source: isNxt? staticImageT2:staticImageT1
                    width: parent.width
                    height: parent.height
            }
	    visible:  ((isVisibleinDimState || !dimState) && animationRunning)
     	}

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
		//visible: ((isVisibleinDimState || !dimState) && animationRunning)
		visible: (isVisibleinDimState || !dimState)
    	}
}
