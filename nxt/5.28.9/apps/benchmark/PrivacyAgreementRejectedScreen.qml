import QtQuick 2.1
import qb.components 1.0

Screen {
	id: privacyAgreementRejectedScreen

	screenTitle: qsTr("No permission")
	anchors.fill: parent

	Text {
		id: titleLabel
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(123 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		color: colors.agreementRejectedTitle
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
		text: qsTr("benchmark_privacy_rejected_title_text")
	}

	Text {
		id: bodyLabel
		anchors {
			baseline: titleLabel.baseline
			baselineOffset: Math.round(33 * verticalScaling)
			left: titleLabel.left
			right: iconImage.left
			rightMargin: designElements.hMargin15
		}
		color: colors.agreementRejectedBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTr("benchmark_privacy_rejected_body_text")
		wrapMode: Text.WordWrap
	}

	Image {
		id: iconImage
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(47 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(47 * horizontalScaling)
		}
		source: "image://scaled/apps/benchmark/drawables/NotAllowed.svg"
	}
}
