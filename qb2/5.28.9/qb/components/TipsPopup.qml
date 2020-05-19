import QtQuick 2.1
import qb.components 1.0

Item {
	id: root
	anchors.fill: parent

	property variant tips: []
	/* Possible values for each tip object
	{
		title: qsTr("a-title"),
		text: qsTr("a-text"),
		richText: true, // set to true if text string contains HTML
		image: Qt.resolvedUrl("drawables/image.png"), // fully resolved url of the image
		align: "left", // position of the text in relation to the image
		buttonText: qsTr("a-button-text"), // don't define this if no button is required
		buttonTargetScreen: Qt.resolvedUrl("app/AppScreen.qml") // fully resolved url of the destination screen
	}
	*/
	property bool showSeparator: false
	property bool carousel: true
	property int imageContainerWidth: 0
	property string countlyLoggingInfix

	QtObject {
		id: p
		property bool textOnRight: false
	}

	function changeTip(index) {
		if (index < 0 || index > tips.length - 1)
			return;

		var tip = tips[index];
		tipText.text = tip.text;
		tipText.textFormat = tip.textFormat !== undefined ? tip.textFormat : Text.PlainText;
		qdialog.context.title = tip.title;
		tipImage.source = tip.image ? tip.image : "";
		tipImageButtonContainer.visible = tip.image ? true : false;

		if (tip.align === "right")
			p.textOnRight  = true;
		else
			p.textOnRight = false;

		if (tip.buttonText && tip.buttonTargetScreen) {
			tipButton.text = tip.buttonText
			tipButton.targetScreen = tip.buttonTargetScreen;
			tipButton.targetArgs = tip.buttonTargetArgs ? tip.buttonTargetArgs : undefined
			tipButton.visible = true;
		} else {
			tipButton.text = ""
			tipButton.targetScreen = "";
			tipButton.targetArgs = undefined
			tipButton.visible = false
		}

		if (countlyLoggingInfix.length !== 0) {
			countly.sendPageViewEvent("qb/components/TipsPopup.qml:" + countlyLoggingInfix + ":page" + index);
		}
	}

	onTipsChanged: if (tips.length) { changeTip(0); }

	Item {
		id: tipImageButtonContainer
		anchors {
			right: parent.right
			rightMargin: Math.round(25 * horizontalScaling)
			// used when text is right aligned
			leftMargin: Math.round(25 * horizontalScaling)
			top: parent.top
			bottom: navBar.visible ? lineSeparator.top : parent.bottom
		}
		width: imageContainerWidth ? Math.round(imageContainerWidth * horizontalScaling) : tipImageButtonColumn.width

		Column {
			id: tipImageButtonColumn
			spacing: designElements.vMargin10
			anchors.centerIn: parent

			Image {
				id: tipImage
				source: ""
				anchors.horizontalCenter: parent.horizontalCenter
			}

			StandardButton {
				id: tipButton
				anchors.horizontalCenter: parent.horizontalCenter
				colorUp: colors.tipsPopupButton
				fontColorUp: colors.tipsPopupButtonText
				text: ""

				property url targetScreen
				property variant targetArgs
				onClicked: {
					if (targetScreen) {
						qdialog.reset();
						stage.openFullscreen(targetScreen, targetArgs);
					}
				}
			}
		}

		states: [
			State {
				name: "rightAligned"
				when: p.textOnRight
				AnchorChanges {
					target: tipImageButtonContainer
					anchors.left: parent.left
					anchors.right: undefined
				}
			}
		]
	}

	Text {
		id: tipText
		text: ""
		anchors {
			top: parent.top
			bottom: navBar.visible ? lineSeparator.top : parent.bottom
			left: parent.left
			leftMargin: Math.round((tipImageButtonContainer.visible ? 25 : 40) * horizontalScaling)
			right: tipImageButtonContainer.visible ? tipImageButtonContainer.left : parent.right
			rightMargin: Math.round((tipImageButtonContainer.visible ? 15 : 40) * horizontalScaling)
		}
		font {
			family: qfont.regular.name
			// AC: changed this to pointSize because for some reason when using StyledText format,
			// a <font size=""> HTML tag doesn't work when the size here is set as pixelSize
			pointSize: qfont.bodyText * 72 / qtUtils.screenDpiY();
		}
		color: colors.tipsPopupText
		verticalAlignment: Text.AlignVCenter
		wrapMode: Text.WordWrap

		states: [
			State {
				name: "rightAligned"
				when: p.textOnRight
				AnchorChanges {
					target: tipText
					anchors.left: tipImageButtonContainer.visible ? tipImageButtonContainer.right : parent.left
					anchors.right: parent.right
				}
				PropertyChanges {
					target: tipText
					anchors.leftMargin: Math.round((tipImageButtonContainer.visible ? 15 : 40) * horizontalScaling)
					anchors.rightMargin: Math.round((tipImageButtonContainer.visible ? 25 : 40) * horizontalScaling)
				}
			}
		]
	}

	Rectangle {
		id: lineSeparator
		anchors {
			bottom: navBar.top
			bottomMargin: designElements.vMargin10
			left: parent.left
			leftMargin: designElements.hMargin5
			right: parent.right
			rightMargin: designElements.hMargin5
		}
		height: 1
		color: colors.tipsPopupSeparator
		visible: navBar.visible ? showSeparator : false
	}

	DottedSelector {
		id: navBar
		anchors {
			bottom: parent.bottom
			bottomMargin: designElements.vMargin10
			horizontalCenter: parent.horizontalCenter
		}
		arrowColorUp: colors.dialogContentArea
		arrowColorDown: colors._middlegrey

		hideArrowsOnBounds: !carousel
		pageCount: tips ? tips.length : 0
		onNavigate: changeTip(page)
		visible: tips.length > 1
	}
}
