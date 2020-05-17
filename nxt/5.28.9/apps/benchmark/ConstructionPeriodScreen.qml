import QtQuick 2.1
import qb.components 1.0

Screen {
	id: constructionPeriodScreen

	function init() {
		frameContainer.setSource(app.constructionPeriodFrameUrl, {"app": app});
		frameContainer.item.initWizardFrame();
	}

	screenTitle: qsTr("Construction period")
	anchors.fill: parent
	isSaveCancelDialog: true

	onShown: {
		frameContainer.item.setCurrentControlId(parseInt(app.profileInfo.homeBuildPeriod));
	}

	onSaved: {
		app.setProfileInfo(app.profileInfo.homeType,
						   app.profileInfo.homeTypeAlt,
						   app.profileInfo.homeSize,
						   frameContainer.item.outcomeData,
						   app.profileInfo.familyType
						   );
	}

	Loader {
		id: frameContainer
		anchors.fill: parent
	}
}
