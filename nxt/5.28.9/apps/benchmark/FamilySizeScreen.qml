import QtQuick 2.1
import qb.components 1.0

Screen {
	id: familySizeScreen

	function init(context) {
		frameContainer.setSource(app.familySizeFrameUrl, {"app": app});
		frameContainer.item.initWizardFrame();
	}

	screenTitle: qsTr("Family size")
	anchors.fill: parent
	isSaveCancelDialog: true

	onShown: {
		frameContainer.item.setCurrentControlId(parseInt(app.profileInfo.familyType));
	}

	onSaved: {
		app.setProfileInfo(app.profileInfo.homeType,
						   app.profileInfo.homeTypeAlt,
						   app.profileInfo.homeSize,
						   app.profileInfo.homeBuildPeriod,
						   frameContainer.item.outcomeData
						   );
	}

	Loader {
		id: frameContainer
		anchors.fill: parent
	}
}
