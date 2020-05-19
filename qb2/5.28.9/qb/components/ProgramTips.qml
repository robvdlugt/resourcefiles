pragma Singleton

import QtQuick 2.11

import themes 1.0

QtObject {
	id: programTips
	property url tipsPopupUrl: "TipsPopup.qml"

	function show(hasPreheating) {
		qdialog.showDialog(qdialog.SizeLarge, "", tipsPopupUrl);
		qdialog.context.titleFontPixelSize = Fonts.navigationTitle;
		var tips = [
			{
				title: qsTr("tip-weekrithm-title"),
				text:  qsTr("tip-weekrithm-text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/qb/components/drawables/program-tips-weekrithm.svg")
			},
			{
				title: qsTr("tip-sleeptime-title"),
				text:  qsTr("tip-sleeptime-text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/qb/components/drawables/program-tips-sleeptime.svg")
			},
			{
				title: qsTr("tip-uptodate-title"),
				text:  qsTr("tip-uptodate-text"),
				textFormat: Text.RichText,
				image: Qt.resolvedUrl("image://scaled/qb/components/drawables/program-tips-uptodate.svg")
			}
		];
		if (hasPreheating)
			tips.unshift(
				{
					title: qsTr("tip-preheating-title"),
					text:  qsTr("tip-preheating-text"),
					textFormat: Text.RichText,
					image: Qt.resolvedUrl("image://scaled/qb/components/drawables/program-tips-preheating.svg")
				});
		qdialog.context.dynamicContent.showSeparator = false;
		qdialog.context.dynamicContent.carousel = true;
		qdialog.context.dynamicContent.imageContainerWidth = 204;
		qdialog.context.dynamicContent.tips = tips;
	}
}
