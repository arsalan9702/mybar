import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.modules.left as Left
import qs.modules.right as Right
import qs.modules.center as Center

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: Theme.background

    // left region
    RowLayout {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: Theme.padding }
        spacing: Theme.spacing
        Left.VolumeButton {}
        Left.BluetoothButton {}
        Left.WifiButton {}
        Left.BatteryButton {}
    }
    
    // center region
    RowLayout {
        anchors.centerIn: parent
        spacing: Theme.spacing
        Center.ClockWidget {}
    }
    
    // right region
    RowLayout {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: Theme.padding }
        spacing: Theme.spacing
        Right.PowerButton {}
    }
}