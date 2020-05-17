.pragma library

// period in milliseconds for timing out http requests
var HTTP_REQUEST_TIMEOUT = 10000

var progressFields = [
	{"object": "boilerInfo", "field": "brandId"},
	{"object": "boilerInfo", "field": "modelId"},
	{"object": "boilerInfo", "field": "productionYear",
		"testFn": function (element) { return element && element !== 0 }},
	{"object": "boilerInfo", "field": "services",
		"testFn": function (element) { return element.length > 0 }},
	{"object": "boilerInfo", "field": "serviceInterval", "configEnableField": "enableServiceInterval",
		"testFn": function (element) { return element > 0 }},
	{"object": "boilerInfo", "field": "maintenanceProviderId", "configEnableField": "enableServiceProvider",
		"testFn": function (element) { return element > 0 }},
	{"object": "contactInfo", "field": undefined, "configEnableField": "enablePhoneNumbers",
		"testFn": function (element) {
			for (var field in element) {
				if (element[field])
					return true;
			}
			return false;
		}}
];

// NOTE: keep these declarations in sync with the boiler-api JSON response
var EMPTY_BOILERINFO = {
	"brandId": undefined,
	"modelId": undefined,
	"productionYear": undefined,
	"subscribedSince": undefined,
	"services": [],
	"serviceInterval": undefined,
	"maintenanceProviderId": undefined
};

var EMPTY_BOILERSTATUS = {
	"state": undefined,
	"fault": {
		"state": undefined,
		"priority": undefined,
		"category": undefined,
		"description": undefined,
		"consequence": undefined,
		"advice": undefined,
		"oemFaultCode": undefined
	},
	"maintenance": {
		"state": undefined,
		"dueBy": undefined,
		"description": undefined,
		"consequence": undefined,
		"advice": undefined
	},
	"waterPressure": null
};

var EMPTY_CONTACTINFO = {
	// Note: the phone numbers are internally stored as a boolean array (see below)
	// and converted into actual phone numbers before sending to the backend.
	// This is done to support updating the phone numbers when the user changes the phones numbers outside
	// of the boilerMonitoring app.
	"phoneNumber1Selected": false,
	"phoneNumber2Selected": false
}

// HTTP response codes from boiler api
var HTTP_OK						= 200;
var HTTP_CREATED				= 201;
var HTTP_NO_CONTENT				= 204;
var HTTP_UNAUTHORIZED			= 401;
var HTTP_FORBIDDEN				= 403;
var HTTP_NOT_FOUND				= 404;
var HTTP_VALIDATION_EXCEPTION	= 405;
var HTTP_UNPROCESSABLE			= 422;

var BACKEND_DATA = {
	SERVICE_CONFIG: (1 << 0),
	BOILER_PROFILE: (1 << 1),
	CONSENT: (1 << 2),
	BOILER_STATUS: (1 << 3),
	MTNC_PROVIDERS: (1 << 4)
}
