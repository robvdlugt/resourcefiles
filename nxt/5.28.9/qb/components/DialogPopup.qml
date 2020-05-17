import QtQuick 2.1
import BasicUIControls 1.0

import qb.base 1.0

Widget {
	id: dialogComponent
	anchors.fill: parent
	visible: false

	// Dialog configuration properties (if you add a property here, make sure it is also reset to a sane value in the reset() function in dialogpopup.c)
	property int size: qdialog.SizeSmall
	property int bodyFontPixelSize: qfont.titleText
	property int bodyFontLineHeight: Math.round(26 * verticalScaling)
	property bool bodyTextAlignLeft: false
	property int bodyHorizontalMargins: -1	// if -1, will be automatically determined by the size
	property int titleFontPixelSize: Math.round(23 * verticalScaling)
	property url iconSource: ""
	property url rightIconSource: ""
	property bool closeBtnForceShow: false
	property bool closeBtnForceHide: false
	property bool highlightPrimaryBtn: false
	property string title: qsTr("Popup title")
	property string content: qsTr("Popup content")
	property alias button1: btn1
	property alias button2: btn2
	property alias contentSource: dialogMessageLoader.source
	property alias dynamicContent: dialogMessageLoader.item
	property alias contentLoader: dialogMessageLoader
	property bool blockDimState: true
	property bool dimmStateWasReachable: true
	property string kpiPrefix: "DialogPopup." + title + "."

	// Private properties
	QtObject {
		id: p
		// size: [width, height, bodyHorizontalMargins]
		property variant sizes: {
			0: [470,250,37],
			1: [540,280,43],
			2: [620,330,50]
		}
		property int width: Math.round(sizes[size][0] * horizontalScaling)
		property int height: Math.round(sizes[size][1] * verticalScaling)
		property int bodyHorizontalMargins: dialogComponent.bodyHorizontalMargins >= 0 ? dialogComponent.bodyHorizontalMargins : Math.round(sizes[size][2] * horizontalScaling)
		property int bodyTopMargin: size === qdialog.SizeLarge ? Math.round(30 * verticalScaling) : Math.round(20 * verticalScaling)
	}

	onShowingChanged: {
		if (blockDimState && showing) {
			dimmStateWasReachable = screenStateController.screenColorDimmedIsReachable;
			screenStateController.screenColorDimmedIsReachable = false;
		} else if (blockDimState && dimmStateWasReachable) {
			screenStateController.screenColorDimmedIsReachable = true;
		}
	}

	onDimStateChanged: {
		if (dimState) {
			qdialog.buttonHeaderRightClicked();
		}
	}

	onCloseBtnForceShowChanged: {
		if (closeBtnForceShow)
			closeBtnForceHide = false;
	}

	onCloseBtnForceHideChanged: {
		if (closeBtnForceHide)
			closeBtnForceShow = false;
	}


	// Clickable transparent black area
	Rectangle {
		id: blackArea
		color: colors.dialogMaskedArea
		anchors.fill: dialogComponent

		MouseArea {
			id: blackMouseArea
			anchors.fill: blackArea
			onClicked: { if (headerRightBtn.visible) headerRightBtn.clicked(); }
			property string kpiPostfix: "blackArea"
		}
	}

	// Dialog popup container
	Rectangle {
		id: dialogArea
		color: colors.dialogContentArea
		width: p.width
		height: p.height
		anchors {
			horizontalCenter: blackArea.horizontalCenter
			verticalCenter: blackArea.verticalCenter
		}
		radius: designElements.radius

		MouseArea {
			anchors.fill: parent
			property string kpiPostfix: "dialogArea"
		}

		// Header container
		Item {
			id: dialogTopContainer
			height: Math.round(53 * verticalScaling)
			anchors.left: parent.left
			anchors.right: parent.right

			// Left Icon
			Image {
				id: dialogIcon
				anchors {
					verticalCenter: parent.verticalCenter
					right: dialogTitle.left
					rightMargin: designElements.hMargin10
				}
				source: iconSource.toString() ? "image://scaled/" + qtUtils.urlPath(iconSource) : ""
			}

			// Title
			Text {
				id: dialogTitle
				objectName: "dialogTitle"
				anchors {
					verticalCenter: parent.verticalCenter
					horizontalCenter: parent.horizontalCenter
					leftMargin: Math.round(22 * horizontalScaling)
					rightMargin: Math.round(22 * horizontalScaling)
				}

				font.family: qfont.semiBold.name
				font.pixelSize: titleFontPixelSize
				color: colors.dialogTitleText
				text: title
			}

			// Right Icon button
			IconButton {
				id: headerRightBtn
				objectName: "headerRightBtn"

				width: Math.round(58 * horizontalScaling)
				height: dialogTopContainer.height
				anchors.right: dialogTopContainer.right

				iconSource: rightIconSource.toString() ? rightIconSource : "qrc:/images/DialogCross.svg"
				radius: dialogArea.radius
				topLeftRadiusRatio: 0
				topRightRadiusRatio: 1
				bottomRightRadiusRatio: 0
				bottomLeftRadiusRatio: 0

				visible: closeBtnForceShow ? true : (closeBtnForceHide ? false : !dialogButtonContainer.visible)
				colorUp: colors.dialogContentArea
				colorDown: colors._pressed
			}
		}

		Item {
			id: dialogMessageContainer
			anchors {
				left: parent.left
				right: parent.right
				top: dialogTopContainer.bottom
				bottom: dialogButtonContainer.visible ? dialogButtonContainer.top : parent.bottom
			}
			Component.onCompleted: heightChanged.connect(dialogMessage.textContentChanged)

			Flickable {
				id: dialogFlickable
				anchors {
					fill: parent
					leftMargin: p.bodyHorizontalMargins
					rightMargin: p.bodyHorizontalMargins
					topMargin: designElements.vMargin6
					bottomMargin: designElements.vMargin6
				}
				contentWidth: width
				interactive: false
				clip: true

				// Message
				Text {
					id: dialogMessage
					objectName: "dialogMessage"
					// Less than 3 lines: center H and V
					// More than 3 lines enough to fit bodyTopMargin on top and bottom: Top with bodyTopMargin and left aligned
					// More than 3 lines and not enough for TopMargin: center V and left align
					// More than 3 lines and overflowing: align to top and scrollbar
					// (LineCount property doesn't work with rich text so an estimated height is used.)
					property bool moreThan3Lines: false
					property bool tooManyLines: false
					property string textContent: content
					property bool isRichText: qtUtils.mightBeRichText(textContent)

					anchors {
						left: parent.left
						right: parent.right
					}
					horizontalAlignment: (moreThan3Lines || bodyTextAlignLeft) ? Text.AlignLeft : Text.AlignHCenter
					color: colors.dialogMessageText
					wrapMode: Text.WordWrap
					font.family: qfont.regular.name
					font.pixelSize: bodyFontPixelSize
					fontSizeMode: Text.VerticalFit
					minimumPixelSize: qfont.bodyText
					lineHeightMode: Text.FixedHeight
					lineHeight: Math.floor(bodyFontPixelSize * 1.5 * (tooManyLines ? 0.9 : 1)) // this doesn't work for rich text

					onTextContentChanged: updateProperties();
					Connections {
						target:	dialogComponent
						onBodyFontLineHeightChanged: dialogMessage.updateProperties();
						onBodyFontPixelSizeChanged: dialogMessage.updateProperties();
					}

					function updateProperties() {
						text = textContent;
						moreThan3Lines = false;
						tooManyLines = false;
						moreThan3Lines = (paintedHeight > (lineHeight * 3));
						tooManyLines = (paintedHeight + (p.bodyTopMargin * 2)) > dialogFlickable.height;
						anchors.topMargin = (moreThan3Lines && !tooManyLines ? p.bodyTopMargin : 0);

						// Rich Text doesn't get aligned using the property horizontalAlignment, so add a HTML tag to do so
						if (isRichText && !moreThan3Lines)
							text = "<center>"+text+"</center>";
						dialogFlickable.contentHeight = Math.max(paintedHeight, dialogFlickable.height);

						if (!moreThan3Lines || (tooManyLines && !scrollbar.visible)) {
							anchors.top = undefined;
							anchors.verticalCenter = parent.verticalCenter;
						} else {
							anchors.verticalCenter = undefined;
							anchors.top = parent.top
						}

						dialogFlickable.contentY = 0;
					}
				}
			}

			ScrollBar {
				id: scrollbar
				anchors {
					right: parent.right
					top: parent.top
					bottom: parent.bottom
				}
				container: dialogFlickable
				alwaysShow: false

				onNext: {
					var newY = container.contentY + dialogMessage.lineHeight;
					if ((container.contentHeight - newY) < container.height)
						newY = (container.contentHeight - container.height);
					container.contentY = newY;
				}

				onPrevious: {
					var newY = Math.max(container.contentY - dialogMessage.lineHeight, 0);
					container.contentY = newY;
				}

			}

			// Load QML file
			Loader {
				id: dialogMessageLoader
				anchors.fill: parent
			}
		}

		/** Footer container, only visible when one off the two buttons contains text.
		  * If not visible set height to 0. This will center dialog content horizontaly nice
		  * in dialog (not taking buttons area into account).
		  */

		Item {
			id: dialogButtonContainer
			width: dialogArea.width
			height: visible ? btn1.height + Math.round(20 * verticalScaling) : 0
			visible: { ((btn1.text.length > 0) ||  (btn2.text.length > 0)) }
			anchors.bottom: dialogArea.bottom

			// Background
			StyledRectangle {
				id: dialogButtonArea
				anchors.fill: parent
				color: colors.dialogFooterBar
				radius: dialogArea.radius
				topLeftRadiusRatio: 0
				topRightRadiusRatio: 0
				bottomRightRadiusRatio: 1
				bottomLeftRadiusRatio: 1
				mouseEnabled: false
			}

			// First button
			StandardButton {
				id: btn1
				objectName: "btn1"
				minWidth: Math.round(80 * horizontalScaling)
				height: Math.round(36 * verticalScaling)
				leftClickMargin: btn2.visible ? 3 : 10
				text: ""
				onTextChanged: {
					btn1.visible = (text.length > 0);
				}
				anchors {
					verticalCenter: parent.verticalCenter
					right: dialogButtonContainer.right
					rightMargin: Math.round(18 * horizontalScaling)
				}
				visible: false
				mouseIsActiveInDimState: false
				primary: highlightPrimaryBtn
			}

			// Second button
			StandardButton {
				id: btn2
				objectName: "btn2"
				minWidth: Math.round(80 * horizontalScaling)
				height: Math.round(36 * verticalScaling)
				rightClickMargin: btn2.visible ? 3 : 10
				text: ""
				onTextChanged: {
					visible = (text.length > 0);
				}
				anchors {
					verticalCenter: parent.verticalCenter
					right: btn1.left
					rightMargin: designElements.hMargin6
				}
				visible: false
				mouseIsActiveInDimState: false
			}
		}
	}
}
