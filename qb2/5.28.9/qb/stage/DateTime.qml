import QtQuick 2.1

import qb.base 1.0
import qb.components 1.0

Widget {
	id: dateTime
	width: 150
	height: parent.height

        Text {
               	id: txtTime
               	text: ""
               	color: colors.white
		anchors.centerIn: parent
               	anchors.verticalCenter: parent.verticalCenter
               	font.pixelSize: isNxt ? 52 : 42
               	font.family: qfont.bold.name
		visible: globals.tsc["showTime"]
       	}

       	Text {
               	id: txtDate
               	text: ""
               	color: colors.white
               	anchors.left: txtTime.right
               	anchors.leftMargin: 20
               	anchors.verticalCenter: parent.verticalCenter
               	font.pixelSize: isNxt ? 36 : 26
               	font.family: qfont.bold.name
		visible: globals.tsc["showDate"]
       	}


       	Timer {
               	id: datetimeTimer
               	interval: 1000
               	triggeredOnStart: true
               	running: globals.tsc["showTime"] || globals.tsc["showDate"]
               	repeat: true
               	onTriggered: {
                               var now = new Date().getTime();
                               txtTime.text = i18n.dateTime(now, i18n.time_yes);
                               txtDate.text = i18n.dateTime(now, i18n.mon_full);
      	                 }
        }
}
