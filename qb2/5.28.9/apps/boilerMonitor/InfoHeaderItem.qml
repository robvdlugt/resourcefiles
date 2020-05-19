import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

Item {
	id: infoHeaderItem
	height: infoHeaderRow.height
	property bool showIndicator: true
	property bool indicatorOk: false
	property bool highlight: false
	property string headerText
	property alias infoText: textLabel.prefilledText
	property bool onlyLabel: false

	signal editInfo

	RowLayout {
		id: infoHeaderRow
		width: parent.width
		height: textLabel.height
		spacing: designElements.hMargin5

		Rectangle {
			id: indicator
			Layout.preferredWidth: Math.round(10 * horizontalScaling)
			Layout.leftMargin: designElements.hMargin10
			Layout.rightMargin: designElements.hMargin10 - parent.spacing
			height: Layout.preferredWidth
			radius: height / 2
			color: indicatorOk ? colors._pocahontas : colors._middlegrey
			border {
				width: 2
				color: indicatorOk ? colors._middlegrey : (highlight ? colors._branding : colors.white)
			}
			opacity: showIndicator ? 1.0 : 0.0
		}

		EditTextLabel {
			id: textLabel
			Layout.fillWidth: true
			leftTextAvailableWidth: width / 2
			labelFontSize: qfont.bodyText
			readOnly: true
			visible: !onlyLabel
			labelText: headerText

			onClicked: editInfoButton.clicked()
		}

		SingleLabel {
			id: label
			Layout.fillWidth: true
			leftTextSize: qfont.bodyText
			visible: !textLabel.visible
			leftText: headerText

			onClicked: editInfoButton.clicked()
		}

		IconButton {
			id: editInfoButton
			Layout.preferredWidth: width
			enabled: infoHeaderItem.enabled
			primary: highlight && !indicatorOk
			iconSource: Qt.resolvedUrl("qrc:/images/edit.svg");
			visible: !onlyLabel

			onClicked: editInfo();
		}
	}
}
