import QtQuick 2.11
import QtQuick.Layouts 1.3

import BasicUIControls 1.0
import Feedback 1.0

Popup {
	id: feedbackPopup
	visible: false
	anchors.fill: parent

	property FeedbackCampaign campaign

	QtObject {
		id: p
		property var ratings: [qsTr("rating-text-1"), qsTr("rating-text-2"), qsTr("rating-text-3"), qsTr("rating-text-4"), qsTr("rating-text-5")]
		property bool showCommentField: ratingControlGroup.currentControlId >= 0 && campaign.commentCallout && !feedbackPopup.state
	}

	Rectangle {
		id: maskedArea
		anchors.fill: parent
		color: colors.fstMaskedArea
		opacity: designElements.opacity
	}

	MouseArea {
		id: maskMouseArea
		anchors.fill: parent
		onClicked: qtUtils.clearFocus()
	}

	ControlGroup {
		id: ratingControlGroup
		exclusive: true
	}

	Rectangle {
		id: background
		width: Math.round(700 * horizontalScaling)
		height: Math.round(400 * verticalScaling)
		anchors.centerIn: parent
		anchors.verticalCenterOffset: Qt.inputMethod.visible ? - (height / 2) - designElements.vMargin20 : 0
		radius: designElements.radius
		color: colors.white

		MouseArea {
			id: bgMouseArea
			anchors.fill: parent
			onClicked: qtUtils.clearFocus()
		}

		Image {
			id: feedbackIcon
			anchors {
				verticalCenter: headerText.verticalCenter
				right: headerText.left
				rightMargin: designElements.hMargin20
			}
			source: "image://scaled/images/feedback.svg"
		}

		Text {
			id: headerText
			anchors.verticalCenter: closeBtn.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			height: closeBtn.height

			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
			minimumPixelSize: qfont.bodyText
			fontSizeMode: Text.Fit

			color: colors.titleText
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			lineHeight: lineCount > 1 ? 0.8 : 1
			wrapMode: Text.WordWrap
			text: campaign.headerText

			onContentWidthChanged: width = Math.min(parent.width * 0.8, contentWidth)
		}

		IconButton {
			id: closeBtn
			height: width
			width: Math.round(53 * verticalScaling)
			anchors.top: parent.top
			anchors.right: parent.right

			radius: background.radius
			topLeftRadiusRatio: 0
			topRightRadiusRatio: 1
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 0

			iconSource: "qrc:/images/DialogCross.svg"
			colorUp: background.color

			onClicked: hide()
		}

		GridLayout {
			id: ratingsGrid
			anchors {
				top: closeBtn.bottom
				topMargin: designElements.vMargin20
				horizontalCenter: parent.horizontalCenter
				bottom: submitButton.top
				bottomMargin: designElements.vMargin10
			}
			columns: p.ratings.length
			columnSpacing: designElements.hMargin10
			rowSpacing: designElements.vMargin15

			Repeater {
				model: p.ratings

				Column {
					Layout.alignment: Qt.AlignTop
					spacing: ratingsGrid.columnSpacing

					TwoStateIconButton {
						id: ratingBtn
						width:  Math.round(120 * horizontalScaling)
						height: Math.round(140 * verticalScaling)

						controlGroupId: index
						controlGroup: ratingControlGroup

						selectionTrigger: "OnClick"
						unselectionTrigger: "OnClick"

						iconSourceUnselected: "drawables/rating-face-" + (index+1) + ".svg"
						iconSourceSelected: "drawables/rating-face-" + (index+1) + "-selected.svg"
						btnColorUnselected: "transparent"
						btnColorSelected: "transparent"

						onClicked: qtUtils.clearFocus()
					}

					Text {
						id: ratingText
						width: ratingBtn.width
						font {
							family: qfont.bold.name
							pixelSize: qfont.bodyText
						}
						color: ratingBtn.selected ? colors.accent : colors.text
						horizontalAlignment: Text.AlignHCenter
						wrapMode: Text.WordWrap
						text: modelData
					}
				}
			}

			Rectangle {
				Layout.columnSpan: ratingsGrid.columns
				Layout.fillWidth: true
				Layout.fillHeight: true
				color: "transparent"
				border.color: colors._bg
				border.width: 1
				visible: p.showCommentField

				Flickable {
					id: commentFlickable
					anchors.fill: parent
					contentWidth: width
					contentHeight: Math.max(height, commentField.contentHeight)
					flickableDirection: Flickable.VerticalFlick
					boundsBehavior: Flickable.StopAtBounds
					clip: true

					function ensureVisible(rect)
					{
						if (contentY >= rect.y)
							contentY = rect.y;
						else if (contentY+height <= rect.y+rect.height)
							contentY = rect.y+rect.height-height;
					}

					TextEdit {
						id: commentField
						anchors.fill: parent
						padding: designElements.vMargin5
						font {
							family: qfont.regular.name
							pixelSize: qfont.bodyText
						}
						color: colors.text
						selectionColor: colors._branding
						selectedTextColor: colors.white
						wrapMode: TextEdit.WordWrap
						property int maximumLength: 200
						property string previousText: text

						onCursorRectangleChanged: commentFlickable.ensureVisible(cursorRectangle)
						onTextChanged: {
							// char limit functionality
							if (text.length > maximumLength) {
								var cursor = cursorPosition;
								text = previousText;
								if (cursor > text.length) {
									cursorPosition = text.length;
								} else {
									cursorPosition = cursor-1;
								}
							}
							previousText = text;
						}

						Text {
							id: commentCalloutText
							anchors {
								left: parent.left
								top: parent.top
								margins: parent.padding
							}
							font {
								family: qfont.semiBold.name
								pixelSize: qfont.bodyText
							}
							color: colors.disabledText
							text: campaign.commentCallout
							visible: p.showCommentField && !commentField.length
						}
					}
				}
			}
		}

		Text {
			id: commentCharCount
			anchors {
				left: ratingsGrid.left
				top: ratingsGrid.bottom
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
			}
			color: colors.disabledText
			text: "%1/%2".arg(commentField.length).arg(commentField.maximumLength)
			visible: p.showCommentField && commentField.length
		}

		StandardButton {
			id: submitButton
			anchors {
				right: ratingsGrid.right
				bottom: parent.bottom
				bottomMargin: designElements.vMargin10
			}
			minWidth: Math.round(125 * horizontalScaling)
			primary: true
			enabled: ratingControlGroup.currentControlId >= 0
			text: qsTr("Send")

			onClicked: {
				commentField.focus = false;
				feedbackPopup.state = "THANK_YOU"
				FeedbackManager.submitFeedback(campaign.id, ratingControlGroup.currentControlId + 1, commentField.text)
			}
		}

		Text {
			id: noFeedbackLink
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: submitButton.verticalCenter
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.metaText
				underline: true
			}
			color: colors.disabledText
			visible: ratingControlGroup.currentControlId === -1
			text: qsTr("dismiss-question-link-text")

			MouseArea {
				anchors.fill: parent
				anchors.margins: - designElements.vMargin10

				onClicked: {
					feedbackPopup.visible = false;
					qdialog.showDialog(qdialog.SizeLarge, qsTr("dismiss-question-popup-title"), qsTr("dismissFeedbackContent"),
									   qsTr("Skip this question"), function() {
						FeedbackManager.setCampaignAnswered(campaign.id, true);
						hide();
					});
					qdialog.setClosePopupCallback(function() {
						if (feedbackPopup)
							feedbackPopup.visible = true;
					});
					qdialog.context.highlightPrimaryBtn = true;
					qdialog.context.iconSource = "../../images/feedback.svg";
					qdialog.context.closeBtnForceShow = true;
				}
			}
		}

		RowLayout {
			id: thankyouLayout
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: spacing
				right: parent.right
				rightMargin: spacing
			}
			spacing: Math.round(50 * horizontalScaling)
			visible: false

			Image {
				source: "image://scaled/qb/components/drawables/smile-and-wave.svg"
			}

			Column {
				Layout.fillWidth: true
				Text {
					font {
						family: qfont.bold.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.titleText
					text: qsTr("Thank you")
				}

				Text {
					width: parent.width
					font {
						family: qfont.regular.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.titleText
					wrapMode: Text.WordWrap
					text: campaign.thanksMessage
				}
			}
		}
	}

	states: [
		State {
			name: "THANK_YOU"
			PropertyChanges { target: background; width: Math.round(620 * horizontalScaling); height: Math.round(330 * verticalScaling) }
			PropertyChanges { target: feedbackIcon; visible: false }
			PropertyChanges { target: headerText; visible: false }
			PropertyChanges { target: ratingsGrid; visible: false }
			PropertyChanges { target: submitButton; visible: false }
			PropertyChanges { target: thankyouLayout; visible: true }
		}
	]
}
