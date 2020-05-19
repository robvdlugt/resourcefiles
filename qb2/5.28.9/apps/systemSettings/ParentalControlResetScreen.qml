import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: parentalControlResetScreen
	hasCancelButton: true
	inNavigationStack: false
	screenTitle: qsTr("resetkey-infopopup-title")
	clip: true

	onCanceled: {
		screenStateController.manualDim = true;
	}

	onCustomButtonClicked: {
		editText.setFocus(false);
		if (parentalControl.reset(editText.inputText)) {
			countly.sendEvent("ParentalControl.Reset", null, null, -1, null);
			stage.openFullscreen(app.parentalControlScreenUrl);
		} else {
			toast.show(qsTr("incorrect-code-toast"), Qt.resolvedUrl("image://scaled/images/bad_white.svg"), 3000);
		}
	}

	onShown: {
		addCustomTopRightButton(qsTr("Done"));
	}


	Column {
		anchors {
			left: parent.left
			leftMargin: Math.round(100 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			top: parent.top
			topMargin: Qt.inputMethod.visible ? Math.round(-30 * verticalScaling) : Math.round(50 * verticalScaling)
		}
		spacing: designElements.vMargin10

		Text {
			id: titleText
			width: parent.width
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors._harry
			text: qsTr("resetkey-infopopup-title")
		}

		Text {
			id: bodyText
			width: parent.width
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors._gandalf
			text: qsTr("resetkey-infopopup-body")
			wrapMode: Text.WordWrap
		}

		Item {
			id: spacer
			width: 1
			height: designElements.vMargin10
		}

		EditTextLabel {
			id: editText
			width: parent.width * 0.7
			labelText: parentalControl.getResetPrefix()
			leftTextAvailableWidth: leftTextImplicitWidth
			maxLength: 30
			inputHints: Qt.ImhPreferNumbers | Qt.ImhPreferUppercase | Qt.ImhSensitiveData
		}
	}

	Toast {
		id: toast
	}
}
