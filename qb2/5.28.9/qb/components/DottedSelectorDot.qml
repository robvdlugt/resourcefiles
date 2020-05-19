import QtQuick 2.1

Rectangle {
	id: root
	height: Math.round(10 * verticalScaling)
	width: height
	color: selected ? colors.dsdSelectedDot : colors.dsdUnselectedDot
	radius: width / 2
	property bool selected: false
}
