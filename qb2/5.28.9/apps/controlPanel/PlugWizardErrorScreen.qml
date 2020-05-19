import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: plugWizardErrorScreen

	property ControlPanelApp app

	hasCancelButton: true
	inNavigationStack: false

	screenTitle: qsTr("Linking plug failed")

	onShown: screenStateController.screenColorDimmedIsReachable = false
	onHidden: screenStateController.screenColorDimmedIsReachable = true

	function abortRestore() {
		zWaveUtils.excludeDevice("stop");
	}

	function handleBottomRightButtonClicked() {
		hide();
	}

	function handleRestoreResponse(status, type, uuid) {
		qdialog.reset()
		if (status === "deleted") {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Restore plug"), app.restoreDecouplePlugPopupUrl, qsTr("Add"), handleBottomRightButtonClicked);
			qdialog.context.dynamicContent.state = "RESTORE_SUCCESS";
		} else if (status !== "canceled") {
			if (status !== "timeout")
				zWaveUtils.excludeDevice("stop");
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Restoring Plug failed"), app.restoreDecouplePlugPopupUrl, qsTr("Retry"), restorePlug, qsTr("Cancel"), null);
			qdialog.context.dynamicContent.state = "RESTORE_FAIL";
		}
		qdialog.context.closeBtnForceShow = true;
	}

	function restorePlug() {
		zWaveUtils.excludeDevice("delete", handleRestoreResponse);
		qdialog.reset();
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Restore plug"), app.restoreDecouplePlugPopupUrl);
		qdialog.context.dynamicContent.state = "RESTORE";
		qdialog.setClosePopupCallback(abortRestore);
		return true;
	}

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Math.round(25 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(30 * horizontalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
		color: colors.plugTabTitle
		text: qsTr("Linking failed.")
	}

	Text {
		id: hintText
		anchors {
			left: titleText.left
			baseline: titleText.baseline
			baselineOffset: Math.round(25 * verticalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		text: qsTr("hint_text")
	}

	Image {
		id: bulletPoint1
		anchors {
			left: titleText.left
			top: hintText.baseline
			topMargin: Math.round(35 * verticalScaling)
		}
		source: "image://scaled/images/green-bullet.svg"
	}
	Text {
		id: bullet1Text
		anchors {
			verticalCenter: bulletPoint1.verticalCenter
			left: bulletPoint1.right
			leftMargin: Math.round(12 * horizontalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		text: qsTr("bullet_1_text")
	}
	StandardButton {
		id: tryAgainButton
		anchors {
			left: bullet1Text.left
			top: bullet1Text.baseline
			topMargin: Math.round(25 * verticalScaling)
		}
		text: qsTr("Try again")
		onClicked: {
			stage.openFullscreen(app.addPlugScreenUrl);
		}
	}

	Image {
		id: bulletPoint2
		anchors {
			left: titleText.left
			top: tryAgainButton.bottom
			topMargin: Math.round(55 * verticalScaling)
		}
		source: "image://scaled/images/green-bullet.svg"
	}
	Text {
		id: bullet2Text1
		anchors {
			verticalCenter: bulletPoint2.verticalCenter
			left: bulletPoint2.right
			leftMargin: Math.round(12 * horizontalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		text: qsTr("bullet_2_text_1")
	}
	Text {
		id: bullet2Text2
		anchors {
			baseline: bullet2Text1.baseline
			baselineOffset: Math.round(23 * verticalScaling)
			left: bullet2Text1.left
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.plugTabText
		text: qsTr("bullet_2_text_2")
	}
	StandardButton {
		id: restoreButton
		anchors {
			left: bullet1Text.left
			top: bullet2Text2.baseline
			topMargin: Math.round(20 * verticalScaling)
		}
		text: qsTr("Restore plug")
		onClicked: restorePlug()
	}
}
