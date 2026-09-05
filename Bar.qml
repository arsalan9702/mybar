import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.modules.left as Left
import qs.modules.right as Right
import qs.modules.center as Center

PanelWindow {
    id: bar
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: Theme.glassBackground

    // This makes the whole bar glassy
    // BackgroundEffect.blurRegion: Region { item: bar.contentItem }

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

    // glass rim around the bar
    Rectangle{
       anchors{ left: parent.left; right: parent.right; bottom: parent.bottom }
       height: 2
       color: Theme.glassBorder
    }
}