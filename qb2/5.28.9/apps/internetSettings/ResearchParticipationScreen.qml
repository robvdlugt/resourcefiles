import QtQuick 2.1

import qb.components 1.0
import BxtClient 1.0

Screen {
	id: researchParticipationScreen

	isSaveCancelDialog: true
	screenTitle: qsTr("research_participation_title", globals.tenant)

	onShown: {
		onOffToggle.selected = app.researchParticipationEnabled;

		// tenant-specific strings marked to be used by lupdate
		QT_TRANSLATE_NOOP("ResearchParticipationScreen", "research_participation_title", "Viesgo");
		QT_TRANSLATE_NOOP("ResearchParticipationScreen", "research_participation_line1", "Viesgo");
		QT_TRANSLATE_NOOP("ResearchParticipationScreen", "research_participation_line2", "Viesgo");
		QT_TRANSLATE_NOOP("ResearchParticipationScreen", "research_participation_line3", "Viesgo");
		QT_TRANSLATE_NOOP("ResearchParticipationScreen", "Participate in research", "Viesgo");
	}
	onSaved: app.setResearchEnabledState(onOffToggle.selected)

	Column {
		width: Math.round(650 * verticalScaling)

		anchors {
			top: parent.top
			topMargin: Math.round(60 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}

		spacing: Math.round(10 * verticalScaling)

		Text {
			id: bodyline1

			color: colors.researchParticipationTitle
			text: qsTr("research_participation_line1", globals.tenant)

			font.pixelSize: qfont.titleText
			font.family: qfont.semiBold.name
		}

		Text {
			id: bodyline2

			color: colors.researchParticipationBody
			text: qsTr("research_participation_line2", globals.tenant)
			width: parent.width
			wrapMode: Text.WordWrap

			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name
		}

		Text {
			id: bodyline3

			color: colors.researchParticipationBody
			text: qsTr("research_participation_line3", globals.tenant)
			width: parent.width
			wrapMode: Text.WordWrap

			font.pixelSize: qfont.bodyText
			font.family: qfont.regular.name
		}

		SingleLabel {
			id: participateLabel

			width: parent.width
			leftText: qsTr("Participate in research", globals.tenant)
			mouseEnabled: false

			OnOffToggle {
				id: onOffToggle

				anchors {
					verticalCenter: parent.verticalCenter
					right: parent.right
					rightMargin: 12
				}

				leftTextOff: qsTr("Off")
				rightTextOn: qsTr("On")
			}
		}

		WarningBox {
			width: parent.width
			height: Math.round(80 * verticalScaling)
			warningText: qsTr("research_participation_warning")
			anchors.horizontalCenter: parent.horizontalCenter
		}

	}

}
