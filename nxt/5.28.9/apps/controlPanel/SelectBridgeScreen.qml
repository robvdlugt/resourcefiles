import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import BasicUIControls 1.0;

Screen {
	id: selectBridge
	screenTitle: qsTr("Multiple bridges found")
	hasCancelButton: true
	inNavigationStack: false

	onShown: {
		addCustomTopRightButton(qsTr("Link"));
		disableCustomTopRightButton();
		for (var key in app.hueBridges) {
			bridgeList.addCustomItem(app.hueBridges[key]);
		}
		screenStateController.screenColorDimmedIsReachable = false;
	}

	onHidden: {
		screenStateController.screenColorDimmedIsReachable = true;
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.addBridgeScreenUrl, {bridgeUuid: p.selectedBridgeUuid});
	}

	QtObject {
		id: p
		property string selectedBridgeUuid
	}

	Text {
		id: line1
		text: qsTr("Toon found multiple bridges in the network.")
		anchors {
			top: parent.top
			left: parent.left
			topMargin: Math.round(30 * verticalScaling)
			leftMargin: Math.round(50 * horizontalScaling)
		}
		color: colors.addBridgeText
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	Text {
		id: line2
		text: qsTr("You can link one bridge with Toon.")
		anchors {
			top: line1.bottom
			left: line1.left
		}
		color: colors.addBridgeText
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}

	Text {
		id: listTitle
		text: qsTr("Select bridge to link")
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: line2.bottom
			topMargin: Math.round(20 * verticalScaling)
		}
		color: colors.addBridgeTitle
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.navigationTitle
		}
	}
	
	Flickable {
		id: container
		width: bridgeList.width
		height: (Math.round(36 * verticalScaling) + bridgeList.listSpacing) * 4
		anchors {
			left: listTitle.left
			top: listTitle.bottom
			topMargin: designElements.vMargin10
		}
		contentHeight: bridgeList.implicitHeight
		clip: true
		interactive: false

		Component.onCompleted: {
			updatePageCount()
			contentHeightChanged.connect(updatePageCount);
		}

		function updatePageCount() {
			pageSelector.pageCount = Math.ceil(container.contentHeight / container.height);
		}

		function changePage(page) {
			if (page >= pageSelector.pageCount)
				return;
			var newY = page * container.height;
			container.contentY = newY;
		}

		RadioButtonList {
			id: bridgeList
			width: Math.round(340 * horizontalScaling)
			listDelegate: StandardRadioButton {
				width: bridgeList.width
				controlGroup: model.controlGroup
				text: model.friendlyName
				Text {
					id: rightText
					text: app.formatMAC(intAddr)
					textFormat: Text.PlainText // Prevent XSS/HTML injection
					anchors {
						verticalCenter: parent.verticalCenter
						right: parent.right
						rightMargin: Math.round(8 * horizontalScaling)
					}
					font.family: qfont.italic.name
					color: colors.rbText
					font.pixelSize: parent.fontPixelSize
				}
				onSelectedChanged: {
					if (selected) {
						p.selectedBridgeUuid = model.uuid;
						enableCustomTopRightButton();
					}
				}
			}
		}
	}

	DottedSelector {
		id: pageSelector
		anchors {
			top: container.bottom
			left: container.left
			right: container.right
		}
		leftArrowEnabled: currentPage != 0
		rightArrowEnabled: currentPage != pageCount - 1
		onNavigate: container.changePage(page)
	}

	Text {
		text: qsTr("For the MAC address see the bottom of the bridge")
		anchors {
			top: pageSelector.bottom
			topMargin: designElements.vMargin5
			horizontalCenter: pageSelector.horizontalCenter
		}
		color: colors.addBridgeText
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}
}
