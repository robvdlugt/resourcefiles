import QtQuick 2.1
import qb.components 1.0

Screen {
	id: privacyAgreementScreen

	screenTitle: qsTr("Terms & condition")
	anchors.fill: parent

	hasCancelButton: true
	inNavigationStack: false

	Text {
		id: topLabel
		anchors {
			top: parent.top
			topMargin: designElements.vMargin10
			left: parent.left
			leftMargin: Math.round(123 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		color: colors.agreementBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.programText
		}
		lineHeight: 0.9
		textFormat: Text.StyledText
		wrapMode: Text.WordWrap
		text: qsTr("benchmark_privacy_top_text")
	}

	Rectangle {
		id: infoBox
		height: Math.round(65 * verticalScaling)
		anchors {
			top: topLabel.bottom
			topMargin: designElements.vMargin15
			left: topLabel.left
			right: topLabel.right
		}
		color: colors.agreementInfoRectangle

		Text {
			id: infoLabel
			anchors {
				verticalCenter: infoBox.verticalCenter
				left: infoBox.left
				leftMargin: Math.round(32 * horizontalScaling)
				right: iconImage.left
				rightMargin: designElements.hMargin10
			}
			color: colors.agreementBody
			font {
				family: qfont.regular.name
				pixelSize: qfont.programText
			}
			text: qsTr("benchmark_privacy_info_text")
			wrapMode: Text.WordWrap
		}

		IconButton {
			id: iconImage
			anchors {
				verticalCenter: infoBox.verticalCenter
				right: infoBox.right
				rightMargin: Math.round(15 * horizontalScaling)
			}
			iconSource: "qrc:/images/info.svg"
			visible: qsTr("benchmark_privacy_info_popup_body") !== " " ? true : false
			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge,
								   qsTr("benchmark_privacy_info_popup_title"),
								   feature.featBenchmarkFriendsEnabled() ? qsTr("benchmark_privacy_info_popup_body") : qsTr("benchmark_privacy_info_popup_body", "no_friends"));
				var popup = qdialog.context;
				popup.bodyFontPixelSize = qfont.bodyText;
			}
		}
	}

	Text {
		id: bottomLabel
		anchors {
			baseline: infoBox.bottom
			baselineOffset: Math.round(29 * verticalScaling)
			left: topLabel.left
			right: topLabel.right
		}
		color: colors.agreementBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.programText
		}
		lineHeight: 0.9
		wrapMode: Text.WordWrap
		text: qsTr("benchmark_privacy_bottom_text")
	}

	StandardButton {
		id: declineButton
		anchors {
			top: bottomLabel.bottom
			topMargin: designElements.vMargin10
			left: topLabel.left
		}
		text: qsTr("Decline")
		onClicked: {
			app.setPermission(false);
			stage.openFullscreen(app.privacyAgreementRejectedScreenUrl);
		}
	}

	StandardButton {
		id: acceptButton
		anchors {
			top: declineButton.top
			left: declineButton.right
			leftMargin: designElements.hMargin6
		}
		text: qsTr("Accept")
		onClicked: {
			stage.openFullscreen(app.wizardScreenUrl, {reset:true});
		}
	}

}
