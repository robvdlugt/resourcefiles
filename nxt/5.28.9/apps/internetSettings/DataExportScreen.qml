import QtQuick 2.1

import qb.components 1.0

Screen {
	id: dataExportScreen
	screenTitle: qsTr("data-export-screen-title")

	QtObject {
		id: p
		function getArchiveUrlString() {
			var oneUrlTemplate  = '<font color="%1"><b>%2</b></font>';
			var twoUrlsTemplate = '<font color="%1"><b>%2</b></font> %3 <font color="%1"><b>%4</b></font>';
			if (app.dataExportInfo.archiveAltUrl) {
				return twoUrlsTemplate
					.arg(colors._branding.toString())
					.arg(app.dataExportInfo.archiveUrl)
					.arg(qsTr("or"))
					.arg(app.dataExportInfo.archiveAltUrl);
			} else {
				return oneUrlTemplate
					.arg(colors._branding.toString())
					.arg(app.dataExportInfo.archiveUrl);
			}
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		if (app.dataExportInfo.state === "READY" && app.dataExportInfo.accessTimeoutDate.getTime() < Date.now()) {
			var tmp = app.dataExportInfo;
			tmp.state = "IDLE";
			app.dataExportInfo = tmp;
		}
	}
	onHidden: screenStateController.screenColorDimmedIsReachable = true

	Rectangle {
		anchors {
			fill: parent
			leftMargin: designElements.vMargin15
			rightMargin: anchors.leftMargin
			bottomMargin: designElements.vMargin5
		}
		color: colors.contentBackground
		radius: designElements.radius
	}

	Column {
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		spacing: designElements.vMargin20

		Text {
			id: titleText
			width: parent.width
			font {
				family: qfont.bold.name
				pixelSize: qfont.titleText
			}
			color: colors._harry
			wrapMode: Text.WordWrap
			text: qsTr("data-export-title")
		}

		Text {
			id: bodyText
			width: parent.width
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._gandalf
			wrapMode: Text.WordWrap
			text: qsTr("data-export-body")
		}

		StandardButton {
			id: dataExportBtn
			primary: true
			text: qsTr("Make copy")

			onClicked: {
				app.createDataArchive();
				countly.sendEvent("DataExport.Start", null, null, -1, null);
			}
		}

		WarningBox {
			id: infoBox
			visible: false
			width: parent.width
			autoHeight: true
			warningTextFormat: Text.RichText
		}

		Item {
			id: inProgressItem
			width: childrenRect.width
			height: childrenRect.height
			visible: false

			Throbber {
				id: throbber
			}

			Text {
				id: inProgressText
				anchors {
					verticalCenter: throbber.verticalCenter
					left: throbber.right
					leftMargin: designElements.hMargin20
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors._gandalf
				text: qsTr("Your Toon data is being copied...")
			}
		}
	}

	state: app.dataExportInfo.state
	states: [
		State {
			name: "IDLE"
			PropertyChanges { target: dataExportBtn; visible: true; enabled: true }
		},
		State {
			name: "IN_PROGRESS"
			PropertyChanges { target: dataExportBtn; visible: true; enabled: false }
			PropertyChanges { target: inProgressItem; visible: true }
		},
		State {
			name: "READY"
			PropertyChanges { target: dataExportBtn; visible: false }
			PropertyChanges {
				target: infoBox; visible: true;
				warningText: qsTr("data-export-available %1 %2")
								.arg(p.getArchiveUrlString())
								.arg(qtUtils.dateToString(app.dataExportInfo.accessTimeoutDate, "hh:mm"))
				warningIcon: "qrc:/images/good.svg"
			}
		},
		State {
			name: "ERROR"
			PropertyChanges { target: dataExportBtn; visible: true; enabled: true }
			PropertyChanges {
				target: infoBox; visible: true;
				warningText: qsTr("data-export-failed");
				warningIcon: "qrc:/images/warning.svg"
			}
		}
	]
}
