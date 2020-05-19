import QtQuick 2.0

import qb.components 1.0

ZwaveRemoveDeviceScreen {
	title: qsTr("strv-disconnect-title")
	stepsText: qsTr("strv-disconnect-steps")
	failedText: qsTr("strv-disconnect-failed")
	forceRemoveTitle: qsTr("Remove smart radiator valve")
	forceRemoveText: qsTr("strv-force-remove-popup")

	imageStart: "drawables/strv-press-button.svg"
	imageBusy: "drawables/strv-searching.svg"
	imageSuccess: "drawables/strv-success.svg"
	imageFailed: "drawables/strv-question.svg"
}
