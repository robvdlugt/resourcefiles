import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

import "AlphaNumericKeyboard.js" as AlphaNumericKeyboardJs

Screen {
        id: alphaNumericKeyboardScreen

        property alias keyboardState: alphaNumericKeyboard.state

        property string alphaState: "alpha_normal"
        property string alphaCapsState: "alpha_caps"
        property string alphaCapsFixedState: "alpha_caps_fixed"
        property string nummericState: "num_shift_down"
        property string nummericShiftUpState: "num_shift_up"
        property bool dimWasReachable

        function open(title, defaultText, cbSavedFunction, cbValidateFunction, maximumLength ) {
                alphaNumericKeyboard.state = alphaState;
                setTitle(title);
                AlphaNumericKeyboardJs.textSavedCallback = cbSavedFunction;
                AlphaNumericKeyboardJs.textChangedCallback = cbValidateFunction;
                alphaNumericKeyboard.inputText = defaultText;
                show();
                alphaNumericKeyboard.inputFocus = true;
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
                if (AlphaNumericKeyboardJs.textChangedCallback) {
                        dialogText = AlphaNumericKeyboardJs.textChangedCallback(alphaNumericKeyboard.inputText, true);
                }
                if (dialogText == null) {
                        if (AlphaNumericKeyboardJs.textSavedCallback) {
                                AlphaNumericKeyboardJs.textSavedCallback(alphaNumericKeyboard.inputText);
                        }
                        hide();
                } else {
                        showKeyboardErrorPopup(dialogText);
                }
        }

        EditTextLabel {
                id: alphaNumericKeyboard
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10
        }
}
