import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

App {
	id: utilsApp

        property Screen alphaNumericKeyboardScreen;
        property Screen numericKeyboardScreen;

        QtObject {
                id: p

                property url alphaNumericKeyboardUrl: "qrc:/apps/tscSettings/AlphaNumericKeyboardScreen.qml"
                property url numericKeyboardUrl: "qrc:/apps/tscSettings/NumericKeyboardScreen.qml"
        }

        function init() {
                registry.registerWidget("screen", p.alphaNumericKeyboardUrl, utilsApp, "alphaNumericKeyboardScreen");
                registry.registerWidget("screen", p.numericKeyboardUrl, utilsApp, "numericKeyboardScreen");
        }
}
