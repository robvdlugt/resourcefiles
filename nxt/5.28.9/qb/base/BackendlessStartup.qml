import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0
import qb.utils 1.0
import themes 1.0
import BasicUIControls 1.0

import "BackendlessTranslations.js" as TranslationsJs

Rectangle {
	id: root
	color: colors.canvas
	anchors.fill: parent

	QtObject {
		id: p
		property string localeSelected
		property bool noFlags
		property variant features: ({})
		property string solarWarningText
	}

	function fromLanguageToFeatures() {
		selectLanguage.visible = false;
		selectFeatures.visible = true;
		btnLeft.visible = true;
	}

	function fromFeaturesToLanguage() {
		selectLanguage.visible = true;
		selectFeatures.visible = false;
		btnLeft.visible = false;
	}

	function fromFeaturesToParams() {
		selectFeatures.visible = false;
		selectParameters.visible = true;
		checkSelection();
	}

	function fromParametersToFeatures() {
		selectParameters.visible = false;
		selectFeatures.visible = true;
		btnRight.visible = true;
	}

	function setFeatures() {
		var features = {};
		features.activated = "1";
		features.standalone = standalone.selected ? "1" : "0";
		features.district_heating = heat.selected ? "1" : "0";
		features.electricity = elec.selected ? "1" : "0";
		features.gas = gas.selected ? "1" : "0";
		features.sw_updates = "1";
		features.content_apps = "1";
		features.telmi_enabeld = "0";
		features.SME = sme.selected ? "1" : "0";
		features.other_provider_elec = "0";
		features.other_provider_gas = "0";
		features.heatwinner = heatRecovery.selected ? "1" : "0";
		features.heatingBeat = heatingBeat.selected ? "1" : "0";
		//config dependent
		features.solar = solar.selected ? "1" : "0";
		features.smokeDetector = smokeDetector.selected ? "1" : "0";
		features.locale = p.localeSelected;
		p.features = features;
	}

	function setParameters() {
		demoParameters.addDemoParameter("smartMeter", smartMeter.selected ? 1 : 0);
		demoParameters.addDemoParameter("hasGas", gas.selected ? 1 : 0);
		demoParameters.addDemoParameter("hasHeat", heat.selected ? 1 : 0);
		demoParameters.addDemoParameter("hasSolar", solar.selected ? 1 : 0);
		demoParameters.addDemoParameter("isSME", sme.selected ? 1 : 0);
		demoParameters.addDemoParameter("heatRecovery", heatRecovery.selected ? 1 : 0);
	}

	function startGUI() {
		canvas.setDemoFeatures(p.features);
	}

	Component.onCompleted: {
		screenStateController.start();
		screenStateController.screenColorDimmedIsReachable = false;
	}

	Text {
		id: title
		anchors {
			top: parent.top
			topMargin: designElements.vMargin15
			horizontalCenter: parent.horizontalCenter
		}
		font.pixelSize: qfont.navigationTitle
	}

	function updateLanguage() {
		title.text = selectLanguage.visible ? TranslationsJs.translations[p.localeSelected].selectLang : TranslationsJs.translations[p.localeSelected].selectFeat;
		elec.text = TranslationsJs.translations[p.localeSelected].elec;
		gas.text = TranslationsJs.translations[p.localeSelected].gas;
		heat.text = TranslationsJs.translations[p.localeSelected].heat;
		heatingBeat.text = TranslationsJs.translations[p.localeSelected].heatingBeat;
		solar.text = TranslationsJs.translations[p.localeSelected].solar;
		smokeDetector.text = TranslationsJs.translations[p.localeSelected].smoke;
		standalone.text = TranslationsJs.translations[p.localeSelected].standalone;
		heatRecovery.text = TranslationsJs.translations[p.localeSelected].heatRecovery;
		smartMeter.text = TranslationsJs.translations[p.localeSelected].smartMeter;
		sme.text = TranslationsJs.translations[p.localeSelected].sme;
		p.solarWarningText = TranslationsJs.translations[p.localeSelected].warningSolar;
		btnLeft.text = TranslationsJs.translations[p.localeSelected].back;
		btnRight.text = TranslationsJs.translations[p.localeSelected]['continue'];
	}

	function checkSelection() {
		if (!smartMeter.selected && solar.selected) {
			warningText.text = p.solarWarningText;
			btnRight.visible = false;
			warningText.visible = true;
		} else if (smartMeter.selected && solar.selected || !solar.selected) {
			warningText.visible = false;
			btnRight.visible = true;
		}
	}

	ControlGroup {
		id: radioButtonGroup
		exclusive: true
	}

	ListModel {
		id: languageModel

		// Load language details from array
		Component.onCompleted: {
			var locales = feature.i18nLocales();
			p.noFlags = locales.length > 1;
			for (var i = 0; i < locales.length - 1; i++) {
				if (locales[i + 1].split("_")[1] !== locales[i].split("_")[1]) {
					p.noFlags = false;
					break;
				}
			}
			for (i in locales) {
				append({languageName: TranslationsJs.translations[locales[i]].language, locale: locales[i], flag: "flag" + locales[i].split("_")[1] + ".png"});
			}
			if (i == 0) {
				fromLanguageToFeatures();
				updateLanguage();
			}
		}
	}

	Item {
		id: selectLanguage
		visible: true
		anchors {
			centerIn: parent
		}
		Column {
			anchors {
				centerIn: parent
			}
			spacing: designElements.spacing10
			Repeater {
				id: languageList
				anchors {
					horizontalCenter: parent.horizontalCenter
				}
				model: languageModel
				delegate: StandardRadioButton {
					controlGroup: radioButtonGroup
					text: languageName
					selected: index === 0
					onSelectedChanged: {
						if (selected) {
							p.localeSelected = locale;
							updateLanguage();
						}
						btnRight.enabled = true;
					}
					Image {
						source: "qrc:/qb/base/drawables/%1".arg(flag)
						visible: !p.noFlags
						anchors {
							right: parent.right
							rightMargin: designElements.hMargin10
							verticalCenter: parent.verticalCenter
						}
					}
				}

			}
		}

	}

	Item {
		id: selectFeatures
		visible: false
		anchors.centerIn: parent
		Flow {
			id: flow
			anchors.centerIn: parent
			width: 216*2 + 10
			spacing: designElements.spacing10

			StandardCheckBox {
				id: elec
				selected: true
				MouseArea {
					anchors.fill: parent
				}
			}
			StandardCheckBox {
				id: gas
				selected: true
				onSelectedChanged: {
					if (selected) {
						heat.selected = false;
						heatingBeat.selected = false;
					}
				}
				MouseArea {
					enabled: parent.selected
					anchors.fill: parent
				}
			}
			StandardCheckBox {
				id: heat
				selected: false
				onSelectedChanged: {
					if (selected) {
						gas.selected = false;
						solar.selected = false;
						heatingBeat.selected = false;
					}
				}
				MouseArea {
					enabled: parent.selected
					anchors.fill: parent
				}
			}
			StandardCheckBox {
				id: heatingBeat
				selected: false
				visible: false
				onSelectedChanged: {
					if (selected) {
						gas.selected = false;
						heat.selected = false;
					}
				}
				MouseArea {
					enabled: parent.selected
					anchors.fill: parent
				}
			}
			StandardCheckBox {
				id: solar
				selected: false
				MouseArea {
					enabled: !gas.selected
					anchors.fill: parent
				}
			}
			StandardCheckBox {
				id: smokeDetector
				selected: true
				visible: feature.appSmokeDetectorEnabled()
			}
			StandardCheckBox {
				id: standalone
				selected: false
			}
			StandardCheckBox {
				id: heatRecovery
				selected: false
				visible: feature.appHeatRecoveryEnabled()
			}
			StandardCheckBox {
				id: sme
				selected: false
				visible: feature.featSMEEnabled()
			}
		}
	}

	Item {
		id: selectParameters
		visible: false
		anchors.centerIn: parent
		Flow {
			id: parameterFlow
			anchors.centerIn: parent
			width: 216*2 + 10
			spacing: 10

			StandardCheckBox {
				id: smartMeter
				selected: solar.selected
				onSelectedChanged: checkSelection()
			}
		}
		Text {
			id: warningText
			anchors {
				top: parameterFlow.bottom
				topMargin: designElements.vMargin10
				horizontalCenter: parent.horizontalCenter
			}
			font {
				pixelSize: qfont.bodyText
			}
			text: p.solarWarningText
			color: "red"
			visible: false
		}
	}

	StandardButton {
		id: btnRight
		enabled: false
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			right: parent.right
			rightMargin: Math.round(50 * horizontalScaling)
		}
		onClicked: {
			if (selectLanguage.visible) {
				fromLanguageToFeatures();
				updateLanguage();
			} else if (selectFeatures.visible) {
				fromFeaturesToParams();
				setFeatures();
			} else if (selectParameters.visible) {
				setParameters();
				startGUI();
			}
		}
	}

	StandardButton {
		id: btnLeft
		visible: false
		anchors {
			bottom: parent.bottom
			bottomMargin: Math.round(50 * verticalScaling)
			left: parent.left
			leftMargin: Math.round(50 * horizontalScaling)
		}
		onClicked: {
			if (selectFeatures.visible) {
				fromFeaturesToLanguage();
				updateLanguage();
			} else if (selectParameters.visible) {
				fromParametersToFeatures();
			}
		}
	}
}
