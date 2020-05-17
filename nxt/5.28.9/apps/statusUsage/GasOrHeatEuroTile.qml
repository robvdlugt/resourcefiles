import QtQuick 2.1

StatusUsageTile {
	type: app.agreementDetailsDistrictHeating ? "heat": "gas"
	unitMoney: true
	diffValues: app.agreementDetailsDistrictHeating ? app.heatDiffValues : app.gasDiffValues
}
