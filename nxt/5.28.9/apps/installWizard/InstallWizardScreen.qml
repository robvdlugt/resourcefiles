import QtQuick 2.1
import BxtClient 1.0;

import qb.base 1.0;
import qb.components 1.0;
import ScreenStateController 1.0

Screen {
	id: mainContent

	anchors.fill: parent

	screenTitleIconUrl: "drawables/InstallWizardIcon.svg"
	screenTitle: qsTr("Installation Wizard")

	property InstallWizardApp app

	function onWidgetRegistered(widgetInfo) {
	}

	function onWidgetDeregistered(widgetInfo) {
	}

	function openWizardOverviewScreen() {
		stage.openFullscreen(app.installWizardOverviewScreenUrl);
	}

	Component.onCompleted: {
		registry.registerWidgetContainer("prominent", rightPanel)
		// Only if the language has been selected we open the overview screen automatically.
		// (If it hasn't, the InstallWizardApp will register the language screen as
		//  the home screen and it will be shown by default.)
		if (wizardstate.stageCompleted("language")) {
			canvas.appsDoneLoading.connect(openWizardOverviewScreen);
		}
	}

	onShown: {
		screenStateController.screenColorDimmedIsReachable = true
	}

	property int panelMargin: 32 * horizontalScaling

	Item {
		id: rightPanel
		width: 248 * horizontalScaling
		height: parent.height
		anchors {
			right: parent.right
			rightMargin: panelMargin
			top: parent.top
			topMargin: Math.round(50 * verticalScaling)
			bottom: parent.bottom
			bottomMargin: Math.round(22 * verticalScaling)
		}

		visible: globals.heatingMode === "central" && (children.length > 0)

		function onWidgetRegistered(widgetInfo) {
			console.log("prominent widget registered: " + widgetInfo.url);
			var obj = util.loadComponent(widgetInfo.url, rightPanel, {app: widgetInfo.context});
			if (obj) obj.initWidget(widgetInfo);
		}

		function onWidgetDeregistered(widgetInfo) {
			console.log("Remove", widgetInfo.url, widgetInfo.uid);
			for (var i = 0; i < rightPanel.children.length; ++i) {
				var curChild = rightPanel.children[i];
				if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
					console.log("Found child with widget.uid", widgetInfo.uid);
					curChild.visible = false;
					curChild.parent = null;
					curChild.destroy();
					break;
				}
			}
		}
	}

	Column {
		anchors {
			left: parent.left
			leftMargin: panelMargin
			verticalCenter: parent.verticalCenter
			right: rightPanel.visible ? rightPanel.left : parent.right
			rightMargin: panelMargin
		}
		spacing: designElements.vMargin5

		Text {
			id: installText
			width: parent.width
			text: qsTr("Complete installation for more functionality")
			color: colors.menuLabel
			horizontalAlignment:  Text.AlignHCenter
			wrapMode: Text.WordWrap
			font {
				family: qfont.bold.name
				pixelSize: qfont.secondaryImportantBodyText
			}
		}

		StandardButton {
			id: installButton;
			anchors.horizontalCenter: installText.horizontalCenter

			colorUp : canvas.dimState ? "black" : "red"
			colorDown : Qt.darker(colorUp, 1.2)
			fontColorUp: "white"
			text: qsTr("Installation");

			borderWidth: 2
			borderColor: "white"
			borderStyle: canvas.dimState ? Qt.SolidLine : Qt.NoPen

			// Allow the button to be activated during dim state
			mouseIsActiveInDimState: true

			onClicked: {
				// When the button is pressed during dim state, don't
				// forget to wake up the screen again, otherwise the
				// screen will end up in an inconsistent state.
				screenStateController.wakeup()
				stage.openFullscreen(app.installWizardOverviewScreenUrl);
			}

			onPressed: extraInfoTimer.restart()
			onReleased: extraInfoTimer.stop()
			Timer {
				id: extraInfoTimer
				interval: 5000 // msec

				onTriggered: {
					app.versionVisible = ! app.versionVisible;
					console.log("Version visible is now set to: ", app.versionVisible);
				}
			}
		}
	}

	StandardButton {
		id: recoverButton;
		anchors.left: parent.left
		anchors.leftMargin: panelMargin
		anchors.bottom: parent.bottom
		anchors.bottomMargin: panelMargin
		text: qsTr("Recover to Factory Settings");

		colorUp : canvas.dimState ? "black" : colors.btnUp
		fontColorUp: canvas.dimState ? "white" : colors.btnText

		borderWidth: 2
		borderColor: "white"
		borderStyle: canvas.dimState ? Qt.SolidLine : Qt.NoPen

		// Allow the button to be activated during dim state
		mouseIsActiveInDimState: true

		onClicked: {
			screenStateController.wakeup()
			stage.openFullscreen(app.factoryResetScreenUrl);
		}
	}

}

