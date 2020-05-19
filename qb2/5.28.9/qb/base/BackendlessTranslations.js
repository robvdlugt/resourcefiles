.pragma library

/*
 * Because real locales are not loaded yet use this fake approach for translations in demo startup screen.
 */
var translations = ({
	nl_NL : { language: 'Nederlands', selectLang: 'Kies een taal',         selectFeat: 'Kies mogelijkheden',          elec: 'Stroom',      gas: 'Gas',
				heat: 'Stadswarmte',        solar: 'Zon',          smoke: 'Rookmelder',         standalone: 'Standalone', heatingBeat: 'Verwarming Grafiek',
				heatRecovery: 'WarmteWinner', sme: 'MKB', 'continue': 'Verder',   back: 'Terug',
				smartMeter: 'Slimme meter', warningSolar: "Ongeldige combinatie. Zon alleen mogelijk met slimme meter."},
	nl_BE : { language: 'Vlaams',     selectLang: 'Kies een taal',         selectFeat: 'Kies mogelijkheden',          elec: 'Stroom',      gas: 'Gas',
				heat: 'Stadswarmte',        solar: 'Zon',          smoke: 'Rookmelder',         standalone: 'Standalone', heatingBeat: 'Verwarming Grafiek',
				heatRecovery: 'Heat Recovery', sme: 'MKB', 'continue': 'Verder',   back: 'Terug',
				smartMeter: 'Slimme meter', warningSolar: "Ongeldige combinatie. Zon alleen mogelijk met slimme meter."},
	en_GB : { language: 'English',    selectLang: 'Select language',       selectFeat: 'Select features',             elec: 'Electricity', gas: 'Gas',
				heat: 'District heating',  solar: 'Solar',          smoke: 'Smoke detector',     standalone: 'Standalone', heatingBeat: 'Heating Beat',
				heatRecovery: 'Heat Recovery', sme: 'SME', 'continue': 'Continue', back: 'Back',
				smartMeter: 'Smart meter', warningSolar: "Invalid combination. Solar only possible with smart meter." },
	fr_BE : { language: 'Français',   selectLang: 'Choisissez une langue', selectFeat: 'Choisissez caractéristiques', elec: 'Electricité', gas: 'Gaz',
				heat: 'Chauffage urbain',  solar: 'Solaire',        smoke: 'Détecteur de fumée', standalone: 'Autonome', heatingBeat: 'Heating Beat',
				heatRecovery: 'Chaleur Gagneur', sme: 'PME', 'continue': 'Suivant',  back: 'En retour',
				smartMeter: 'Smart meter', warningSolar: "Invalid combination. Solar only possible with smart meter." },
	fr_FR : { language: 'Français',   selectLang: 'Choisissez une langue', selectFeat: 'Choisissez caractéristiques', elec: 'Electricité', gas: 'Gaz',
				heat: 'Chauffage urbain',  solar: 'Solaire',        smoke: 'Détecteur de fumée', standalone: 'Autonome', heatingBeat: 'Heating Beat',
				heatRecovery: 'Chaleur Gagneur', sme: 'PME', 'continue': 'Suivant',  back: 'En retour',
				smartMeter: 'Smart meter', warningSolar: "Invalid combination. Solar only possible with smart meter." },
	es_ES : { language: 'Español',   selectLang: 'Seleccione idioma', selectFeat: 'Seleccionar características', elec: 'Electricidad', gas: 'Gas',
				heat: 'Calefacción urbana', solar: 'Energía solar', smoke: 'Detector de humo', standalone: 'Ser único', heatingBeat: 'Heating Beat',
				heatRecovery: 'Recuperación de calor', sme: 'PMI', 'continue': 'Continuar', back: 'Retroceder',
				smartMeter: 'Smart meter', warningSolar: "Invalid combination. Solar only possible with smart meter." },
	de_DE : { language: 'Deutsch',   selectLang: 'Sprache auswählen', selectFeat: 'Funktionen auswählen', elec: 'Elektrizität', gas: 'Gas',
				heat: 'Heizung', solar: 'Solar', smoke: 'Rauchmelder', standalone: 'Eigenständige', heatingBeat: 'Heating Beat',
				heatRecovery: 'Wärmerückgewinnung', sme: 'KMU', 'continue': 'fortsetzen', back: 'zurück',
				smartMeter: 'Smart Meter', warningSolar: "Ungültige Kombination. Solar nur möglich mit Smart Meter." }

})

