import QtQuick 2.1

Item {
    id: root

    QtObject {
        id: p
        property string valueStr: "000000"
        property string title
        
        function valueToString() {
            p.valueStr = "";
            var valStr = "" + value;
            var valStrLength = valStr.length;
            for(var i = 0; i < (6 - valStrLength); i++) {
                valStr = "0" + valStr;
            }
            p.valueStr = valStr;
        }

    }
    
	width: childrenRect.width
	height: childrenRect.height
    
    property int value: 0

    onValueChanged: {
        p.valueToString();
    }

    function setTitle(titleText) {
        title.text = titleText;
    }

    Text {
        id: title
    }

    Row {
        spacing: 5 
        Repeater {
            model: 6
            Rectangle {
				width: designElements.buttonSize
				height: Math.round(40 * verticalScaling)

				color: colors.meterReadingBackground
                Text {
                    id: digit
                    anchors.centerIn: parent
                    text: p.valueStr.charAt(index)
                    color: colors.meterReadingText
                    font {
                        family: qfont.semiBold.name
                        pixelSize: qfont.navigationTitle
                    }
                }
            }
     }
 }
}
