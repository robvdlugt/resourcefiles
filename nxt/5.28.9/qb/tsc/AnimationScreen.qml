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

	Rectangle {
        	id: balloonScreen
        	color: "transparent"
			width: isNxt? 1024: 800
		    height: isNxt? 600: 480
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
