import QtQuick 2.1
import qb.components 1.0

Screen {
	id: editZonePresetScreen
	screenTitleIconUrl: "drawables/Temperature.svg"
	screenTitle: qsTr("Presets")

	signal navigateNext

	QtObject {
		id: p
		property string preset
		property var zoneUuids
		property bool fromAddWizard
	}

	onShown: {
		if (args) {
			p.preset = args.preset;
			p.zoneUuids = args.zoneUuids;
			p.fromAddWizard = args.fromAddWizard;
		}
		checkZoneListModel();
		updateCustomTopRightButton();

		stage.customButton.image = "image://scaled/images/arrow-right-menubutton.svg";
	}

	onHidden: {
		stage.customButton.image = "";
	}

	Connections {
		target: app
		onZoneListChanged: checkZoneListModel();
		onZoneRenamed: {
			// If a zone is renamed, clear the list so we reinitialize with the correct (new) order
			zoneListModel.clear();
		}
	}

	function presetToTitleText(preset) {
		switch (preset) {
		case "away":    return qsTr("When I am <font color=\"%1\">Away</font>").arg(qtUtils.colorToArgbString(app.presetNameToColor(preset)));
		case "home":    return qsTr("When I am <font color=\"%1\">Active</font> at home").arg(qtUtils.colorToArgbString(app.presetNameToColor(preset)));
		case "sleep":   return qsTr("When I am <font color=\"%1\">Sleeping</font>").arg(qtUtils.colorToArgbString(app.presetNameToColor(preset)));
		case "comfort": return qsTr("When I want <font color=\"%1\">Comfort</font> at home").arg(qtUtils.colorToArgbString(app.presetNameToColor(preset)));
		default: return "Invalid preset"; // Should never happen except during initialization
		}
	}

	function nextPreset(preset) {
		switch (preset) {
		case "away":    return "home";
		case "home":    return "sleep";
		case "sleep":   return "comfort";
		case "comfort": return "away";
		default: return undefined; // Should never happen
		}
	}

	function updateCustomTopRightButton() {
		if (p.fromAddWizard && p.preset === "comfort") {
			addCustomTopRightButton(qsTr("Continue"));
		} else {
			addCustomTopRightButton(app.presetNameToString(nextPreset(p.preset)));
		}
	}

	function checkZoneListModel() {
		if (zoneListModel.count === app.zoneList.length) {
			// Nothing to do
			return;
		}

		if (Array.isArray(p.zoneUuids)) {
			zoneListModel.clear();
			// first add just added devices/zones
			p.zoneUuids.forEach(function (uuid) {
				zoneListModel.append({"uuid": uuid});
			});
			// then add the remaining zones
			app.zoneList.forEach(function (zone) {
				if (p.zoneUuids.indexOf(zone.uuid) === -1)
					zoneListModel.append({"uuid": zone.uuid});
			});
		} else {
			zoneListModel.clear();
			app.zoneList.forEach(function (zone) {
				zoneListModel.append({"uuid": zone.uuid});
			});
		}
		presetContainer.centralized = (zoneListModel.count < 4);
	}

	onCustomButtonClicked: {
		if (p.fromAddWizard && p.preset === "comfort") {
			stage.openFullscreen(app.programScreenUrl, {"fromAddWizard": true, "resetNavigation": true});
		} else {
			navigateNext();
			p.preset = nextPreset(p.preset);
			updateCustomTopRightButton();
		}
	}

	ListModel {
		id: zoneListModel
	}

	Component {
		id: zoneListDelegate
		ZonePresetItem {
			preset: p.preset
			zoneUuid: model.uuid
			Component.onCompleted: {
				// Make sure we also commit the updated value(s) when we "navigate" to
				// the next preset
				editZonePresetScreen.navigateNext.connect(ensureValueCommitted);
			}
		}
	}

	Text {
		id: presetTitle

		text: presetToTitleText(p.preset)
		textFormat: Text.StyledText

		font.family: qfont.semiBold.name
		font.pixelSize: qfont.primaryImportantBodyText

		anchors {
			top: parent.top
			topMargin: Math.round(20 * verticalScaling)
			left: presetContainerParent.left
			right: presetContainerParent.right
		}
	}

	Text {
		id: presetSubtitle

		text: qsTr("I want my rooms to be these temperatures.")

		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText

		anchors {
			top: presetTitle.bottom
			topMargin: designElements.vMargin6
			left: presetContainerParent.left
			right: presetContainerParent.right
		}
	}

	UnFlickable {
		id: presetContainerParent

		width: (Math.round(145 * horizontalScaling) + presetContainer.spacing) * 4
		height: Math.round(160 * verticalScaling)
		clip: true

		anchors {
			top: presetSubtitle.bottom
			topMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(80 * horizontalScaling)
		}

		function navigatePage(page) {
			if (page >= 0)
				contentX = page * width;
		}

		Row {
			id: presetContainer
			spacing: designElements.hMargin20

			anchors.horizontalCenter: centralized ? parent.horizontalCenter : undefined
			property bool centralized: false

			Repeater {
				model: zoneListModel
				delegate: zoneListDelegate
			}
		}
	}

	DottedSelector {
		id: widgetNavBar
		width: presetContainerParent.width
		anchors {
			horizontalCenter: presetContainerParent.horizontalCenter
			top: presetContainerParent.bottom
			topMargin: Math.round(60 * verticalScaling)
		}
		pageCount: Math.ceil(zoneListModel.count / 4)

		onNavigate: presetContainerParent.navigatePage(page)
	}
}
