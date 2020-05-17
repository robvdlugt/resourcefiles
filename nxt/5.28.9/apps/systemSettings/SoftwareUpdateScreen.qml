import QtQuick 2.1

import qb.components 1.0

Screen {
	id: softwareUpdateScreen

	screenTitle: qsTr("Software Update")
	anchors.fill: parent
	hasCancelButton: true
	inNavigationStack: false

	onCustomButtonClicked: {
		app.softwareUpdateInProgressPopup.show();
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = false;
		addCustomTopRightButton(qsTr("top-right-button-text"));
	}
	
	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	Text {
		id: text
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(67 * verticalScaling)
			right: image.left
			rightMargin: Math.round(50 * horizontalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.updateSoftwareText
		wrapMode: Text.WordWrap
		text: qsTr("update_toon")
	}

	Image {
		id: image
		anchors {
			right: parent.right
			rightMargin: anchors.bottomMargin
			bottom: parent.bottom
			bottomMargin: Math.round(80 * verticalScaling)
		}
		source: "image://scaled/apps/systemSettings/drawables/surprise-box.svg"
	}
}
