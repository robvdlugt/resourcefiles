import QtQuick 2.1
import qb.components 1.0

Screen {
	id: profileWelcomeScreen

	screenTitle: qsTr("Profile")
	anchors.fill: parent

	Text {
		id: titleLabel
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(70 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(123 * horizontalScaling)
			right: parent.right
			rightMargin: Math.round(130 * horizontalScaling)
		}
		color: colors.benchmarkWelcomeTitle
		font {
			family: qfont.semiBold.name
			pixelSize: qfont.titleText
		}
		text: qsTr("title_text")
	}

	Text {
		id: bodyLabel
		anchors {
			baseline: titleLabel.baseline
			baselineOffset: Math.round(33 * verticalScaling)
			left: titleLabel.left
			right: titleLabel.right
		}
		color: colors.benchmarkWelcomeBody
		font {
			family: qfont.regular.name
			pixelSize: qfont.bodyText
		}
		text: qsTr("body_text")
		wrapMode: Text.WordWrap
	}

	Image {
		id: iconImage
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(47 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(88 * horizontalScaling)
		}
		source: "image://scaled/apps/benchmark/drawables/ProfileIconBig.svg"
	}

	StandardButton {
		id: startButton
		anchors {
			top: bodyLabel.bottom
			topMargin: designElements.vMargin20
			left: titleLabel.left
		}
		text: qsTr("Start")
		onClicked: {
			app.openBenchmarkAfterWizard = false;
			if (parseInt(app.benchmarkInfo.permission) !== 3) {
				stage.openFullscreen(app.privacyAgreementScreenUrl);
			} else {
				stage.openFullscreen(app.wizardScreenUrl, {reset:true});
			}
		}
	}

}
