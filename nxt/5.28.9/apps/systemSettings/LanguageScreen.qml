import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0

Screen {
	id: languageScreen
	hasCancelButton: true
	screenTitle: qsTr("Select your language")

	onShown: {
		addCustomTopRightButton(qsTr("Save"));
		var sortedLocales = feature.i18nLocales();
		sortedLocales.sort(function (a, b) {
			if (globals.languageList[a] < globals.languageList[b])
				return -1;
			else if (globals.languageList[a] > globals.languageList[b])
				return 1;
			return 0;
		});
		langListView.model = sortedLocales;
	}

	onCustomButtonClicked: {
		var newLocale = langListView.model[radioGroup.currentControlId];
		if (newLocale === canvas.locale) {
			hide();
		} else {
			qdialog.showDialog(qdialog.SizeMedium, qsTr("Warning"), qsTr("Warn Reboot Language %1").arg(globals.languageList[newLocale]), qsTr("Reboot"), function(){
				app.fullScreenThrobber.show();
				app.setLocale(newLocale);
			}, qsTr("Cancel"));
		}
	}

	ControlGroup {
		id: radioGroup
		exclusive: true
	}

	ListView {
		id: langListView
		width: parent.width / 4
		height: count && currentItem ? count * currentItem.height + (count - 1) * spacing : 0
		anchors {
			centerIn: parent
			// Slightly move the buttonlist upward, to center it in the physical screen rather
			// than the LanguageScreen.
			verticalCenterOffset: Math.round(-0.5 * designElements.menubarHeight)
		}
		spacing: Math.round(8 * verticalScaling)
		interactive: false
		delegate: StandardRadioButton {
			id: radioButton
			width: parent.width
			controlGroupId: index
			controlGroup: radioGroup
			text: globals.languageList[modelData]
			selected: (modelData === canvas.locale)
		}
	}
}
