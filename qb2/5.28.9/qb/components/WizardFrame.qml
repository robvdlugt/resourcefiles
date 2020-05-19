import QtQuick 2.1
import qb.base 1.0

Widget {
	property bool hasDataSelected: false
	property int page: 0
	property int previousPage: 0
	property int nextPage: 0
	property string title: ""

	// SelectorWizard that owns this WizardFrame
	property SelectorWizard wizard

	// holds user selection data
	property variant outcomeData

	width:  parent != null ? parent.width  : canvas.width
	height: parent != null ? parent.height : canvas.height

	function clear() {
	}

	function getFrameData() {
		return outcomeData;
	}

	function initWizardFrame(data) {
		outcomeData = data;
	}
}
