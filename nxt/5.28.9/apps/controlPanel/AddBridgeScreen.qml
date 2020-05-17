import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0

Screen {
	id: addBridgeStartPage

	inNavigationStack: false
	screenTitle: p.screenTitleTexts[0]

	QtObject {
		id: p

		property bool waitingForLink: false

		property variant firstSearchTexts : [qsTr("firstSearch_Step1"),
			qsTr("firstSearch_Step2"),
			qsTr("firstSearch_Step3")]
		property variant repeatedSearchTexts : [qsTr("repeatedSearch_Step1"),
			qsTr("repeatedSearch_Step2"),
			qsTr("repeatedSearch_Step3")]
		property variant screenTitleTexts : [qsTr("addBridgeTitle_firstSearch"), qsTr("addBridgeTitle_repeatedSearch"),
			qsTr("addBridgeTitle_oneFound"), qsTr("addBridgeTitle_multipleFound")]
		property variant subtitleTexts: [qsTr("addBridgeSubtitle_firstSearch"), qsTr("addBridgeSubtitle_repeatedSearch"),
			qsTr("addBridgeSubtitle_oneFound"), qsTr("addBridgeSubtitle_multipleFound")]
		property variant bridgeFoundScreenTitle: [qsTr("Link bridge"), qsTr("Bridge found")]
		property string bridgeToLinkUuid: ""

		function searchIsOver() {
			searchTimer.stop();
			btnSearch.state = "up";
			searchThrobber.visible = false;
			if (Object.keys(app.hueBridges).length === 1) {
				for (var key in app.hueBridges) {
					bridgeToLinkSelected(key);
				}
			} else if (Object.keys(app.hueBridges).length > 1) {
				stage.openFullscreen(app.selectBridgeScreenUrl);
			} else {
				state = "repeatedSearch";
			}
		}

		function bridgeLinked() {
			state = "done";
		}
	}

	function bridgeToLinkSelected(bridgeUuid) {
		p.bridgeToLinkUuid = bridgeUuid;
		var multipleBridges = Object.keys(app.hueBridges).length > 1 ? true : false;
		if (multipleBridges) {
			state = "moreFoundWaiting";
		} else {
			state = "oneFoundWaiting";
		}
	}

	onShown: {
		if (args && args.bridgeUuid) {
			bridgeToLinkSelected(args.bridgeUuid);
		}

		btnSearch.state = "up";
		searchThrobber.visible = false;
		hasCancelButton = true;
		addCustomTopRightButton(qsTr("Ready"));
		disableCustomTopRightButton();
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
		if (p.bridgeToLinkUuid !== "" && state !== "done")
			app.cancelBridgeLink(p.bridgeToLinkUuid);
	}

	onCanceled: {
		searchTimer.stop();
		state = 'firstSearch';
	}

	Component.onCompleted: {
		app.bridgeLinked.connect(p.bridgeLinked);
		state = 'firstSearch';
	}

	Component.onDestruction: {
		app.bridgeLinked.disconnect(p.bridgeLinked);
	}

	onCustomButtonClicked: {
		hide();
	}

	Text {
		id: subtitle
		text: p.subtitleTexts[0]
		anchors {
			left: background.left
			baseline: background.top
			baselineOffset: Math.round(-13 * verticalScaling)
		}
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
		color: colors.addBridgeTitle
	}

	Timer {
		id: searchTimer
		repeat: false
		interval: 30000
		onTriggered: {
			p.searchIsOver();
		}
	}

	Rectangle {
		id: background
		radius: designElements.radius
		width: Math.round(756 * horizontalScaling)
		height: Math.round(265 * verticalScaling)
		color: colors.addBridgeBackground
		anchors {
			horizontalCenter: parent.horizontalCenter
			verticalCenter:   parent.verticalCenter
		}

		Image {
			id: bridgeImage
			anchors {
				verticalCenter: parent.verticalCenter
				left: parent.right
				leftMargin: Math.round(-250 * horizontalScaling)
			}
			source: "image://scaled/apps/controlPanel/drawables/bridge.svg"
		}

		Item {
			id: bridgeSearching
			visible: true
			anchors {
				top: parent.top
				topMargin: designElements.vMargin10
				bottom: parent.bottom
				left: parent.left
				leftMargin: designElements.hMargin10
				right: bridgeImage.left
				rightMargin: anchors.leftMargin
			}

			GridLayout {
				id: stepsGrid
				anchors {
					left: parent.left
					leftMargin: designElements.hMargin10
					top: parent.top
					right: parent.right
				}
				columns: 2
				columnSpacing: designElements.hMargin10
				rowSpacing: designElements.vMargin20

				NumberBullet {
					id: bulletOne
					text: "1"
				}

				Text {
					id: step1text
					Layout.fillWidth: true
					text: ""
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					wrapMode: Text.WordWrap
				}

				NumberBullet {
					id: bulletTwo
					text: "2"
				}

				Text {
					id: step2text
					Layout.fillWidth: true
					text: ""
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					wrapMode: Text.WordWrap
				}

				NumberBullet{
					id: bulletThree
					text: "3"
				}

				Text {
					id: step3text
					Layout.fillWidth: true
					text: ""
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					wrapMode: Text.WordWrap
				}
			}

			StandardButton {
				id: btnSearch
				anchors {
					left: stepsGrid.left
					leftMargin: Math.round(35 * horizontalScaling)
					top: stepsGrid.bottom
					topMargin: designElements.vMargin20
				}
				text: qsTr("Search")
				primary: true

				onClicked: {
					searchThrobber.visible = true;
					state = "down";
					searchTimer.start();
					app.discoverBridges(p.searchIsOver);
				}
			}

			Throbber {
				id: searchThrobber
				anchors {
					verticalCenter: btnSearch.verticalCenter
					left: btnSearch.right
					leftMargin: Math.round(20 * horizontalScaling)
				}
				visible: false
			}
		}

		Item {
			id: bridgeFound
			anchors {
				top: parent.top
				topMargin: designElements.vMargin20
				bottom: parent.bottom
				left: parent.left
				leftMargin: designElements.hMargin10
				right: bridgeImage.left
				rightMargin: anchors.leftMargin
			}
			visible: false

			GridLayout {
				id: linkingSteps
				anchors {
					left: parent.left
					leftMargin: designElements.hMargin10
					top: parent.top
					right: parent.right
				}
				columns: 2
				columnSpacing: designElements.hMargin10
				rowSpacing: Math.round(30 * verticalScaling)

				Rectangle {
					id: bridgeBullet
					width: height
					height: Math.round(24 * verticalScaling)
					radius: height / 2
					color: colors.addBridgeBullet
				}

				Text {
					id: pushButton
					Layout.fillWidth: true
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					text: qsTr("Push button")
				}

				Image {
					id: greenCheck
					height: Math.round(24 * verticalScaling)
					sourceSize {
						width: 0
						height: height
					}
					source: "qrc:/images/good.svg"
					visible: false
				}

				Text {
					id: bridgeConnectedText
					text: qsTr("Bridge connected")
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					visible: false
				}
			}

			Row {
				id: linkingThrobber
				anchors {
					top: linkingSteps.bottom
					topMargin: designElements.vMargin20
					left: parent.left
				}
				spacing: designElements.hMargin10

				Throbber { }

				Text {
					id: notConnectedText
					anchors.verticalCenter: parent.verticalCenter
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.addBridgeText
					text: qsTr("Not connected yet")
				}
			}

			Text {
				text: qsTr("Bridge mac-address: %1").arg(p.bridgeToLinkUuid === "" ? "" : app.formatMAC(app.hueBridges[p.bridgeToLinkUuid].intAddr))
				textFormat: Text.PlainText // Prevent XSS/HTML injection
				anchors {
					left: parent.left
					bottom: parent.bottom
					bottomMargin: designElements.vMargin10
				}
				font {
					family: qfont.regular.name
					pixelSize: qfont.bodyText
				}
				color: colors.addBridgeText
			}
		}
	}

	states: [
		State {
			name: "firstSearch"
			PropertyChanges { target: bridgeSearching; visible: true }
			PropertyChanges { target: bridgeFound; visible: false }
			PropertyChanges { target: step1text; text: p.firstSearchTexts[0] }
			PropertyChanges { target: step2text; text: p.firstSearchTexts[1] }
			PropertyChanges { target: step3text; text: p.firstSearchTexts[2] }
			PropertyChanges { target: subtitle; text: p.subtitleTexts[0] }
			StateChangeScript {
				script: {
					setTitle(p.screenTitleTexts[0]);
				}
			}
		},

		State {
			name: "repeatedSearch"
			PropertyChanges { target: bridgeSearching; visible: true }
			PropertyChanges { target: bridgeFound; visible: false }
			PropertyChanges { target: step1text; text: p.repeatedSearchTexts[0] }
			PropertyChanges { target: step2text; text: p.repeatedSearchTexts[1] }
			PropertyChanges { target: step3text; text: p.repeatedSearchTexts[2] }
			PropertyChanges { target: subtitle; text: p.subtitleTexts[1] }
			StateChangeScript {
				script: {
					setTitle(p.screenTitleTexts[1])
				}
			}
		},
		State {
			name: "oneFoundWaiting"
			PropertyChanges { target: bridgeSearching; visible: false }
			PropertyChanges { target: bridgeFound; visible: true }
			PropertyChanges { target: subtitle; text: p.subtitleTexts[2] }
			PropertyChanges { target: pushButton; color: colors.addBridgeText }
			PropertyChanges { target: bridgeImage; source: "image://scaled/apps/controlPanel/drawables/bridge-push.svg" }
			StateChangeScript {
				script: {
					setTitle(p.screenTitleTexts[2]);
					app.sendBridgeLinkMsg(p.bridgeToLinkUuid);
					p.waitingForLink = true;
				}
			}
		},
		State {
			name: "done"
			PropertyChanges { target: bridgeSearching; visible: false }
			PropertyChanges { target: bridgeFound; visible: true }
			PropertyChanges { target: linkingThrobber; visible: false }
			PropertyChanges { target: notConnectedText; visible: false }
			PropertyChanges { target: greenCheck; visible: true }
			PropertyChanges { target: bridgeConnectedText; visible: true }
			PropertyChanges { target: bridgeBullet; color: colors.addBridgeDisabled }
			PropertyChanges { target: pushButton; color: colors.addBridgeDisabled }
			StateChangeScript {
				script: {
					enableCustomTopRightButton();
					disableCancelButton();
				}
			}
		},
		State {
			name: "moreFoundWaiting"
			PropertyChanges { target: bridgeSearching; visible: false }
			PropertyChanges { target: bridgeFound; visible: true }
			PropertyChanges { target: subtitle; text: p.subtitleTexts[3] }
			PropertyChanges { target: pushButton; color: colors.addBridgeText }
			PropertyChanges { target: bridgeImage; source: "image://scaled/apps/controlPanel/drawables/bridge-push.svg" }
			StateChangeScript {
				script: {
					setTitle(p.screenTitleTexts[3]);
					app.sendBridgeLinkMsg(p.bridgeToLinkUuid);
					p.waitingForLink = true;
				}
			}

		}
	]
}

