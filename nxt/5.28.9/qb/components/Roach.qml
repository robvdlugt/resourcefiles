//Balloon by Oepi-Loepi for Toon

import QtQuick 2.1

Item {
    id: roach

    property bool destroyed: false

    width: 120
    height: 120

    Item {
        id: sprite
        property int frame: randomNumber(1, 9)
        anchors.centerIn: parent
		height: parent.height
        width: parent.height
        clip: true
	y: parent.height

    function randomNumber(from, to) {
		return Math.floor(Math.random() * (to - from + 1) + from);
    }
	//Text {
	//	//text: Math.floor(rotator.angle)
	//	//text: Math.floor(20*Math.cos((rotator.angle-90)*Math.PI/180))
	//	text: Math.floor(20*Math.sin((rotator.angle-90)*Math.PI/180))

	//	font.pixelSize:  12
	//	anchors {
	//		right: parent.right
	//		top: parent.top
	//	}
	//}


        transform: Rotation {
            id: rotator
            origin{
                x: 60
                y: 100
             }
             angle:  randomNumber(-10, 10)
        
	}
  
	ParallelAnimation {
            id: shake
            //PropertyAnimation { easing.type: Easing.InQuad; duration: 400; target: rotator; property: "angle"; to: rotator.angle+1}
            PropertyAnimation { easing.type: Easing.InQuad; duration: 400; target: rotator; property: "angle"; to: rotator.angle+randomNumber(-20, 20)}
	    NumberAnimation { target: roach; property: "y"; to: (roach.y + Math.floor(40*Math.sin((rotator.angle-90)*Math.PI/180))); duration: 400 }
            NumberAnimation { target: roach; property: "x"; to: (roach.x + Math.floor(40*Math.cos((rotator.angle-90)*Math.PI/180))); duration: 400 }
        }

        Timer {
            running: true
            repeat: true
            interval: 1200
            onTriggered: {
                shake.restart();
        }
}

        Image {
			id: spriteImage
			source: "http://localhost/images/RoachSprites.png"
			y:0
			x:-parent.width*sprite.frame
        }
    }

    function randomNumber(from, to) {
		return Math.floor(Math.random() * (to - from + 1) + from);
    }

    property int speed: randomNumber(1, 4)

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
	    if (sprite.frame == 7) {
			sprite.frame = 0
            }
            sprite.frame++;
            if (roach.y + roach.height < -30) {
               roach.destroy();
            }
        }
    }

}
