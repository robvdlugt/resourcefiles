import QtQuick 2.0

import qb.components 1.0

Item {
	id: root
	property alias statusArea: statusArea
	property alias infoBox: infoBox
	property bool isCurrentMonth
	property date periodStart
	property date periodEnd

	signal helpButtonClicked()

	StatusUsageStatusArea {
		id: statusArea
		anchors {
			left: parent.left
			leftMargin: Math.round(54 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			top: parent.top
			bottom: infoBox.top
		}

		Component.onCompleted: {
			statusArea.statusBar.helpButton.clicked.connect(helpButtonClicked);
		}
	}

	StatusUsageInformationBox {
		id: infoBox
		anchors {
			left: statusArea.left
			right: statusArea.right
			bottom: parent.bottom
			bottomMargin: Math.round(16 * verticalScaling)
		}
	}
}
