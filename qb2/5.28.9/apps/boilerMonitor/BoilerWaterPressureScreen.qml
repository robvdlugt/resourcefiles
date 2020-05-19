import QtQuick 2.0

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Screen {
	screenTitle: qsTr("Water pressure")

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: Math.round(35 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: image.left
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.largeTitle
		}
		color: colors.text
		wrapMode: Text.WordWrap
		lineHeight: 0.8
		text: qsTr("water-pressure-normal-title")
	}

	Text {
		id: bodyText
		anchors {
			top: title.bottom
			topMargin: designElements.vMargin20
			left: title.left
			right: title.right
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		color: colors.text
		wrapMode: Text.WordWrap
		text: qsTr("water-pressure-normal-text")
	}

	Image {
		id: image
		anchors {
			top: title.top
			right: parent.right
			rightMargin: title.anchors.leftMargin
		}
		source: "image://scaled/apps/boilerMonitor/drawables/big-boiler-pressure-normal.svg"

		Rectangle {
			id: qrCodeBg
			width: Math.round(140 * horizontalScaling)
			height: width
			anchors {
				top: parent.top
				topMargin: Math.round(-25 * horizontalScaling)
				right: parent.right
				rightMargin: designElements.hMargin10
			}
			radius: height / 2
			color: colors._middlegrey
			visible: qrCode.content ? true : false

			QrCode {
				id: qrCode
				anchors.centerIn: parent
				width: parent.width * 0.7
				height: width
			}
		}

		Image {
			id: pressureNeedle
			anchors {
				bottom: parent.bottom
				bottomMargin: Math.round(52 * horizontalScaling)
				horizontalCenter: parent.horizontalCenter
				horizontalCenterOffset: Math.round(offset * horizontalScaling)
			}
			source: "image://scaled/apps/boilerMonitor/drawables/pressure-indicator.svg"

			// mid value is 1.5 bar, width of entire bar is 175px
			property int offset: (175/2/1.5) * Math.min(Math.max(app.boilerStatus.waterPressure.pressure.value, 0), 3) - (175/2)
		}
	}

	Text {
		id: pressureValue
		anchors {
			verticalCenter: image.bottom
			horizontalCenter: image.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.largeTitle
		}
		color: colors.text
		wrapMode: Text.WordWrap
		text: app.boilerStatus.waterPressure ? "%1 %2"
											   .arg(i18n.number(app.boilerStatus.waterPressure.pressure.value,1))
											   .arg(app.boilerStatus.waterPressure.pressure.unit)
											 : "-"
	}

	states: [
		State {
			name: "LOW"
			when: app.boilerStatus.waterPressure.state === "LOW"
			PropertyChanges { target: title; text: qsTr("water-pressure-low-title") }
			PropertyChanges { target: bodyText; text: qsTr("water-pressure-low-text") }
			PropertyChanges { target: image; source: "image://scaled/apps/boilerMonitor/drawables/big-boiler-pressure-low.svg" }
			PropertyChanges { target: qrCode; content: qsTr("$(waterPressureLowVideoUrl)") }
		},
		State {
			name: "HIGH"
			when: app.boilerStatus.waterPressure.state === "HIGH"
			PropertyChanges { target: title; text: qsTr("water-pressure-high-title") }
			PropertyChanges { target: bodyText; text: qsTr("water-pressure-high-text") }
			PropertyChanges { target: image; source: "image://scaled/apps/boilerMonitor/drawables/big-boiler-pressure-high.svg" }
			PropertyChanges { target: qrCode; content: qsTr("$(waterPressureHighVideoUrl)") }
		}
	]
}
