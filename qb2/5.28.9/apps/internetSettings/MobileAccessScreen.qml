import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: mobileAccessScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("mobile_access_title")

	onShown: radioButtonList.currentIndex = app.mobileAccessEnabled ? 0 : 1
	onSaved: app.setMobileAccessState(radioButtonList.currentIndex === 0 ? true : false)

	Text {
		id: bodyText
		anchors {
			top: parent.top
			topMargin: Math.round(60 * horizontalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(600 * horizontalScaling)
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.mobileAccesBody
		wrapMode: Text.WordWrap
		text: qsTr("mobile_access_body")
	}

	RadioButtonList {
		id: radioButtonList
		radioLabelWidth: Math.round(150 * horizontalScaling)
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyText.baseline
			topMargin: Math.round(60 * verticalScaling)
		}
		title: qsTr("Mobile access")

		Component.onCompleted: {
			addItem(qsTr("On"));
			addItem(qsTr("Off"));
			forceLayout();
		}
	}

	WarningBox {
		width: Math.round(600 * horizontalScaling)
		height: Math.round(80 * verticalScaling)
		warningText: qsTr("mobile_access_warning")
		anchors {
			top: radioButtonList.bottom
			topMargin: Math.round(10 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
	}
}
