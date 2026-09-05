import QtQuick
import Quickshell
import qs
import qs.popups as Popups
import qs.services as Services

Rectangle {
    id: root
    implicitWidth: label.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.barHeight
    radius: Theme.radius
    color: mouseArea.containsMouse ? Theme.hoverBackground : "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "dd/MM/yy  •  HH:mm")
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall+4
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (calendarPopup.visible) {
                calendarPopup.visible = false;
            } else {
                Services.PopupManager.requestOpen(calendarPopup);
            }
        }
    }

    Popups.CalendarPopup {
        id: calendarPopup
        anchor.item: root
        anchor.edges: Edges.Bottom
    }
}