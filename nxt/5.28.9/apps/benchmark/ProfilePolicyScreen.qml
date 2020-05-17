import QtQuick 2.1
import qb.components 1.0

Screen {
	id: profilePolicyScreen

	screenTitle: qsTr("Privacy")
	anchors.fill: parent

	Text {
		id: titleLabel
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(85 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(85 * horizontalScaling)
		}
		text: qsTr("profilePrivacy_title_text")
		color: colors.profilePolicyTitle
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
	}

	Column {
		anchors {
			top: titleLabel.baseline
			topMargin: designElements.vMargin15
			left: titleLabel.left
			right: titleLabel.right
		}
		spacing: designElements.vMargin15

		Text {
			id: topLabel
			width: parent.width
			text: qsTr("profilePrivacy_body_text")
			color: colors.profilePolicyBody
			wrapMode: Text.Wrap
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}

		StandardButton {
			id: conditionsButton
			visible: qsTr("profilePrivacy_conditions_popup_body") !== " " ? true : false
			text: qsTr("Conditions")

			onClicked: {
				qdialog.showDialog(qdialog.SizeLarge, qsTr("profilePrivacy_conditions_popup_title"), qsTr("profilePrivacy_conditions_popup_body"));
				var popup = qdialog.context;
				popup.bodyFontPixelSize = Math.round(14 * verticalScaling);
			}
		}

		Item {
			width: parent.width
			height: childrenRect.height

			Rectangle {
				id: infoBox
				anchors {
					left: parent.left
					right: deleteButton.left
					rightMargin: designElements.hMargin6
				}

				height: Math.round(35 * verticalScaling)
				radius: designElements.radius
				color: colors.profilePolicyRect

				Text {
					id: profileDeleteLabel
					anchors {
						verticalCenter: parent.verticalCenter
						left: parent.left
						leftMargin: designElements.vMargin15
					}
					text: qsTr("profilePrivacy_remove_text")
					color: colors.profilePolicyBody
					font {
						family: qfont.regular.name
						pixelSize: qfont.bodyText
					}
				}
			}

			StandardButton {
				id: deleteButton
				text: qsTr("Delete")
				anchors {
					top:infoBox.top
					right: parent.right
				}

				onClicked: {
					qdialog.showDialog(qdialog.SizeLarge,
									   qsTr("profilePrivacy_delete_popup_title"),
									   feature.featBenchmarkFriendsEnabled() ? qsTr("profilePrivacy_delete_popup_body") : qsTr("profilePrivacy_delete_popup_body", "no_friends"),
									   qsTr("profilePrivacy_delete_popup_delete"),
									   (function() { app.removeProfile(); stage.navigateHome();}),
									   qsTr("profilePrivacy_delete_popup_cancel"), null);
				}
			}
		}

		Text {
			id: bottomLabel
			width: parent.width
			text: qsTr("profilePrivacy_bottom_text")
			color: colors.profilePolicyBody
			wrapMode: Text.Wrap
			font {
				family: qfont.regular.name
				pixelSize: qfont.bodyText
			}
		}
	}
}
