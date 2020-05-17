import QtQuick 2.1

/**
  * Draw line from point [x1, y1] to point [x2, y2].
  *
  * Use color property to change color of the line.
  * Use width property to change width of the line.
  */

Rectangle {
	id: root
	property alias x1: root.x
	property alias y1: root.y
	property real x2: root.x
	property real y2: root.y

	// use estimation line of the bar graph as default
	color: colors.barGraphEstimationLine
	height: Math.round(2 * verticalScaling)
	antialiasing: true
	transformOrigin: Item.TopLeft

	width: getWidth(x1,y1,x2,y2)
	rotation: getSlope(x1,y1,x2,y2)

	function getWidth(sx1,sy1,sx2,sy2)
	{
		var w=Math.sqrt(Math.pow((sx2-sx1),2)+Math.pow((sy2-sy1),2));
		return w;
	}

	function getSlope(sx1,sy1,sx2,sy2)
	{
		var a,m,d;
		var b=sx2-sx1;
		if (b===0)
			return 0;
		a=sy2-sy1;
		m=a/b;
		d=Math.atan(m)*180/Math.PI;

		if (a<0 && b<0)
			return d+180;
		else if (a>=0 && b>=0)
			return d;
		else if (a<0 && b>=0)
			return d;
		else if (a>=0 && b<0)
			return d+180;
		else
			return 0;
	}
}
