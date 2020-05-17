import QtQuick 2.1

import BasicUIControls 1.0;

Item {
	id: root
	implicitWidth: keysGrid.width
	implicitHeight: childrenRect.height

	property int buttonWidth: Math.round(50 * horizontalScaling)
	property int buttonHeight: buttonWidth
	property int buttonSpace: Math.round(20 * horizontalScaling)
	property bool pinMode: false
	property int maxTextLength: pinMode ? 4 : -1
	property alias numberText: enteredNumber.text
	property int numberLength: pinMode ? p.enteredPin.length : enteredNumber.text.length
	property alias leftText: leftText.text
	property alias rightText: rightText.text
	property int maxDecimals: 4

	signal pinEntered(string pin)
	signal digitEntered(string digit)

	QtObject {
		id: p
		property bool disableInput: false
		property string enteredPin

		onEnteredPinChanged: checkMaxLength(enteredPin)

		function backspace() {
			if (pinMode)
				p.enteredPin = p.enteredPin.slice(0, -1);
			else
				enteredNumber.removeLastCharOfText();
		}

		function addDecimalSeparator(decimalSymbol) {
			if (pinMode)
				return;

			if (enteredNumber.text.length > 0 && enteredNumber.text.indexOf(decimalSymbol) == -1) {
				enteredNumber.addTextPartToText(decimalSymbol);
			}
		}

		function checkMaxLength(text) {
			var decimalIdx = text.indexOf(i18n.decimalSeparator());
			if ((decimalIdx >= 0 && (text.length - decimalIdx - 1) >= root.maxDecimals) || text.length === root.maxTextLength) {
				p.disableInput = true;
				pinEntered(p.enteredPin);
			} else {
				p.disableInput = false;
			}
		}
	}

	function clear() {
		if (pinMode)
			p.enteredPin = "";
		else
			enteredNumber.clearText();
	}

	function wrongPin() {
		if (!pinMode)
			return;

		clear();
		if (isNxt)
			wrongPinAnim.restart();
	}

	KeyboardGroup {
		id: keyboard
		enableLongPress: false
		onKeyPressed: {
			digitEntered(key);

			if (pinMode)
				p.enteredPin += key;
			else
				enteredNumber.addTextPartToText(key);

		}
	}

	StyledRectangle {
		id: editField
		width: keysGrid.width
		height: Math.round(40 * verticalScaling)
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		color: colors.keyboardOuterBorder
		radius: designElements.radius
		visible: !pinMode

		StyledCursorLabel {
			id: enteredNumber

			anchors.margins: Math.round(6 * horizontalScaling)
			anchors.fill: parent

			color: colors.keyboardInnerBg
			borderColor: colors.keyboardInnerBorder
			borderWidth: 2
			borderStyle: Qt.SolidLine

			fontFamily: qfont.regular.name
			fontPixelSize: qfont.bodyText
			fontColor: colors.keyboardInputColor

			radius: 0

			leftMargin: designElements.hMargin6
			rightMargin: designElements.hMargin6
			alignment: "AlignmentLeft"

			cursorHeight: root.buttonWidth / 2.5
			cursorActivated: visible

			maxTextWidth: width - leftMargin - rightMargin - 2
			maxTextLength: root.maxTextLength

			onTextChanged: p.checkMaxLength(text)
		}
	}

	Row {
		id: pinDigits
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Math.round(2 * horizontalScaling)
		visible: pinMode
		property int digitWidth: (keysGrid.width - ((maxTextLength - 1) * pinDigits.spacing)) / maxTextLength

		SequentialAnimation on anchors.horizontalCenterOffset {
			id: wrongPinAnim
			running: false
			loops: 3 // doesn't seem to work
			SmoothedAnimation{ to: 10; duration: 100 }
			SmoothedAnimation{ to: -10; duration: 100 }
			SmoothedAnimation{ to: 0; duration: 100 }
		}

		Repeater {
			id: digitsRepeater
			model: maxTextLength

			StyledRectangle {
				width: pinDigits.digitWidth
				height: width
				color: colors.keyboardPinDigitsBg
				radius: designElements.radius

				topLeftRadiusRatio: index === 0 ? 1 : 0
				bottomLeftRadiusRatio: topLeftRadiusRatio
				topRightRadiusRatio: index === digitsRepeater.count - 1 ? 1 : 0
				bottomRightRadiusRatio: topRightRadiusRatio

				Text {
					anchors.centerIn: parent
					font {
						family: qfont.semiBold.name
						pixelSize: qfont.primaryImportantBodyText
					}
					color: colors.keyboardInputColor
					text: "*"
					visible: index < p.enteredPin.length
				}
			}

		}
	}

	Text {
		id: leftText
		anchors {
			right: editField.left
			rightMargin: Math.round(14 * horizontalScaling)
			verticalCenter: editField.verticalCenter
		}
		color: colors._fantasia
		font {
			pixelSize: qfont.navigationTitle
			family: qfont.semiBold.name
		}
	}

	Text {
		id: rightText
		anchors {
			left: editField.right
			leftMargin: Math.round(14 * horizontalScaling)
			verticalCenter: editField.verticalCenter
		}
		color: colors._fantasia
		font {
			pixelSize: qfont.navigationTitle
			family: qfont.semiBold.name
		}
	}

	Grid {
		id: keysGrid
		columns: 3
		rows: 4
		spacing: root.buttonSpace

		anchors {
			top: pinMode ? pinDigits.bottom : editField.bottom
			topMargin: root.buttonSpace
			horizontalCenter: parent.horizontalCenter
		}

		Repeater {
			model: 9
			KeyButton {
				width: root.buttonWidth
				height: root.buttonHeight
				controlGroup: keyboard

				fontFamily: qfont.semiBold.name
				fontPixelSize: qfont.navigationTitle
				enabled: !p.disableInput && root.enabled
			}
		}

		KeyButton {
			id: leftBtn
			width: root.buttonWidth
			height: root.buttonHeight

			fontFamily: qfont.semiBold.name
			fontPixelSize: qfont.navigationTitle
		}

		KeyButton {
			id: zeroBtn
			width: root.buttonWidth
			height: root.buttonHeight
			controlGroup: keyboard

			fontFamily: qfont.semiBold.name
			fontPixelSize: qfont.navigationTitle
			enabled: !p.disableInput && root.enabled
		}

		KeyButton {
			id: rightBtn
			width: root.buttonWidth
			height: root.buttonHeight

			fontFamily: qfont.semiBold.name
			fontPixelSize: qfont.navigationTitle
		}
	}

	state: pinMode ? "num_integer_clear_backspace" : "num_normal"
	states: [
		State {
			name: "num_normal"
			PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
			PropertyChanges { target: rightBtn; text: qsTr("C"); onClicked: clear() }
			PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); onClicked: p.addDecimalSeparator(text); enabled: !p.disableInput && root.enabled }
		},
		State {
			name: "num_integer"
			PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
			PropertyChanges { target: rightBtn; text: qsTr("C"); onClicked: clear(); enabled: root.enabled }
			PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); enabled: false }
		},
		State {
			name: "num_integer_backspace"
			PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
			PropertyChanges { target: rightBtn; text: ""; iconSource: "drawables/backspace_numkeyb.svg"; onClicked: p.backspace(); enabled: root.enabled }
			PropertyChanges { target: leftBtn; text: i18n.decimalSeparator(); enabled: false }
		},
		State {
			name: "num_integer_clear_backspace"
			PropertyChanges { target: keyboard; keys: qsTr("0123456789") }
			PropertyChanges { target: rightBtn; text: ""; iconSource: "drawables/backspace_numkeyb.svg"; onClicked: p.backspace(); enabled: root.enabled }
			PropertyChanges { target: leftBtn; text: qsTr("C"); onClicked: clear(); enabled: root.enabled }
		}
	]
}
