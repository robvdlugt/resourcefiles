import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

Item {
	property variant userValue

	function confirmTextSD() {
		if (i18n.countValues(userValue) > 1) {
			return qsTr("notifications-confirm-phone-smoke-detector-text", "more")
		} else {
			return qsTr("notifications-confirm-phone-smoke-detector-text", "one")
		}
	}

	Text {
		id: numberText
		anchors {
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			rightMargin: Math.round(40 * horizontalScaling)
			right: parent.right
			top: parent.top
			topMargin: Math.round(30 * verticalScaling)
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		text: qsTr("Use %1 for:").arg(i18n.arrayToSentence(userValue, "b"))
		wrapMode: Text.WordWrap
	}

	Image {
		id: serviceImage
		anchors {
			left: parent.left
			leftMargin: Math.round(55 * horizontalScaling)
			top: numberText.bottom
			topMargin: Math.round(20 * verticalScaling)
		}
	}

	Text {
		id: serviceName
		anchors {
			left: serviceImage.right
			leftMargin: designElements.hMargin15
			verticalCenter: serviceImage.verticalCenter
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.bold.name
		}
	}

	Text {
		id: confirmText
		anchors {
			left: parent.left
			leftMargin: Math.round(40 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(40 * horizontalScaling)
			top: serviceName.bottom
			topMargin: Math.round(20 * verticalScaling)
		}
		font {
			pixelSize: qfont.titleText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
	}

	state: "SD"
	states: [
		State {
			name: "SD"
			PropertyChanges { target: serviceImage; source: "image://scaled/apps/smokeDetector/drawables/smokedetector-systray.svg" }
			PropertyChanges { target: serviceName; text: qsTr("Toon Smoke Detector") }
			PropertyChanges { target: confirmText; text: confirmTextSD() }
		}
	]
}
