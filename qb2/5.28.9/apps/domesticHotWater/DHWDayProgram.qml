import QtQuick 2.1
import qb.components 1.0

Item {
	id: root

	property string kpiPostfix: "DHWday" + index
	property bool isDaySelected: false
	property bool dayEnabled: true

	// Signal emitted when day is daySelected
	// parameter dayToSelect is Sunday based index of the day
	signal daySelected(int dayToSelect);

	property int programDisplayHeight: (isNxt ? 288 : 216)

	width: 75 * horizontalScaling
	height: (isNxt ? 288 : 216) + dayButton.height // Can't use vertical scaling because hour lines need to be aligned to pixels. 288 = 24 * 12-> 24 lines of 12 pixels

	// Use a separate property to inform the 'column' component of the height. I suspect there is a reference loop somehow, but there is no
	// logging to debug the issue.
	property int extHeight: (isNxt ? 288 : 216) + dayButton.height

	QtObject {
		id: p
		property int dayProgramHeight: 0

		function isLastInDay(blockIdx) {
			return (blockIdx === programModel.count - 1);
		}

		function isFirstInDay(blockIdx) {
			var result = (blockIdx === 0) || (blockIdx === 1 && (programModel.get(blockIdx).startHour + programModel.get(blockIdx).startMinute === 0))
			return result;
		}

		function calculatePxHeight() {
			if (!programModel.count) return;
			var totalHeight = 0;
			var blockHeight = 0;
			var blockLength = 0;

			// Each segment is 10 minutes
			var segmentSize = (programDisplayHeight / 24.0) / 6

			if (programModel.count === 1) {
				programModel.get(0).pxHeight = programDisplayHeight;
				return;
			}
			for (var i = 0; i < programModel.count - 1; i++) {
				blockLength = programModel.get(i + 1).startHour * 60 + programModel.get(i + 1).startMinute;
				if (i > 0)
					blockLength -= programModel.get(i).startHour * 60 + programModel.get(i).startMinute;
				//1.5 pixels per 10 minutes for Toon, 2 pixels per 10 minutes for NXT
				blockHeight = Math.floor(blockLength / 10 * segmentSize);
				totalHeight += blockHeight;
				programModel.get(i).pxHeight = blockHeight;
			}
			//Last block in day
			programModel.get(programModel.count - 1).pxHeight = programDisplayHeight - totalHeight;
		}
	}

	// Populate program for one day.
	function populateDayProgram(dayProgram) {
		programModel.clear();
		for(var i = 0; i < dayProgram.length; i++) {
			var programItem = dayProgram[i];
			programItem['pxHeight'] = 0;
			programModel.append(dayProgram[i]);
		}
		p.calculatePxHeight();
	}

	Component {
		id: programRectangle
		Item {
			width: 75 * horizontalScaling
			height: pxHeight;
			RoundedRectangle {
				id: rectangle
				radius: designElements.radius
				mouseEnabled: false
				color: app.stateColor[targetState]
				height: parent.height - (p.isLastInDay(index) ? 0 : 2 )
				width: parent.width
				topLeftRadiusRatio: p.isFirstInDay(index) ? 1 : 0
				topRightRadiusRatio: p.isFirstInDay(index) ? 1 : 0
				bottomRightRadiusRatio: p.isLastInDay(index) ?  1 : 0
				bottomLeftRadiusRatio: p.isLastInDay(index) ? 1 : 0
				opacity: !dayEnabled ? 0.3 : (!isDaySelected ? 0.7 : 1)
				visible: height > 0

				Text {
					id: txtMode
					text: app.stateName[targetState]
					visible: (paintedHeight < parent.height) && isDaySelected && dayEnabled
					color: colors.psModeName
					font.pixelSize: qfont.bodyText
					font.family: qfont.regular.name
					anchors.centerIn: parent
				}
			}
			Item {
				id: separator
				width: parent.width
				height: p.isLastInDay(index) ? 0 : 2
				anchors.bottom: parent.bottom
			}
		}
	}

	ListModel {
		id: programModel
	}

	RoundedRectangle {
		// Overlay to visualy indicate that the termostat programming is disabled.
		color: colors.psDisabled
		opacity: 0.3
		anchors.fill: parent
		visible: !dayEnabled
	}

	Column {
		id: column
		height: parent.extHeight
		width: parent.width

		Item {
			id: dayButton
			width: parent.width
			height: Math.round(44 * verticalScaling)

			Rectangle {
				id: txtDay
				width: parent.width
				height: Math.round(36 * verticalScaling)
				radius: designElements.radius
				color: (isDaySelected && dayEnabled) ? colors.psDayBckgSelected : colors.psDayBckgUnselected
				border.color: colors.psDayBckgUnselected
				border.width: isDaySelected ? Math.round(2 * verticalScaling) : 0

				Text {
					text: i18n.daysExtraShort[index + 1] // Monday based index
					color: {
						if (!dayEnabled) colors.psDisabled;
						else if (isDaySelected && dayEnabled) colors.psDayTextSelected;
						else colors.psDayTextUnselected;
					}
					anchors.centerIn: parent
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.navigationTitle
					}
				}
			}
		}

		Repeater {
			id: repeatProgram
			model: programModel
			delegate: programRectangle
			anchors.topMargin: 8;
		}
	}

	MouseArea {
		id: maColumn
		anchors.fill: column
		enabled: dayEnabled
		onClicked: {
			daySelected((index + 1) % 7);
		}
	}
}
