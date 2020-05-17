import QtQuick 2.1

Item {
	Text {
		id: text
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(50 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.controlPanelTileText
		text: qsTr("signal_strength_explanation")
		wrapMode: Text.WordWrap
	}

	Column {
		id: signalColumn
		anchors {
			top: text.bottom
			topMargin: designElements.vMargin15
			horizontalCenter: parent.horizontalCenter
		}
		property variant signalNames: [qsTr("Bad"), qsTr("Poor"), qsTr("Decent"), qsTr("Good"), qsTr("Very good")]

		Repeater {
			id: starRowRepeater
			model: 5

			Row {
				id: signalStrengthRow
				spacing: Math.round(3 * horizontalScaling)
				property int starRowIndex: index

				Repeater {
					id: signalStrengthStars
					model: 5
					Image {
						anchors.verticalCenter: parent.verticalCenter
						source: "qrc:/images/star-" + (index <= starRowIndex ? "on" : "off") + ".svg";
					}
				}

				Item {
					id: spacer
					width: designElements.hMargin10
					height: 1
				}

				Text {
					id: signalLabel
					color: colors.controlPanelQualityExplanation
					font {
						pixelSize: qfont.bodyText
						family: qfont.regular.name
					}
					text: signalColumn.signalNames[starRowIndex]
				}
			}
		}
	}
}
