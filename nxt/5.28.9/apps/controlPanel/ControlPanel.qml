import QtQuick 2.11
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0
import BasicUIControls 1.0

Widget {
	id: controlPanel

	property string kpiPrefix: "ControlPanel."
	property variant tabButtonObj

	width: controlPanelContent.width
	height: parent.height
	enabled: controlsPane.shown || rightPane.shown
	onShowingChanged: {
		if (tabButtonObj)
			tabButtonObj.imageSource = showing && !dimState ? p.tabIconOpenedUrl : p.tabIconClosedUrl;
	}
	onTabButtonObjChanged: {
		if (tabButtonObj) {
			tabButtonObj.imageSource = p.tabIconClosedUrl;
			tabButtonObj.imageMirror = true;
		}
	}

	QtObject {
		id: p
		property url tabIconOpenedUrl: "image://scaled/apps/controlPanel/drawables/controlPanelOpened.svg"
		property url tabIconClosedUrl: "image://scaled/apps/controlPanel/drawables/controlPanelClosed.svg"

		property int horizontalSpacing: Math.round(32 * horizontalScaling)
		property int verticalSpacing: Math.round(6 * verticalScaling)
		property int rightPaneWidth: Math.round(195 * horizontalScaling)
		property int oneColumnExtraHMargin: Math.round(33 * horizontalScaling)

		property url controlPlugItemUrl: "ControlPanelPlugItem.qml"
		property url controlLampItemUrl: "ControlPanelLampItem.qml"
		property Component preloadedPlugItem
		property Component preloadedLampItem

		function clearControls() {
			var containers = [plugControlsContainer, lampControlsContainer];

			containers.forEach(function (container) {
				while (container.children.length > 0) {
					var obj = container.children[0];
					obj.visible = false;
					obj.parent = null;
					obj.destroy();
				}
			});
		}

		function fillControls() {
			clearControls();
			var plugs = app.devPlugs;
			plugs.sort(app.compareDeviceNames);
			var lamps = app.devLamps;
			lamps.sort(app.compareDeviceNames);

			plugs.forEach(function (plug) {
				util.instantiateComponent(preloadedPlugItem, plugControlsContainer, {configInfo: plug, app: app});
			});

			lamps.forEach(function (lamp) {
				util.instantiateComponent(preloadedLampItem, lampControlsContainer, {configInfo: lamp, app: app});
			});

			if (plugs.length === 0 && lamps.length === 0) {
				controlsPane.shown = false;
				controlsPane.width = 0;
			} else {
				var columns = 0;
				var itemWidth = 0;
				if (plugs.length) {
					itemWidth = plugControlsContainer.children[0].width;
					if (plugControlsContainer.children.length > plugControlsContainer.rows)
						columns += 2;
					else
						columns++;
				}
				if (lamps.length) {
					if (!itemWidth)
						itemWidth = lampControlsContainer.children[0].width;
					if (lampControlsContainer.children.length > lampControlsContainer.rows)
						columns += 2;
					else
						columns++;
				}
				controlsFlickable.anchors.leftMargin = p.horizontalSpacing + (columns === 1 ? p.oneColumnExtraHMargin : 0);
				controlsPane.width = (controlsFlickable.anchors.leftMargin * 2) + (itemWidth * (columns === 1 ? 1 : 2)) + (columns > 1 ? p.horizontalSpacing : 0);
				controlsPane.shown = true;
			}
		}

		Component.onCompleted: {
			preloadedPlugItem = util.preloadComponent(controlPlugItemUrl);
			preloadedLampItem = util.preloadComponent(controlLampItemUrl);
			app.devicesChanged.connect(fillControls);
		}
	}

	Rectangle {
		id: topBar
		width: parent.width
		height: designElements.menubarHeight
		color: colors.canvas

		Text {
			text: qsTr("Control")
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.left
				leftMargin: Math.round(16 * horizontalScaling)
			}
			color: colors.fullScreenTitle
			font.pixelSize: qfont.navigationTitle
			font.family: qfont.semiBold.name
		}

		MenuBarButton {
			id: settingsButton
			isLeftBarButton: false
			anchors.right: parent.right
			visible: controlsPane.shown

			onClicked: stage.openFullscreen(controlPanel.app.controlPanelScreenUrl, {tab: "first"});

			Image {
				anchors.centerIn: parent
				source: "image://scaled/images/settings.svg"
			}
		}
	}

	Row {
		id: controlPanelContent
		anchors {
			top: topBar.bottom
			bottom: parent.bottom
		}

		Rectangle {
			id: controlsPane
			width: 0
			height: parent.height
			color: colors.canvas
			visible: shown
			property bool shown: false

			UnFlickable {
				id: controlsFlickable
				anchors {
					top: parent.top
					topMargin: Math.round(25 * verticalScaling)
					left: parent.left
					right: parent.right
					bottom: onOffButtonsWrapper.top
					bottomMargin: Math.round(25 * verticalScaling)
				}
				contentWidth: containersRow.width
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.HorizontalFlick
				clip: true

				Row {
					id: containersRow
					spacing: p.horizontalSpacing
					height: parent.height

					GridLayout {
						id: plugControlsContainer
						rows: 4
						flow: GridLayout.TopToBottom
						columnSpacing: p.horizontalSpacing
						rowSpacing: p.verticalSpacing
					}

					GridLayout {
						id: lampControlsContainer
						rows: 4
						flow: GridLayout.TopToBottom
						columnSpacing: p.horizontalSpacing
						rowSpacing: p.verticalSpacing
					}
				}

				Behavior on contentX {
					enabled: globals.slideTransitionEnabled
					SmoothedAnimation {
						duration: globals.slideTransitionDuration
					}
				}

				function navigatePage(page) {
					if (page >= 0)
						contentX = page * width;
				}
			}

			Item {
				id: onOffButtonsWrapper
				width: childrenRect.width
				height: childrenRect.height
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom: parent.bottom
					bottomMargin: Math.round(85 * verticalScaling)
				}

				StandardButton {
					id: groupOn
					iconSource: "drawables/group_white.svg"
					text: qsTr("Group On")

					colorUp: colors.controlPanelAllOnColorUp
					colorDown: colors.controlPanelAllOnColorDown
					fontColorUp: colors.controlPanelOnOffText
					fontColorDown: colors.controlPanelOnOffText

					onClicked: app.switchAll(1)
				}

				StandardButton {
					id: groupOff
					anchors {
						left: groupOn.right
						leftMargin: Math.round(8 * horizontalScaling)
					}
					iconSource: "drawables/group_white.svg"
					text: qsTr("Group Off")

					colorUp: colors.controlPanelAllOffColorUp
					colorDown: colors.controlPanelAllOffColorDown
					fontColorUp: colors.controlPanelOnOffText
					fontColorDown: colors.controlPanelOnOffText

					onClicked: app.switchAll(0)
				}
			}

			DottedSelector {
				id: widgetNavBar
				anchors {
					bottom: parent.bottom
					bottomMargin: Math.round(26 * verticalScaling)
					horizontalCenter: parent.horizontalCenter
				}
				pageCount: controlsFlickable.width > 0 ? Math.ceil(controlsFlickable.contentWidth / controlsFlickable.width) : 0
				onNavigate: controlsFlickable.navigatePage(page)
			}
		}

		Rectangle {
			id: rightPane
			width: p.rightPaneWidth
			height: parent.height
			color: colors.canvas
			visible: shown
			property bool shown: scenesSection.shown || ventilationLevelSection.shown

			Column {
				id: rightPanelColumn
				anchors {
					fill: parent
					margins: Math.round(25 * horizontalScaling)
				}
				spacing: Math.round(25 * horizontalScaling)

				Item {
					id: scenesSection
					width: childrenRect.width
					height: childrenRect.height
					visible: shown
					property bool shown: app.devLamps.length > 0

					Text {
						id: scenesTitle
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.navigationTitle
						}
						color: colors.controlPanelRightPaneTitle
						text: qsTr("Hue-scenes")
					}

					Grid {
						id: scenesGrid
						spacing: Math.round(18 * horizontalScaling)
						columns: 2
						anchors {
							top: scenesTitle.baseline
							topMargin: Math.round(25 * verticalScaling)
							left: parent.left
						}

						Repeater {
							model: 4
							StyledButton {
								id: scenesButton

								height: designElements.menubarHeight
								width: Math.round(58 * horizontalScaling)
								color: colors.white
								selected: false
								state: selected ? "selected" : "up"
								radius: designElements.radius
								property string kpiPostfix: "scene" + index

								states: [
									State {
										name: "up"
										PropertyChanges { target: scenesButton; color: colors.controlPanelSceneBtnUp }
										PropertyChanges { target: sceneRect; opacity: 1 }
									},
									State {
										name: "selected"
										PropertyChanges { target: scenesButton; color: colors.controlPanelSceneBtnSelected }
										PropertyChanges { target: sceneRect; opacity: 0.6 }
									}
								]

								StyledRectangle {
									id: sceneRect
									height: Math.round(39 * verticalScaling)
									width: Math.round(41 * horizontalScaling)
									anchors.centerIn: parent
									gradientStyle: StyledRectangle.TopLeftToBottomRight
									gradientColors: app.gradientColorTL[index] ? [app.gradientColorTL[index], app.gradientColorMiddle[index], app.gradientColorBR[index]] : []
									leftClickMargin: 17
									rightClickMargin: 17
									topClickMargin: 17
									bottomClickMargin: 17
									Text {
										id: sceneText
										anchors.centerIn: parent
										font {
											family: qfont.bold.name
											pixelSize: qfont.bodyText
										}
										color: colors.white
										text: index + 1
									}
									onPressed: scenesButton.state = "selected"
									onReleased: scenesButton.state = "up"
									onClicked: app.loadScene(index)
								}
							}
						}
					}
				}

				Item {
					id: ventilationLevelSection
					width: parent.width
					height: childrenRect.height
					visible: shown
					property bool shown: app.hasHeatRecoveryVentLevel

					Text {
						id: ventilationLevelTitle
						font {
							family: qfont.semiBold.name
							pixelSize: qfont.navigationTitle
						}
						color: colors.controlPanelRightPaneTitle
						text: qsTr("Ventilation")
					}

					Image {
						id: ventLevelImage
						anchors {
							top: ventilationLevelTitle.baseline
							topMargin: Math.round(25 * verticalScaling)
						}
						source: app.hasHeatRecoveryVentLevel ? "image://scaled/apps/controlPanel/drawables/vent_level_" + app.heatRecoveryInfo["TargetVentilationLevel"] + ".svg" : ""

						MouseArea {
							id: ventLevel1MouseArea
							property string kpiId: "ventLevel1"
							anchors {
								top: ventLevel2MouseArea.top
								bottom: ventLevel2MouseArea.bottom
								left: parent.left
								right: ventLevel2MouseArea.left
							}
							onClicked: app.setVentilationLevel(1)
						}
						MouseArea {
							id: ventLevel2MouseArea
							property string kpiId: "ventLevel2"
							width: Math.round(parent.width / 3)
							anchors {
								top: parent.top
								topMargin: Math.round(13 * verticalScaling)
								bottom: parent.bottom
								bottomMargin: Math.round(13 * verticalScaling)
								horizontalCenter: parent.horizontalCenter
							}
							onClicked: app.setVentilationLevel(2)
						}
						MouseArea {
							id: ventLevel3MouseArea
							property string kpiId: "ventLevel3"
							anchors {
								top: ventLevel2MouseArea.top
								bottom: ventLevel2MouseArea.bottom
								left: ventLevel2MouseArea.right
								right: parent.right
							}
							onClicked: app.setVentilationLevel(3)
						}
					}

					IconButton {
						id: ventLevelDecrease
						enabled: app.hasHeatRecoveryVentLevel && app.heatRecoveryInfo["TargetVentilationLevel"] > 1
						anchors {
							top: ventLevelImage.bottom
							topMargin: Math.round(6 * verticalScaling)
							left: ventLevelImage.left
							right: ventLevelImage.horizontalCenter
							rightMargin: Math.round(3 * horizontalScaling)
						}
						height: Math.round(36 * verticalScaling)
						colorUp: colors.background

						topLeftRadiusRatio: 0
						topRightRadiusRatio: 0
						bottomRightRadiusRatio: 0

						iconSource: "qrc:/images/minus.svg"

						onClicked: app.setVentilationLevel("-1")
					}

					IconButton {
						id: ventLevelIncrease
						enabled: app.hasHeatRecoveryVentLevel && app.heatRecoveryInfo["TargetVentilationLevel"] < 3
						anchors {
							top: ventLevelDecrease.top
							right: ventLevelImage.right
							left: ventLevelImage.horizontalCenter
							leftMargin: Math.round(3 * horizontalScaling)
						}
						height: ventLevelDecrease.height
						colorUp: colors.background

						topLeftRadiusRatio: 0
						topRightRadiusRatio: 0
						bottomLeftRadiusRatio: 0

						iconSource: "qrc:/images/plus.svg"

						onClicked: app.setVentilationLevel("+1")
					}
				}
			}
		}
	}
}
