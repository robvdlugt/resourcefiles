import QtQuick 2.1
import qb.components 1.0

Screen {
	id: profileOverviewScreen

	function init(context) {
		frameContainer.setSource(app.profileOverviewFrameUrl, {"app": app});
	}

	screenTitle: qsTr("Profile")
	screenTitleIconUrl: "drawables/profile_menu.svg"
	anchors.fill: parent

	onShown: {
		frameContainer.item.houseTypeIconSource = app.houseTypeScreenData[app.profileInfo.homeType].iconUnselected;
		frameContainer.item.houseTypeLabelText =  app.houseTypeScreenData[app.profileInfo.homeType].name;
		frameContainer.item.familyTypeIconSource = app.familyTypeScreenData[parseInt(app.profileInfo.familyType) - 1].iconUnselected;
		frameContainer.item.familyTypeLabelText = app.familyTypeScreenData[parseInt(app.profileInfo.familyType) - 1].name;
		frameContainer.item.buildPeriodLabelText = app.constructionPeriodScreenData[app.profileInfo.homeBuildPeriod];
		frameContainer.item.areaLabelText = app.profileInfo.homeSize + " m²";
		frameContainer.item.nameLabelText = Qt.binding(function () { return app.profileInfo.screenName });
		addCustomTopRightButton(qsTr("Privacy"));
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.profilePolicyScreenUrl);
	}

	Loader {
		id: frameContainer
		anchors.fill: parent
	}

	Text {
		id: displayCodeLabel

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: Math.round(20 * verticalScaling)
		}

		text: qsTr("overview_display_code_text").arg(bxtClient.getCommonname());

		color: colors.profOverviewDispCode

		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
	}
}
