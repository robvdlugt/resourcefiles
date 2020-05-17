import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: programScreen
	screenTitle: qsTranslate("AddStrvWizardScreen", "Install smart radiator valves")
	hasBackButton: false

	Text {
		id: titleText
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: womanMobileImage.left
			rightMargin: designElements.hMargin6
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
		lineHeight: 0.8
		wrapMode: Text.WordWrap
		text: qsTr("strv-install-done-title")
	}

	Text {
		id: contentText
		anchors {
			top: titleText.bottom
			topMargin: designElements.vMargin20
			left: titleText.left
			right: titleText.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTr("strv-install-done-body %1").arg(bxtClient.getCommonname())
		wrapMode: Text.WordWrap
	}

	StandardButton {
		id: doneButton
		anchors {
			top: contentText.bottom
			topMargin: designElements.vMargin20
			left: contentText.left
		}
		minWidth: Math.round(100 * horizontalScaling)
		text: qsTr("Good to go")

		onClicked: stage.navigateHome()
	}

	Rectangle {
		id: qrCodeBg
		width: Math.round(230 * horizontalScaling)
		height: width
		radius: width / 2
		anchors {
			top: titleText.top
			right: parent.right
			rightMargin: Math.round(30 * horizontalScaling)
		}
		color: "white"

		QrCode {
			id: qrCode
			anchors {
				centerIn: parent
				verticalCenterOffset: Math.round(-10 * verticalScaling)
			}
			width: Math.round(120 * horizontalScaling)
			height: width
			content: qsTr("$(mobileAppUrl)")
		}

		Text {
			id: urlText
			anchors {
				top: qrCode.bottom
				topMargin: designElements.vMargin15
				horizontalCenter: parent.horizontalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors._gandalf
			text: util.minimizeUrl(qrCode.content)
		}
	}

	Image {
		id: womanMobileImage
		source: "image://scaled/apps/strvSettings/drawables/woman_mobile.svg"
		anchors {
			bottom: parent.bottom
			bottomMargin: - designElements.bottomBarHeight
			right: qrCodeBg.left
			rightMargin: Math.round(-34 * horizontalScaling)
		}
	}

	Image {
		id: radiator
		source: "image://scaled/apps/strvSettings/drawables/radiator.svg"
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(22 * verticalScaling)
			right: parent.right
		}
	}
}
