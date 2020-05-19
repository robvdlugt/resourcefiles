.pragma library

// RequestArgs object constructor declaration
function RequestArgs(utility, origin, type, isCost, interval, from, to, callbackArgs) {
	this.utility = utility;
	this.origin = origin;
	this.type = type;
	this.tariff = undefined;
	this.isCost = isCost;
	this.interval = interval;
	this.from = from;
	this.to = to;
	this.callbackArgs = Array.isArray(callbackArgs) ? callbackArgs : [];
}
