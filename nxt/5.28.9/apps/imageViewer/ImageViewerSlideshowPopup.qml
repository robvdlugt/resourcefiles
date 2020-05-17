import QtQuick 2.1
import qb.components 1.0

Popup {
	id: imageViewerSlideshowPopup

	property alias autoplay: timer.running


	ListView {
		id: flickable

		anchors.fill: parent
		focus: true
		highlightRangeMode: ListView.StrictlyEnforceRange
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		model: app.imageList
		delegate: Image {
			source: model.path + "/" + model.file
			width: flickable.width
			height: flickable.height
			fillMode: Image.PreserveAspectCrop
			clip: true
		}
		keyNavigationWraps: true

		MouseArea {
			anchors.fill: parent
			onClicked: {
				text.visible = !text.visible
			}
		}

		Text {
			id: text
			text: getText()
			visible: false
			anchors {
				top: parent.top
				left: parent.left
				topMargin: 8
				leftMargin: 15
			}
			height: 40
			width: 370
			font.pixelSize: 18
			font.bold: true
			color: "white"
			style: Text.Outline
			styleColor: "black"

			function getText() {
				if (app.imageList && app.imageList.count > 0) {
					if (-1 != flickable.currentIndex) {
						return app.imageList.get(flickable.currentIndex).file
					} else {
						 return "Loading, please wait..."
					}
				} else {
					return "No images were found."
				}
			}
		}
	}

	MouseArea {
		anchors {
			left: parent.left
			bottom: parent.bottom
		}
		height: 50
		width: 50

		onClicked: {
			app.stopSlideshow()
		}
	}

	Timer {
		id: timer
		repeat: true
		interval: 15000
		onTriggered: flickable.incrementCurrentIndex()
	}
}
