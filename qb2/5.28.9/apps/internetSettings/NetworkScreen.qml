import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: networkScreen
	hasCancelButton: true
	hasSaveButton: false
	screenTitle: qsTr("Connect to network")

	QtObject {
		id: p
		property bool connectBtnEnabled: (p.networkInfo || networkNameInput.acceptableInput) && passwordInput.acceptable
		onConnectBtnEnabledChanged: connectBtnEnabled ? enableCustomTopRightButton() : disableCustomTopRightButton()
		property var networkInfo

		function validatePassword(field) {
			if (!field.acceptable) {
				qdialog.showDialog(qdialog.SizeSmall, qsTr("Error"), qsTr("password-too-short"));
				qdialog.setClosePopupCallback(function () {
					field.setFocus(true);
				});
			}
		}
	}

	onShown: {
		addCustomTopRightButton(qsTr("Connect"))
		if (args && args.networkInfo)
			p.networkInfo = args.networkInfo;
		if (!p.connectBtnEnabled)
			disableCustomTopRightButton();
	}

	onCustomButtonClicked: {
		var newNetworkInfo = {};
		if (p.networkInfo && p.networkInfo.hasOwnProperty("essid")) {
			newNetworkInfo = p.networkInfo;
			if (newNetworkInfo.auth !== "OPEN")
				newNetworkInfo.password = passwordInput.inputText;
		} else {
			newNetworkInfo.essid = networkNameInput.inputText
			newNetworkInfo.enc = "UNUSED";
			if (app.hiddenNetworkAuth > -1) {
				newNetworkInfo.auth = app.securityTypes[app.hiddenNetworkAuth];
				newNetworkInfo.password = passwordInput.inputText;
			} else {
				newNetworkInfo.auth = "OPEN";
			}
			app.hiddenNetworkEssid = newNetworkInfo.essid;
		}
		app.connectToWifi(newNetworkInfo);
		hide();
	}


	Text {
		id: title
		anchors {
			left: container.left
			right: container.right
			bottom: container.top
			bottomMargin: designElements.vMargin6
		}
		font {
			pixelSize: qfont.navigationTitle
			family: qfont.semiBold.name
		}
		color: colors.rbTitle
		text: qsTr("Enter the network details")
	}

	GridLayout {
		id: container
		anchors {
			left: parent.left
			leftMargin: Math.round(200 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Qt.inputMethod.visible ? Math.round(-115 * verticalScaling) : 0
		}
		rowSpacing: designElements.vMargin6
		columnSpacing: rowSpacing
		columns: 2

		EditTextLabel {
			id: networkNameInput
			Layout.fillWidth: true
			Layout.columnSpan: 2
			labelText: qsTr("Name")
			prefilledText: p.networkInfo ? p.networkInfo.essid : ""
			leftTextAvailableWidth: Math.max(networkNameInput.leftTextImplicitWidth, passwordInput.leftTextImplicitWidth) + Math.round(30 * horizontalScaling)
			inputHints: Qt.ImhPreferLowercase | Qt.ImhSensitiveData | Qt.ImhLatinOnly
			validator: RegExpValidator { regExp: /.+/ } // not empty
			readOnly: p.networkInfo && p.networkInfo.essid ? true : false
			maxLength: 32
		}

		SingleLabel {
			id: securityLabel
			Layout.fillWidth: true
			Layout.columnSpan: securityButton.visible ? 1 : 2
			leftText: qsTr("Security")
			rightText: p.networkInfo && p.networkInfo.auth ? p.networkInfo.auth : (app.hiddenNetworkAuth !== -1 ? app.securityTypes[app.hiddenNetworkAuth] :"")
			mouseEnabled: securityButton.visible

			onClicked: securityButton.clicked()
		}

		IconButton {
			id: securityButton
			Layout.minimumWidth: height
			iconSource: "qrc:/images/edit.svg"
			topClickMargin: 3
			bottomClickMargin: 3
			visible: p.networkInfo ? false : true

			onClicked: stage.openFullscreen(app.securityScreenUrl)
		}

		EditTextLabel {
			id: passwordInput
			Layout.fillWidth: true
			Layout.columnSpan: 2
			labelText: qsTr("Password")
			leftTextAvailableWidth: Math.max(networkNameInput.leftTextImplicitWidth, passwordInput.leftTextImplicitWidth) + Math.round(30 * horizontalScaling)
			isPassword: true
			inputHints: Qt.ImhNoAutoUppercase | Qt.ImhSensitiveData
			maxLength: 64
			// make our own validation so we can show feedback
			property bool acceptable: (app.securityTypes[app.hiddenNetworkAuth] === "WEP" ? inputText.length >= 5 : inputText.length >= 8)

			onInputAccepted: p.validatePassword(passwordInput)
		}
	}
}
