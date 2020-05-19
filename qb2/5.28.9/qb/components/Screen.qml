import QtQuick 2.1

import qb.base 1.0

/**
 * The base class for any screen.
 * Provides default onShow & onHide transitions.
 */
Widget {
	/// The screen is saved
	signal saved()
	/// The screen is canceled
	signal canceled()
	/// The custom buttom is clicked
	signal customButtonClicked()

	property string kpiPrefix
	property string identifier
	property string screenTitle
	property url screenTitleIconUrl
	property bool inNavigationStack: true
	property bool disableAutoPageViewLogging: false

	// The screen has both a save and a cancel button
	property bool isSaveCancelDialog: false

	// In case this screen is not a save-cancel-dialog it can still have a save or cancel button by setting one of the following
	property bool hasSaveButton: false
	property bool hasCancelButton: false
	property bool hasHomeButton: true
	property bool hasBackButton: true

	// When screen has save button and this is enabled, clicking on Save will not
	// hide screen. Screen has to do it by itself!
	property bool synchronousSave: false

	property bool saveEnabled: true
	onSaveEnabledChanged: saveEnabled ? enableSaveButton() : disableSaveButton()

	property bool cancelEnabled: true
	onCancelEnabledChanged: cancelEnabled ? enableCancelButton() : disableCancelButton()

	property bool customButtonEnabled: true
	onCustomButtonEnabledChanged: customButtonEnabled ? enableCustomTopRightButton() : disableCustomTopRightButton()

	function show(args) {
		stage.openFullscreen(identifier, args);
	}

	function hide() {
		stage.navigateBack();
	}

	function setTitle(title) {
		screenTitle = title;
	}

	function addCustomTopRightButton(label) {
		stage.addCustomTopRightButton(label);
	}

	function clearTopRightButtons() {
		stage.clearTopRightButtons();
	}

	function disableCustomTopRightButton() {
		stage.disableCustomTopRightButton();
	}

	function enableCustomTopRightButton() {
		stage.enableCustomTopRightButton();
	}

	function disableCancelButton() {
		stage.disableCancelButton();
	}

	function enableCancelButton() {
		stage.enableCancelButton();
	}

	function enableSaveButton() {
		stage.enableSaveButton();
	}

	function disableSaveButton() {
		stage.disableSaveButton();
	}

	function showSaveThrobber(state) {
		stage.saveButton.showThrobber = state;
	}

	/// Calculate the combined height of a list of items.
	/// This just adds the heights and top-/bottom-margins,
	/// it does not take the relative layout into account.
	/// Example:
	/// height: calculateCombinedHeight([child1, child2, child3])
	function calculateCombinedHeight(itemList) {
		var height = 0
		var index
		for (index = 0; index < itemList.length; ++index) {
			height += itemList[index].height +
					  itemList[index].anchors.topMargin +
					  itemList[index].anchors.bottomMargin
		}

		return height
	}

	/// Calculate the combined width of a list of items.
	/// This just adds the widths and left-/right-margins,
	/// it does not take the relative layout into account.
	/// Example:
	/// width: calculateCombinedWidth([child1, child2, child3])
	function calculateCombinedWidth(itemList) {
		var width = 0
		var index
		for (index = 0; index < itemList.length; ++index) {
			width += itemList[index].width +
					 itemList[index].anchors.leftMargin +
					 itemList[index].anchors.rightMargin
		}

		return width
	}

	anchors.fill: parent

	onDoInit: kpiPrefix = identifier.slice(5) // remove qrc:/
	onScreenTitleChanged: if (showing) stage.setScreenTitle(screenTitle)

	onHidden: {
		stage.clearTopRightButtons();
		stage.enableCancelButton();
		stage.enableSaveButton();
		showSaveThrobber(false);
	}

	Behavior on scale {
		enabled:  globals.screenTransitionEnabled;
		NumberAnimation {duration: globals.screenTransitionDuration; easing.type: Easing.OutCubic}
	}
}
