import QtQuick 2.1
import QueuedConnection 1.0
import ScreenStateController 1.0

Item {
	id: notificationBar
	anchors {
		left: parent.left
		right: parent.right
		top: parent.top
		topMargin: -height
	}
	height: childrenRect.height
	visible: false
	property bool blockConditions: false

	signal queuedSignal();
	signal itemAdded();

	QtObject {
		id: p
		property bool expandOnDim: false
		property Timer hideTimer: null
		property Timer blackModeTimer: null
	}

	function show(expanded) {
//TSC mod to remove network errors in notification bar
		notifications.removeByTypeSubType("error","network");
//TSC mod end
		if (notifications.count === 0 || blockConditions)
			return;
		cancelHideTimer();
		if (!expanded)
			collapse();
		if (state === "hidden") {
			notificationColumn.animateAddItem = false;
			if (notifications.count === 1)
				addNextItem();
			else if (expanded)
				expand();
			state = "shown";
		}
	}

	function hide(timeout) {
		if (state === "shown") {
			if (timeout) {
				cancelHideTimer();
				p.hideTimer = util.delayedCall(timeout, hideImpl);
			} else {
				hideImpl();
			}
		}
	}

	function hideImpl() {
		notificationColumn.animateAddItem = false;
		notificationBar.state = "hidden";
	}

	function collapse() {
		underlay.clicked.disconnect(collapse);
		underlay.visible = false;
		if (notificationColumn.headerItem !== null) {
			notificationColumn.animateRemoveItem = true;
			model.clear();
			notificationColumn.headerItem.state = "collapsed";
		}
	}

	function expand() {
		if (notifications.count < 2)
			return;

		if (canvas.dimState) {
			p.expandOnDim = true;
			screenStateController.wakeup();
		}
		underlay.clicked.connect(collapse);
		underlay.visible=  true;
		cancelHideTimer();
		if (notificationColumn.headerItem !== null)
			notificationColumn.headerItem.state = "expanded";
		notificationColumn.animateAddItem = true;
		notificationBar.populate();
	}

	function populate() {
		if (globals.notificationAnimationsEnabled) {
			itemAddedQueuedConn.signalEmitted.connect(addNextItem);
			addNextItem();
		} else {
			while(addNextItem());
		}
	}

	function addNextItem() {
		if (model.count < notifications.count) {
			model.append(notifications.dataModel[model.count]);
			return true;
		} else {
			itemAddedQueuedConn.signalEmitted.disconnect(addNextItem);
			return false;
		}
	}

	function cancelHideTimer() {
		if (p.hideTimer) {
			p.hideTimer.destroy();
			p.hideTimer = null;
		}
	}

	function setBlackMode(enable) {
		if (enable) {
			screenStateController.screenOffBlackMode = true;
			scheduleBlackModeTimer(true);
		} else {
			screenStateController.screenOffBlackMode = false;
			cancelBlackModeTimer();
		}
	}

	function scheduleBlackModeTimer(show) {
		if (screenStateController.screenState === ScreenStateController.ScreenOff) {
			screenStateController.screenOffBlackMode = show;
			var timeout;
			cancelBlackModeTimer();
			if (show) {
				timeout = notifications.conf_SHOW_TIME_SCREENOFF * 1000;
				notificationBar.show();
			} else {
				timeout = notifications.conf_HIDE_TIME_SCREENOFF * 1000;
				notificationBar.hide();
			}
			p.blackModeTimer = util.delayedCall(timeout, scheduleBlackModeTimer, !show);
		} else {
			notificationBar.show();
			cancelBlackModeTimer();
		}
	}

	function cancelBlackModeTimer() {
		if (p.blackModeTimer) {
			p.blackModeTimer.destroy();
			p.blackModeTimer = null;
		}
	}

	state: "hidden"
	states: [
		State {
			name: "hidden"
			PropertyChanges { target: notificationBar; anchors.topMargin: -notificationBar.height }
		},
		State {
			name: "shown"
			PropertyChanges { target: notificationBar; anchors.topMargin: 0 }
		}
	]

	transitions: [
		Transition {
			from: "hidden"; to: "shown"
			SequentialAnimation {
				PropertyAction { target: notificationBar; property: "visible"; value: true }
				NumberAnimation { target: notificationBar; easing.type: Easing.OutQuad; properties: "anchors.topMargin"; duration: 300 }
			}
		},
		Transition {
			from: "shown"; to: "hidden"
			SequentialAnimation {
				NumberAnimation { target: notificationBar; easing.type: Easing.InQuad; properties: "anchors.topMargin"; duration: 300 }
				PropertyAction { target: notificationBar; property: "visible"; value: false }
				ScriptAction {
					script: {
						collapse();
					}
				}
			}
		}
	]

	Connections {
		target: screenStateController
		onScreenStateChanged: {
			if ((screenStateController.screenState === ScreenStateController.ScreenColorDimmed ||
					screenStateController.screenState === ScreenStateController.ScreenOff) &&
					notifications.count) {
				setBlackMode(true);
				notificationBar.show();
			} else if (screenStateController.previousScreenState !== ScreenStateController.ScreenDimmed &&
					   screenStateController.screenState === ScreenStateController.ScreenActive) {
				if (!parentalControl.enabled) {
					notificationBar.show();
					if (!p.expandOnDim)
						notificationBar.hide(notifications.conf_HIDE_TIMEOUT);
				} else {
					notificationBar.hide();
				}
				p.expandOnDim = false;
				setBlackMode(false);
			}
		}
	}

	Connections {
		target: stage
		onOnRootScreenChanged: {
			if (!stage.onRootScreen)
				notificationBar.hide();
		}
	}

	Connections {
		target: notifications
		onDataModelChanged: {
			if (notifications.count === 0) {
				notificationBar.hide();
				setBlackMode(false);
				return;
			}

			notificationColumn.animateRemoveItem = false;
			model.clear();
			if (notificationColumn.headerItem !== null &&
					 notificationColumn.headerItem.state === "expanded" && notifications.count > 1) {
				// TODO: add only the new items?
				notificationColumn.animateAddItem = false;
				notificationBar.populate();
			} else if (notifications.count === 1) {
				collapse();
				notificationColumn.animateAddItem = false;
				notificationBar.addNextItem();
			}
		}
		onNotificationsAddedOrUpdated: {
			setBlackMode(true);
			if (screenStateController.screenState === ScreenStateController.ScreenActive)
				notificationBar.hide(notifications.conf_HIDE_TIMEOUT);
		}
	}

	QueuedConnection {
		id: itemAddedQueuedConn
		target: notificationBar
	}

	Component.onCompleted: {
		itemAdded.connect(queuedSignal);
	}

	ListModel {
		id: model
	}

	Rectangle {
		id: notificationBarBg
		width: parent.width
		color: dimmableColors.notificationsBackground
		height: notificationColumn.contentHeight + (notificationColumn.anchors.topMargin * 2)
		clip: true

		MouseArea {
			anchors.fill: parent
		}

		Behavior on height {
			enabled: globals.notificationAnimationsEnabled
			SmoothedAnimation { easing.type: Easing.InQuad; duration: 300 }
		}

		Component {
			id: notificationHeader
			NotificationElement {
				id: headerElement
				header: true
				iconSource: "drawables/notifications-icon.svg"
				title: qsTr("notification-header-text")
					.arg(i18n.capitalizeFirstChar(i18n.greetingText))
					.arg(dimmableColors.notificationsTextHighlight.toString())
					.arg(notifications.dataset.length)
				activeInDim: true && !parentalControl.enabled
				onAction: {
					if (state === "collapsed") {
						notificationBar.expand();
					} else {
						notificationBar.collapse();
					}
				}
				onClose: {
					notificationBar.hide();
				}

				state: "collapsed"
				states: [
					State {
						name: "collapsed"
						PropertyChanges { target: headerElement; actionButtonIconRotation: 0; actionButtonRotationAnim.direction: RotationAnimation.Counterclockwise; bgColor: colors.notificationsElement }
					},
					State {
						name: "expanded"
						PropertyChanges { target: headerElement; actionButtonIconRotation: 180; actionButtonRotationAnim.direction: RotationAnimation.Clockwise; bgColor: colors.notificationsHeader }
					}
				]

				transitions: [
					Transition {
						// duration conditional workaround for QtQuick1, on QQ2 it's possible to disable transition
						from: "collapsed"; to: "expanded"
						ColorAnimation { target: headerElement; property: "bgColor"; duration: globals.notificationAnimationsEnabled ? 200 : 0 }
					},
					Transition {
						from: "expanded"; to: "collapsed"
						SequentialAnimation {
							PauseAnimation { duration: globals.notificationAnimationsEnabled ? 200 : 0 }
							ColorAnimation { target: headerElement; property: "bgColor"; duration: globals.notificationAnimationsEnabled ? 200 : 0 }
						}
					}
				]
			}
		}

		ListView {
			id: notificationColumn
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
				margins: Math.round(16 * verticalScaling)
			}
			height: canvas.height
			spacing: Math.round(4 * verticalScaling)
			interactive: false

			header: notifications.count > 1 ? notificationHeader : null
			property bool animateAddItem: false
			property bool animateRemoveItem: false

			model: model
			delegate: NotificationElement {
				id: notificationElement
				iconSource: notifications.getIconUrl(model.type, model.subType)
				title: model.subType === "_grouped" ? model.text.arg(dimmableColors.notificationsTextHighlight.toString()) : model.text
				actionUrl: notifications.getActionUrl(model.type, model.subType)
				actionArgs: notifications.formatActionArgs(notifications.getActionArgsFormat(model.type, model.subType), model.args)
				activeInDim: notifications.count === 1 && !parentalControl.enabled
				showClose: notifications.count === 1
				onAction: {
					if (canvas.dimState)
						screenStateController.wakeup();

					if (actionUrl.toString().length)
						notificationBar.hide();

					if (model.uuid)
						notifications.remove(model.uuid);
					else if (model.type)
						notifications.removeByType(model.type);
				}
				onClose: {
					notificationBar.hide();
				}
				ListView.onAdd:	{
					if (notificationColumn.animateAddItem && globals.notificationAnimationsEnabled)
						addAnimation.restart()
					else
						itemAdded();
				}
				ListView.onRemove: {
					if (notificationColumn.animateRemoveItem && globals.notificationAnimationsEnabled)
						removeAnimation.restart()
				}
				SequentialAnimation {
					id: addAnimation
					PropertyAction { target: notificationElement; property: "height"; value: 0 }
					NumberAnimation { target: notificationElement; property: "height"; to: notificationElement.itemHeight; easing.type: Easing.InOutQuad; duration: 200 }
					ScriptAction { script: itemAdded() }
				}
				SequentialAnimation {
					id: removeAnimation
					PropertyAction { target: notificationElement; property: "ListView.delayRemove"; value: true }
					NumberAnimation { target: notificationElement; property: "height"; to: 0; easing.type: Easing.InQuad; duration: 200 }
					PropertyAction { target: notificationElement; property: "ListView.delayRemove"; value: false }
				}
			}
		}
	}

	Image {
		id: shadow
		width: parent.width
		anchors.top: notificationBarBg.bottom
		source: "drawables/bar-shadow.png"
		fillMode: Image.TileHorizontally
		visible: !canvas.dimState
	}
}
