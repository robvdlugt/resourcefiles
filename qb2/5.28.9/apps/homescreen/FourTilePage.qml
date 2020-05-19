import QtQuick 2.1;

Flow {
	property bool empty: true
	width: (Math.round(230 * horizontalScaling) * 2) + spacing
	height: (Math.round(158 * verticalScaling) * 2) + spacing
	spacing: Math.round(10 * horizontalScaling)

	EmptyTile {}
	EmptyTile {}
	EmptyTile {}
	EmptyTile {}
}
