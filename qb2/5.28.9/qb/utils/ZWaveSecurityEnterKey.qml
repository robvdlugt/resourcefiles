import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

import qb.base 1.0
import qb.components 1.0

Widget {
	id: zwaveSecurityEnterKey
	anchors.fill: parent

	QtObject {
		id: p
		property int totalTime: 0
		property int timeLeft: 0
		property string deviceDsk
		property var callback
	}

	onShown: {
		securityPopup.titleText = qsTr("Secure your connection");
		if (args && args.dsk) {
			p.deviceDsk = args.dsk;
			p.callback = args.callback;
			p.totalTime = p.timeLeft = args.timeout;
			authTimer.restart();
		}
	}

	onHidden: {
		authTimer.stop();
	}

	ColumnLayout {
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			bottom: progressBar.top
			bottomMargin: designElements.vMargin15
		}

		Text {
			id: bodyText
			Layout.fillWidth: true
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.text
			text: qsTr("zwave-security-enter-first-digits")
			wrapMode: Text.WordWrap
		}

		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true

			GridLayout {
				id: fieldGrid
				anchors {
					left: parent.left
					verticalCenter: parent.verticalCenter
				}
				columns: 2

				Rectangle {
					id: dskInputRect
					Layout.preferredWidth: Math.round(90 * horizontalScaling)
					Layout.preferredHeight: Math.round(30 * horizontalScaling)
					border.color: colors._middlegrey
					border.width: 2
					color: "white"
					radius: designElements.radius

					TextInput {
						id: dskInputField
						anchors.fill: parent
						leftPadding: designElements.hMargin5
						rightPadding: leftPadding

						font {
							family: qfont.regular.name
							pixelSize: qfont.navigationTitle
						}
						clip: true
						color: colors.editTextLabelInput
						horizontalAlignment: TextInput.AlignHCenter
						verticalAlignment: TextInput.AlignVCenter
						selectionColor: colors._branding
						selectedTextColor: colors.white

						validator: RegExpValidator { regExp: /\d{5}/ }
						inputMethodHints: Qt.ImhDigitsOnly

						EnterKeyAction.actionId: EnterKeyAction.Done

						onAccepted: continueBtn.clicked()
					}
				}

				Text {
					id: dskFirstLine
					Layout.alignment: Qt.AlignRight
					font {
						family: qfont.regular.name
						pixelSize: qfont.navigationTitle
						letterSpacing: Math.round(2 * horizontalScaling)
					}
					color: colors._pressed
					text: p.deviceDsk.slice(0, 18).replace(/-/g," - ")
					wrapMode: Text.WordWrap
				}

				Text {
					id: dskSecondLine
					Layout.columnSpan: 2
					Layout.alignment: Qt.AlignRight
					font {
						family: qfont.regular.name
						pixelSize: qfont.navigationTitle
						letterSpacing: Math.round(2 * horizontalScaling)
					}
					color: colors._pressed
					text: p.deviceDsk.slice(18).replace(/-/g," - ")
					wrapMode: Text.WordWrap
				}
			}

			Rectangle {
				id: underline
				anchors {
					left: fieldGrid.left
					verticalCenter: fieldGrid.verticalCenter
					verticalCenterOffset: Math.round(3 * verticalScaling)
				}
				width: dskInputRect.width
				height: Math.round(2 * verticalScaling)
				radius: height / 2
				color: colors.accent
			}

			StandardButton {
				id: continueBtn
				anchors {
					right: parent.right
					verticalCenter: fieldGrid.verticalCenter
				}
				minWidth: Math.round(100 * horizontalScaling)
				primary: true
				enabled: dskInputField.acceptableInput
				text: qsTr("Continue")

				onClicked: {
					zWaveUtils.ssaAuthDevice(true, dskInputField.text.concat(p.deviceDsk), p.callback);
					zwaveSecurityEnterKey.state = "busy";
				}
			}

			Throbber {
				id: throbber
				anchors.centerIn: continueBtn
				width: height
				height: continueBtn.height
				visible: false
			}
		}

		WarningBox {
			Layout.fillWidth: true
			autoHeight: true
			warningText: qsTr("zwave-security-dsk-info-text")
			warningIcon: "qrc:/images/info_warningbox.svg"
		}
	}

	ProgressBar {
		id: progressBar
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		height: Math.round(10 * verticalScaling)
		radius: designElements.radius - 1
		topLeftCornerRadiusRatio: 0
		topRightCornerRadiusRatio: 0

		colorBg: "white"
		colorProgress: progress < 0.2 ? colors._marypoppins : colors.progressBarFill
		progress: p.totalTime ? p.timeLeft / p.totalTime : 0
	}

	Timer {
		id: authTimer
		interval: 1000
		repeat: true
		onTriggered: {
			p.timeLeft--;
			if (p.timeLeft === 0) {
				stop();
				zWaveUtils.ssaAuthDevice(false, "", p.callback);
				zwaveSecurityEnterKey.state = "busy";
			}
		}
	}

	states: [
		State {
			name: "busy"
			PropertyChanges { target: continueBtn; visible: false }
			PropertyChanges { target: progressBar; visible: false }
			PropertyChanges { target: dskInputField; readOnly: true; focus: false }
			PropertyChanges { target: throbber; visible: true }
			PropertyChanges { target: authTimer; running: false }
		}
	]
}
