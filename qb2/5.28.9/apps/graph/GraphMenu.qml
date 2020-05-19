import QtQuick 2.1

import qb.components 1.0

MenuItem {
	label: qsTr("Graphs")
	image: "drawables/graphs.svg"
	objectName: "graphMenuItem"
	weight: 200

	onClicked: stage.openFullscreen(app.graphScreenUrl, {agreementType: "electricity", unitType: "energy", intervalType: "hours", consumption: true, production: app.hasSolar})
}
