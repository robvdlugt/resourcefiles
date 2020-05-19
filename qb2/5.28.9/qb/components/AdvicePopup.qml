import QtQuick 2.1
import qb.components 1.0

Item {
	id: root
	anchors.fill: parent
	property string content
	property string errorCode

	QtObject {
		id: p
		property int bodyTopMargin: Math.round(17 * verticalScaling)
	}

	Flickable {
		id: adviceFlickable
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: errorCodeRect.top
			leftMargin: Math.round(50 * horizontalScaling)
			rightMargin: anchors.leftMargin
			topMargin: designElements.vMargin6
			bottomMargin: designElements.vMargin6
		}
		contentWidth: width
		interactive: false
		clip: true

		// Message
		Text {
			id: adviceText
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.advicePopupText
			wrapMode: Text.WordWrap

			Connections {
				target: root
				onContentChanged: adviceText.updateProperties()
			}

			function updateProperties() {
				text = content;
				var tooManyLines = false;
				tooManyLines = (paintedHeight + (p.bodyTopMargin * 2)) > adviceFlickable.height;
				anchors.topMargin = (!tooManyLines ? p.bodyTopMargin : 0);
				adviceFlickable.contentHeight = Math.max(paintedHeight, adviceFlickable.height);
				adviceFlickable.contentY = 0;
			}
		}
	}


	ScrollBar {
		id: scrollbar
		anchors {
			right: parent.right
			top: parent.top
			bottom: errorCodeRect.top
		}
		container: adviceFlickable
		alwaysShow: false

		onNext: {
			var newY = container.contentY + (adviceText.font.pixelSize * 3);
			if ((container.contentHeight - newY) < container.height)
				newY = (container.contentHeight - container.height);
			container.contentY = newY;
		}

		onPrevious: {
			var newY = Math.max(container.contentY - (adviceText.font.pixelSize * 3), 0);
			container.contentY = newY;
		}

	}

	Rectangle {
		id: errorCodeRect
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		height: errorCodeImage.height + (designElements.vMargin10 * 2)
		color: colors.advicePopupErrorBar

		ErrorButton {
			id: errorCodeImage
			anchors {
				left: parent.left
				leftMargin: designElements.hMargin15
				verticalCenter: parent.verticalCenter
			}
			error: true
			enabled: false
			errorCode: root.errorCode
		}

		Text {
			id: errorCodeHelpText
			anchors {
				left: errorCodeImage.right
				right: parent.right
				leftMargin: errorCodeImage.anchors.leftMargin
				rightMargin: anchors.leftMargin
				verticalCenter: parent.verticalCenter
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.regular.name
			}
			color: colors.advicePopupText
			text: qsTr("advice_errorcode_help")
			wrapMode: Text.WordWrap
		}
	}
}
