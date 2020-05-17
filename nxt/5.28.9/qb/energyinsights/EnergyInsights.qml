pragma Singleton
import QtQuick 2.0

import BxtClient 1.0

import "Definitions.js" as Definitions

Item {
	id: energyInsights

	property string p1Uuid

	function init() {

	}

	/**
	 * @brief Send a REST-like request to retrieve insights data
	 * @param[out]	callback	callback function to be called with the response data (format: fn(success, response))
	 * @param[in]	utility		name of utility to query, i.e. electricity, gas, water
	 * @param[in]	origin		origin of the data, i.e. consumption, production, import, export
	 * @param[in]	type		type of data, i.e. quantity, flow
	 * @param[in]	tariff		for dual tariff, which tariff to query, i.e. low-tariff, normal-tariff
	 * @param[in]	isCost		whether response should be unit based or cost based
	 * @param[in]	interval	data interval, i.e. days, weeks, months, years
	 * @param[in]	from		period to query from, date/time in ISO 8601, i.e. 2018-06-25T09:01:36+02:00
	 * @param[in]	to			period to query to
	 */
	function requestData(callback, utility, origin, type, tariff, isCost, interval, from, to) {

		function requestDataCB(response) {
			if (response) {
				var success = false;
				var jsonText = response.getArgument("json");
				var jsonObj;
				try {
					jsonObj = JSON.parse(jsonText);
					if (jsonObj.responseHeader.statusCode === 200)
						success = true;
					else if(jsonObj.responseHeader.statusCode === 408)
						console.log("EnergyInsights.requestData: request timeout!");
				} catch(e) {
					console.log("EnergyInsights.requestData: failed parsing JSON response!", e);
				}
				if (typeof callback === "function")
					callback(success, success ? jsonObj.body : undefined);
			} else {
				console.log("EnergyInsights.requestData: request timeout!");
				if (typeof callback === "function")
					callback(false);
			}
		}

		var uri = "/insights/home/" + utility;
		if (origin)
			uri += "/" + origin;
		if (type)
			uri += "/" + type;
		if (type === "quantity")
			uri += "/" + (isCost ? "price" : "unit");
		if (interval)
			uri += "/" + interval;
		if (tariff)
			uri += "/" + tariff;
		var queryParams = [];
		if (from)
			queryParams.push("from=" + from);
		if (to)
			queryParams.push("to=" + to);
		if (queryParams.length)
			uri += "?" + queryParams.join("&");

		var json = {
			"requestHeader": {"uri": uri, "method": "GET"}
		};

		var msg = BxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, p1Uuid, "rest", "RestCall");
		msg.addArgument("json", JSON.stringify(json));
		BxtClient.doAsyncBxtRequest(msg, requestDataCB, 40);
	}

	/**
	 * @brief Send a batch of REST-like requests to retrieve consumption insights data
	 * @param[in]	requestArgs		array of request arguments to query, (array of object of @Definitions.RequestArgs)
	 * @param[out]	callback		callback function to be called after every query with the response data (format: fn(calbackArgs..., success, response, batchDone))
	 * @see Definitions.RequestArgs
	 */
	function requestBatchData(requestArgs, callback) {
		if (!Array.isArray(requestArgs))
			return;

		var requestPending = 0;
		var requestCB = function (id, callbackArgs, success, response) {
			requestPending &= ~(id);
			var batchDone = (requestPending === 0 ? true : false);
			if (typeof callback === "function")
				callback.apply(null, callbackArgs.concat([success, response, batchDone]));
		}

		for (var i = 0; i < requestArgs.length; i++) {
			if (!(requestArgs[i] instanceof Definitions.RequestArgs))
				continue;
			var args = requestArgs[i];
			var requestId = 1 << i;
			requestPending |= requestId;
			requestData(_partialFn(requestCB, requestId, args.callbackArgs),
									 args.utility, args.origin, args.type, args.tariff, args.isCost, args.interval, args.from, args.to);
		}
	}

	function _partialFn(f) {
		var args = Array.prototype.slice.call(arguments, 1);
		return function() {
			var remainingArgs = Array.prototype.slice.call(arguments);
			return f.apply(null, args.concat(remainingArgs));
		}
	}

	BxtDiscoveryHandler {
		id: p1DiscoHandler
		deviceType: "hdrv_p1"
		onDiscoReceived: {
			p1Uuid = deviceUuid;
		}
	}
}
