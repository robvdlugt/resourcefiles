import QtQuick 2.1

import qb.components 1.0

Screen {
	id: localAccessScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("zwave_control_title")

	onShown: radioButtonList.currentIndex = app.zwaveControlEnabled ? 0 : 1
	onSaved: app.setZwaveControlState(radioButtonList.currentIndex === 0 ? true : false)

	Text {
		id: bodyText

		wrapMode: Text.WordWrap
		color: colors.localAccesBody
		text: qsTr("zwave_control_body")

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name

		anchors {
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(60 * horizontalScaling)
		}
	}

	RadioButtonList {
		id: radioButtonList
		radioLabelWidth: Math.round(150 * horizontalScaling)

		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyText.baseline
			topMargin: Math.round(60 * verticalScaling)
		}

		title: qsTr("Z-Wave control")

		Component.onCompleted: {
			addItem(qsTr("On"));
			addItem(qsTr("Off"));
			forceLayout();
		}
	}

	WarningBox {
		width: Math.round(600 * horizontalScaling)
		height: Math.round(80 * verticalScaling)
		warningText: qsTr("zwave_control_warning")
		anchors {
			top: radioButtonList.bottom
			topMargin: designElements.vMargin10
			horizontalCenter: parent.horizontalCenter
		}
	}
}
