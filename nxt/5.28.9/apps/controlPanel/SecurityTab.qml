import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0
import BxtClient 1.0

Widget {
	id: securityTab
	anchors.fill: parent

	QtObject {
		id: p

		property string verificationUrl
		property string verificationUrlComplete
		property string userCode
		property int totalTime: 0
		property int timeLeft: 0
		property bool errorState: false

		function unlinkSystem() {
			qdialog.showDialog(qdialog.SizeMedium, qsTr("unlink-system-popup-title"),
							   qsTr("unlink-system-popup-body"),
							   qsTr("Yes"), function() { app.unlinkAlarmSystem(); stage.navigateBack(); },
							   qsTr("No"), null);
			qdialog.context.closeBtnForceShow = true;
		}

		function finishedLinking(success, reason) {
			if (securityTab) {
				screenStateController.wakeup();
				if (success) {
					errorState = false;
					if (!app.hasAlarmSystem)
						stage.navigateHome();
					else
						linkPage.visible = false;
				} else {
					errorState = true;
					if (reason === "timeout")
						errorText.text = qsTr("Verification code expired");
					else
						errorText.text = qsTr("Error during pairing");
					retryButton.enabled = true;
				}
			}
		}

		function linkCodeCallback(success, data) {
			if (securityTab) {
				if (success === true) {
					screenStateController.screenColorDimmedIsReachable = false;
					p.errorState = false;
					p.verificationUrl = data.verificationUrl;
					p.verificationUrlComplete = data.verificationUrlComplete;
					p.userCode = data.userCode;
					p.totalTime = p.timeLeft = data.expiresIn;
					expirationTimer.restart();
				} else {
					p.errorState = true;
					errorText.text = qsTr("Error getting verification code");
					retryButton.enabled = true;
				}
			}
		}
	}

	function init() {}

	onShown: {
		if (!app.hasAlarmSystem) {
			linkPage.visible = true;
			app.getAlarmSystemLinkCode(p.linkCodeCallback);
		}
		app.finishedAlarmSystemLinking.connect(p.finishedLinking);
	}

	Component.onDestruction: {
		screenStateController.screenColorDimmedIsReachable = true;
		app.finishedAlarmSystemLinking.disconnect(p.finishedLinking);
	}

	Column {
		id: connectedPage
		visible: !linkPage.visible
		anchors {
			top: parent.top
			topMargin: Math.round(22 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(56 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		spacing: designElements.vMargin6

		Text {
			id: titleText
			anchors {
				left: parent.left
				right: right.left
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors._harry
			wrapMode: Text.WordWrap
			text: qsTr("Toon Security System")
		}

		Item {
			id: spacer
			width: 1
			height: Math.round(14 * verticalScaling)
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: pinLabel
				anchors {
					left: parent.left
					right: editPinBtn.left
					rightMargin: designElements.vMargin6
				}
				leftText: qsTr("PIN code")
				rightText: app.alarmPinIsSet ? "****" : qsTr("Not set")
			}

			IconButton {
				id: editPinBtn
				width: designElements.buttonSize
				anchors.right: parent.right
				iconSource: "qrc:/images/edit.svg"

				onClicked: stage.openFullscreen(app.alarmEditPinScreenUrl)
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			SingleLabel {
				id: systemLabel
				anchors {
					left: parent.left
					right: relinkBtn.visible ? relinkBtn.left : unlinkSystemBtn.left
					rightMargin: designElements.vMargin6
				}
				leftText: qsTr("Status")
				rightText: app.alarmInfo.connected === false ? qsTr("Error, please link again!") : qsTr("Connected")
			}

			IconButton {
				id: relinkBtn
				width: designElements.buttonSize
				anchors.right: unlinkSystemBtn.left
				anchors.rightMargin: designElements.vMargin6
				iconSource: "qrc:/images/refresh.svg"
				visible: app.alarmInfo.connected === false

				onClicked: {
					linkPage.visible = true;
					app.getAlarmSystemLinkCode(p.linkCodeCallback);
				}
			}

			IconButton {
				id: unlinkSystemBtn
				width: designElements.buttonSize
				anchors.right: parent.right
				iconSource: "qrc:/images/delete.svg"

				onClicked: p.unlinkSystem()
			}
		}
	}

	Item {
		id: linkPage
		visible: false
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(55 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(30 * horizontalScaling)
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
		}

		Text {
			id: linkTitleText
			anchors {
				top: parent.top
				left: parent.left
				right: qrCodeBg.left
				rightMargin: designElements.hMargin15
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors._harry
			wrapMode: Text.WordWrap
			lineHeight: 0.8
			text: qsTr("link-security-title")
		}

		Text {
			id: linkBodyTextOne
			anchors {
				top: linkTitleText.bottom
				topMargin: Math.round(40 * verticalScaling)
				left: linkTitleText.left
				right: linkTitleText.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._gandalf
			wrapMode: Text.WordWrap
			text: p.verificationUrl ? qsTr("link-security-body-one") : (!p.errorState ? qsTr("Please wait...") : "")
		}

		Text {
			id: linkBodyUrl
			anchors {
				top: linkBodyTextOne.bottom
				topMargin: designElements.vMargin20
				left: linkTitleText.left
				right: linkTitleText.right
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.bodyText
			}
			minimumPixelSize: qfont.metaText
			fontSizeMode: Text.HorizontalFit
			color: colors._gandalf
			text: p.verificationUrl
		}

		Text {
			id: linkBodyTextTwo
			anchors {
				top: linkBodyUrl.bottom
				topMargin: designElements.vMargin20
				left: linkTitleText.left
				right: linkTitleText.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._gandalf
			wrapMode: Text.WordWrap
			text: qsTr("link-security-body-two")
			visible: p.verificationUrl
		}

		Rectangle {
			id: qrCodeBg
			width: codeBg.width
			height: width
			anchors {
				top: linkTitleText.top
				right: codeBg.right
			}
			color: colors.contentBackground
			radius: designElements.radius

			Throbber {
				anchors.centerIn: parent
				width: Math.round(100 * horizontalScaling)
				height: width
				visible: !p.verificationUrl && !p.userCode && !p.errorState
			}

			QrCode {
				id: qrCode
				anchors.centerIn: parent
				width: Math.round(160 * horizontalScaling)
				height: width
				content: p.verificationUrlComplete ? p.verificationUrlComplete : (p.errorState ? "error" : "")
				color: p.errorState ? colors._pressed : colors.black
			}

			Image {
				anchors.centerIn: parent
				source: "image://scaled/images/bad.svg"
				sourceSize.height: Math.round(80 * verticalScaling)
				visible: p.errorState
			}

			// Maybe enable again when url is small
			/*
			Text {
				id: urlText
				anchors {
					bottom: parent.bottom
					bottomMargin: designElements.vMargin5
					left: parent.left
					right: parent.right
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				horizontalAlignment: Text.AlignHCenter
				fontSizeMode: Text.HorizontalFit
				minimumPixelSize: qfont.thermostatTimeText
				color: colors._gandalf
				text: util.minimizeUrl(p.verificationUrl)
			}
			*/
		}

		Rectangle {
			id: codeBg
			width: Math.round(200 * horizontalScaling)
			height: Math.round(100 * verticalScaling)
			anchors {
				top: qrCodeBg.bottom
				topMargin: designElements.vMargin15
				right: parent.right
			}
			color: colors.contentBackground
			radius: designElements.radius
			visible: p.errorState || p.userCode

			Text {
				id: codeTitle
				anchors {
					top: parent.top
					topMargin: designElements.vMargin5
					horizontalCenter: parent.horizontalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors._gandalf
				text: qsTr("Verification code")
				visible: !p.errorState
			}

			Text {
				id: codeText
				anchors {
					top: codeTitle.baseline
					topMargin: designElements.vMargin10
					horizontalCenter: parent.horizontalCenter
				}
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.secondaryImportantBodyText
					letterSpacing: designElements.hMargin5
				}
				color: colors._harry
				text: p.userCode
				visible: !p.errorState
			}

			Text {
				id: codeExpiresText
				anchors {
					top: codeText.baseline
					topMargin: designElements.vMargin10
					horizontalCenter: parent.horizontalCenter
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				color: colors._gandalf
				text: qsTr("expires after %n minute(s)", "", Math.floor(p.totalTime / 60))
				visible: !p.errorState && p.totalTime
			}

			ProgressBar {
				id: progressBar
				anchors {
					left: parent.left
					right: parent.right
					bottom: parent.bottom
				}
				height: Math.round(5 * verticalScaling)
				topLeftCornerRadiusRatio: 0
				topRightCornerRadiusRatio: 0

				colorBg: parent.color
				colorProgress: p.timeLeft < 20 ? colors._marypoppins : colors.progressBarFill
				progress: p.totalTime ? p.timeLeft / p.totalTime : 0
				visible: p.totalTime > 0 && !p.errorState
			}

			Text {
				id: errorText
				anchors {
					left: parent.left
					right: parent.right
					top: parent.top
					bottom: retryButton.top
					margins: designElements.vMargin10
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				visible: p.errorState
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				wrapMode: Text.WordWrap
				color: colors._harry
			}

			StandardButton {
				id: retryButton
				anchors {
					left: parent.left
					right: parent.right
					bottom: parent.bottom
					margins: designElements.vMargin10
				}
				primary: true
				visible: p.errorState
				text: qsTr("Retry")

				onClicked: {
					enabled = false;
					p.errorState = false;
					p.verificationUrl = "";
					p.verificationUrlComplete = "";
					p.userCode = "";
					p.totalTime = 0;
					app.getAlarmSystemLinkCode(p.linkCodeCallback);
				}
			}
		}
	}

	Timer {
		id: expirationTimer
		interval: 1000
		repeat: true
		onTriggered: {
			p.timeLeft--;
			if (p.timeLeft === 0)
				stop();
		}
	}
}
