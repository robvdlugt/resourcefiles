import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: firmwareUpdateScreen

	screenTitle: qsTr("Firmware update")


	onShown: {
	}

        Text {
                id: title
                anchors {
                        top: parent.top
                        topMargin: Math.round(40 * 1.25)
                        left: parent.left
                        leftMargin: Math.round(60 * 1.28)
                        right: parent.right
                        rightMargin: anchors.leftMargin
                }
                font {
                        family: qfont.semiBold.name
                        pixelSize: qfont.navigationTitle
                }
                color: "#565656"
                text: "Press the button to update the Toon firmware. Please be aware that this firmware update function provided by the TSC team is in BETA state and not tested on a lot of toons yet. In the worst case you will end up with a not working Toon! You can follow the update logs using SSH with the command 'tail -f /var/log/tsc.toonupdate.log'" 
                wrapMode: Text.WordWrap
        }


	StandardButton {
		id: toonUpdateButton

		text: qsTr("Update firmware")

		height: 40

		anchors {
			top: title.bottom
			topMargin: Math.round(60 * app.nxtScale)
			left: title.left
		}

		topClickMargin: 2
		onClicked: {
                                var commandFile = new XMLHttpRequest();
                                commandFile.open("PUT", "file:///tmp/tsc.command");
				commandFile.send("toonupdate");
				commandFile.close
				app.softwareUpdateInProgressPopup.show();
		}
	}



}
