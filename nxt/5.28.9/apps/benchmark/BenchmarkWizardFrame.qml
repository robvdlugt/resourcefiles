import QtQuick 2.1
import qb.components 1.0

WizardFrame {
	onHasDataSelectedChanged: {
		if (typeof selectorWizardFrames === "undefined")
			return;

		if (page !== selectorWizardFrames.length - 1) {
			selectorWizardSelector.rightArrowVisible = hasDataSelected;
		}
	}
}
