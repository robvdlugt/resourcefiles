import QtQuick 2.1

Text {
	id: caption

	color: colors.thumbnailCaption
	font.pixelSize: qfont.tileThumbnailCaption
	font.family: qfont.semiBold.name
	text: tileWidgetInfo.args.thumbCaption
}
