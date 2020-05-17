import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

import BasicUIControls 1.0

Popup {
	id: basePopup
	visible: false
	anchors.fill: parent
	property alias popupWidth: background.width
	property alias popupHeight: background.height
	property alias iconSource: icon.source
	property alias titleText: headerText.text
	property alias headerBgColor: headerBar.color
	property bool hideCloseBtn: false
	property alias contentSource: loader.source

	function setContent(contentUrl, contentArgs) {
		if (loader.item !== null) {
			if (loader.item.hidden instanceof Function)
				loader.item.hidden();
		}
		if (contentUrl) {
			loader.loaded.connect(function onLoaded() {
				if (loader.item.shown instanceof Function)
					loader.item.shown(contentArgs);
				loader.loaded.disconnect(onLoaded);
			});
		}
		loader.setSource(contentUrl);
	}

	QtObject {
		id: _p
		property int inputItemOffset: 0

		function ensureInputVisibility() {
			_p.inputItemOffset = 0;
			if (InputContext.inputItem !== null && !qtUtils.isRootItem(InputContext.inputItem)) {
				var keyboardRectY = background.mapFromItem(home, 0, Qt.inputMethod.keyboardRectangle.y - Qt.inputMethod.keyboardRectangle.height).y;
				var inputItemBottomY = background.mapFromItem(InputContext.inputItem, 0, InputContext.inputItem.y + InputContext.inputItem.height).y;
				if (inputItemBottomY - keyboardRectY > 0) {
					_p.inputItemOffset = - (inputItemBottomY - keyboardRectY) - InputContext.inputItem.height - designElements.vMargin20;
				}
			}
		}
	}

	Connections {
		target: InputContext
		enabled: basePopup.visible
		onInputItemChanged: _p.ensureInputVisibility()
	}

	Rectangle {
		id: maskedArea
		anchors.fill: parent
		color: colors.dialogMaskedArea
	}

	MouseArea {
		id: maskMouseArea
		anchors.fill: parent
		onClicked: qtUtils.clearFocus()
	}

	Rectangle {
		id: background
		width: Math.round(620 * horizontalScaling)
		height: Math.round(330 * verticalScaling)
		anchors.centerIn: parent
		anchors.verticalCenterOffset: Qt.inputMethod.visible ? _p.inputItemOffset : 0
		radius: designElements.radius
		color: colors.white

		MouseArea {
			id: bgMouseArea
			anchors.fill: parent
			onClicked: qtUtils.clearFocus()
		}

		StyledRectangle {
			id: headerBar
			height: Math.round(53 * verticalScaling)
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			color: colors.dialogHeaderBar
			radius: background.radius

			topLeftRadiusRatio: 1
			topRightRadiusRatio: 1
			bottomRightRadiusRatio: 0
			bottomLeftRadiusRatio: 0

			mouseEnabled: false

			Image {
				id: icon
				anchors {
					verticalCenter: headerText.verticalCenter
					right: headerText.left
					rightMargin: designElements.hMargin20
				}
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

				onTextChanged: width = Math.min(parent.width * 0.8, implicitWidth);
			}

			IconButton {
				id: closeBtn
				width: height
				height: parent.height
				anchors.top: parent.top
				anchors.right: parent.right

				radius: background.radius
				topLeftRadiusRatio: 0
				topRightRadiusRatio: 1
				bottomRightRadiusRatio: 0
				bottomLeftRadiusRatio: 0

				iconSource: "qrc:/images/DialogCross.svg"
				colorUp: parent.color
				visible: !hideCloseBtn

				onClicked: basePopup.hide()
			}
		}

		Loader {
			id: loader
			anchors {
				top: headerBar.bottom
				bottom: parent.bottom
				left: parent.left
				right: parent.right
			}
		}
	}
}
