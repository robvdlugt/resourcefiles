import QtQuick 2.0
import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: root
	title: qsTr("Connecting a smart radiator valve")
	property bool canContinue: false

	onHidden: {
		if (state === "linking") {
			zWaveUtils.includeDevice("stop");
		}
	}

	function handleIncludeResponse(status, type, uuid) {
		// check if frame still exists (lazy loaded screen)
		if (typeof root !== 'undefined') {
			if (status === "added") {
				parentScreen.newDeviceUuid = uuid;
				app.strvJustAddedUuids.push(uuid);
				canContinue = true;
				root.state = "linked";
			} else {
				root.state = "failed";
			}
		}
	}

	Text {
		id: generalText
		text: qsTr("Keep the valve in the same room as $(display) during the process")
		wrapMode: Text.WordWrap

		anchors {
			left: parent.left
			right: parent.right
		}

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	Text {
		id: stepOneText
		text: qsTr("add-connect-step1")
		wrapMode: Text.WordWrap

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: generalText.bottom
			topMargin: designElements.vMargin20
			left: nb1.right
			leftMargin: designElements.hMargin15
			right: parent.right
		}
	}

	NumberBullet {
		id: nb1
		text: "1"
		color: "black"
		anchors.verticalCenter: stepOneText.verticalCenter
	}

	Text {
		id: stepTwoText
		text: qsTr("add-connect-step2")
		wrapMode: Text.WordWrap

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}

		anchors {
			top: stepOneText.bottom
			topMargin: designElements.vMargin10
			left: nb2.right
			leftMargin: designElements.hMargin15
			right: parent.right
		}
	}

	NumberBullet {
		id: nb2
		text: "2"
		color: "black"
		anchors.verticalCenter: stepTwoText.verticalCenter
	}

	StandardButton {
		id: connectButton
		primary: true

		anchors {
			top: stepTwoText.bottom
			topMargin: designElements.vMargin15
			left: stepTwoText.left
		}

		onClicked: {
			root.state = "linking";
			zWaveUtils.includeDevice("add", handleIncludeResponse);
		}

		Throbber {
			id: connectThrobber
			visible: false

			anchors {
				left: parent.right
				leftMargin: designElements.hMargin15
				verticalCenter: parent.verticalCenter
			}
		}

		Image {
			id: checkMark
			source: "image://scaled/images/good.svg"
			visible: false

			anchors {
				left: parent.right
				leftMargin: designElements.hMargin15
				verticalCenter: parent.verticalCenter
			}
		}
	}

	WarningBox {
		id: warningBox
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		autoHeight: true
		warningIcon: ""
	}

	Image {
		id: failedIcon
		anchors {
			verticalCenter: failedText.verticalCenter
			left: parent.left
		}
		source: "image://scaled/images/bad.svg"
		visible: false
	}

	Text {
		id: failedText
		anchors {
			bottom: parent.bottom
			left: failedIcon.right
			leftMargin: designElements.hMargin15
			right: parent.right
		}
		text: qsTr("add-connect-failed")
		wrapMode: Text.WordWrap
		visible: false
		color: colors._marypoppins

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	state: "notlinked"
	states: [
		State {
			name: "notlinked"
			PropertyChanges { target: connectButton; text: qsTr("Connect"); enabled: true }
			PropertyChanges { target: warningBox; warningText: qsTr("add-connect-warning1") }
			PropertyChanges { target: root; imageSource: "drawables/add-connect-1.svg" }
		},
		State {
			name: "linking"
			PropertyChanges { target: connectButton; text: qsTr("Connecting"); enabled: false }
			PropertyChanges { target: connectThrobber; visible: true }
			PropertyChanges { target: warningBox; visible: false }
			PropertyChanges { target: root; imageSource: "drawables/strv-searching.svg" }
		},
		State {
			name: "linked"
			PropertyChanges { target: connectButton; text: qsTr("Connected"); enabled: false; primary: false }
			PropertyChanges {
				target: warningBox;
				warningText: qsTr("add-connect-warning2");
				warningIcon: "image://scaled/images/info_warningbox.svg"
			}
			PropertyChanges { target: root; imageSource: "drawables/add-connect-3.svg" }
			PropertyChanges { target: checkMark; visible: true }
			StateChangeScript {
				script: {
					parentScreen.enableCustomTopRightButton();
					parentScreen.disableCancelButton();
				}
			}
		},
		State {
			name: "failed"
			PropertyChanges { target: connectButton; text: qsTr("Connect"); enabled: true }
			PropertyChanges { target: root; imageSource: "drawables/add-connect-1.svg" }
			PropertyChanges { target: warningBox; visible: false }
			PropertyChanges { target: failedIcon; visible: true }
			PropertyChanges { target: failedText; visible: true }
		}
	]
}
