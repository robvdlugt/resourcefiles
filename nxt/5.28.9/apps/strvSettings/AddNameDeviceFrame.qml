import QtQuick 2.0
import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: addNameDeviceFrame
	title: qsTr("Give this valve a name")
	imageSource: "drawables/add-naming.svg"
	property bool canContinue: editText.acceptableInput

	onShown: {
		parentScreen.editingDeviceUuidChanged.connect(function uuidChanged() {
			if (parentScreen.editingDeviceUuid) {
				enableCancelButton();
				var device = app.getDeviceByUuid(parentScreen.editingDeviceUuid);
				if (device)
					editText.inputText = device.name;
			}
			parentScreen.editingDeviceUuidChanged.disconnect(uuidChanged);
		});
	}

	onNext: {
		var uuid = parentScreen.editingDeviceUuid ? parentScreen.editingDeviceUuid : parentScreen.newDeviceUuid;
		app.setDeviceName(uuid, editText.inputText);
	}

	Text {
		id: bodyText
		anchors {
			top: parent.top
			left: parent.left
			right: parent.right
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("Enter a name for the smart radiator valve up to %1 characters.").arg(app._STRV_NAME_MAX_LENGTH)
	}

	EditTextLabel {
		id: editText
		anchors {
			top: bodyText.bottom
			topMargin: designElements.vMargin6
			left: bodyText.left
			right: bodyText.right
		}
		labelText: qsTr("Name")
		maxLength: app._STRV_NAME_MAX_LENGTH
		validator: RegExpValidator { regExp: /^\S.*$/ } // empty name is not allowed

		topClickMargin: designElements.vMargin10
		bottomClickMargin: designElements.vMargin10
	}

	WarningBox {
		anchors {
			top: editText.bottom
			topMargin: designElements.vMargin20
			left: bodyText.left
			right: bodyText.right
		}
		autoHeight: true

		warningText: qsTr("add-name-warning")
		warningIcon: ""
	}
}
