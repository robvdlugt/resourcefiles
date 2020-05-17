import QtQuick 2.1
import qb.components 1.0

Tile {
	id: solarMonthPerformance

	//false for cost
	property bool production: true
	property int value: app.monthProduced

	QtObject {
		id: p

		property int isDim: dimState ? 1 : 0
		property variant lessEqualMoreStr: [qsTr('Less'), qsTr('Equal'), qsTr('More')]
		property variant lessEqualMoreImg: [["drawables/panels-cloudy.svg",
											 "drawables/panels-only.svg",
											 "drawables/panels-sun.svg"],
											["drawables/panels-cloudy-dim.svg",
											 "drawables/panels-only-dim.svg",
											 "drawables/panels-sun-dim.svg"]]
		property double diffValue: value - Math.round(app.expectedProduced * (production ? 1 : app.produPrice))
		property int lessEqualMore: diffValue < 0 ? 0 : (diffValue > 0 ? 2 : 1)

		function getValueText() {
			if (isNaN(p.diffValue))
				return '-';
			else if (p.diffValue === 0)
				return '%1'.arg(lessEqualMoreStr[lessEqualMore]);
			else {
				if (production) {
					return '%1 kWh %2'.arg(i18n.number(Math.abs(p.diffValue), 0)).arg(lessEqualMoreStr[lessEqualMore]);
				} else {
					return '%1 %2'.arg(i18n.currency(Math.abs(p.diffValue), i18n.curr_round)).arg(lessEqualMoreStr[lessEqualMore]);
				}
			}
		}

	}

	onClicked: {
		stage.openFullscreen(app.solarScreenUrl,{isYield: false, isUsage: production, intervalType: 1});
	}

	Text {
		id: tileTitle
		color: dimmableColors.tileTitleColor
		text: qsTr("Performance %1").arg(i18n.monthsFull[app.actualMonth])
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.tileTitle
		font.family: qfont.regular.name
	}

	Image {
		id: performanceImage
		source: "image://scaled/apps/solar/" + p.lessEqualMoreImg[p.isDim][p.lessEqualMore]
		sourceSize.height: Math.round(65 * verticalScaling)
		anchors.centerIn: parent
	}

	Text {
		id: tileText
		color: dimmableColors.tileTextColor
		text: p.getValueText()
		anchors {
			horizontalCenter: parent.horizontalCenter
			baseline: parent.bottom
			baselineOffset: designElements.vMarginNeg16
		}
		verticalAlignment: Text.AlignBottom
		horizontalAlignment: Text.AlignRight
		font.pixelSize: qfont.tileText
		font.family: qfont.regular.name
	}
}
