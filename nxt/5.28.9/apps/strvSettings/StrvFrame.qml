import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0

Widget {
	id: strvSettingsFrame

	property StrvSettingsApp app

	onShown: {
		app.getDevices();
	}

	anchors.fill: parent

	Column {
		id: labelContainer
		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			left: parent.left
			leftMargin: Math.round(44 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(27 * horizontalScaling)
		}
		spacing: designElements.vMargin6

		RowLayout {
			width: parent.width
			spacing: designElements.hMargin6

			SingleLabel {
				id: label
				Layout.fillWidth: true
				leftText: qsTr("Smart radiator valves")
				rightText: {
					if (installButton.visible)
						qsTr("Not installed")
					else if (app.errors > 0)
						qsTr("%1 not connected").arg(app.errors)
					else
						qsTr("%n connected", "", app.strvDevicesList.length)
				}

				onClicked: installButton.visible ? installButton.clicked() : editButton.clicked()
			}

			StandardButton {
				id: installButton
				text: qsTr("Install")
				visible: !editButton.visible

				onClicked: stage.openFullscreen(app.strvInstallIntroScreenUrl)
			}

			IconButton {
				id: editButton
				Layout.preferredWidth: width
				iconSource: "qrc:/images/edit.svg"
				visible: app.strvDevicesList.length > 0

				onClicked: stage.openFullscreen(app.deviceOverviewScreen)
			}
		}
	}
}
