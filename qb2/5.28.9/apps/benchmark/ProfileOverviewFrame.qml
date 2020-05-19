import QtQuick 2.1
import QtQuick.Layouts 1.3

import qb.base 1.0
import qb.components 1.0

BenchmarkWizardFrame {
	id: profileOverviewFrame
	title: qsTr("Profile overview")
	clip: true

	property alias houseTypeIconSource: houseTypeIcon.iconSource
	property alias houseTypeLabelText: houseTypeLabel.text
	property alias familyTypeIconSource: familyTypeIcon.iconSource
	property alias familyTypeLabelText: familyTypeLabel.text
	property alias buildPeriodLabelText: buildPeriodLabel.prefilledText
	property alias areaLabelText: areaLabel.prefilledText
	property alias nameLabelText: nameLabel.prefilledText
	property int labelWidth: -1

	function initWizardFrame() {
		var houseType = wizardScreen.outcomeData[0];
		houseTypeIconSource = app.houseTypeScreenData[houseType].iconUnselected;
		houseTypeLabelText = app.houseTypeScreenData[houseType].name;
		buildPeriodLabelText = app.constructionPeriodScreenData[wizardScreen.outcomeData[2]];
		areaLabelText = wizardScreen.outcomeData[3].size + " m²";
		var familyType = wizardScreen.outcomeData[4] - 1;
		familyTypeIconSource = app.familyTypeScreenData[familyType].iconUnselected;
		familyTypeLabelText = app.familyTypeScreenData[familyType].name
		nameLabelText = wizardScreen.outcomeData[5];
		state = "WIZARD";
	}

	Item {
		id: container
		anchors.fill: parent
		anchors.topMargin: Qt.inputMethod.visible ? - Math.round(195 * verticalScaling) : 0

		Text {
			id: titleLabel
			anchors {
				top: parent.top
				topMargin: designElements.margin20
				left: detailGrid.left
				right: detailGrid.right
			}
			font {
				family: qfont.semiBold.name
				pixelSize: qfont.titleText
			}
			color: colors.profOverviewTitle
			text: qsTr("overview_title_text")
		}

		Text {
			id: bodyLabel
			anchors {
				baseline: titleLabel.baseline
				baselineOffset: Math.round(33 * verticalScaling)
				left: titleLabel.left
				right: titleLabel.right
			}
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
			color: colors.profOverviewBody
			wrapMode: Text.WordWrap
			text: qsTr("overview_body_text_screen").arg(i18n.dateTime(app.getLastProfileEditDate(), i18n.date_yes))
		}

		Item {
			id: centeredItem
			width: familyType.width + houseType.anchors.leftMargin + houseType.width
			height: familyType.height
			anchors {
				baseline: bodyLabel.baseline
				baselineOffset: Math.round(33 * verticalScaling)
				horizontalCenter: parent.horizontalCenter
			}

			Item {
				id: familyType
				width: Math.round(88 * horizontalScaling)
				height: Math.round(64 * verticalScaling)

				IconButton {
					id: familyTypeIcon
					anchors.fill: parent
					radius: designElements.radius
					iconSource: "drawables/HouseOption01.svg"
					colorUp: colors.twoStateBtnUp

					onClicked: {
						stage.openFullscreen(app.familySizeScreenUrl);
					}
				}

				Text {
					id: familyTypeLabel
					anchors {
						baseline: parent.bottom
						baselineOffset: Math.round(21 * verticalScaling)
						horizontalCenter: parent.horizontalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.twoStateBtnText
					text: "Family"
				}
			}

			Item {
				id: houseType
				width: Math.round(88 * horizontalScaling)
				height: Math.round(64 * verticalScaling)
				anchors {
					left: familyType.right
					leftMargin: Math.round(50 * horizontalScaling)
				}

				IconButton {
					id: houseTypeIcon
					anchors.fill: parent
					radius: designElements.radius
					iconSource: "drawables/HouseOption01.svg"
					colorUp: colors.twoStateBtnUp

					onClicked: {
						stage.openFullscreen(app.houseTypeScreenUrl);
					}
				}

				Text {
					id: houseTypeLabel
					anchors {
						baseline: parent.bottom
						baselineOffset: Math.round(21 * verticalScaling)
						horizontalCenter: parent.horizontalCenter
					}
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
					color: colors.twoStateBtnText
					text: "House"
				}
			}
		}

		GridLayout {
			id: detailGrid
			anchors {
				top: centeredItem.bottom
				topMargin: Math.round(40 * verticalScaling)
				left: parent.left
				leftMargin: Math.round(160 * horizontalScaling)
				right: parent.right
				rightMargin: anchors.leftMargin
			}
			rowSpacing: designElements.spacing6
			columnSpacing: rowSpacing
			columns: 2

			Component.onCompleted: labelWidth = Math.max(nameLabel.leftTextImplicitWidth,
														 buildPeriodLabel.leftTextImplicitWidth,
														 areaLabel.leftTextImplicitWidth)

			EditTextLabel {
				id: nameLabel
				Layout.fillWidth: true
				Layout.columnSpan: 2
				Layout.row: 0
				labelText: qsTr("Name")
				leftTextAvailableWidth: labelWidth
				maxLength: 15
				showAcceptButton: true
				validator: RegExpValidator { regExp: /.+/ } // empty name is not allowed

				onInputAccepted: app.setScreenName(inputText);
			}

			EditTextLabel {
				id: buildPeriodLabel
				Layout.fillWidth: true
				Layout.row: 1
				labelText: qsTr("Build period")
				leftTextAvailableWidth: labelWidth
				readOnly: true

				onClicked: editBuildPeriodButton.clicked()
			}

			IconButton {
				id: editBuildPeriodButton
				Layout.minimumWidth: height
				iconSource: "qrc:/images/edit.svg"
				bottomClickMargin: 3
				topClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.constructionPeriodScreenUrl);
				}
			}

			EditTextLabel {
				id: areaLabel
				Layout.fillWidth: true
				Layout.row: 2
				labelText: qsTr("Surface")
				leftTextAvailableWidth: labelWidth
				readOnly: true

				onClicked: editSurfaceAreaButton.clicked()
			}

			IconButton {
				id: editSurfaceAreaButton
				Layout.minimumWidth: height
				iconSource: "qrc:/images/edit.svg"
				topClickMargin: 3

				onClicked: {
					stage.openFullscreen(app.surfaceAreaScreenUrl);
				}
			}
		}
	}

	states: [
		State {
			name: "WIZARD"
			PropertyChanges { target: nameLabel; readOnly: true; showAcceptButton: false; Layout.columnSpan: 1 }
			PropertyChanges { target: buildPeriodLabel; mouseEnabled: false}
			PropertyChanges { target: areaLabel; mouseEnabled: false}
			PropertyChanges { target: editBuildPeriodButton; visible: false }
			PropertyChanges { target: editSurfaceAreaButton; visible: false }
			PropertyChanges { target: houseTypeIcon; mouseEnabled: false }
			PropertyChanges { target: familyTypeIcon; mouseEnabled: false }
			PropertyChanges { target: bodyLabel; text: qsTr("overview_body_text_frame") }
		}
	]
}
