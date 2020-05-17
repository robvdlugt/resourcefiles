import QtQuick 2.1

import qb.components 1.0

Screen {
	id: root

	screenTitleIconUrl: "drawables/CustomerServiceIcon.svg"
	screenTitle: qsTr("Toon support")

	onShown: app.requestSupportState()

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: Math.round(40 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(60 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.customerServiceTitle
		text: qsTr("toon_support_title_text")
		wrapMode: Text.WordWrap
	}

	Text {
		id: text
		anchors {
			left: title.left
			right: title.right
			baseline: title.baseline
			baselineOffset: Math.round(44 * verticalScaling)
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		color: colors.customerServiceText
		text: qsTr("toon_support_text")
		wrapMode: Text.WordWrap
	}

	Rectangle {
		id: onOffLabel
		height: Math.round(100 * verticalScaling)
		radius: designElements.radius
		anchors {
			left: text.left
			right: text.right
			bottom: parent.bottom
			bottomMargin: Math.round(40 * verticalScaling)
		}
		color: colors.labelBackground

		Text {
			id: textBlockLabel
			font.family: qfont.semiBold.name
			font.pixelSize: qfont.titleText
			color: colors.singleLabelLeftText
			anchors {
				left: parent.left
				leftMargin: Math.round(13 * horizontalScaling)
				baseline: parent.top
				baselineOffset: Math.round(30 * verticalScaling)
			}
			text: qsTr("Customer remote access")
		}

		OnOffToggle {
			id: toggle
			anchors {
				verticalCenter: textBlockLabel.verticalCenter
				right: infoButton.left
				rightMargin: designElements.hMargin10
			}
			rightTextOn: qsTr('On')
			rightTextOff:  qsTr('Off')
			leftIsSwitchedOn: false
			selected: app.supportEnabled

			onSelectedChangedByUser: app.setSupportState(selected)
		}

		Text {
			id: innerText
			anchors {
				left: textBlockLabel.left
				baseline: textBlockLabel.baseline
				baselineOffset: Math.round(28 * verticalScaling)
			}
			font {
				pixelSize: qfont.bodyText
				family: qfont.italic.name
			}
			color: colors.customerServiceText
			text: qsTr("toon_support_inner_text")
		}

		IconButton {
			id: infoButton
			anchors {
				right: parent.right
				rightMargin: designElements.hMargin5
				verticalCenter: textBlockLabel.verticalCenter
			}
			iconSource: "qrc:/images/info.svg"
			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge, qsTr("info_popup_title"), qsTr("info_popup_text"));
			}
		}
	}
}
