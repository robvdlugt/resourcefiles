import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0

Screen {
	id: logonCredentialsMobileAppScreen

	isSaveCancelDialog: true
	screenTitle: "Logon credentials toon mobile"

	property bool firstShown: true;  // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again


	onSaved: {
		// save logon credentials
		var doc2 = new XMLHttpRequest();
		doc2.open("PUT", "file:///HCBv2/etc/lighttpd/lighttpd.user");
		doc2.send(userNameLabel.rightText + ":" + passwordLabel.rightText);
	}

	onShown: {
		if (firstShown) {
			firstShown = false;
		}
	}

	function saveName(text) {
		if (text) {
			userNameLabel.rightText = text;	
		}
	}

	function savePasswd(text) {
		if (text) {
			passwordLabel.rightText = text;	
		}
	}

        Text {
                id: bodyText

                width: Math.round(650 * app.nxtScale)
                wrapMode: Text.WordWrap

                text: "Set credentials for toon mobile web logon. See toonstore for the toon mobile app itself."
                color: "#000000"

                font.pixelSize: qfont.bodyText
                font.family: qfont.regular.name

                anchors {
                        top: parent.top
                        topMargin: isNxt ? Math.round(30 * 1.28) : 10
                        horizontalCenter: parent.horizontalCenter
                }
        }

	
	SingleLabel {
		id: userNameLabel
		width: isNxt ? 800 : 650
		leftText: "User:"
		anchors {
			top: parent.top
			topMargin : 160
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}
	
	IconButton {
		id: userNameButton
		width: 45
		height: userNameLabel.height
			iconSource: "qrc:/images/edit.svg" 
			anchors {
			top: userNameLabel.top
			left: userNameLabel.right
			leftMargin: 10
		}
		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Username toon mobile app", userNameLabel.rightText, saveName);
		}
	}
	
	SingleLabel {
		id: passwordLabel
		width: isNxt ? 800 : 650
		leftText: "Password:"
		anchors {
			top: userNameButton.bottom
			topMargin : 60
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}
	
	IconButton {
		id: passwordButton
		width: 45
		height: passwordLabel.height
			iconSource: "qrc:/images/edit.svg" 
			anchors {
			top: passwordLabel.top
			left: passwordLabel.right
			leftMargin: 10
		}
		topClickMargin: 3
		onClicked: {
			qkeyboard.open("Password toon mobile app", passwordLabel.rightText, savePasswd);
		}
	}
}

