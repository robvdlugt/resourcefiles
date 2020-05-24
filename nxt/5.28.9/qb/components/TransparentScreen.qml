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

	property string identifier

	function show(args) {
		stage.openFullscreen(identifier, args);
	}

	function hide() {
		stage.navigateBack();
	}


	Behavior on scale {
		enabled:  globals.screenTransitionEnabled;
		NumberAnimation {duration: globals.screenTransitionDuration; easing.type: Easing.OutCubic}
	}

	function balloonMode(balloonmode, animationtime, animationtype, visibleindimstate, animationDuration) {
		if (animationtime === undefined) animationtime = 1000
		if (visibleindimstate === undefined) visibleindimstate = false
		animationInterval = animationtime
		qmlAnimationURL = animationtype
		animationMaxTime = animationDuration
		if ((balloonmode == "Start")&&(animationtype != undefined)){isBalloonMode = true}
		if ((balloonmode == "Stop")||(animationtype === undefined)){isBalloonMode = false}
		if (visibleindimstate == "yes"){isVisibleinDimState = true}
		if (visibleindimstate == "no"){isVisibleinDimState = false}
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
