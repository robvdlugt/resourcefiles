import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

StyledRectangle {
	id: root
	width: row.anchors.leftMargin + row.width + row.anchors.rightMargin
	height: row.anchors.topMargin + row.height + row.anchors.bottomMargin
	anchors.centerIn: parent ? parent : undefined
	color: qtUtils.addColorAlpha(colors.black, 0.8)
	radius: designElements.radius
	visible: false
	mouseEnabled: false
	z: 9999
	property int maxWidth: Math.round(580 * horizontalScaling)

	QtObject {
		id: p
		property int defaultTimeout: 5000
		property Timer hideTimer: null
		property int maxTextWidth: root.maxWidth - icon.width - row.anchors.leftMargin - (icon.source ? row.spacing : 0) - row.anchors.rightMargin

		function cancelHideTimer() {
			if (p.hideTimer) {
				p.hideTimer.destroy();
				p.hideTimer = null;
			}
		}
	}

	Component.onDestruction: p.cancelHideTimer()

	Row {
		id: row
		anchors {
			top: parent.top
			left: parent.left
			topMargin: Math.round(44 * verticalScaling)
			leftMargin: Math.round(30 * horizontalScaling)
			rightMargin: anchors.topMargin
			bottomMargin: anchors.topMargin
		}
		spacing: anchors.leftMargin

		Image {
			id: icon
			anchors.verticalCenter: parent.verticalCenter
			source: ""
			visible: source ? true : false
		}

		Text {
			id: textElement
			anchors.verticalCenter: parent.verticalCenter
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.white
			text: " "
			wrapMode: Text.WordWrap
			onTextChanged: width = Math.min(paintedWidth, p.maxTextWidth)
		}
	}

	Item {
		id: closeBtn
		width: row.anchors.rightMargin
		height: row.anchors.topMargin
		anchors {
			top: parent.top
			right: parent.right
		}

		Image {
			id: closeIcon
			anchors.centerIn: parent
			source: "image://scaled/images/white-cross.svg"
		}

		MouseArea {
			anchors.fill: parent
			property string kpiPostfix: "CloseToast"
			onClicked: root.hide()
		}
	}

	function show(text, iconUrl, timeout) {
		p.cancelHideTimer();
		icon.source = iconUrl ? iconUrl : "";
		textElement.text = text;
		visible = true;
		if (typeof timeout === "undefined")
			timeout = p.defaultTimeout;
		if (timeout)
			p.hideTimer = util.delayedCall(timeout, hide);
	}

	function hide() {
		p.cancelHideTimer();
		visible = false;
		icon.source = "";
	}
}
