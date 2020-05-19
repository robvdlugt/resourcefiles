import QtQuick 2.1

import qb.base 1.0;
import qb.components 1.0;
import BasicUIControls 1.0;
import ScreenStateController 1.0

Rectangle {
	id: home
	anchors.fill: parent
	color: dimmableColors.canvas
	property bool fsPopupShowing: popupContainer.visibleChildren.length > 0

	function initStage() {
		stage.init(fullScreenContent, topTitleText, topTitleIcon);
	}

	Component.onCompleted: {
		registry.registerWidgetContainer("topRight", topRightContainer);
		registry.registerWidgetContainer("topLeft", topLeftContainer);
		registry.registerWidgetContainer("popupContainer", popupLoader);
		registry.registerWidgetContainer("popup", popupContainer);
		registry.registerWidgetContainer("topRightButton", topRightButtonContainer)
		registry.registerWidgetContainer("slidePanel", slidePanelContainer)
		qdialog.init(dialogContainer);
	}

	Rectangle {
		id: topBar
		width: parent.width
		height: designElements.menubarHeight
		color: dimmableColors.topbar

		Flow {
			id: topLeftContainer

			property string kpiPrefix: "TopLeft."

			//width: parent.width / 2
			height: parent.height
			layoutDirection: Qt.RightToLeft
			flow: Flow.LeftToRight

			function onWidgetRegistered(widgetInfo) {
				var component = util.loadComponent(widgetInfo.url, topLeftContainer, {app: widgetInfo.context});
				if (component) component.initWidget(widgetInfo);
			}
		}

		Item {
			id: topTitleContainer
			anchors.centerIn: parent
			visible: isNormalMode || ! canvas.dimState

			function setWidth() {
				width = topTitleIcon.width + topTitleText.anchors.leftMargin + topTitleText.paintedWidth;
			}

			Image {
				id: topTitleIcon
				anchors.verticalCenter: parent.verticalCenter
				source: ""

				onSourceSizeChanged: parent.setWidth();
			}

			Text {
				id: topTitleText
				text: ""
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: topTitleIcon.right
				anchors.leftMargin: Math.round(16 * horizontalScaling)
				color: colors.fullScreenTitle
				font.pixelSize: qfont.navigationTitle
				font.family: qfont.semiBold.name

				onTextChanged: parent.setWidth();
			}
		}

		FeedbackButton {
			id: autoUpdateFeedbackBtn
			anchors {
				top: parent.top
				right: topRightContainer.left
				rightMargin: designElements.hMargin5
			}
			position: FeedbackButton.Position.Top
			targets: ["action:autoUpdated-groupA", "action:autoUpdated-groupB"]
			visibleConditions: stage.onRootScreen
		}

		Loader {
			id: topRightContainer
			height: parent.height
			anchors.right: parent.right

			function onWidgetRegistered(widgetInfo) {
				console.log("topRight widget registered: " + widgetInfo.url);
				topRightContainer.source = widgetInfo.url;
			}

			onLoaded: {
				item.init();
			}
		}

		FeedbackButton {
			id: screenFeedbackBtn
			anchors {
				top: parent.top
				right: parent.right
				rightMargin: Math.max(home.width - topRightButtonContainer.x + designElements.hMargin10, Math.round(16 * horizontalScaling))
			}
			position: FeedbackButton.Position.Top
			targets: stage.currentScreenIdentifier ? ["screen:" + stage.currentScreenIdentifier, "action:graph/GraphScreen/water"] : []
		}

		Flow {
			id: topRightButtonContainer
			height: parent.height
			anchors.right: parent.right

			layoutDirection: Qt.LeftToRight
			flow: Flow.LeftToRight

			function onWidgetRegistered(widgetInfo) {
				var component = util.loadComponent(widgetInfo.url, topRightButtonContainer, {app: widgetInfo.context});
				if (component) component.initWidget(widgetInfo);
			}
		}
	}

	Item {
		id: fullScreenContent
		width: parent.width
		anchors {
			top: topBar.bottom
			bottom: bottomBar.top
		}
	}

	Image {
		id: bottomBar
		anchors {
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		height: designElements.bottomBarHeight
		sourceSize.width: width
		sourceSize.height: height
		source: "qrc:/images/bottomBar.svg"
		visible: isNormalMode && !dimState
	}

	Rectangle {
		id: slidePanelUnderlay

		anchors.fill: parent
		color: colors.dialogMaskedArea
		opacity: 0.35
		visible: false

		MouseArea {
			property string kpiId: "Home.slidePanelUnderlay"
			anchors.fill: parent
			onClicked: slidePanelContainer.close()
		}
	}

	Column {
		id: slidePanelTabsContainer
		anchors {
			verticalCenter: parent.verticalCenter
			verticalCenterOffset: Math.round(-7 * verticalScaling)
		}
		spacing: Math.round(4 * verticalScaling)
		visible: stage.onRootScreen
		property bool panelOpen: slidePanelRect.visible && slidePanelRect.width > 0

		property bool positionLeft: !screenStateController.prominentWidgetLeft
		onPositionLeftChanged: {
			if (positionLeft) {
				anchors.right = undefined;
				anchors.left = slidePanelRect.right;
			} else {
				anchors.left = undefined;
				anchors.right = slidePanelRect.left;
			}
		}
	}

	Rectangle {
		id: slidePanelRect
		anchors {
			top: parent.top
			bottom: parent.bottom
		}
		width: setWidth >= 0 ? setWidth : slidePanelContainer.width
		color: colors.canvas
		visible: stage.onRootScreen
		property int setWidth: 0

		property bool positionLeft: !screenStateController.prominentWidgetLeft
		onPositionLeftChanged: {
			if (positionLeft) {
				anchors.right = undefined;
				anchors.left = parent.left;
			} else {
				anchors.left = undefined;
				anchors.right = parent.right;
			}
		}

		//Prevent clicking through
		MouseArea {
			property string kpiId: "Home.slidePanelRect"
			anchors.fill: parent
		}

		Behavior on width {
			id: slidePanelAnimation
			enabled: globals.slideTransitionEnabled
			NumberAnimation {
				easing.type: Easing.OutCubic
				duration: 500
				onRunningChanged: {
					if(!running)
						if (slidePanelRect.setWidth === 0)
							slidePanelContainer.hideAll();
				}
			}
		}
	}

	Row {
		id: slidePanelContainer
		height: parent.height
		property Component slidePanelButton: util.preloadComponent(Qt.resolvedUrl("qrc:/qb/components/SlidePanelButton.qml"))
		property bool positionLeft: !screenStateController.prominentWidgetLeft
		onPositionLeftChanged: {
			if (positionLeft) {
				anchors.left = undefined;
				anchors.right = slidePanelRect.right;
			} else {
				anchors.right= undefined;
				anchors.left  = slidePanelRect.left;
			}
		}

		Connections {
			target: stage
			onOnRootScreenChanged: {
				if (!stage.onRootScreen)
					slidePanelContainer.hideAll();
			}
		}

		function onWidgetRegistered(widgetInfo) {
			console.log("slide panel widget registered: " + widgetInfo.url);
			var obj = util.loadComponent(widgetInfo.url, slidePanelContainer, {app: widgetInfo.context});
			if (obj) {
				obj.initWidget(widgetInfo);
				var first = true, last = true, nrButtons = slidePanelTabsContainer.children.length;
				if (nrButtons) {
					first = false;
					slidePanelTabsContainer.children[nrButtons - 1].last = false;
				}
				var tabObj = util.instantiateComponent(slidePanelButton, slidePanelTabsContainer, {widgetObject: obj, first: first, last: last});
				if (tabObj) {
					tabObj.tabClicked.connect(onTabButtonClicked);
					try {
						obj.tabButtonObj = tabObj;
					} catch (e) {
						console.log("SlidePanel widget", widgetInfo.url, "does not contain tabButtonObj property!")
					}
				}
				obj.hide();
			}
		}

		function onWidgetDeregistered(widgetInfo) {
			console.log("Remove slide panel widget", widgetInfo.url, widgetInfo.uid);
			for (var i = 0; i < children.length; ++i) {
				var curChild = children[i];
				if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
					console.log("Found child with widget.uid", widgetInfo.uid);
					if (typeof curChild.tabButtonObj !== "undefined") {
						if (curChild.tabButtonObj.first && children[i+1] && children[i+1].tabButtonObj)
							children[i+1].tabButtonObj.first = true;
						if (curChild.tabButtonObj.last && children[i-1] && children[i-1].tabButtonObj)
							children[i-1].tabButtonObj.last = true;
						curChild.tabButtonObj.parent = null;
						curChild.tabButtonObj.destroy();
						curChild.tabButtonObj = null;
					}
					curChild.hide();
					curChild.parent = null;
					curChild.destroy();
					close();
					break;
				}
			}
		}

		function onTabButtonClicked(widgetInfo) {
			screenStateController.wakeup();

			// Iterate over the children to show the one corresponding to the reference sent by the signal
			for (var i = 0; i < children.length; ++i) {
				var curObj = children[i];
				if (curObj.widgetInfo.uid === widgetInfo.uid) {
					if (curObj.showing) {
						if (!slidePanelAnimation.enabled)
							curObj.hide();
						slidePanelRect.setWidth = 0;
						slidePanelUnderlay.visible = false;
						// When we close the slidePanel we will show the homescreen
						countly.sendPageViewEvent(util.absoluteToRelativePath(stage.homeScreenUrl));
					} else {
						curObj.show();
						slidePanelRect.setWidth = -1;
						slidePanelUnderlay.visible = true;
						countly.sendPageViewEvent(util.absoluteToRelativePath(widgetInfo.url));
					}
				} else {
					curObj.hide();
				}
			}
		}

		function hideAll() {
			for (var i = 0; i < children.length; ++i) {
				var curObj = children[i];
				curObj.hide();
			}
			slidePanelUnderlay.visible = false;
		}

		function close() {
			slidePanelRect.setWidth = 0;
			if (!slidePanelAnimation.enabled) {
				hideAll();
			}
			// When we close the slidePanel we will show the homescreen
			countly.sendPageViewEvent(util.absoluteToRelativePath(stage.homeScreenUrl));
		}
	}

	Connections {
		target: screenStateController
		onScreenStateChanged: {
			if (screenStateController.screenState == ScreenStateController.ScreenColorDimmed ||
					screenStateController.screenState == ScreenStateController.ScreenOff) {
				var prevState = slidePanelAnimation.enabled;
				slidePanelAnimation.enabled = false;
				slidePanelContainer.close();
				slidePanelAnimation.enabled = prevState;
			}
		}
	}

	Loader {
		id: popupLoader
		anchors.fill: home

		function onWidgetRegistered(widgetInfo) {
			console.log("popupLoader widget registered: " + widgetInfo.url);
			popupLoader.source = widgetInfo.url;
		}

		onLoaded: {
			item.init();
		}
	}

	DialogPopup {
		id: dialogContainer
		z: 1
	}

	Item {
		id: popupContainer
		function onWidgetRegistered(widgetInfo) {
			var obj = util.loadComponent(widgetInfo.url, null, {app: widgetInfo.context, visible:false, container: popupContainer});
			if (!obj) {
				console.log("failed loading dialog " + widgetInfo.url);
				return;
			}
			console.debug("Registered dialog " + widgetInfo.url + " > " + obj);
			obj.initWidget(widgetInfo);
		}
	}
}
