import QtQuick
import Quickshell
import qs
import qs.services as Services
import qs.popups as Popups
import qs.modules as Modules

Rectangle {
    id: root
    implicitWidth: icon.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.barHeight
    radius: Theme.radius
    color: mouseArea.containsMouse ? Theme.hoverBackground : "transparent"

    readonly property real pct: Services.BatteryService.percentage

    readonly property string iconName: {
        if (Services.BatteryService.charging || Services.BatteryService.fullyCharged) return "battery-charging-vertical.svg";
        if (pct < 0.15) return "battery-warning-vertical.svg";
        if (pct < 0.30) return "battery-vertical-low.svg";
        if (pct < 0.60) return "battery-vertical-medium.svg";
        if (pct < 0.95) return "battery-vertical-high.svg";
        return "battery-vertical-full.svg";
    }

    readonly property color iconColor: {
        if (Services.BatteryService.charging) return Theme.batteryCharging;
        if (pct < 0.15) return Theme.batteryCritical;
        if (pct < 0.30) return Theme.batteryLow;
        return Theme.batteryNormal;
    }

    Modules.PhosphorIcon {
        id: icon
        anchors.centerIn: parent
        icon: root.iconName
        color: root.iconColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (batteryPopup.visible) {
                batteryPopup.visible = false;
            } else {
                Services.PopupManager.requestOpen(batteryPopup);
            }
        }
    }

    Popups.BatteryPopup {
        id: batteryPopup
        anchor.item: root
        anchor.edges: Edges.Bottom
    }
}