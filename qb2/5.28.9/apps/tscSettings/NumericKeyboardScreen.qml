import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

import "NumericKeyboard.js" as NumericKeyboardJs

Screen {
        id: numericKeyboardScreen

        property alias keyboardState: numericKeyboard.state

        property string alphaState: "alpha_normal"
        property string alphaCapsState: "alpha_caps"
        property string alphaCapsFixedState: "alpha_caps_fixed"
        property string nummericState: "num_shift_down"
        property string nummericShiftUpState: "num_shift_up"
        property bool dimWasReachable

        function open(title, defaultNumber, leftText, rightText, cbSavedFunction, cbValidateFunction ) {
                numericKeyboard.state = alphaState;
                setTitle(title);
                NumericKeyboardJs.numberSavedCallback = cbSavedFunction;
                NumericKeyboardJs.numberChangedCallback = cbValidateFunction;
                numericKeyboard.inputText = defaultNumber;
                show();
                numericKeyboard.inputFocus = true;
        }

        function showKeyboardErrorPopup(dialogContentText) {
                if (dialogContentText) {
                        qdialog.showDialog(qdialog.SizeLarge,
                                                        dialogContentText.title ? dialogContentText.title : qsTr("Keyboard error"),
                                                        dialogContentText.content);
                }
        }

        hasCancelButton: true
        hasSaveButton: false

        onShown: {
                dimWasReachable = screenStateController.screenColorDimmedIsReachable;
                screenStateController.screenColorDimmedIsReachable = false;
                addCustomTopRightButton(qsTr("Save"));
        }

        onHidden: {
                screenStateController.screenColorDimmedIsReachable = dimWasReachable;
        }

        onCustomButtonClicked: {
                var dialogText = null;
                if (NumericKeyboardJs.numberChangedCallback) {
                        dialogText = NumericKeyboardJs.numberChangedCallback(numericKeyboard.inputText, true);
                }
                if (dialogText == null) {
                        if (NumericKeyboardJs.numberSavedCallback) {
                                NumericKeyboardJs.numberSavedCallback(numericKeyboard.inputText);
                        }
                        hide();
                } else {
                        showKeyboardErrorPopup(dialogText);
                }
        }

        EditTextLabel {
                id: numericKeyboard
                anchors.horizontalCenter: parent.horizontalCenter
		inputHints: Qt.ImhDigitsOnly 
                y: 10
        }
}
