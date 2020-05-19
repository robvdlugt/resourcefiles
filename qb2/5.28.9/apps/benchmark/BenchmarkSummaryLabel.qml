import QtQuick 2.1

Item {
	id: summaryLabel
	height: summaryBalloon.height

	QtObject {
		id: p

		property string lessEnergy : ""
		property string equalEnergy : ""
		property string moreEnergy : ""
	}

	function setLabel(trend, colorizeColor) {
		visible = true;
		if (trend === 0) {
			summaryText.text = p.equalEnergy;
		} else if (trend === 1) {
			summaryText.text = p.moreEnergy;
		} else if (trend === -1) {
			summaryText.text = p.lessEnergy;
		}
		summaryBalloon.colorizeColor = colorizeColor;
	}

	BenchmarkSmallBalloon {
		id: summaryBalloon
		imageSource: "drawables/notificationBlack.svg"
		colorize: true
	}

	Text {
		id: summaryText
		anchors {
			left: summaryBalloon.right
			leftMargin: Math.round(14 * horizontalScaling)
			right: parent.right
			verticalCenter: summaryBalloon.verticalCenter
		}
		color: colors.benchmarkTopLabel
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		wrapMode: Text.WordWrap
	}

	state: "NORESULT"

	states: [
		State {
			name: "YOURSELF"
			PropertyChanges { target: p; lessEnergy : qsTr("You use less energy"); }
			PropertyChanges { target: p; equalEnergy : qsTr("You use the same amount of energy"); }
			PropertyChanges { target: p; moreEnergy : qsTr("You use more energy"); }
		},
		State {
			name: "FRIENDS"
			PropertyChanges { target: p; lessEnergy : qsTr("You use less energy compared to your friends"); }
			PropertyChanges { target: p; equalEnergy : qsTr("You use an average amount of energy compared to your friends"); }
			PropertyChanges { target: p; moreEnergy : qsTr("You use more energy compared to your friends"); }
		},
		State {
			name: "NORESULT"
			PropertyChanges { target: summaryBalloon; colorizeColor: colors.balloonNoData; }
			PropertyChanges { target: summaryText; text: qsTr("No results received"); }
		},
		State {
			name: "NOTENOUGH"
			PropertyChanges { target: summaryBalloon; colorizeColor: colors.balloonNoData; }
			PropertyChanges { target: summaryText; text: qsTr("Please be patient"); }
		}
	]
}
