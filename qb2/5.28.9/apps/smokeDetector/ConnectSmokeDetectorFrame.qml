import QtQuick 2.1
import qb.components 1.0

FSWizardFrame {
	id: root
	title: qsTr("Link your smoke detector")
	imageSource: "drawables/sd-battery.svg"
	property bool canContinue: false

	onHidden: {
		if (state === "linking") {
			zWaveUtils.includeDevice("stop");
		}
	}

	function handleIncludeResponse(status, type, uuid) {
		// check if frame still exists (lazy loaded screen)
		if (typeof root !== 'undefined') {
			var validType = false;
			if (type) {
				validType = (type.indexOf("FGSD002") === 0 || type.indexOf("FGSS001") === 0);
			}

			if (status === "added" && validType) {
				if (!app.isLinkedSmokedetector(uuid)) {
					state = "linked";
					app.addDeviceToScenario(uuid, type);
				} else {
					state = "";
					qdialog.showDialog(qdialog.SizeMedium, qsTr("The smoke detector is already coupled"), qsTr("This smoke detector is already coupled to your Toon."));
				}
			} else if (status !== "canceled") {
				if (state === "linking") {
					state = "";
					stage.openFullscreen(app.linkErrorScreenUrl);
				}
			}
		}
	}

	NumberBullet {
		id: nbOne
		anchors {
			left: parent.left
			top: parent.top
		}
		color: "black"
		text: "1"
	}

	Text {
		id: stepOneText
		anchors {
			baseline: nbOne.bottom
			baselineOffset: - designElements.vMargin6
			left: nbOne.right
			leftMargin: designElements.hMargin15
			right: parent.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.text
		wrapMode: Text.WordWrap
		text: qsTr("Remove the smokedetector from the box and place the battery")
	}

	NumberBullet {
		id: nbTwo
		anchors {
			left: nbOne.left
			top: stepOneText.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		color: "black"
		text: "2"
	}

	Text {
		id: stepTwoText
		anchors {
			baseline: nbTwo.bottom
			baselineOffset: stepOneText.anchors.baselineOffset
			left: stepOneText.left
		}
		width: stepOneText.width
		wrapMode: Text.WordWrap
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.text
		text: qsTr("Press link")
	}

	StandardButton {
		id: linkButton
		anchors {
			top: stepTwoText.bottom
			left: stepTwoText.left
			topMargin: designElements.vMargin20
		}
		minWidth: Math.round(100 * horizontalScaling)
		primary: true
		text: qsTr("Link")

		onClicked: {
			root.state = "linking";
			zWaveUtils.includeDevice("add", handleIncludeResponse);
		}
	}

	Throbber {
		id: linkThrobber
		anchors {
			left: linkButton.right
			leftMargin: designElements.hMargin10
			verticalCenter: linkButton.verticalCenter
		}
		visible: false
	}

	Image {
		id: greenCheck
		anchors.centerIn: linkThrobber
		visible: false
		source: "qrc:/images/good.svg"
	}

	NumberBullet {
		id: nbThree
		anchors {
			left: nbOne.left
			top: linkButton.bottom
			topMargin: Math.round(30 * verticalScaling)
		}
		color: "black"
		text: "3"
	}

	Text {
		id: stepThreeText
		anchors {
			baseline: nbThree.bottom
			baselineOffset: stepOneText.anchors.baselineOffset
			left: stepOneText.left
		}
		width: stepOneText.width
		wrapMode: Text.WordWrap
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.text
		text: qsTr("Press the button on the smokedetector")
	}

	states: [
		State {
			name: "linking"
			PropertyChanges { target: linkButton; enabled: false }
			PropertyChanges { target: linkThrobber; visible: true }
			PropertyChanges { target: root; imageSource: "drawables/sd-press.svg" }
		},
		State {
			name: "linked"
			PropertyChanges { target: linkThrobber; visible: false }
			PropertyChanges { target: greenCheck; visible: true	}
			PropertyChanges { target: linkButton; enabled: false }
			PropertyChanges { target: root; imageSource: "drawables/sd-ok.svg"; canContinue: true }
			StateChangeScript { script:	parentScreen.disableCancelButton() }
		}
	]
}
