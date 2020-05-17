import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

StandardButton {
	id: root
	property string presetName: ""

	topLeftRadiusRatio: 0
	topRightRadiusRatio: 0
	bottomLeftRadiusRatio: 0
	bottomRightRadiusRatio: 0

	radius: designElements.radius

	colorUp: (presetName === app.presetUuidToName(app.activePresetUUID)) ? colors.tempTileBackgroundDown : colors.tempTileBackgroundUp
	colorDown: (presetName === app.presetUuidToName(app.activePresetUUID)) ? qtUtils.addColorAlpha(colors.white, 0.4) : colors.tempTileBackgroundDown
	colorSelected: colors.tempTileBackgroundDown
	colorDisabled: colors.tempTileBackgroundDown

	fontColorUp: (presetName === app.presetUuidToName(app.activePresetUUID)) ? colors.btnUpPrimary : colors.tempTileTextUp
	fontColorDown: colors.tempTileTextDown
	fontColorSelected: colors.tempTileTextUp
	fontColorDisabled: "lightgray"

	fontFamily: qfont.semiBold.name
	fontPixelSize: qfont.tileTitle

	onClicked: {
		app.setPresetsOverride(presetName);
	}
}
