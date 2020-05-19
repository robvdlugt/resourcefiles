import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3

import BasicUIControls 1.0

Item {
	id: root
	width: Math.round(430 * horizontalScaling)
	height: Math.round(36 * verticalScaling)

	property alias leftText: labelTitle.text
	property alias labelText: labelTitle.text
	property alias inputText: labelInput.text
	property string prefilledText
	property alias labelTextFormat: labelTitle.textFormat
	property alias inputHints: labelInput.inputMethodHints
	property alias validator: labelInput.validator
	property alias readOnly: labelInput.readOnly
	property alias acceptableInput: labelInput.acceptableInput
	property bool isPassword: false
	property alias inputAlignment: labelInput.horizontalAlignment
	property alias inputFocus: labelInput.focus
	property int leftTextAvailableWidth: -1
	property int leftTextImplicitWidth: Math.ceil(labelTitle.implicitWidth)
	property alias labelFontFamily: labelTitle.font.family
	property alias labelFontSize: labelTitle.font.pixelSize
	property string kpiPostfix: leftText ? leftText : "editTextLabel"
	property alias maxLength: labelInput.maximumLength
	property bool showAcceptButton: false
	property bool showValidationIcon: false
	property bool mouseEnabled: true
	property string placeholder

	property bool useLabelForInputFocus: true
	// The following margins only have effect if useLabelForInputFocus is true
	property real leftClickMargin: 0
	property real rightClickMargin: 0
	property real topClickMargin: 0
	property real bottomClickMargin: 0


	signal clicked()
	signal inputAccepted()
	signal inputEdited()

	function setFocus(value) {
		labelInput.focus = value;
	}

	function selectFocusAll() {
		labelInput.forceActiveFocus();
		labelInput.selectAll();
	}

	onPrefilledTextChanged: labelInput.text = root.prefilledText

	Rectangle {
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			right: showAcceptButton ? acceptButton.left : parent.right
			rightMargin: showAcceptButton ? designElements.spacing6 : 0
		}
		color: enabled ? colors.editTextLabelBg : colors.editTextLabelBgDisabled
		radius: designElements.radius

		MouseArea {
			anchors.fill: parent
			enabled: root.mouseEnabled
			onClicked: {
				if (useLabelForInputFocus)
					labelInput.forceActiveFocus();
				root.clicked();
			}

			anchors {
				leftMargin:   - root.leftClickMargin
				rightMargin:  - root.rightClickMargin
				topMargin:    - root.topClickMargin
				bottomMargin: - root.bottomClickMargin
			}
		}

		RowLayout {
			anchors.fill: parent
			anchors.margins: designElements.vMargin5
			spacing: designElements.hMargin10

			Text {
				id: labelTitle
				Layout.leftMargin: designElements.hMargin5
				Layout.minimumWidth: leftTextAvailableWidth > 0 ? -1 : Math.round(127 * horizontalScaling)
				Layout.preferredWidth: leftTextAvailableWidth
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.titleText
				}
				text: leftText
				visible: text ? true : false
				color: root.enabled ? colors.editTextLabelTitle : colors.editTextLabelTitleDisabled
			}

			Rectangle {
				id: labelField
				Layout.fillWidth: true
				Layout.fillHeight: true
				color: root.enabled ? colors.editTextLabelField : colors.editTextLabelFieldDisabled
				radius: designElements.radius
				border {
					width: 1
					color: colors.editTextLabelBorder
				}

				TextInput {
					id: labelInput
					anchors {
						left: parent.left
						right: fieldIcon.visible ? fieldIcon.left : parent.right
						leftMargin: Math.round(5 * horizontalScaling)
						rightMargin: anchors.leftMargin
						verticalCenter: parent.verticalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					clip: true
					color: root.enabled ? colors.editTextLabelInput : colors.editTextLabelInputDisabled
					selectionColor: colors._branding
					selectedTextColor: colors.white
					echoMode: root.isPassword && !labelInput.peekPassword ? TextInput.Password : TextInput.Normal
					passwordMaskDelay: 3000
					passwordCharacter: !isNxt ? "*" : ""
					rightPadding: horizontalAlignment & TextInput.AlignRight ? designElements.hMargin10 : 0
					EnterKeyAction.actionId: EnterKeyAction.Done

					property bool peekPassword: false

					onAccepted: {
						focus = false;
						root.inputAccepted();
					}
					onTextEdited: root.inputEdited();

					Text {
						text: root.placeholder
						anchors.right: parent.right
						color: colors.disabledText
						visible: !labelInput.text
						font: labelInput.font
					}
				}

				Image {
					id: fieldIcon
					anchors {
						right: parent.right
						rightMargin:labelInput.anchors.rightMargin
						verticalCenter: parent.verticalCenter
					}
					sourceSize.height: Math.round(16 * verticalScaling)
					visible: false

					MouseArea {
						id: fieldIconMA
						anchors {
							fill: parent
							margins: - designElements.vMargin10
						}
						enabled: false
					}

					states: [
						State {
							when: root.isPassword && !labelInput.peekPassword && labelInput.text.length
							PropertyChanges {
								target: fieldIcon
								source: "image://scaled/images/view.svg"
								visible: true
							}
							PropertyChanges {
								target: fieldIconMA
								enabled: true
								onClicked: labelInput.peekPassword = true
							}
						},
						State {
							when: root.isPassword && labelInput.peekPassword && labelInput.text.length
							PropertyChanges {
								target: fieldIcon
								source: "image://scaled/images/hide.svg"
								visible: true
							}
							PropertyChanges {
								target: fieldIconMA
								enabled: true
								onClicked: labelInput.peekPassword = false
							}
						},
						State {
							when: root.showValidationIcon && !root.isPassword
							PropertyChanges {
								target: fieldIcon
								source: "image://scaled/images/bad.svg"
								visible: labelInput.text.length && !labelInput.focus && !labelInput.acceptableInput
							}
						}
					]
				}

				MouseArea {
					anchors.fill: parent
					enabled: root.mouseEnabled && labelInput.readOnly
					onClicked: root.clicked()
				}
			}
		}
	}

	IconButton {
		id: acceptButton
		width: designElements.buttonSize
		anchors.right: parent.right
		iconSource: "qrc:/images/check.svg"
		visible: showAcceptButton
		enabled: labelInput.acceptableInput && labelInput.text !== root.prefilledText

		onClicked: labelInput.accepted()
	}

	Connections {
		target: Qt.inputMethod
		onVisibleChanged: {
			if (!Qt.inputMethod.visible)
				labelInput.focus = false;
		}
	}
}
