import QtQuick 2.1
import qb.components 1.0

/**
	Main screen of thermostat program. Shows program schedule for whole week.
 */
Screen {
	id: programScreen

	screenTitleIconUrl: "drawables/program.svg"
	screenTitle: qsTr("Program")

	function init() {
		app.thermostatProgramLoaded.connect(p.programLoaded);
	}

	QtObject {
		id: p

		// type of the change done to save: 0 - no change, 1 - edit day program, 2 - copy day program
		property int savingProgram: 0
		// argument for saving the program change
		property variant saveProgramArgs

		property int rememberedTabIndex: 0

		property bool shownScheduleOffReminder: false

		function programLoaded() {
			if (p.savingProgram > 0) {
				app.waitPopup.hide();

				if (!app.programEnabled && !shownScheduleOffReminder) {
					qdialog.showDialog(qdialog.SizeSmall, qsTr("Enable program"), qsTr("Your schedule is disabled, do you want to enable it?"), qsTr("Yes"), (function(){app.sendProgramState(true);}), qsTr("No"));
					qdialog.context.highlightPrimaryBtn = true;
					qdialog.context.bodyTextAlignLeft = true;
					shownScheduleOffReminder = true;
				}
			}
			p.savingProgram = 0;
		}
	}

	function saveProgram(changeType, args) {
		p.savingProgram = changeType;
		p.saveProgramArgs = args;
		app.waitPopup.show();
		saveTimer.start();
	}

	onShown: {
		if (args && args.openTabIndex) {
			p.rememberedTabIndex = args.openTabIndex;
		}

		contentContainer.showAll();
		buttonPanelContainer.navigateToTab(p.rememberedTabIndex);
		p.rememberedTabIndex = 0;
	}

	onHidden: {
		contentContainer.hideAll();
	}

	Component.onCompleted: {
		registry.registerWidgetContainer("weekProgramContent", contentContainer)
		registry.registerWidgetContainer("weekProgramTab", buttonPanelContainer)
	}

	Rectangle {
		id: firstUsePanel
		anchors.fill: parent
		z: 1
		color: colors.canvas

		visible: app.programFirstUse

		MouseArea {
			anchors.fill: parent
			property string kpiPostfix: "ignore"
		}

		Text {
			id: firstUseTitle
			text: app.programFirstRunTexts['programFirstRunTitle']
			wrapMode: Text.WordWrap

			anchors {
				top: parent.top
				topMargin: Math.round(50 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(120 * horizontalScaling)
				right: firstUseImage.left
				rightMargin: Math.round(10 * horizontalScaling)
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.navigationTitle
			}
		}

		Text {
			id: firstUseText
			text: app.programFirstRunTexts['programFirstRunText']
			wrapMode: Text.WordWrap

			anchors {
				top: firstUseTitle.bottom
				topMargin: Math.round(20 * verticalScaling)
				left: firstUseTitle.left
				right: firstUseTitle.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: firstUseCloseBtn
			kpiPostfix: "closeFirstUse"
			text: app.programFirstRunTexts['programFirstRunButtonText']
			onClicked: {
				app.programFirstUse = false;
				ProgramTips.show(true);

				// Store that the user has acknowledged the first-run screen
				app.sendThermostatAppConfig();
			}

			anchors {
				left: firstUseTitle.left
				bottom: firstUseImage.bottom
				bottomMargin: Math.round(20 * verticalScaling)
			}
		}

		Image {
			id: firstUseImage
			source: app.programFirstUse ? "image://scaled/apps/thermostat/drawables/day-setup.svg" : ""
			anchors {
				right: parent.right
				rightMargin: Math.round(50 * horizontalScaling)
				bottom: parent.bottom
				bottomMargin: Math.round(50 * verticalScaling)
			}
		}
	}

	Timer {
		id: saveTimer
		interval: 100
		running: false
		repeat: false
		onTriggered: {
			if (p.savingProgram == 1)
				app.saveEditedProgram();
			else if (p.savingProgram == 2)
				app.saveCopyProgramDay(p.saveProgramArgs.fromDay, p.saveProgramArgs.toDays);
		}
	}

	IconButton {
		id: infoButton
		anchors {
			right: contentContainerPanel.right
			verticalCenter: buttonPanelContainer.verticalCenter
		}
		iconSource: "qrc:/images/info.svg"
		onClicked: {
			ProgramTips.show(true);
		}
	}

	Text {
		id: infoText
		anchors {
			right: infoButton.left
			rightMargin: Math.round(8 * horizontalScaling)
			verticalCenter: infoButton.verticalCenter
		}
		font {
			pixelSize: qfont.metaText
			family: qfont.regular.name
		}
		color: colors.customerServiceText
		text: qsTr("programPopupTeaser")
	}

	Row {
		id: buttonPanelContainer
		anchors {
			top: parent.top
			topMargin: Math.round(16 * verticalScaling)
			left: contentContainerPanel.left
		}
		spacing: Math.round(4 * horizontalScaling)

		function onWidgetRegistered(widgetInfo) {
			console.log("Widget registered (2): " + widgetInfo.url);
			var obj = util.loadComponent(widgetInfo.url, buttonPanelContainer, {app: widgetInfo.context});
			if (obj) {
				obj.initWidget(widgetInfo);
				obj.showPanel.connect(onTabButtonClicked);

				// The first button (the one from thermostat) will be made active immediately
				// Later buttons start as inactive
				if (buttonPanelContainer.children.length === 1) {
					obj.selected = true;
				} else {
					obj.selected = false;
				}
			}
			navigateToFirstTab();
			p.rememberedTabIndex = 0;
		}

		function onWidgetDeregistered(widgetInfo) {
			console.log("Remove widget (2):", widgetInfo.url, widgetInfo.uid);
			for (var i = 0; i < buttonPanelContainer.children.length; ++i) {
				var curChild = buttonPanelContainer.children[i];
				if (curChild.widgetInfo !== undefined && curChild.widgetInfo.uid === widgetInfo.uid) {
					console.log("Found child with widget.uid", widgetInfo.uid);
					curChild.visible = false;
					curChild.parent = null;
					curChild.destroy();
					break;
				}
			}
			navigateToFirstTab();
			p.rememberedTabIndex = 0;
		}

		function navigateToFirstTab() {
			navigateToTab(0);
		}

		function navigateToTab(tabIndex) {
			if (buttonPanelContainer.children.length > tabIndex) {
				// Navigate to the indicated panel
				onTabButtonClicked(buttonPanelContainer.children[tabIndex].contentUrl);
			}
		}

		function onTabButtonClicked(contentUrl) {
			console.log("onTabButtonClicked(", contentUrl, ")");

			// Iterate over the panels to show the one corresponding to the panelUrl
			for (var i = 0; i < contentContainer.children.length; ++i) {
				var curObj = contentContainer.children[i];
				// We need the "==" here to compare the url values instead of the (object) instances
				if (curObj.sourceUrl == contentUrl) {
					contentContainerPanel.contentX = curObj.x;
					break;
				}
			}

			// Iterate over the tab buttons to activate the one corresponding to the panelUrl
			for (var j = 0; j < buttonPanelContainer.children.length; ++j) {
				var curBtn = buttonPanelContainer.children[j];
				// We need the "==" here to compare the url values instead of the (object) instances
				if (curBtn.contentUrl == contentUrl) {
					curBtn.selected = true;
				} else {
					curBtn.selected = false;
				}
			}
		}
	}
	UnFlickableRectangle {
		id: contentContainerPanel
		color: colors.contentBackground

		anchors {
			top: buttonPanelContainer.bottom
			topMargin: colors.tabButtonUseExtension ? Math.round(4 * verticalScaling) : 0
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			leftMargin: Math.round(16 * horizontalScaling)
			rightMargin: anchors.leftMargin
			bottomMargin: buttonPanelContainer.anchors.topMargin
		}

		Row {
			id: contentContainer
			spacing: 10
			anchors {
				top: parent.top
				bottom: parent.bottom
			}

			function rememberSelectedProgramTab() {
				for (var j = 0; j < buttonPanelContainer.children.length; ++j) {
					var curBtn = buttonPanelContainer.children[j];
					if (curBtn.selected === true) {
						p.rememberedTabIndex = j;
						break;
					}
				}
			}

			function showAll() {
				for (var i = 0; i < contentContainer.children.length; ++i) {
					var curChild = contentContainer.children[i];
					curChild.showTab();
				}
			}
			function hideAll() {
				for (var i = 0; i < contentContainer.children.length; ++i) {
					var curChild = contentContainer.children[i];
					curChild.hideTab();
				}
			}

			function onWidgetRegistered(widgetInfo) {
				console.log("Widget registered (2): " + widgetInfo.url);
				var obj = util.loadComponent(widgetInfo.url, contentContainer, {app: widgetInfo.context});
				if (obj) {
					obj.initWidget(widgetInfo);
				}
			}
			function onWidgetDeregistered(widgetInfo) {
				console.log("Remove widget (2):", widgetInfo.url, widgetInfo.uid);
				for (var i = 0; i < contentContainer.children.length; ++i) {
					var curChild = contentContainer.children[i];
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
	}
}
