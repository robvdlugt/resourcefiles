import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: localAccessScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("local_access_title")

	onShown: radioButtonList.currentIndex = app.localAccessEnabled ? 0 : 1
	onSaved: app.setLocalAccessState(radioButtonList.currentIndex === 0 ? true : false)

	Text {
		id: bodyText
		anchors {
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		width: Math.round(600 * horizontalScaling)
		color: colors.localAccesBody
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: qsTr("local_access_body")

	}

	RadioButtonList {
		id: radioButtonList
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: bodyText.baseline
			topMargin: Math.round(60 * verticalScaling)
		}
		title: qsTr("Local access")

		Component.onCompleted: {
			addItem(qsTr("On (2 hours)"));
			addItem(qsTr("Off"));
			forceLayout();
		}
	}

	WarningBox {
		width: Math.round(600 * horizontalScaling)
		height: Math.round(80 * verticalScaling);
		anchors {
			top: radioButtonList.bottom
			topMargin: Math.round(10 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		warningText: qsTr("local_access_warning")
	}
}
