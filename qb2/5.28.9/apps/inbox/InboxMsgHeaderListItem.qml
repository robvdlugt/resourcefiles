import QtQuick 2.1
import qb.components 1.0

/// UI definition for message header shown in list view in Inbox application.

Item {
	id: itemHeaderDelegate

	/// Indication if this message was already read.
	property bool read: true
	property string subjectText: ""
	/// Item in list was clicked.
	signal clicked
	property string kpiPostfix: "message" + index

	height: Math.round(60 * verticalScaling)
	anchors {
		right: parent ? parent.right : undefined
		left: parent ? parent.left : undefined
	}

	Rectangle {
		id: itemRectangle
		anchors.fill: parent
		color: colors.none

		MouseArea {
			id: maItem
			z: 1
			hoverEnabled: false
			anchors.fill: parent
			onClicked: itemHeaderDelegate.clicked()
		}

		Item {
			id: imgMsgWrap
			height: Math.round(24 * verticalScaling)
			width: height
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: Math.round(2 * horizontalScaling)
			}
			Rectangle {
				id: readIcon
				height: Math.round(8 * verticalScaling)
				width: height
				radius: (width*0.5)
				color: colors.ibMsgDotUnread
				visible: !read
				anchors.centerIn: parent
			}
		}

		Text {
			id: txtSubject
			text:  subjectText
			elide: Text.ElideRight
			anchors {
				verticalCenter: imgMsgWrap.verticalCenter
				left: imgMsgWrap.right
				leftMargin: Math.round(14 * verticalScaling)
			}
			color: read ? colors.ibMsgTitleRead : colors.ibMsgTitleUnread
			font {
				pixelSize: read ? qfont.bodyText : qfont.titleText
				family: read ? qfont.regular.name : qfont.bold.name
			}
		}

		ThreeStateButton {
			id: arrow
			height: Math.round(44 * verticalScaling)
			width: height
			backgroundUp: "transparent"
			backgroundDown: "transparent"
			buttonDownColor: colors.ibMsgTitleSelected
			image: "qrc:/images/arrow-right.svg"
			anchors {
				verticalCenter: parent.verticalCenter
				right: parent.right
			}
			leftClickMargin: 10
			rightClickMargin: 10
			topClickMargin: 10
			onClicked: {
				maItem.clicked();
			}
		}
	}
}
