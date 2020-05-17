import QtQuick 2.1
import qb.components 1.0
import FileIO 1.0

Screen {
	id: imageViewerScreen

	screenTitleIconUrl: "drawables/ImageViewerIcon.svg"
	screenTitle: qsTr("Image viewer")


	function updateCustomTopRightButton() {
		if (app.imageList.count > 0) {
			enableCustomTopRightButton();
		} else {
			disableCustomTopRightButton();
		}
	}


	onShown: {
		addCustomTopRightButton(qsTr("View"));
		app.reloadImageList();
	}

	onCustomButtonClicked: {
		app.startSlideshow(autoPlay.selected)
	}


	Connections {
		target: app.imageList
		onCountChanged: {
			updateCustomTopRightButton();
		}
	}

	Text {
		id: label
		text: qsTr("%n pictures(s) found", "", app.imageList.count)
		anchors {
			top: parent.top
			topMargin: Math.round(100 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
	}

	StandardButton {
		id: refreshButton
		text: qsTr("Refresh")
		topClickMargin: 2

		anchors {
			horizontalCenter: label.horizontalCenter
			top: label.bottom
			topMargin: designElements.vMargin10
		}

		onClicked: {
			app.reloadImageList();
		}
	}

	StandardCheckBox {
		id: autoPlay
		text: qsTr("Autoplay")

		anchors {
			horizontalCenter: label.horizontalCenter
			top: refreshButton.bottom
			topMargin: designElements.vMargin10
		}
	}

	Text {
		id: ipText
		text: qsTr("LAN IP address: %1").arg(app.lanIp);

		anchors {
			top: autoPlay.bottom
			topMargin: designElements.vMargin10
			horizontalCenter: label.horizontalCenter
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
	}

	Text {
		anchors {
			leftMargin: designElements.hMargin10
			rightMargin: designElements.hMargin10
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
			italic: true
		}
		wrapMode: Text.WordWrap
		// app.path.toString().substr(7) - cut off 'file://'
		text: "Images can be uploaded to <b>" + app.path.toString().substr(7) + "</b> directory using <b>SCP</b> protocol."
	}
}
