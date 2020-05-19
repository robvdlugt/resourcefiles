import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	id: connectionQualityFrame

	title: qsTr("Connection quality")
	nextPage: 1
	property ControlPanelApp app

	QtObject {
		id: p

		property url signalStrengthPopupUrl: "SignalStrengthPopup.qml"

		function nodeHealthTestCB(status, health) {
			if (status) {
				for (var i = 0; i < 5; i++)
					signalStrengthStars.itemAt(i).source = "qrc:/images/star-" + (i < health ? "on" : "off") + ".svg";
			}
			selectorWizardSelector.rightArrowEnabled = true;
			state = "checked";
		}
	}

	function initWizardFrame(hasData) {
		if (hasData !== undefined) {
			drawStars();
		} else {
			selectorWizardSelector.rightArrowEnabled = false;
		}
	}

	Text {
		id: text
		anchors {
			top: parent.top
			topMargin: Math.round(79 * verticalScaling)
			left: connectionQualityRow.left
			right: connectionQualityRow.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.plugTabText
		text: qsTr("quality_screen_text")
		wrapMode: Text.WordWrap
	}

	IconButton {
		id: infoPopupButton
		anchors {
			top: text.top
			left: text.right
			leftMargin: Math.round(11 * horizontalScaling)
		}
		iconSource: "qrc:/images/info.svg"
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Signal strength"), p.signalStrengthPopupUrl);
		}
	}

	Row {
		id: connectionQualityRow
		anchors {
			top: text.bottom
			topMargin: Math.round(25 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		height: connectionQualityLabel.height
		spacing: designElements.spacing10

		SingleLabel {
			id: connectionQualityLabel
			width: Math.round(420 * horizontalScaling)

			leftText: qsTr("Connection quality")
			rightText: ""
			rightTextFont: qfont.bold.name
			rightTextSize: qfont.titleText

			Row {
				id: signalStrengthRow
				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: designElements.hMargin10
				}
				spacing: Math.round(2 * horizontalScaling)

				Repeater {
					id: signalStrengthStars
					model: 5

					Image {
					}
				}
			}

			Text {
				id: progressText
				anchors {
					right: parent.right
					rightMargin: designElements.hMargin10
					verticalCenter: parent.verticalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
			}
		}

		StandardButton {
			id: checkQualityButton
			height: connectionQualityLabel.height
			text: qsTr("Check quality")

			onClicked: {
				if (connectionQualityFrame.state === "begin" || connectionQualityFrame.state === "checked") {
					selectorWizardSelector.rightArrowEnabled = false;
					zWaveUtils.doNodeHealthTest(app.smartplugZwaveUuid, p.nodeHealthTestCB);
					connectionQualityFrame.state = "checking";
				}
			}
		}
	}

	Throbber {
		id: throbber
		anchors {
			left: connectionQualityRow.right
			leftMargin: designElements.hMargin10
			verticalCenter: connectionQualityRow.verticalCenter
		}
		height: connectionQualityRow.height
		width: height
	}

	state: "begin"
	states: [
		State {
			name: "begin"
			PropertyChanges {target: throbber; visible: false}
			PropertyChanges {target: signalStrengthRow; visible: false}
			PropertyChanges {target: progressText; visible: false}
		},
		State {
			name: "checking"
			PropertyChanges {target: throbber; visible: true}
			PropertyChanges {
				target: progressText
				visible: true
				text: (zWaveUtils.networkHealth.progress !== undefined ? zWaveUtils.networkHealth.progress : "0") + "%"
			}
			PropertyChanges {target: signalStrengthRow; visible: false}
			PropertyChanges {target: checkQualityButton; enabled: false}
		},
		State {
			name: "checked"
			PropertyChanges {target: throbber; visible: false}
			PropertyChanges {target: progressText; visible: false}
			PropertyChanges {target: signalStrengthRow; visible: true}
			PropertyChanges {target: connectionQualityFrame; outcomeData: true}
		}
	]
}
