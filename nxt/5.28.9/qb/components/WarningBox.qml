import QtQuick 2.1

/**
 * Static rectangle showing warning message. This warning is meant to be placed on the screen
 * where e.g. uncorrect setting of parameter by user may be dangerous.
*/
Rectangle {
	id: warningBox
	implicitWidth: Math.round(530 * horizontalScaling)
	implicitHeight: autoHeight ? Math.max(txtWarning.implicitHeight,imgWarning.implicitHeight) + (designElements.vMargin15 * 2) : Math.round(86 * verticalScaling)
	radius: designElements.radius
	color: colors.warningBackground
	border {
		width: Math.round(2 * horizontalScaling)
		color: colors.warningBorder
	}
	property bool autoHeight: false
	property alias textPixelSize: txtWarning.font.pixelSize
	/// Text displayed by warning box.
	property alias warningText: txtWarning.text
	property alias warningTextFormat: txtWarning.textFormat
	property alias warningIcon: imgWarning.source
	property string kpiPostfix: "WarningBox"

	Image {
		id: imgWarning
		source: "image://scaled/images/warning.svg"
		anchors {
			left: parent.left
			leftMargin: designElements.margin22
			verticalCenter: parent.verticalCenter
		}
		visible: source == "" ? false : true
	}

	Text {
		id: txtWarning
		wrapMode: Text.WordWrap
		anchors {
			left: imgWarning.visible ? imgWarning.right : parent.left
			leftMargin: designElements.margin20
			right: parent.right
			rightMargin: designElements.margin20
			verticalCenter: parent.verticalCenter
		}
		color: colors.warningText
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}
}
