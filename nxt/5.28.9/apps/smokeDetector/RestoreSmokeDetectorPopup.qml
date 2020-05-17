import QtQuick 2.1
import qb.components 1.0

Item {
	id: popupContent

	Item {
		id: removeFailedSection
		visible: false
		anchors.fill: parent

		Image {
			id: greenBullet1
			anchors {
				left: parent.left
				leftMargin: designElements.hMargin15
				verticalCenter: greenBullet1Text.verticalCenter
			}
			source: "image://scaled/images/green-bullet.svg"
		}

		Text {
			id: greenBullet1Text
			anchors {
				left: greenBullet1.right
				leftMargin: designElements.hMargin15
				topMargin: designElements.vMargin15
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
			color: colors.smokedetectorPopupText
			text: qsTr("remove_smoke_detector_error_line_1")
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
				rightMargin: anchors.leftMargin
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.semiBold.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("remove_smoke_detector_error_line_2");
		}

		Text {
			id: deletePlugInfoText
			anchors {
				left: greenBullet2Text.left
				baseline: greenBullet2Text.bottom
				baselineOffset: Math.round(40 * verticalScaling)
				right: parent.right
				rightMargin: Math.round(15 * horizontalScaling)
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.bold.name
			}
			wrapMode: Text.WordWrap
			color: colors.smokedetectorPopupText
			text: qsTr("remove_smoke_detector_error_line_3")
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
		color: colors.smokedetectorPopupText
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
		bigRadius: designElements.radius

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
			left: parent.left;
			leftMargin: popupText.anchors.leftMargin
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
		color: colors.smokedetectorPopupText
		visible: false
	}

	states: [
		State {
			name: "CONNECTING"
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: popupText; text: qsTr("Press the button on the smokedetector three times in a row to restore it") }
		},
		State {
			name: "DECOUPLE"
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: popupText; text: qsTr("Press the button on the smokedetector three times in a row to remove it") }
		},
		State {
			name: "RESTORE_FAIL"
			PropertyChanges { target: popupText; text: qsTr("Restore failed press try again to restore the smokedetector") }
		},
		State {
			name: "DECOUPLE_FAIL"
			PropertyChanges { target: popupText; visible: false }
			PropertyChanges { target: removeFailedSection; visible: true }
		},
		State {
			name: "RESTORE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("The smokedetector is restored") }
			PropertyChanges { target: popupTextBottom; visible: true; text: qsTr("Press add to link the smokedetector") }
			PropertyChanges { target: greenCheck; visible: true }
		},
		State {
			name: "DECOUPLE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("The smokedetector is decoupled") }
			PropertyChanges { target: greenCheck; visible: true }
		},
		State {
			name: "DECOUPLE_SUCCESS_UNKNOWN"
			PropertyChanges { target: popupText; text: qsTr("Unknown device is decoupled") }
			PropertyChanges { target: greenCheck; visible: true }
		},
		State {
			name: "DELETE_SUCCESS"
			PropertyChanges { target: popupText; text: qsTr("The smokedetector is removed") }
			PropertyChanges { target: greenCheck; visible: true }
		}
	]
}
