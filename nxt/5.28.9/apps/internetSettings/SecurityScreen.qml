import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: securityScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("Security")

	onShown: {
		radioButtonList.currentIndex = app.hiddenNetworkAuth === -1 ? 0 : app.hiddenNetworkAuth;
	}

	onSaved: {
		app.hiddenNetworkAuth = radioButtonList.currentIndex;
	}

	RadioButtonList {
		id: radioButtonList
		width: Math.round(150 * horizontalScaling)
		anchors.centerIn: parent
		title: qsTr("Type")

		Component.onCompleted: {
			for (var i in app.securityTypes)
				addItem(app.securityTypes[i]);
			forceLayout();
		}
	}
}
