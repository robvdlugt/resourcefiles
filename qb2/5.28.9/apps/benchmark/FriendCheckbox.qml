import QtQuick 2.1
import qb.components 1.0

Item {
	id: friendBox

	width: Math.round(448 * horizontalScaling)
	height: checkBox.height

	signal infoClicked
	signal deleteClicked
	signal boxClicked

	property alias auxText: auxText.text
	property alias boxEnabled: checkBox.enabled
	property alias text: checkBox.text
	property alias selected: checkBox.selected

	property string kpiPrefix: "FriendCheckbox."

	StandardCheckBox {
		id: checkBox
		anchors {
			left: parent.left
			right: infoIcon.left
			rightMargin: designElements.spacing6
		}

		Component.onCompleted: { selectedChanged.connect(boxClicked); }
	}

	Text {
		id: auxText
		anchors {
			verticalCenter:parent.verticalCenter
			right: checkBox.right
			rightMargin: designElements.hMargin5
		}
		color: colors.cbText
		font {
			family: qfont.lightItalic.name
			pixelSize: qfont.metaText
		}
		textFormat: Text.PlainText // Prevent XSS/HTML injection
	}

	IconButton {
		id: infoIcon
		anchors {
			verticalCenter: parent.verticalCenter
			right: deleteIcon.left
			rightMargin: designElements.spacing6
		}
		iconSource: "qrc:/images/info.svg"

		onClicked: infoClicked()
	}

	IconButton {
		id: deleteIcon
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
		}
		iconSource: "qrc:/images/delete.svg"

		onClicked: deleteClicked()
	}
}
