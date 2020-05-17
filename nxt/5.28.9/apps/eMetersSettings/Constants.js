.pragma library

// 1D - meter type
// 2D - measure type
var meterImageUrls = {
	'gas': ["m3", "smartmeter"],
	'elec': ["kwh","smartmeter","laser"],
	'heat': ["gj"],
	'solar': ["solar"],
	'water': ["m3"]
}

var meterType = {
	'gas' :  0,	// analog or smart measure type
	'elec':  1,	// analog, smart or laser measure type
	'heat':  2,	// analog measure type
	'solar': 3, // analog measure type
	'water': 4, // analog measure type
}

var meterNames = {
	'gas': [qsTr("Gas meter"), qsTr("Smart meter")],
	'elec': [qsTr("Power meter"),qsTr("Smart meter"),qsTr("Power meter")],
	'heat': [qsTr("Heat meter")],
	'solar': [qsTr("Solar meter")],
	'water': [qsTr("Water meter")]
}

var cValueUnits = {
	"elec": [
		{
			"name": qsTr("Pulse"),
			"min": 30,
			"max": 10000,
			"units": [
				{'id': 0,
				'unitNames': [qsTr("imp/kWh"),qsTr("pulsen/kWh"),qsTr("p/kWh")],
				'divisor' : 0		, 'multi' : 0	, 'defVal' : 1000},
				{'id': 4,
				'unitNames': [qsTr("Wh/imp")],
				'divisor' : 1000	, 'multi' : 0	, 'defVal' : 1000}
			]
		},
		{
			"name": qsTr("Disk"),
			"min": 30,
			"max": 1000,
			"units": [
				{'id': 5,
				'unitNames': [{"name": qsTr("C ="), "unitBefore": true},qsTr("tr/kWh"),qsTr("omw/kWh"),qsTr("r/kWh"),qsTr("U/kWh")],
				'divisor': 0		, 'multi' : 0	, 'defVal' : 300},
				{'id': 9,
				'unitNames': [{"name": qsTr("a ="), "unitBefore": true}],
				'divisor' : 0		, 'multi' : 60	, 'defVal' : 300}
			]
		}
	],
	"gas": [
		{
			"name": "",
			"min": 30,
			"max": 10000,
			"units": [
				{'id': 10,
				'unitNames': [qsTr("rev/m3")],
				'divisor' : 0		, 'multi' :	0	, 'defVal' : 100},
				{'id': 11,
				'unitNames': [qsTr("L/pulse")],
				'divisor' : 0		, 'multi' :	10	, 'defVal' : 100}
			]
		}
	],
	"solar": [
		{
			"name": qsTr("Pulse"),
			"min": 30,
			"max": 10000,
			"units": [
				{'id': 0,
				'unitNames': [qsTr("imp/kWh"),qsTr("pulsen/kWh"),qsTr("p/kWh")],
				'divisor' : 0		, 'multi' : 0	, 'defVal' : 10000},
				{'id': 4,
				'unitNames': [qsTr("Wh/imp")],
				'divisor' : 1000	, 'multi' : 0	, 'defVal' : 10000}
			]
		}
	],
	"water": [
		{
			"name": "",
			"min": 30,
			"max": 10000,
			"units": [
				{'id': 10,
				'unitNames': [qsTr("rev/m3")],
				'divisor' : 0		, 'multi' :	0	, 'defVal' : 1000},
				{'id': 11,
				'unitNames': [qsTr("L/rev")],
				'divisor' : 1000	, 'multi' :	0, 'defVal' : 1000},
			]
		}
	]
}

var USAGEDEVICE_STATUS = {
	CONN_NOT_CONFIGURED: 0,
	CONN_NOT_CONNECTED: 1,
	CONN_OK: 2
}

var meterStatusValues = {
	ST_DISABLED: 0,
	ST_OPERATIONAL: 1,
	ST_COMMISSIONING: 2,
	ST_SIGNAL_LOW: 3,
	ST_COMMISSIONING_TIMEOUT: 4,
	ST_ACCURACY_WARNING: 5,
	ST_ERROR: 6,
	ST_INACTIVE: 7,
	ST_UNKNOWN: 8,
}

var MEASURE_TYPE = {
	ANALOG: 0,
	SMART_METER: 1,
	LASER: 2
}

var STATUS = {
	UNKNOWN: 0,
	ERROR: 1,
	OK: 2
}

var RATE_TYPE = {
	SINGLE: 0,
	DUAL: 1
}

var ELEC_METER_TYPE = {
	PULSE: 0,
	DISK: 1
}

var GAS_METER_TYPE = {
	PULSE: 0,
	DISK: 1
}

var CONFIG_STATUS = {
	GAS: 1 << 0,
	ELEC: 1 << 1,
	SOLAR: 1 << 2,
	HEAT: 1 << 3,
	WATER: 1 << 4
}

var measureTypeStrings = ["analog", "p1", "laser"];

// translates the meterStatusValues-based sensor status from the driver into simpler statuses for this app
var meterStatusCodes = [STATUS.ERROR,		// ST_DISABLED
						STATUS.OK,			// ST_OPERATIONAL
						STATUS.OK,			// ST_COMMISSIONING
						STATUS.ERROR,		// ST_SIGNAL_LOW
						STATUS.ERROR,		// ST_COMMISSIONING_TIMEOUT
						STATUS.ERROR,		// ST_ACCURACY_WARNING
						STATUS.ERROR,		// ST_ERROR
						STATUS.ERROR,		// ST_INACTIVE
						STATUS.UNKNOWN];	// ST_UNKNOWN

var combinedMeasureTypes = [MEASURE_TYPE.SMART_METER];

var usageDeviceUrls = {
	"HAE_METER_v2":"meteradapter",
	"HAE_METER_v3":"meteradapter",
	"HAE_METER_v4":"meteradapter_v2",
	"HOME_ENERGY_METER":"hem",
	"HOME_ENERGY_METER_GEN5":"hem",
	"HOME_ENERGY_METER_3_PHASE":"hem",
}

////////////////////////////////////////////////
// Graph item status:
// 0:"STATUS.UNKONWN", 1:"STATUS.ERROR", 2:"STATUS.OK"
var lineColors = [
	"overMeterDashedLineDefault",
	"overMeterDashedLineError",
	"overMeterDashedLineOk"
]
var labelColors = [
	"overMeterDisabled",
	"overMeterLabel",
	"overMeterLabel"
]
var statusIconVisibilities = [false, true, true]

////////////////////////////////////////////////

// Graph item getters
function getMeterImageUrl(type, measureType) {
	if (typeof meterImageUrls[type] !== "undefined") {
		if (measureType < meterImageUrls[type].length) {
			return "drawables/" + meterImageUrls[type][measureType];
		}
	}
	// on error return default icon
	return "drawables/energymeter";
}

function getMeterName(type, measureType) {
	if (typeof meterNames[type] !== "undefined") {
		if (measureType < meterNames[type].length) {
			return meterNames[type][measureType];
		}
	}
	// on error return unknown
	return "Unknown meter";
}

function getUsageDeviceImageUrl(type) {
	var url = usageDeviceUrls[type];
	return url ? "drawables/" + url : "drawables/meteradapter";
}

function getStatusIconVisible(status) {
	if (status >= statusIconVisibilities.length) {
		return false;
	}
	return statusIconVisibilities[status];
}

function getMeterStatus(status) {
	if (status <= meterStatusCodes.length)
		return 0;
	return GraphConstants.meterStatusCodes[status];
}
