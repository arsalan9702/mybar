import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services as Services
import qs.popups as Popups
import qs.modules as Modules

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.barHeight
    radius: Theme.radius
    color: mouseArea.containsMouse ? Theme.hoverBackground : "transparent"

    function deviceIcon(device) {
        if (device.icon.includes("audio") || device.icon.includes("headset") || device.icon.includes("headphone")) return "headset.svg";
        if (device.icon.includes("mouse")) return "mouse-simple.svg";
        return "bluetooth-connected.svg";
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Base bluetooth state icon: off, on-but-nothing-connected, or
        // on-and-connected (shown alongside per-device icons below).
        Modules.PhosphorIcon {
            icon: {
                if (!Services.BluetoothService.adapterEnabled) return "bluetooth-slash.svg";
                if (Services.BluetoothService.connectedDevices.length === 0) return "bluetooth.svg";
                return "bluetooth-connected.svg";
            }
            color: Theme.foreground
        }

        // One icon per connected device, e.g. bluetooth-connected + mouse + headset
        Repeater {
            model: Services.BluetoothService.adapterEnabled ? Services.BluetoothService.connectedDevices : []
            delegate: Modules.PhosphorIcon {
                icon: root.deviceIcon(modelData)
                color: Theme.foreground
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (bluetoothPopup.visible) {
                bluetoothPopup.visible = false;
            } else {
                Services.PopupManager.requestOpen(bluetoothPopup);
            }
        }
    }

    Popups.BluetoothPopup {
        id: bluetoothPopup
        anchor.item: root
        anchor.edges: Edges.Bottom
    }
}