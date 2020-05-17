import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Item {
	id: alarmPanelIntroFrame

	QtObject {
		id: p
		property string newPin

		function setPinCallback(success, reason) {
			pinThrobber.visible = false;
			if (success === true) {
				reenterPinPage.state = "PIN_SET";
				util.delayedCall(3000, function () { app.alarmPinIsSet = true });
			} else {
				enterPinPage.state = "ERROR";
				pageSelector.navigateBtn(1);
			}
			reenterPinKeyboard.clear();
		}

		function cancelPinEntry() {
			enterPinPage.state = "";
			reenterPinPage.state = "";
			pinKeyboard.clear();
			reenterPinKeyboard.clear();
			pinThrobber.visible = false;
			p.newPin = "";
			pageSelector.navigateBtn(0);
		}

		function onShowingChanged() {
			if (!showing)
				p.cancelPinEntry();
		}
	}

	Component.onCompleted: {
		showingChanged.connect(p.onShowingChanged);
	}

	Component.onDestruction: {
		showingChanged.disconnect(p.onShowingChanged);
	}

	Flickable {
		id: container
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
			bottom: pageSelector.top
			leftMargin: Math.round(20 * verticalScaling)
			rightMargin: anchors.leftMargin
		}
		contentWidth: containerRow.width
		clip: true
		interactive: false
		property int pageCount: Math.ceil(contentWidth / width)

		Behavior on contentX {
			enabled: isNxt
			SmoothedAnimation { duration: 200 }
		}

		function showPage(page) {
			if (page < 0 || page >= pageCount)
				return;

			container.contentX = container.width * page;
		}

		Row {
			id: containerRow
			height: parent.height

			Item {
				id: introPage
				width: container.width
				height: container.height

				Text {
					id: introTitleText
					anchors {
						top: parent.top
						topMargin: designElements.vMargin15
						left: choosePinBtn.left
						right: choosePinBtn.right
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.alarmPanelStateText
					text: qsTr("A safe set up")
					elide: Text.ElideRight
				}

				Image {
					id: introImg
					anchors {
						top: introTitleText.bottom
						topMargin: designElements.vMargin20
						horizontalCenter: parent.horizontalCenter
					}
					source: "image://scaled/apps/controlPanel/drawables/living-room.svg"
				}

				Text {
					id: introBodyText
					anchors {
						top: introImg.bottom
						topMargin: designElements.vMargin20
						left: choosePinBtn.left
						right: choosePinBtn.right
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.alarmPanelStateText
					text: qsTr("intro-body-text")
					wrapMode: Text.WordWrap
				}

				StandardButton {
					id: choosePinBtn
					anchors {
						bottom: parent.bottom
						left: parent.left
						right: parent.right
						leftMargin: container.anchors.leftMargin
						rightMargin: anchors.leftMargin
					}
					primary: true
					text: qsTr("Choose PIN code")
					onClicked: pageSelector.navigateBtn(1)
				}
			}

			Item {
				id: enterPinPage
				width: container.width
				height: container.height

				Text {
					id: pinTitleText
					anchors {
						top: parent.top
						left: parent.left
						right: parent.right
					}
					font {
						family: qfont.bold.name
						pixelSize: qfont.titleText
					}
					color: colors.alarmPanelStateText
					text: qsTr("Choose a 4-digit PIN code")
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
				}

				NumericKeyboard {
					id: pinKeyboard
					anchors {
						bottom: continueBtn.top
						bottomMargin: pinKeyboard.buttonSpace
						horizontalCenter: parent.horizontalCenter
					}
					buttonWidth: Math.round(60 * verticalScaling)
					buttonHeight: Math.round(50 * verticalScaling)
					buttonSpace: designElements.vMargin10
					pinMode: true
					maxTextLength: 4

					onPinEntered: {
						p.newPin = pin;
						continueBtn.enabled = true;
					}
					onNumberLengthChanged: {
						if (numberLength < maxTextLength)
							continueBtn.enabled = false;
					}
				}

				StandardButton {
					id: continueBtn
					anchors {
						bottom: parent.bottom
						left: pinKeyboard.left
						right: pinKeyboard.right
					}
					enabled: false
					primary: true
					text: qsTr("Confirm")
					onClicked: {
						pageSelector.navigateBtn(2)
					}
				}

				states: [
					State {
						name: "ERROR"
						PropertyChanges {
							target: pinTitleText
							text: qsTr("There was an error setting the PIN, please try again.").arg(colors.alarmPanelTextHighlight.toString());
						}
					}
				]
			}

			Item {
				id: reenterPinPage
				width: container.width
				height: container.height

				Text {
					id: reenterPinTitleText
					anchors {
						top: parent.top
						left: parent.left
						right: parent.right
					}
					font {
						family: qfont.bold.name
						pixelSize: qfont.titleText
					}
					color: colors.alarmPanelStateText
					text: qsTr("Toon needs your PIN one more time")
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
				}

				NumericKeyboard {
					id: reenterPinKeyboard
					anchors {
						bottom: parent.bottom
						bottomMargin: continueBtn.height + reenterPinKeyboard.buttonSpace
						horizontalCenter: parent.horizontalCenter
					}
					buttonWidth: pinKeyboard.buttonWidth
					buttonHeight: pinKeyboard.buttonHeight
					buttonSpace: pinKeyboard.buttonSpace
					pinMode: true
					maxTextLength: pinKeyboard.maxTextLength

					onPinEntered: {
						if (pin === p.newPin) {
							pinThrobber.visible = true;
							app.setAlarmPinCode("", p.newPin, p.setPinCallback);
							p.newPin = "";
							pinKeyboard.clear();
						} else {
							reenterPinPage.state = "WRONG_PIN";
							reenterPinKeyboard.wrongPin();
						}
					}
				}

				Throbber {
					id: pinThrobber
					width: height
					height: Math.round(30 * verticalScaling)
					anchors {
						top: reenterPinKeyboard.top
						topMargin: designElements.vMargin10
						left: reenterPinKeyboard.right
						leftMargin: designElements.hMargin5
					}
					visible: false

					smallRadius: 1.5
					mediumRadius: 2
					largeRadius: 2.5
					bigRadius: 3
				}

				Text {
					id: cancelTextBtn
					anchors {
						bottom: parent.bottom
						bottomMargin: designElements.vMargin5
						left: reenterPinKeyboard.left
						right: reenterPinKeyboard.right
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
						underline: true
					}
					color: colors.alarmPanelStateText
					text: qsTranslate("AlarmPanelControlFrame", "Cancel")
					elide: Text.ElideRight
					horizontalAlignment: Text.AlignHCenter

					MouseArea {
						anchors.fill: parent
						onClicked: {
							p.cancelPinEntry();
						}
					}
				}

				Text {
					id: pinSetText
					anchors {
						bottom: pinSetImg.top
						bottomMargin: Math.round(30 * verticalScaling)
						left: parent.left
						right: parent.right
					}
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.alarmPanelStateText
					text: qsTr("New PIN set up")
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					visible: false
				}

				Image {
					id: pinSetImg
					anchors.centerIn: parent
					source: "qrc:/images/good.svg"
					width: Math.round(72 * horizontalScaling)
					sourceSize.width: width
					visible: false
				}

				states: [
					State {
						name: "WRONG_PIN"
						PropertyChanges { target: reenterPinTitleText; text: qsTr("Looks like that was not the same number") }
					},
					State {
						name: "PIN_SET"
						PropertyChanges { target: pinSetText; visible: true }
						PropertyChanges { target: pinSetImg; visible: true }
						PropertyChanges { target: reenterPinTitleText; visible: false }
						PropertyChanges { target: reenterPinKeyboard; visible: false }
						PropertyChanges { target: cancelTextBtn; visible: false }
					}
				]
			}
		}
	}

	DottedSelector {
		id: pageSelector
		anchors {
			bottom: parent.bottom
			horizontalCenter: parent.horizontalCenter
		}
		height: Math.round(32 * verticalScaling)
		pageCount: 3
		leftArrowVisible: false
		rightArrowVisible: false
		onNavigate: container.showPage(page)
	}
}
