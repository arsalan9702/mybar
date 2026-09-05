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

    readonly property string iconName: {
        if (!Services.NetworkService.wifiEnabled) return "wifi-slash.svg";
        if (!Services.NetworkService.connected) return "wifi-none.svg";
        const s = Services.NetworkService.signalStrength;
        if (s > 0.66) return "wifi-high.svg";
        if (s > 0.33) return "wifi-medium.svg";
        return "wifi-low.svg";
    }

    Modules.PhosphorIcon {
        id: icon
        anchors.centerIn: parent
        icon: root.iconName
        color: Theme.foreground
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (wifiPopup.visible) {
                wifiPopup.visible = false;
            } else {
                Services.PopupManager.requestOpen(wifiPopup);
            }
        }
        
    }

    Popups.WifiPopup {
        id: wifiPopup
        anchor.item: root
        anchor.edges: Edges.Bottom

        onVisibleChanged: Services.NetworkService.setScanning(visible)
    }
}