import QtQuick 2.1

import qb.components 1.0

Screen {
	id: factoryResetScreen

	screenTitle: qsTr("Factory settings")
	anchors.fill: parent
	hasCancelButton: true


	onCustomButtonClicked: {
		app.waitPopup.show();
		resetDelay.start();
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("Reset"));
		disableCustomTopRightButton();
		imSureCheckbox.selected = false;
	}
	
	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	WarningBox {
		id: warningBox

		anchors {
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(67 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(67 * horizontalScaling)
		}

		textPixelSize: qfont.titleText
		warningText: qsTr("restore_factory_title").arg(globals.productOptions["district_heating"] === "1" ? qsTr("heat") : qsTr("gas"))
	}

	Text {
		id: textBelowYellowRectangle

		anchors {
			top: warningBox.bottom
			topMargin: Math.round(37 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(67 * horizontalScaling)
		}

		text: qsTr("restore_factory_text_1")
		color: colors.factoryResetSmallText

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}



	Text {
		id: textBelowText
		anchors {
			top: textBelowYellowRectangle.bottom
			topMargin: Math.round(25 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(67 * horizontalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		text: qsTr("restore_factory_text_2")
		color: colors.factoryResetBigText

		font.pixelSize: qfont.bodyText
		font.family: qfont.regular.name
	}

	StandardCheckBox {
		id: imSureCheckbox
		anchors {
			top: textBelowText.bottom
			topMargin: Math.round(30 * verticalScaling)
			left: warningBox.left
			right: warningBox.right
		}

		text: qsTr('confirmation_text')
		selected: false
		fontColorSelected: colors.cbText
		fontFamilySelected: qfont.regular.name

		onSelectedChanged: {
			if (selected) {
				enableCustomTopRightButton();
			} else {
				disableCustomTopRightButton();
			}
		}
	}

	Timer {
		id: resetDelay
		interval: 100
		running: false
		onTriggered: {
			wizardstate.deleteFile();
			app.factoryReset();
		}
	}
}
