import QtQuick 2.1
import qb.components 1.0
import "Constants.js" as Constants

Item {
	id: singleGraphElement

	property int lineWidth: Math.round(139 * horizontalScaling)
	property bool first
	property bool last
	property int statusPrev
	property int statusNext
	property int deviceStatus
	property string name
	property string iconUrl
	property string errorCode
	signal errorButtonClicked()
	property int heightMargin: 0

	width: childrenRect.width - (singleLabel.paintedWidth === 0 ? singleLabel.width : 0)
	height: Math.round(65 * verticalScaling)  //childrenRect.height + (heightMargin * 2) -> this is causing a binding loop

	DashedLine {
		id: singleMeterLine
		width: lineWidth
		anchors {
			left: parent.left
			verticalCenter: parent.verticalCenter
		}
		color: colors[Constants.lineColors[deviceStatus]]
	}

	DashedLine {
		id: topVerticalLine
		anchors {
			left: singleMeterLine.left
			top: parent.top
			bottom: singleMeterLine.verticalCenter
		}
		color: colors[Constants.lineColors[last ? deviceStatus : statusPrev]]
		visible: !first
	}

	DashedLine {
		id: bottomVerticalLine
		anchors {
			left: parent.left
			top: singleMeterLine.verticalCenter
			bottom: parent.bottom
		}
		color: colors[Constants.lineColors[first ? deviceStatus : statusNext]]
		visible: !last
	}

	ErrorButton {
		id: errorButton
		anchors {
			verticalCenter: singleMeterLine.verticalCenter
			horizontalCenter:  singleMeterLine.horizontalCenter
			horizontalCenterOffset: 1
		}
		visible: Constants.getStatusIconVisible(deviceStatus)
		error: (deviceStatus === Constants.STATUS.ERROR)
		errorCode: singleGraphElement.errorCode
		onClicked: errorButtonClicked()
	}

	Item {
		id: singleIcon
		width: height
		height: Math.round(50 * horizontalScaling)
		anchors {
			left: singleMeterLine.right
			leftMargin: designElements.hMargin20
			verticalCenter: singleMeterLine.verticalCenter
		}

		Image {
			anchors.centerIn: parent
			source: (deviceStatus < Constants.STATUS.OK ? "image://colorized/" + colors.ibOverlayColorDisabled.toString() : "image://scaled/") + qtUtils.urlPath(Qt.resolvedUrl(iconUrl + ".svg"))
		}

	}

	Text {
		id: singleLabel
		width: Math.round(140 * horizontalScaling)
		anchors {
			left: singleIcon.right
			leftMargin: designElements.hMargin20
			verticalCenter: singleIcon.verticalCenter
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.semiBold.name
		}
		color: colors[Constants.labelColors[deviceStatus]]
		wrapMode: Text.WordWrap
		text: name
	}
}
