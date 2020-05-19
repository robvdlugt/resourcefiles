import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

FSWizardFrame {
	id: wizardFinishFrame
	title: qsTr("Place the smoke detector")
	imageSource: "drawables/sd-mount.svg"

	onNext: {
		// Reset the smokedetector uuid and name once it is fully added
		app.currentSmokedetectorUuid = "";
		app.currentSmokedetectorName = "";
		app.checkWarnEmptyPhoneNumbers();
	}

	Text {
		id: bodyText
		width: parent.width
		font {
			pixelSize: qfont.primaryImportantBodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		color: colors.text
		text: qsTr("mount-smokedetector")
	}
}
