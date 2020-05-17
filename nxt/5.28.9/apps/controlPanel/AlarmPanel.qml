import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Widget {
	id: controlPanel

	property string kpiPrefix: "AlarmPanel."
	property ControlPanelApp app
	property variant tabButtonObj

	width: Math.round(315 * horizontalScaling)
	height: parent ? parent.height : undefined

	onTabButtonObjChanged: {
		if (tabButtonObj)
			tabButtonObj.imageSource = "image://scaled/apps/controlPanel/drawables/alarmPanel_disarmed.svg";
	}

	Connections {
		target: app
		onAlarmPinIsSetChanged: {
			if (app.alarmPinIsSet === true) {
				loader.source = "AlarmPanelControlFrame.qml"
			} else if (app.alarmPinIsSet === false) {
				loader.source = "AlarmPanelIntroFrame.qml"
			} else {
				loader.source = "";
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		color: colors.canvas

		Item {
			id: topBar
			width: parent.width
			height: designElements.menubarHeight

			Text {
				text: qsTr("Security")
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Math.round(16 * horizontalScaling)
				}
				font {
					family: qfont.semiBold.name
					pixelSize: qfont.navigationTitle
				}
				color: colors.fullScreenTitle
			}

			MenuBarButton {
				id: settingsButton
				isLeftBarButton: false
				anchors.right: parent.right

				onClicked: stage.openFullscreen(controlPanel.app.controlPanelScreenUrl, {tab: controlPanel.app.securityTabUrl});

				Image {
					anchors.centerIn: parent
					source: "image://scaled/images/settings.svg"
				}
			}
		}

		Loader {
			id: loader
			anchors {
				top: topBar.bottom
				left: parent.left
				right: parent.right
				bottom: parent.bottom
			}

			onLoaded: {
				if (source.toString() === Qt.resolvedUrl("AlarmPanelIntroFrame.qml").toString()
						&& tabButtonObj	&& tabButtonObj.selected === false && stage.onRootScreen) {
					tabButtonObj.clicked();
				}
			}
		}
	}
}
