import QtQuick 2.1

import qb.components 1.0

Item {
	id: contentContainer

	property variant holidays: [
		qsTr("January 1st"),
		qsTr("Ascension Day"),
		qsTr("Easter monday"),
		qsTr("Whit monday"),
		qsTr("Kingsday"),
		qsTr("Christmas and Boxing day")
	]

	Text {
		id: text1
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
			topMargin: Math.round(20 * verticalScaling)
		}
		width: parent.width - Math.round(80 * horizontalScaling)
		wrapMode: Text.WordWrap

		text: qsTr("low_rate_hours_explanation_1")
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	Text {
		id: text2
		visible: feature.featHolidayOffPeakEnabled()
		anchors {
			top: text1.bottom
			horizontalCenter: parent.horizontalCenter
			topMargin: Math.round(20 * verticalScaling)
		}
		width: parent.width - Math.round(80 * horizontalScaling)
		wrapMode: Text.WordWrap

		text: qsTr("low_rate_hours_explanation_2")
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	Grid {
		id: holidaysGrid
		visible: feature.featHolidayOffPeakEnabled()
		anchors {
			top: text2.bottom
			topMargin: Math.round(20 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		columns: 2
		rows: 3

		Repeater {
			id: holidayRepeater
			model: 6

			Text {
				id: holidayText
				width: Math.round(150 * horizontalScaling)
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
			}
		}

		Component.onCompleted: {
			for (var i = 0; i < holidayRepeater.model; i++) {
				var textfield = holidayRepeater.itemAt(i);
				textfield.text = holidays[i];
			}
		}
	}
}
