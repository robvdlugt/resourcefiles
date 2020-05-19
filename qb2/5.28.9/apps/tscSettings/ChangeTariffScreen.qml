import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import BxtClient 1.0

Screen {
	id: tscChangeTariffScreen

	isSaveCancelDialog: true
	screenTitle: "Change electra and gas tariff"

	property bool firstShown: true;  // we need this because exiting a keyboard will load onShown again. Without this the input will be overwritten with the app settings again


	onSaved: {
		app.setTariff(tariffElec.inputText, tariffElecLow.inputText, tariffElecDualToggle.isSwitchedOn, tariffGas.inputText);
	}

	onShown: {
		if (firstShown) {
                        tariffElec.inputText = app.billingInfos["elec"].price 
                        tariffElecLow.inputText = app.billingInfos["elec"].lowPrice 
			tariffElecDualToggle.isSwitchedOn = app.billingInfos["elec"].rate === 1

                        tariffGas.inputText = app.billingInfos["gas"].price 


			firstShown = false;
		}
	}

        Text {
                id: bodyText

                width: Math.round(650 * app.nxtScale)
                wrapMode: Text.WordWrap

                text: "Set custom tariffs for your energy provider. See your contract for details."
                color: "#000000"

                font.pixelSize: qfont.bodyText
                font.family: qfont.regular.name

                anchors {
                        top: parent.top
                        topMargin: isNxt ? Math.round(10 * 1.28) : 10
                        horizontalCenter: parent.horizontalCenter
                }
        }

	
	EditTextLabel {
		id: tariffElec
		width: isNxt ? 300 : 250
		leftText: "Elec normal:"
		inputHints: Qt.ImhDigitsOnly
		anchors {
			top: bodyText.bottom
			topMargin : 10
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}
        Text {
                id: tariffElecDualToggleText
                anchors {
                        left: tariffElec.right
			leftMargin: 20
                        top: tariffElec.top
                        topMargin: 10
                }
                font.pixelSize: 16
                font.family: qfont.semiBold.name
                text: "Dual tariff"
        }
        OnOffToggle {
                id: tariffElecDualToggle
                height: 40
                anchors.left: tariffElecDualToggleText.right
                anchors.leftMargin: 10
                anchors.top: tariffElecDualToggleText.top
                leftIsSwitchedOn: false
        }
	EditTextLabel {
		id: tariffElecLow
		width: isNxt ? 300 : 250
		leftText: "Elec low:"
		inputHints: Qt.ImhDigitsOnly
		visible: tariffElecDualToggle.isSwitchedOn
		anchors {
			top: bodyText.bottom
			topMargin : 10
			left: tariffElecDualToggle.right
			leftMargin: 20 
		}
	}
	EditTextLabel {
		id: tariffGas
		width: isNxt ? 300 : 250
		leftText: "Gas:"
		inputHints: Qt.ImhDigitsOnly
		anchors {
			top: tariffElec.bottom
			topMargin : 10
			left: parent.left
			leftMargin: isNxt ? 60 : 50
		}
	}
	
}

