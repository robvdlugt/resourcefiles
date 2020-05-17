import QtQuick 2.1
import qb.components 1.0

MenuItem {
	label: qsTr("Status usage")
	weight: 200

	onClicked: {
		if (app.statusUsageScreen) {
			app.statusUsageScreen.show();
		}
	}
}
