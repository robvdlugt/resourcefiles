import QtQuick 2.1
import qb.components 1.0

Item {
	id: popupContent
	property string plugName: ""

	Item {
		id: removeFailedSection
		visible: false
		anchors.fill: parent

		Image {
			id: greenBullet1
			anchors {
				left: parent.left
				leftMargin:  designElements.hMargin15
				verticalCenter: greenBullet1Text.verticalCenter
			}
			source: "image://scaled/images/green-bullet.svg"
		}

		Text {
			id: greenBullet1Text
			anchors {
				left: greenBullet1.right
				leftMargin:  designElements.hMargin15
				baseline: parent.top
				baselineOffset: Math.round(30 * verticalScaling)
				right: parent.right
				rightMargin: designElements.hMargin15
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.semiBold.name
			}
			wrapMode: Text.WordWrap
			color: colors.controlPanelTileText
			text: qsTr("remove_plug_error_1st_bullet")
		}

		Image {
			id: greenBullet2
			anchors {
				left: parent.left
				leftMargin: designElements.hMargin15
				verticalCenter: greenBullet2Text.verticalCenter
			}
			source: "image://scaled/images/green-bullet.svg"
		}

		Text {
			id: greenBullet2Text
			anchors {
				left: greenBullet2.right
				leftMargin: designElements.hMargin15
				baseline: greenBullet1Text.bottom
				baselineOffset: Math.round(40 * verticalScaling)
				right: parent.right
				rightMargin: designElements.hMargin15
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.semiBold.name
			}
			wrapMode: Text.WordWrap
			color: colors.controlPanelTileText
			text: qsTr("remove_plug_error_2nd_bullet")
		}

		Text {
			id: deletePlugInfoText
			anchors {
				left: greenBullet2Text.left
				baseline: greenBullet2Text.bottom
				baselineOffset: Math.round(40 * verticalScaling)
				right: parent.right
				rightMargin: designElements.hMargin15
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.bold.name
			}
			wrapMode: Text.WordWrap
			color: colors.controlPanelTileText
			text: qsTr("remove_plug_error_delete_plug")
		}
	}

	Text {
		id: popupText
		anchors {
			left: parent.left
			leftMargin: Math.round(58 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			bottomMargin: state === "THROBBER" || state === "TEXT_BELOW" ? font.pixelSize : 0
			verticalCenter: parent.verticalCenter
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		visible: true
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		color: colors.controlPanelTileText
		states: [
			State {
				name: "THROBBER"
				when: throbber.visible
				AnchorChanges {target: popupText; anchors.verticalCenter: undefined; anchors.bottom: throbber.top }
			},
			State {
				name: "TEXT_BELOW"
				when: popupTextBottom.visible
				AnchorChanges {target: popupText; anchors.verticalCenter: undefined; anchors.bottom: parent.verticalCenter }
			}
		]
	}

	Throbber {
		id: throbber

		visible: false
		width: Math.round(88 * horizontalScaling)
		height: Math.round(88 * verticalScaling)

		smallRadius: 3
		mediumRadius: 4
		largeRadius: 5
		bigRadius: 6

		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter: parent.verticalCenter
		}
	}

	Image {
		id: greenCheck
		anchors {
			verticalCenter: popupText.verticalCenter
			horizontalCenter: popupText.horizontalCenter
			horizontalCenterOffset: popupText.paintedWidth / 2 + Math.round(30 * horizontalScaling)
		}
		visible: false
		source: "qrc:/images/good.svg"
	}

	Text {
		id: popupTextBottom
		anchors {
			left: parent.left
			leftMargin: Math.round(58 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			top: throbber.visible ? throbber.bottom : popupText.bottom
			topMargin: font.pixelSize
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		horizontalAlignment: Text.AlignHCenter
		wrapMode: Text.WordWrap
		color: colors.controlPanelTileText
		visible: false
	}

	states: [
		State {
			name: "RESTORE"
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: popupText; text: qsTr("Press the button on the Smartplug three times in a row in order to restore the Smartplug") }
		},
		State {
			name: "DECOUPLE"
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: popupText; text: qsTr("remove_plug_info_text") }
		},
		State {
			name: "RESTORE_FAIL"
			PropertyChanges { target: popupText; text: qsTr("Restoring of Smartplug was not successful.") }
			PropertyChanges { target: popupTextBottom; visible: true; text: qsTr("Set the Smartplug closer to Quby and retry to restore.") }
		},
		State {
			name: "DECOUPLE_FAIL"
			PropertyChanges { target: popupText; visible: false }
			PropertyChanges { target: removeFailedSection; visible: true }
		},
		State {
			name: "RESTORE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("The Smartplug is restored.") }
			PropertyChanges { target: popupTextBottom; visible: true; text: qsTr("Unplug the Smartplug for five seconds before adding it to Quby again.") }
			PropertyChanges { target: greenCheck; visible: true }
		},
		State {
			name: "DECOUPLE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("%1 remove_plug_OK_text").arg(plugName) }
			PropertyChanges { target: greenCheck; visible: true }
		},
		State {
			name: "DELETE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("%1 delete_plug_OK_text").arg(plugName) }
			PropertyChanges { target: greenCheck; visible: true }
		}
	]
}
