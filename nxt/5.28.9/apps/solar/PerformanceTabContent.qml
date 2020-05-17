import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0

Item {
	id: root

	property bool noExpectations: !app.billingInfos.elec_produ || parseInt(app.billingInfos.elec_produ.usage) === 0
	property int expectedProduction: 0
	property int realProduction: 0
	property string period: ""
	property string periodFull: ""
	property int daysLeft: 0
	property bool displayMoneyWise: false

	QtObject {
		id: p
		property variant lessEqualMoreImages: ["panels-cloudy.svg", "panels-only.svg", "panels-sun.svg"]
		property int lessEqualMore: (expectedProduction === realProduction ? 1 : (expectedProduction > realProduction ? 0 : 2))
		property url estProductionPopup: "EstimatedProductionPopup.qml"

		function infoBoxLeftText() {
			var number = "";
			if (displayMoneyWise) {
				number = i18n.currency(expectedProduction, i18n.curr_round);
			} else {
				number = i18n.number(expectedProduction) + " kWh";
			}
			return (daysLeft == 0 ? qsTr('In %1 was %2 expected').arg(period).arg(number) : qsTr('So far in %1 is %2 expected').arg(period).arg(number));
		}

		function infoBoxTextRight() {
			if (noExpectations) {
				return qsTr("no_expectations_info_text");
			}
			var number = "";
			if (displayMoneyWise) {
				number = i18n.currency(realProduction, i18n.curr_round);
			} else {
				number = i18n.number(realProduction) + " kWh";
			}
			return (daysLeft === 0 ? qsTr('In %1 you have %2 produced').arg(period).arg(number) : qsTr('Until now in %1 you have %2 produced').arg(period).arg(number));
		}

		function lessEqualMoreStrings() {
			var result;
			result = [ qsTr('%1 %2 less'),
					  qsTr('exactly the same amount'),
					  qsTr('%1 %2 more')][lessEqualMore];

			if (lessEqualMore === 1) return result;

			if (displayMoneyWise)
				result = result.arg(i18n.currency(Math.abs(expectedProduction - realProduction), i18n.curr_round)).arg('');
			else
				result = result.arg(i18n.number(Math.abs(expectedProduction - realProduction))).arg('kWh');
			return result;
		}
	}

	Text {
		id: daysLeftText
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(40 * verticalScaling)
			left: informationTextRect.left
		}
		font.family: qfont.italic.name
		font.pixelSize: qfont.bodyText
		visible: noExpectations || daysLeft > 0
		text: noExpectations ? qsTr("- Fill in your expected yield -") : qsTr("%1 days left", "", daysLeft).arg(daysLeft)
		color: colors.solarAppPerformanceDaysLeftText
	}

	Row {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
		}
		spacing: Math.round(60 * horizontalScaling)
		visible: !noExpectations

		Image {
			id: statusImage
			source: "image://scaled/apps/solar/drawables/" + p.lessEqualMoreImages[p.lessEqualMore]
		}

		Column {
			width: Math.round(300 * horizontalScaling)

			Text {
				text: daysLeft === 0 ? qsTr('In %1 you had').arg(periodFull) : qsTr('In %1 you have').arg(periodFull)
				font.family: qfont.regular.name
				font.pixelSize: qfont.titleText
				color: colors.solarAppText
			}

			Text {
				text: p.lessEqualMoreStrings()
				font.family: qfont.regular.name
				font.pixelSize: qfont.primaryImportantBodyText
				color: colors.solarAppValue
			}

			Text {
				text: p.lessEqualMore === 1 ? qsTr('as expectation') : qsTr('against expectation')
				font.family: qfont.regular.name
				font.pixelSize: qfont.titleText
				color: colors.solarAppText
			}
		}
	}

	StandardButton {
		id: noExpectationFillInButton
		anchors {
			right: performanceInfoButton.left
			rightMargin: designElements.hMargin10
			top: performanceInfoButton.top
		}
		visible: noExpectations
		text: qsTr("Expected yield")
		onClicked: {
			stage.openFullscreen(app.estimatedGenerationScreenUrl, {from: "SolarApp"});
		}
	}

	IconButton {
		id: performanceInfoButton
		anchors {
			right: parent.right
			rightMargin: designElements.hMargin15
			top: parent.top
			topMargin: anchors.rightMargin
		}
		iconSource: "qrc:/images/info.svg"
		onClicked: {
			qdialog.showDialog(qdialog.SizeLarge, qsTr("Production per year"), p.estProductionPopup, qsTr("Expected production"), openEstProductionScreen);
			qdialog.context.closeBtnForceShow = true;
		}
		function openEstProductionScreen() {
			stage.openFullscreen(app.estimatedGenerationScreenUrl, {from: "SolarApp", editing: true});
		}
	}

	Rectangle {
		id: informationTextRect
		radius: designElements.radius
		height: Math.round(74 * verticalScaling)
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(22 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(30 * horizontalScaling)
			right: parent.right
			rightMargin: anchors.leftMargin
		}
		color: noExpectations ? colors.solarAppInfoBoxNoExpectation : colors.solarAppInfoBox

		Image {
			id: sunImage
			visible: !noExpectations
			anchors {
				left: parent.left
				leftMargin: Math.round(24 * horizontalScaling)
				verticalCenter: parent.verticalCenter
			}
			source: "image://scaled/apps/solar/drawables/white-sun.svg"
		}

		Text {
			id: sunText
			visible: sunImage.visible
			anchors {
				verticalCenter: parent.verticalCenter
				left: sunImage.right
				leftMargin: Math.round(24 * horizontalScaling)
				right: panelsImage.left
				rightMargin: anchors.leftMargin
			}
			text: p.infoBoxLeftText()
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			color: colors.solarAppInfoBoxText
			wrapMode: Text.WordWrap
		}

		Image {
			id: panelsImage
			anchors {
				verticalCenter: parent.verticalCenter
				left: noExpectations ? parent.left : parent.horizontalCenter
				leftMargin: Math.round(24 * horizontalScaling)
			}
			source: "image://scaled/apps/solar/drawables/white-panels.svg"
		}
		Text {
			id: noExpectationInfoText
			anchors {
				verticalCenter: parent.verticalCenter
				left: panelsImage.right
				leftMargin: Math.round(24 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.rightMargin

			}
			font.family: qfont.regular.name
			font.pixelSize: qfont.bodyText
			color: noExpectations ? colors.noExpectationInfoText : colors.solarAppInfoBoxText

			text: p.infoBoxTextRight()
			wrapMode: Text.WordWrap
		}
	}
}
