import QtQuick 2.1
import qb.components 1.0

Tile {
	id: dayTile

	property alias dayTileTitleText: dayTileTitleText.text
	property alias dayTileLeftRectLeftText: leftRect.leftTextText
	property alias dayTileMiddleRectLeftText: middleRect.leftTextText
	property alias dayTileRightRectLeftText: rightRect.leftTextText
	property alias dayTileLeftRectRightText: leftRect.rightTextText
	property alias dayTileMiddleRectRightText: middleRect.rightTextText
	property alias dayTileRightRectRightText: rightRect.rightTextText

	property bool displayInEuro: false
	property string unitString: ""
	property variant values: [0, 0, 0]

	property int bigHouseHeight: Math.round(60 * verticalScaling)
	property int middleHouseHeight: Math.round(51 * verticalScaling)
	property int smallHouseHeight: Math.round(42 * verticalScaling)

	property string agreementType

	property color rectangleColor: dimmableColors.graphTileRect

	property bool consumption: true
	property bool production: false

	function init() {
		app.dayChanged.connect(updateDayTexts);
		updateDayTexts();
	}

	Component.onDestruction: {
		app.dayChanged.disconnect(updateDayTexts);
	}

	function lastButXDay(x) {
		var now = new Date();
		var day = now.getDay();
		if (x > day)
			day += 7;
		return i18n.daysExtraShort[day - x];
	}

	function updateDayTexts() {
		leftRect.dayTextText = lastButXDay(3);
		middleRect.dayTextText = lastButXDay(2);
		rightRect.dayTextText = lastButXDay(1);
	}

	function roundUsageValue(value) {
		return app.usageTileRounding(agreementType, "days", value);
	}

	function roundToDecimals(value, decimals) {
		var multiplicator = Math.pow(10, decimals);
		value *= multiplicator;
		value = Math.round(value);
		value /= multiplicator;
		return value;
	}

	onClicked: {
		stage.openFullscreen(app.graphScreenUrl, {agreementType: dayTile.agreementType, unitType: displayInEuro ? "money" : "energy", intervalType: "days", consumption: consumption, production: production})
	}

	onValuesChanged: {
		var valuesRounded = [];
		var decimals;
		for (var i=0; i<values.length; i++) {
			decimals = displayInEuro ? 2 : app.usageTileRoundingDecimals(agreementType, "days", values[i]);
			valuesRounded[i] = roundToDecimals(values[i], decimals);
		}

		//Houses can have 3 different heights. If values match use the same house sizes
		//Value array 0 has the value of the oldest left house
		if ((valuesRounded[0] === valuesRounded[1]) && (valuesRounded[0] === valuesRounded[2])) {
			leftRect.height = middleRect.height = rightRect.height = middleHouseHeight;
		} else if ((valuesRounded[0] === valuesRounded[1]) && (valuesRounded[0] !== valuesRounded[2])) {
			leftRect.height = middleRect.height = middleHouseHeight;
			if (valuesRounded[0] < valuesRounded[2])
				rightRect.height = bigHouseHeight;
			else
				rightRect.height = smallHouseHeight;
		} else if ((valuesRounded[0] === valuesRounded[2]) && (valuesRounded[0] !== valuesRounded[1])) {
			leftRect.height = rightRect.height = middleHouseHeight;
			if(valuesRounded[0] < valuesRounded[1])
				middleRect.height = bigHouseHeight;
			else
				middleRect.height = smallHouseHeight;
		} else if ((valuesRounded[1] === valuesRounded[2]) && (valuesRounded[0] !== valuesRounded[1])) {
			middleRect.height = rightRect.height = middleHouseHeight;
			if (valuesRounded[1] < valuesRounded[0])
				leftRect.height = bigHouseHeight;
			else
				leftRect.height = smallHouseHeight;
		} else {
			if (valuesRounded[0] < valuesRounded[1]) {
				if (valuesRounded[0] < valuesRounded[2]) {
					leftRect.height = smallHouseHeight;
					if (valuesRounded[1] < valuesRounded[2]) {
						middleRect.height = middleHouseHeight;
						rightRect.height = bigHouseHeight;
					} else {
						middleRect.height = bigHouseHeight;
						rightRect.height = middleHouseHeight;
					}
				} else {
					leftRect.height = middleHouseHeight;
					middleRect.height = bigHouseHeight;
					rightRect.height = smallHouseHeight;
				}
			} else	{
				if (valuesRounded[0] > valuesRounded[2]) {
					leftRect.height = bigHouseHeight;
					if (valuesRounded[1] < valuesRounded[2]) {
						middleRect.height = smallHouseHeight;
						rightRect.height = middleHouseHeight;
					} else {
						middleRect.height = middleHouseHeight;
						rightRect.height = smallHouseHeight;
					}
				} else {
					leftRect.height = middleHouseHeight;
					middleRect.height = smallHouseHeight;
					rightRect.height = bigHouseHeight;
				}
			}
		}
	}

	Text {
		id: dayTileTitleText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	Item {
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(41 * verticalScaling)
		}
		height: Math.round(60 * verticalScaling)
		width: Math.round(172 * horizontalScaling)

		DayTileRectangle {
			id: leftRect
			height: middleHouseHeight
			color: rectangleColor
			anchors {
				right: middleRect.left
				rightMargin: Math.round(8 * horizontalScaling)
				bottom: parent.bottom
			}
			leftTextText: displayInEuro ? i18n.currency(values[0]) : roundUsageValue(values[0]) + " "
			rightTextText: displayInEuro ? "" : unitString
		}

		DayTileRectangle {
			id: middleRect
			height: middleHouseHeight
			color: rectangleColor
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.bottom: parent.bottom
			leftTextText: displayInEuro ? i18n.currency(values[1]) : roundUsageValue(values[1]) + " "
			rightTextText: displayInEuro ? "" : unitString
		}

		DayTileRectangle {
			id: rightRect
			height: middleHouseHeight
			color: rectangleColor
			anchors {
				left: middleRect.right
				leftMargin: Math.round(8 * horizontalScaling)
				bottom: parent.bottom
			}
			leftTextText: displayInEuro ? i18n.currency(values[2]) : roundUsageValue(values[2]) + " "
			rightTextText: displayInEuro ? "" : unitString
		}
	}
}
