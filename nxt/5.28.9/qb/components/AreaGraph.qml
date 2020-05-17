import QtQuick 2.1

import BasicUIControls 1.0;

/**
 * Component extending AreaGraphControl with other features such as X legend representing 24 hours, Y legend values, horizontal guiding lines, warning icon when there are missing (NaN) values.
 * Y legend values starts at @maxValue and drops to 0 by fixed delta (dependant on @yLegendItemCount).
 * X legend values represents hours from 0:00 till 24:00 with visible only each 2nd hour.
 */
Item {
	id: root

	/// xLegend left margin - right side of the 0 hour (0 hour minutes "00" are anchored left here)
	property int xLegendLeftMargin: Math.round(24 * horizontalScaling)
	/// distance from xLegend hour text right till next hour text right
	property int xLegendItemWidth: Math.round(58 * horizontalScaling)
	property color xLegendTextColor: colors.graphXLegendText
	property int xLegendTextSize: Math.round(12 * horizontalScaling)
	/// baseline offset from xLegend top
	property int xLegendTextBaselineOffset: Math.round(24 * verticalScaling)
	/// yLegend text right margin
	property int yLegendrightMargin: designElements.hMargin10
	/// yLegend text bttom margin from horizontal guiding lines
	property int yLegendBottomMargin: Math.round(8 * verticalScaling)
	/// horizontal guiding lines left margin from component left
	property int yLinesLeftMargin: Math.round(13 * horizontalScaling)
	/// horizontal guiding lines right margin from component right
	property int yLinesRightMargin: designElements.hMargin5
	/// yLegend item height - horizontal guiding lines gap
	property int yLegendItemHeight: Math.round(40 * horizontalScaling)
	/// number of yLegend texts and lines, including zero and with @maxValue as top value
	property int yLegendItemCount: 6
	property color yLegendTextColor: colors.graphYLegendText
	property int yLegendTextSize: qfont.bodyText
	property color yLinesColor: colors.graphHorizontalLine
	/// default graph color
	property alias graphColor: graph.color
	/// second graph color for alternative rate
	property alias graph2ndRateColor: graph.color2
	/// default graph 2 color
	property alias graph2Color: graph2.color
	/// to show or not missing values area (NaNs)
	property alias showNaN: graph.showNaN
	/// color of the missing values area
	property alias colorNaN: graph.colorNaN
	/// opacity of the missing values area
	property alias opacityNaN: graph.opacityNaN
	/// values for graph Y positions scaled by the ratio of @maxValue and the graph area height (without xLegend), effectivly yLegend height
	property alias graphValues: graph.values
	property alias graph2Values: graph2.values
	/// list of indexes when the color of the graph shoudl change from @color to @color2 and back
	property alias colorChangeIndexes: graph.colorChangeIndexes
	/// maximum value for yLegend texts and also used to scale graph Y positions by the graph height
	property real maxValue: 250
	/// warning icon source if there are any missing values (NaNs)
	property alias warningIconSource: hasNaNImage.source
	/// flag to make warning icon visible
	property alias warningIconVisible: hasNaNImage.visible
	property real avgValue: 0.0
	property alias avgLineVisible: avgLine.visible
	property alias graph1Visible: graph.visible
	property alias graph2Visible: graph2.visible

	property bool dstStart: false
	property bool dstEnd: false
	property int dstHourChange: 0

	property string kpiPostfix: "areaGraph"

	QtObject {
		id: p

		property int xLegendItemWidthDstStart: Math.floor(xLegendItemWidth * 12 / 11.5)
		property int xLegendItemWidthDstEnd: Math.floor(xLegendItemWidth * 12 / 12.5)
	}

	/// when graph area (without xLegend and yLegend) is clicked
	signal graphClicked();

	/// returns (x,y) position in area graph of value at index. {"valid", "x", "y"}
	function getValuePos(valueIdx, values) {
		var retVal = {"valid": false, "x": 0.0, "y": 0.0};
		if (values.length <= 1 || graph.yScale == 0 || valueIdx < 0)
			return retVal;
		retVal.valid = true;
		retVal.x = xLegendRow.x + (valueIdx * (graph.width / (values.length - 1)));
		retVal.y = yLegendColumn.height - (values[valueIdx] * graph.yScale);
		return retVal;
	}

	/// vertical Repeater representing yLegend containing texts for values and horizontal guiding lines. The text values going from @maxValue as top down to 0 with
	/// delta deducted from @yLegendItemCount and @maxValue. Each item has the same width as the root component (displaying the horizontal guiding lines).
	Column {
		id: yLegendColumn
		Repeater {
			id: yLegendRepeater
			model: yLegendItemCount
			Item {
				id: yLegendItem
				width: root.width
				height: yLegendItemHeight
				Rectangle {
					id: yLine
					height: Math.round(1 * verticalScaling)
					width: root.width - yLinesLeftMargin - yLinesRightMargin
					anchors.bottom: parent.bottom
					anchors.left: parent.left
					anchors.leftMargin: yLinesLeftMargin
					color: yLinesColor
				}
				Text {
					anchors {
						right: parent.right
						rightMargin: yLegendrightMargin
						bottom: yLine.top
						bottomMargin: yLegendBottomMargin
					}
					font {
						pixelSize: yLegendTextSize
						family: qfont.regular.name
					}
					color: yLegendTextColor
					// text starting with @maxValue and decreased with each index by yDelta (max/(count-1))
					text: (maxValue / (yLegendItemCount - 1)) * (yLegendRepeater.count - index - 1)
				}
			}
		}
	}

	/// Horizontal Repeater representing xLegend containing texts for hours 0:00 till 24:00 with evry 2nd hour shown.
	/// Each Repeater item contains only minutes text "00" on the left and next hour text (e.g. "4") on the right. The zero hour
	/// text "0" and the 24 hour minutes "00" are added separately.
	Row {
		id: xLegendRow
		anchors.top: yLegendColumn.bottom
		anchors.left: parent.left
		anchors.leftMargin: xLegendLeftMargin

		Repeater {
			id: xLegendRepeater
			model: 12
			Item {
				height: root.height - yLegendColumn.height
				width: {
					if (dstStart) {
						index === Math.floor(dstHourChange / 2) ? p.xLegendItemWidthDstStart * 0.5 : p.xLegendItemWidthDstStart;
					} else if (dstEnd) {
						index === Math.floor(dstHourChange / 2) ? p.xLegendItemWidthDstEnd * 1.5 : p.xLegendItemWidthDstEnd;
					} else {
						xLegendItemWidth;
					}
				}

				Text {
					id: hourText
					anchors {
						baseline: parent.top
						baselineOffset: xLegendTextBaselineOffset
						right: parent.right
					}
					font {
						family: qfont.semiBold.name
						pixelSize: xLegendTextSize
					}
					color: xLegendTextColor
					// show only evry 2nd hour
					text: 2 * (index+1)
				}
				Text {
					anchors {
						bottom: hourText.verticalCenter
						left: parent.left
					}
					font {
						family: qfont.semiBold.name
						pixelSize: xLegendTextSize / 2
					}
					color: xLegendTextColor
					text: "00"
				}
			}
		}
	}

	/// separate zero hour text "0" on the left of xLegendRow
	Text {
		id: hour0
		anchors {
			baseline: xLegendRow.top
			baselineOffset: xLegendTextBaselineOffset
			right: xLegendRow.left
		}
		font {
			family: qfont.semiBold.name
			pixelSize: xLegendTextSize
		}
		color: xLegendTextColor
		text: "0"
	}

	/// separate 24 hour minutes text "00" on the right of xLegendRow
	Text {
		id: minute24_00
		anchors {
			bottom: hour0.verticalCenter
			left: xLegendRow.right
		}
		font {
			family: qfont.semiBold.name
			pixelSize: xLegendTextSize / 2
		}
		color: xLegendTextColor
		text: "00"
	}

	AreaGraphControl {
		id: graph
		width: xLegendRow.width;
		height: yLegendColumn.height - yLegendItemHeight
		anchors.left: xLegendRow.left
		anchors.bottom: yLegendColumn.bottom
		yScale: (yLegendItemHeight * (yLegendItemCount - 1)) / maxValue
	}

	AreaGraphControl {
		id: graph2
		width: graph.width;
		height: graph.height
		anchors.left: graph.left
		anchors.bottom: graph.bottom
		yScale: graph.yScale
	}

	MouseArea {
		anchors.top: graph.top
		anchors.left: graph.left
		width: graph.width
		height: graph.width
		onClicked: graphClicked();
	}

	Rectangle {
		id: avgLine
		color: colors.graphAreaAverageLine
		height: Math.round(2 * verticalScaling)
		width: graph.width
		anchors {
			bottom: graph.bottom
			bottomMargin: graph.yScale > 0 ? (avgValue * graph.yScale) -1 : 0;
			left: graph.left
		}
	}

	/// warning icon when missing (NaN) data are present
	Image {
		id: hasNaNImage
		anchors {
			top: parent.top
			topMargin: Math.round(8 * verticalScaling)
			right: graph.right
			rightMargin: Math.round(8 * horizontalScaling)
		}
	}
}

