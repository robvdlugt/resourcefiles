import QtQuick 2.1
import qb.components 1.0

Screen {
	id: surfaceAreaScreen

	function init(context) {
		frameContainer.setSource(app.surfaceAreaFrameUrl, {"app": app});
	}

	screenTitle: qsTr("Surface Area")
	anchors.fill: parent
	isSaveCancelDialog: true

	onShown: {
		frameContainer.item.selectedHouseType = parseInt(app.profileInfo.homeType);
		frameContainer.item.setSurfaceArea(app.profileInfo.homeSize);
	}

	onSaved: {
		app.setProfileInfo(app.profileInfo.homeType,
						   app.profileInfo.homeTypeAlt,
						   frameContainer.item.outcomeData,
						   app.profileInfo.homeBuildPeriod,
						   app.profileInfo.familyType
						   );
	}

	Loader {
		id: frameContainer
		anchors.fill: parent
	}
}
