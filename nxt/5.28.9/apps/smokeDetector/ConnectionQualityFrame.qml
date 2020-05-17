import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: connectionQualityFrame
	title: qsTr("Test your smoke detector")
	imageSource: "drawables/sd-test-menu.svg"

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
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("connection_explanation_1")
	}

	NumberBullet {
		id: nbTwo
		anchors {
			left: nbOne.left
			top: stepOneText.bottom
			topMargin: designElements.vMargin10
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
		text: qsTr("connection_explanation_2")
	}

	WarningBox {
		id: warningBox
		anchors {
			left: nbOne.left
			right: stepOneText.right
			top: stepTwoText.bottom
			topMargin: designElements.vMargin10
		}
		autoHeight: true

		warningText: qsTr("connection_explanation_3")
		warningIcon: ""
	}

	IconButton {
		id: infoButton
		anchors {
			top: warningBox.bottom
			topMargin: designElements.vMargin10
			left: warningBox.left
		}
		iconSource: "qrc:/images/info.svg"

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTranslate("QualityAcknowledgeFrame", "More info"), app.colorExplanationPopupUrl);
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
		text: qsTranslate("QualityAcknowledgeFrame", "info-icon-text")

		MouseArea {
			anchors.fill: parent
			property string kpiPostfix: "infoButtonText"
			onClicked: infoButton.clicked()
		}
	}
}
