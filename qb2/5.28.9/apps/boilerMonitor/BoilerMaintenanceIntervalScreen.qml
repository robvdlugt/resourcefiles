import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

EditScreen {
	id: root
	screenTitle: qsTr("screen-title")

	QtObject {
		id: p
		property variant selectedInterval
		property variant intervalsList: [
			{"interval": 365,	"text": qsTr("Every year")},
			{"interval": 730,	"text": qsTr("Every two years")},
			{"interval": 1095,	"text": qsTr("Every three years")}
		]
	}

	onScreenShown: {
		p.selectedInterval = app.boilerInfo.serviceInterval;
		if (p.selectedInterval === undefined || p.selectedInterval === null)
			p.selectedInterval = p.intervalsList[1].interval; // two years as default
	}

	onScreenSaved: {
		app.setBoilerMaintenanceInterval(p.selectedInterval, root);
	}

	Text {
		id: headerText
		anchors {
			top: parent.top
			topMargin: Math.round(42 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}
		color: colors._harry
		wrapMode: Text.WordWrap
		text: qsTr("header-text")
	}

	Text {
		id: bodyText
		anchors {
			top: headerText.baseline
			topMargin: Math.round(20 * verticalScaling)
			left: headerText.left
			right: headerText.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors._gandalf
		wrapMode: Text.WordWrap
		text: qsTr("body-text")
	}

	ControlGroup {
		id: radioControlGroup
		exclusive: true
	}

	Column {
		id: radioColumn
		anchors {
			top: bodyText.bottom
			topMargin: Math.round(20 * verticalScaling)
			left: bodyText.left
			right: bodyText.right
		}
		spacing: Math.round(20 * verticalScaling)

		Repeater {
			id: radioRepeater
			model: p.intervalsList
			property int radioWidth: 0
			delegate: StandardRadioButton {
				id: radioButton
				width: radioRepeater.radioWidth
				spacing: Math.round(40 * horizontalScaling)
				controlGroup: radioControlGroup
				selected: p.selectedInterval === modelData.interval
				text: modelData.text

				Component.onCompleted: radioRepeater.radioWidth = Math.max(radioRepeater.radioWidth, radioButton.implicitWidth)

				onClicked: p.selectedInterval = modelData.interval
			}
		}
	}

	WarningBox {
		id: infoBox
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(34 * verticalScaling)
			left: headerText.left
			right: headerText.right
		}
		height: Math.round(86 * verticalScaling)

		warningText: qsTr("infobox-text")
		warningIcon: Qt.resolvedUrl("qrc:/images/info_warningbox.svg")
	}
}
