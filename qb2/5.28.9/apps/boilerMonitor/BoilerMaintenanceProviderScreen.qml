import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0

import "BoilerMonitorConstants.js" as Constants

EditScreen {
	id: root
	screenTitle: qsTr("screen-title")

	QtObject {
		id: p
		property variant selectedOption
	}

	onScreenShown: {
		if (!app.hasBackendData(Constants.BACKEND_DATA.MTNC_PROVIDERS))
			app.fetchMaintenanceProviders();
		if (app.boilerInfo.maintenanceProviderId > 0)
			p.selectedOption = app.boilerInfo.maintenanceProviderId;
	}

	onScreenSaved: {
		app.setBoilerMaintenanceProvider(p.selectedOption, root);
	}

	Text {
		id: headerText
		anchors {
			top: parent.top
			topMargin: Math.round(42 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.titleText
		}
		color: colors._harry
		wrapMode: Text.WordWrap
		text: qsTr("header-text")
	}

	Text {
		id: bodyText
		anchors {
			top: headerText.baseline
			topMargin: Math.round(20 * verticalScaling)
			left: headerText.left
			right: headerText.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors._gandalf
		wrapMode: Text.WordWrap
		text: qsTr("body-text")
	}

	ControlGroup {
		id: radioControlGroup
		exclusive: true
	}

	Column {
		id: radioColumn
		anchors {
			top: bodyText.bottom
			topMargin: Math.round(20 * verticalScaling)
			left: bodyText.left
			right: bodyText.right
		}
		spacing: Math.round(20 * verticalScaling)

		Repeater {
			id: radioRepeater
			model: app.maintenanceProviders
			property int radioWidth: 0
			delegate: StandardRadioButton {
				id: radioButton
				width: radioRepeater.radioWidth
				spacing: Math.round(40 * horizontalScaling)
				controlGroup: radioControlGroup
				selected: p.selectedOption === modelData.id
				text: modelData.longDescription
				onClicked: p.selectedOption = modelData.id
				Component.onCompleted: radioRepeater.radioWidth = Math.max(radioRepeater.radioWidth, radioButton.implicitWidth)
			}
		}
	}
}
