import QtQuick 2.1
import QtQuick.VirtualKeyboard 2.3
import QtQuick.VirtualKeyboard.Settings 2.2

import qb.components 1.0

Screen {
	id: languageScreen

	property variant selectedData
	property variant langList
	property variant langCodeList
	property string  curLangCode: qlanguage.locale

	inNavigationStack: false
	hasCancelButton: false
	hasHomeButton: false

	// Since this language screen should function without any translations loaded,
	// none of the strings here are translated.
	screenTitle: "Select your language"

	onShown: {
		initialize();
		screenStateController.screenColorDimmedIsReachable = false
		addCustomTopRightButton(saveLabel)
		disableCustomTopRightButton()
	}

	onCustomButtonClicked: {
		console.log(langList[langListView.currentIndex], langCodeList[langListView.currentIndex])
		app.setLocale(langCodeList[langListView.currentIndex])
	}

	function initialize(){
		var tmpLangList = []
		var tmpLangCodeList = []

		// QStringList
		var tenantLocales = feature.i18nLocales()

		// Go through all defined languages. Note that this list is unordered!
		for (var langCode in globals.languageList) {
			// Get the name for the current language code. E.g. nl-BE -> Nederlands
			var languageName = globals.languageList[langCode]

			// Show only the languages that are available for the tenant.
			if (tenantLocales.indexOf(langCode) !== -1) {
				// Add the language to the RadioButtonList, and the local lists.
				console.log(languageName, langCode)
				tmpLangList.push(languageName)
				tmpLangCodeList.push(langCode)
				langListView.addItem("%1 (%2)".arg(languageName).arg(langCode))
				//console.log(tmpLangList)
			} else {
				console.log("Skipping", languageName, langCode, "because of tenant.")
			}
		}
		// Keep a local list of the languages
		langList = tmpLangList
		langCodeList = tmpLangCodeList
	}

	Text {
		id: explanationText

		width: parent.width * 2 / 3
		height: Math.round(40 * verticalScaling)

		text: " "

		font.family: qfont.regular.name
		font.pixelSize: qfont.bodyText
		color: colors.foreground
		wrapMode: Text.WordWrap

		anchors {
			top: parent.top
			topMargin: designElements.vMargin20
			horizontalCenter: parent.horizontalCenter
		}
	}

	RadioButtonList {
		id: langListView

		width: parent.width / 4

		anchors {
			top: explanationText.bottom
			topMargin: designElements.vMargin10
			horizontalCenter: parent.horizontalCenter
		}

		onCurrentIndexChanged: {
			enableCustomTopRightButton();
			parent.curLangCode = langCodeList[langListView.currentIndex]
		}
	}

	property string saveLabel: "Save"

	onSaveLabelChanged: {
		addCustomTopRightButton(saveLabel);
	}

	onStateChanged: {
		// ** CTH-279 ** In Belgium, the AZERTY keyboard is commonly used, even for Flemish users
		if (state.indexOf("_BE") !== -1) {
			VirtualKeyboardSettings.locale = "fr_FR";
		} else {
			VirtualKeyboardSettings.locale = canvas.getKeyboardLocale(state);
		}
	}

	// TODO: Use translator for the folowing text fields once the language can be changed in run-time.
	state: curLangCode
	states: [
		State {
			name: 'nl_NL'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Selecteer je taal"
				saveLabel: "Opslaan"
			}
			PropertyChanges {
				target: explanationText
				text: "Nadat je de taal hebt geselecteerd zal de installatie wizard eenmalig opnieuw opstarten om deze taal in te laden."
			}

		},
		State {
			name: 'en_GB'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Select your language"
				saveLabel: "Save"
			}
			PropertyChanges {
				target: explanationText;
				text: "After choosing your language the installation wizard will restart once to load the language."
			}
		},
		State {
			name: 'nl_BE'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Selecteer je taal"
				saveLabel: "Opslaan"
			}
			PropertyChanges {
				target: explanationText;
				text: "Nadat je de taal hebt geselecteerd zal de installatie wizard eenmalig opnieuw opstarten om deze taal in te laden."
			}
		},
		State {
			name: 'fr_BE'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Choisissez votre langue"
				saveLabel: "Sauvegarder"
			}
			PropertyChanges {
				target: explanationText;
				text: "Une fois que vous avez sélectionné la langue voulue, l’assistant d’installation redémarre une fois pour la télécharger."
			}
		},
		State {
			name: 'fr_FR'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Choisissez votre langue"
				saveLabel: "Sauvegarder"
			}
			PropertyChanges {
				target: explanationText;
				text: "Une fois que vous avez sélectionné la langue voulue, l’assistant d’installation redémarre une fois pour la télécharger."
			}
		},
		State {
			name: 'es_ES'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Selecciona tu idioma"
				saveLabel: "Guardar"
			}
			PropertyChanges {
				target: explanationText;
				text: "Una vez que hayas seleccionado el idioma, el asistente de instalación se reiniciará una vez para cargar dicho idioma."
			}
		},
		State {
			name: 'de_DE'
			PropertyChanges {
				target: languageScreen
				screenTitle: "Wähle deine Sprache"
				saveLabel: "Speichern"
			}
			PropertyChanges {
				target: explanationText;
				text: "Nachdem Sie Ihre Sprache ausgewählt haben, wird der Installationsassistent einmal neu gestartet, um die Sprache zu laden."
			}
		}
	]
}
