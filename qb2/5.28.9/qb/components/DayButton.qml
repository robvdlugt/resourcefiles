import QtQuick 2.0
import ThermostatUtils 1.0

Item {
	id: dayButtonItem
	property bool isDaySelected: false
	property bool invertBackgroundColor: false
	width: Math.round(88 * horizontalScaling)
	height: Math.round(36 * verticalScaling)
	property string kpiPostfix: "day" + index

	// Day is sundayBased
	signal daySelected(int day)

	Rectangle {
		id: txtDay
		width: parent.width
		height: Math.round(36 * verticalScaling)
		radius: designElements.radius
		color: (isDaySelected ^ invertBackgroundColor) ? colors.psDayBckgSelected : colors.psDayBckgUnselected

		Text {
			text: i18n.daysExtraShort[index + 1] // Monday based index
			color:  isDaySelected ? colors.esDayTextSelected : colors.esDayTextUnselected
			anchors.centerIn: parent
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
		}
	}
	MouseArea {
		id: maDayButton
		anchors.fill: parent
		onClicked: {
			// emit signal with Sunday based index of the day
			daySelected(ThermostatUtils.mondayBaseToSundayBase(index));
		}
	}
}
