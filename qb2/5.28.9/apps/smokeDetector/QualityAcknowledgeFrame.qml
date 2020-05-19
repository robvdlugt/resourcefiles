import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: qualityAcknowledgeFrame
	title: qsTr("Test the connection")
	imageSource: "drawables/sd-test-green.svg"

	Text {
		id: bodyText
		width: parent.width
		anchors.top: parent.top
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("quality_acknowledge_1")
	}

	NumberBullet {
		id: nbOne
		anchors {
			left: bodyText.left
			top: bodyText.bottom
			topMargin: designElements.vMargin15
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
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("quality_acknowledge_2")
	}

	IconButton {
		id: infoButton
		anchors {
			top: stepOneText.bottom
			topMargin: designElements.vMargin15
			left: stepOneText.left
		}
		iconSource: "qrc:/images/info.svg"

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("More info"), app.colorExplanationPopupUrl);
		}
	}

	Text {
		id: infoText
		anchors {
			left: infoButton.right
			leftMargin: designElements.hMargin15
			right: stepOneText.right
			verticalCenter: infoButton.verticalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.text
		wrapMode: Text.WordWrap
		text: qsTr("info-icon-text")

		MouseArea {
			anchors.fill: parent
			property string kpiPostfix: "infoButtonText"
			onClicked: infoButton.clicked()
		}
	}

	NumberBullet {
		id: nbTwo
		anchors {
			left: nbOne.left
			top: infoText.bottom
			topMargin: designElements.vMargin15
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
		text: qsTr("quality_finish_1")
	}

	WarningBox {
		id: warningBox
		width: parent.width
		anchors {
			top: stepTwoText.bottom
			topMargin: designElements.vMargin15
		}
		autoHeight: true

		warningText: qsTr("quality_finish_warning")
		warningIcon: ""
	}
}
