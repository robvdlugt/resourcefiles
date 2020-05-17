import QtQuick 2.1
import qb.components 1.0

/**
	Component showing program blocks for single day together with tab-button for the day.
 */
Item {
	id: root

	property string kpiPostfix: "Thermostatday" + index
	property bool isDaySelected: false
	property bool dayEnabled: true
	property var stateNames:  [ qsTr('Comfort'), qsTr('Home'), qsTr('Sleep'), qsTr('Away'), qsTr('Vacation') ]
	property var stateColors: [colors.tpModeComfort, colors.tpModeHome, colors.tpModeSleep, colors.tpModeAway]

	// Signal emitted when day is daySelected
	// parameter dayToSelect is Sunday based index of the day
	signal daySelected(int dayToSelect);

	property int programDisplayHeight: (isNxt ? 288 : 216)

	width: Math.round(75 * horizontalScaling)
	height: column.height

	QtObject {
		id: p
		property int dayProgramHeight: 0

		function isLastInDay(blockIdx) {
			return (blockIdx === programModel.count - 1);
		}

		function isFirstInDay(blockIdx) {
			var result = (blockIdx === 0) || (blockIdx === 1 && (programModel.get(blockIdx).startHour + programModel.get(blockIdx).startMin === 0))
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
				blockLength = programModel.get(i + 1).startHour * 60 + programModel.get(i + 1).startMin;
				if (i > 0)
					blockLength -= programModel.get(i).startHour * 60 + programModel.get(i).startMin;
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
				color: stateColors[targetState]
				height: parent.height - (p.isLastInDay(index) ? 0 : 2 )
				width: parent.width
				topLeftRadiusRatio: p.isFirstInDay(index) ? 1 : 0
				topRightRadiusRatio: p.isFirstInDay(index) ? 1 : 0
				bottomRightRadiusRatio: p.isLastInDay(index) ?  1 : 0
				bottomLeftRadiusRatio: p.isLastInDay(index) ? 1 : 0
				opacity: (!dayEnabled ? 0.3 : (!isDaySelected ? 0.7 : 1))
				visible: height > 0

				Text {
					id: txtMode
					text: stateNames[targetState]
					visible: (paintedHeight < parent.height) && isDaySelected && dayEnabled ? true : false
					color: colors.psModeName
					font.pixelSize: qfont.metaText
					font.family: qfont.semiBold.name
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
		width: parent.width

		Rectangle {
			id: dayButton
			width: parent.width
			height: Math.round(36 * verticalScaling)
			radius: designElements.radius
			color: (isDaySelected && dayEnabled) ? colors.psDayBckgSelected : colors.psDayBckgUnselected
			border.color: colors.psDayBckgUnselected
			border.width: isDaySelected ? Math.round(2 * verticalScaling) : 0

			Text {
				text: i18n.daysExtraShort[index + 1] // Monday based index
				color: !dayEnabled ?  colors.psDisabled : (isDaySelected ? colors.psDayTextSelected : colors.psDayTextUnselected)
				anchors.centerIn: parent
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.navigationTitle
				}
			}
		}

		Item {
			id: spacer
			width: 1
			height: Math.round(8 * verticalScaling)
		}

		Repeater {
			id: repeatProgram
			model: programModel
			delegate: programRectangle
		}
	}

	MouseArea {
		id: maColumn
		anchors.fill: column
		enabled: dayEnabled
		onClicked: daySelected(index)
	}
}
