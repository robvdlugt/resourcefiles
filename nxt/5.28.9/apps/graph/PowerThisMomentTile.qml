import QtQuick 2.1
import qb.components 1.0

import DateTracker 1.0

Tile {
	id: powerMeter

	QtObject {
		id: p

		function redraw() {
			var avg = app.powerUsageData.avgValue;
			avg = (avg === 0 ? 1 : avg);
			var value = app.powerUsageData.value;
			var filledBars;
			if (isNaN(value) || isNaN(avg)) {
				filledBars = 0;
				powerValue.text = "-";
			} else {
				filledBars = Math.round(value / (avg / 3));
				powerValue.text = qsTr("%1 Watt").arg(value);
			}
			powerList.filledBars = filledBars;
		}
	}

	function init() {
		if (app.powerUsageDataRead)
			p.redraw();
		app.powerUsageDataChanged.connect(p.redraw);
	}

	Component.onDestruction: app.powerUsageDataChanged.disconnect(p.redraw);

	onDimStateChanged: p.redraw()

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "energy", intervalType: "hours"})

	Text {
		id: powerWidgetText
		color: dimmableColors.tileTitleColor
		text: qsTr("Power at this moment")
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.tileTitle
		font.family: qfont.regular.name
	}

	PowerList {
		id: powerList
		anchors.centerIn: parent
		barWidth: mask.width
	}

	Image {
		id: mask
		source: maskFile ? "image://" + (dimState ? "scaled" : "colorized/" + bgColor.toString()) + "/apps/graph/drawables/" + maskFile : ""
		anchors.centerIn: powerList
		visible: source ? true : false
		sourceSize.height: Math.round(77 * verticalScaling)
		property string maskFile

		states: [
			State {
				name: "xmas"
				when: DateTracker.month === 12 && (DateTracker.day >= 24 && DateTracker.day <= 26)
				PropertyChanges { target: mask; maskFile: "powerbar-mask-xmas.svg" }
			},
			State {
				name: "valentine"
				when: DateTracker.day === 14 && DateTracker.month === 2
				PropertyChanges { target: mask; maskFile: "powerbar-mask-valentine.svg" }
			}
		]
	}

	Text {
		id: powerValue
		color: dimmableColors.tileTextColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
	}
}
