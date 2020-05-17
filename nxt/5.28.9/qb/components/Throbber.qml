import QtQuick 2.1

/**
 * A component that represent an animation of dots.
 *
 * There are small dots in a circle and bigger dots, which is used for animation (changing position).
 * Count of dots is variable (property dotCnt). Every position of dots is precalculated at the begining.
 * Timer is used for changing position of bigger dots. Timer is running only when component is visible.
*/

Item {
	width: height
	height: Math.round(44 * verticalScaling)

	property int  dotCnt : 8
	property int  currentDot: 0
	property bool clockwise: true

	property real smallRadius: 1.9
	property real mediumRadius: 2.4
	property real largeRadius: 3.1
	property real bigRadius: 3.7

	property color smallDotColor: colors.animThrobber
	property color mediumDotColor: colors.animThrobber
	property color largeDotColor: colors.animThrobber
	property color bigDotColor: colors.animThrobber

	property bool animate: true
	property alias running: timer.running

	QtObject {
		id: p
		property variant smallPositions
		property variant mediumPositions
		property variant largePositions
		property variant bigPositions
	}

	function getPositions(radius) {
		var tmp = [];
		for (var i = 0; i < dotCnt; i++) {
			var x = width / 2 - width / 3 * Math.sin(2 * Math.PI * (dotCnt - 1 - i) / dotCnt) - radius;
			var y = height / 2 - height / 3 * Math.cos(2 * Math.PI * (dotCnt - 1 - i) / dotCnt) - radius;
			tmp.push({x: x,  y: y});
		}
		return tmp;
	}

	function changeIndex(index) {
		if (clockwise) {
			if (--index < 0) index = dotCnt - 1;
		} else {
			if (++index >= dotCnt) index = 0;
		}
		return index;
	}

	function changePosition() {
		if (clockwise) {
			if (++currentDot >= dotCnt) currentDot = 0;
		} else {
			if (--currentDot < 0) currentDot = dotCnt - 1;
		}

		var index = currentDot;
		bigDot.x = p.bigPositions[index].x;
		bigDot.y = p.bigPositions[index].y;

		index = changeIndex(index);
		largeDot.x = p.largePositions[index].x;
		largeDot.y = p.largePositions[index].y;

		index = changeIndex(index);
		mediumDot.x = p.mediumPositions[index].x;
		mediumDot.y = p.mediumPositions[index].y;
	}

	onVisibleChanged: currentDot = 0;

	Component.onCompleted: {
		p.smallPositions = getPositions(smallRadius);
		for (var i = 0; i < dotCnt; i++){
			var rect = smallDots.itemAt(i);
			rect.x = p.smallPositions[i].x;
			rect.y = p.smallPositions[i].y;
		}

		p.mediumPositions = getPositions(mediumRadius);
		p.largePositions = getPositions(largeRadius);
		p.bigPositions = getPositions(bigRadius);

		// Trigger the first animation to position the dots on the right location, in case
		// the animation is not running.
		changePosition();
	}

	Repeater {
		id: smallDots
		model: parent.dotCnt
		Rectangle {
			height: Math.round(2 * parent.smallRadius)
			width:  Math.round(2 * parent.smallRadius)
			color: smallDotColor
			radius: height / 2
		}
	}

	Rectangle {
		id: bigDot
		height: Math.round(2 * parent.bigRadius)
		width: Math.round(2 * parent.bigRadius)
		color: bigDotColor
		radius: height / 2
	}

	Rectangle {
		id: largeDot
		height: Math.round(2 * parent.largeRadius)
		width:  Math.round(2 * parent.largeRadius)
		color: largeDotColor
		radius: height / 2
	}

	Rectangle {
		id: mediumDot
		height: Math.round(2 * parent.mediumRadius)
		width:  Math.round(2 * parent.mediumRadius)
		color: mediumDotColor
		radius: height / 2
	}

	Timer {
		id: timer
		interval: 70
		repeat: true
		running: parent.visible && parent.animate

		onTriggered: parent.changePosition()
	}
}
