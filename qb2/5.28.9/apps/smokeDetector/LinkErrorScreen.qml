import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0

Screen {
	id: linkErrorScreen

	hasCancelButton: true
	screenTitle: qsTr("Linking failed")

	function handleExcludeResponse(status, type, uuid) {
		qdialog.reset();
		if (status === "deleted") {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Restore smokedetector"), app.restoreSmokedetectorPopupUrl, qsTr("Link"), linkSmokedetector);
			qdialog.context.dynamicContent.state = "RESTORE_SUCCESS";
		} else if (status !== "canceled") {
			if (status !== "timeout")
				zWaveUtils.excludeDevice("stop");
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Restore smokedetector"), app.restoreSmokedetectorPopupUrl, qsTr("Retry"), restoreSmokedetector, qsTr("Cancel"), null);
			qdialog.context.dynamicContent.state = "RESTORE_FAIL";
		}
		qdialog.context.closeBtnForceShow = true;
	}

	function restoreSmokedetector() {
		zWaveUtils.excludeDevice("delete", handleExcludeResponse);
		qdialog.reset();
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Restore smokedetector"), app.restoreSmokedetectorPopupUrl);
		qdialog.context.dynamicContent.state = "CONNECTING";
		qdialog.setClosePopupCallback(cancelRestore);
		return true;
	}

	function linkSmokedetector() {
		hide();
		stage.openFullscreen(app.addSmokeDetectorScreenUrl);
	}

	// cancel button clicked while waiting for smoke detector to be restored
	function cancelRestore() {
		zWaveUtils.excludeDevice("stop");
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	Rectangle {
		id: backgroundRect
		anchors {
			fill: parent
			margins: Math.round(16 * verticalScaling)
		}
		radius: designElements.radius
		color: colors.contentBackground
		clip: true

		Text {
			id: titleText
			anchors {
				top: parent.top
				topMargin: designElements.vMargin20
				left: parent.left
				leftMargin: anchors.topMargin
				right: parent.right
				rightMargin: anchors.rightMargin
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.largeTitle
			}
			color: colors.titleText
			text: qsTr("Linking the smokedetector failed")
			wrapMode: Text.WordWrap
		}

		GridLayout {
			anchors {
				top: titleText.bottom
				topMargin: designElements.vMargin20
				left: titleText.left
				right: titleText.right
			}
			columns: 2
			columnSpacing: designElements.hMargin10
			rowSpacing: designElements.hMargin15

			Text {
				id: hintText
				Layout.fillWidth: true
				Layout.columnSpan: 2
				font {
					pixelSize: qfont.bodyText
					family: qfont.regular.name
				}
				color: colors.text
				text: qsTr("hint_text")
				wrapMode: Text.WordWrap
			}

			Image {
				id: bulletPoint1
				Layout.alignment: Qt.AlignTop
				Layout.topMargin: Math.round(3 * verticalScaling)
				source: "image://scaled/images/green-bullet.svg"
			}

			Text {
				id: bullet1Text
				Layout.fillWidth: true
				font {
					pixelSize: qfont.bodyText
					family: qfont.regular.name
				}
				color: colors.addDeviceText
				text: qsTr("bullet_1_text")
				wrapMode: Text.WordWrap
			}

			StandardButton {
				id: tryAgainButton
				Layout.row: 2
				Layout.column: 1
				text: qsTr("Try again")

				onClicked: {
					hide();
					stage.openFullscreen(app.addSmokeDetectorScreenUrl);
				}
			}

			Image {
				id: bulletPoint2
				Layout.alignment: Qt.AlignTop
				Layout.topMargin: Math.round(3 * verticalScaling)
				source: "image://scaled/images/green-bullet.svg"
			}

			Text {
				id: bullet2Text
				Layout.fillWidth: true
				font {
					pixelSize: qfont.bodyText
					family: qfont.regular.name
				}
				color: colors.addDeviceText
				text: qsTr("bullet_2_text")
				wrapMode: Text.WordWrap
			}

			StandardButton {
				id: restoreButton
				Layout.row: 5
				Layout.column: 1
				text: qsTr("Restore")

				onClicked: {
					restoreSmokedetector();
				}
			}
		}
	}
}
