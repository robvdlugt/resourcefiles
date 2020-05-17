import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.components 1.0
import BasicUIControls 1.0

RowLayout {
	id: legendsRow
	height: designElements.buttonSize
	spacing: Math.round(15 * horizontalScaling)

	property string dlgLastUpdate

	// there are several legend types
	property int lt_EMPTY: 0
	property int lt_COMMON: 1
	property int lt_MONTH: 2
	property int lt_PRODUCTION: 3
	property int lt_COMMON_DT: 4
	property int lt_MONTH_DT: 5
	property int lt_AREA_CONSUMPTION: 6
	property int lt_AREA_CONSUMPTION_DT: 7
	property int lt_AREA_PRODUCTION: 8
	property int lt_HEATING_BEAT: 9

	QtObject {
		id: p
		property int legendType: -1
		property variant legendModel: []

		property url estProductionPopup: "EstimatedProductionPopup.qml"
		property url editEstimatedGenerationScreenUrl: "qrc:/apps/eMetersSettings/EstimatedGenerationScreen.qml"
	}

	function setType(lType, otherProvider, isCost) {
		p.legendType = lType;

		infoPopupConsumption.visible = false;
		infoPopupProduction.visible = false;
		var legends = [];

		var legendLowTariff = {"type" : "square", "color" : colors.graphElecSingleOrLowTariff,"text" : qsTr("Low tariff")};
		var legendNormalTariff = {"type" : "square", "color" : colors.graphElecHighTariff,"text" : qsTr("Normal tariff")};
		var legendSingleTariff = {"type" : "square", "color" : colors.graphElecSingleOrLowTariff,"text" : qsTr("Single tariff")};

		switch (p.legendType) {
		case lt_COMMON_DT:
			legends.push(legendLowTariff);
			legends.push(legendNormalTariff);
			// fallthrough
		case lt_COMMON:
			if (feature.featElecFixedDayCostEnabled() && isCost) {
				if (!legends.length)
					legends.push(legendSingleTariff);
				legends.push({"type" : "square", "color" : colors.graphFixedCosts,"text" : qsTr("Fixed cost")});
			}
			if (otherProvider && isCost) {
				infoPopupConsumption.visible = true;
				infoPopupConsumption.popupContent = qsTr("default_tariff_explanation");
				infoPopupConsumption.popupTitle = qsTr("default_tariff_title");
			}
			break;
		case lt_MONTH_DT:
			legends.push(legendLowTariff);
			legends.push(legendNormalTariff);
			// fallthrough
		case lt_MONTH:
			if (feature.featElecFixedDayCostEnabled() && isCost) {
				if (!legends.length)
					legends.push(legendSingleTariff);
				legends.push({"type" : "square", "color" : colors.graphFixedCosts,"text" : qsTr("Fixed cost")});
			}
			if (!otherProvider)
				legends.push({"type" : "line", "color" : colors.barGraphEstimationLine,"text" : qsTr("Estimated consumption")});
			infoPopupConsumption.visible = (!otherProvider || (otherProvider && isCost));
			infoPopupConsumption.popupContent = otherProvider ? qsTr("default_tariff_explanation") : qsTr("estimations_dialog_content %1").arg(dlgLastUpdate);
			infoPopupConsumption.popupTitle = otherProvider ? qsTr("default_tariff_title") : qsTr("estimations_dialog_title");
			break;
		case lt_PRODUCTION:
			legends.push({"type" : "line", "color" : colors.barGraphEstimationLineProduction,"text" : qsTr("Estimated production")});
			infoPopupProduction.visible = true;
			break;
		case lt_AREA_CONSUMPTION_DT:
			legends.push(legendLowTariff);
			legends.push(legendNormalTariff);
			// fallthrough
		case lt_AREA_CONSUMPTION:
			legends.push({"type" : "circle", "color" : colors.graphElecSingleOrLowTariffSelected,"text" : qsTr("Lowest consumption")});
			legends.push({"type" : "line", "color" : colors.graphAreaAverageLine,"text" : qsTr("Average consumption")});
			break;
		case lt_AREA_PRODUCTION:
			legends.push({"type" : "circle", "color" : colors.graphSolarSelected, "text" : qsTr("Highest production")});
			break;
		case lt_HEATING_BEAT:
			infoPopupConsumption.visible = true;
			infoPopupConsumption.popupTitle = qsTr("heating_beat_dialog_title");
			infoPopupConsumption.popupContent = qsTr("heating_beat_explanation");
			break;
		case lt_EMPTY:
			// fallthrough
		default:
			break;
		}
		p.legendModel= legends;
	}

	// to ocuppy space on the left of layout, pushing all elements to align to the right
	Item {
		Layout.fillWidth: true
		Layout.fillHeight: true
	}

	Repeater {
		id: legendRepeater
		model: p.legendModel

		RowLayout {
			id: legendRow
			spacing: designElements.hMargin10
			Layout.fillHeight: true

			Rectangle {
				id: legendItemColor
				Layout.preferredWidth: Math.round(15 * (modelData.type === "circle" ? 0.8 : 1) * horizontalScaling)
				height: modelData.type === "line" ? Math.round(2 * verticalScaling) : Layout.preferredWidth
				radius: modelData.type === "circle" ? height / 2 : 0
				color: modelData.color
			}

			Text {
				id: legendItemText
				Layout.fillWidth: true
				Layout.maximumWidth: Math.ceil(implicitWidth)
				font {
					family: qfont.regular.name
					pixelSize: qfont.metaText
				}
				text: modelData.text
				wrapMode: Text.WordWrap
				lineHeight: lineCount > 1 ? 0.8 : 1
				maximumLineCount: 2
				elide: Text.ElideRight
			}
		}
	}

	IconButton {
		id: infoPopupConsumption
		Layout.preferredWidth: height
		height: parent.height
		iconSource: "qrc:/images/info.svg"
		rightClickMargin: designElements.hMargin5
		visible: false
		property string popupContent
		property string popupTitle

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, popupTitle, popupContent);
			var popup = qdialog.context;
			popup.bodyFontPixelSize = qfont.bodyText;
			popup.iconSource = "qrc:/images/info_popup.svg";
		}
	}

	IconButton {
		id: infoPopupProduction
		Layout.preferredWidth: height
		height: parent.height
		iconSource: "qrc:/images/info.svg"
		rightClickMargin: designElements.hMargin5
		visible: false

		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Production per year"), p.estProductionPopup, qsTr("Expected production"), function () {
				stage.openFullscreen(p.editEstimatedGenerationScreenUrl, {from: "GraphApp", editing: true});
			});
			qdialog.context.closeBtnForceShow = true;
		}
	}
}
