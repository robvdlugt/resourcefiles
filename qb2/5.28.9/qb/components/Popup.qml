import QtQuick 2.1

import qb.base 1.0

/**
 * The base class for any Popup.
 */
Widget {
	width: canvas.width
	height: canvas.height
	property Item container
	property bool dimWasReachable: true
	function show(args) {
		if (!visible) {
			dimWasReachable = screenStateController.screenColorDimmedIsReachable;
			screenStateController.screenColorDimmedIsReachable = false;
			visible = true;
			showing = true;
		}
		parent = container;
		shown(args);
	}

	function hide() {
		screenStateController.screenColorDimmedIsReachable = dimWasReachable;
		if (visible) {
			visible = false;
			showing = false;
		}
		parent = null;
		hidden();
	}
}
