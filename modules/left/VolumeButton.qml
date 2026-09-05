import QtQuick
import QtQuick.Layouts
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

   Behavior on color {
           ColorAnimation { duration: Theme.animationFast }
       }
   
   scale: mouseArea.pressed ? 0.92 : 1.0
   Behavior on scale {
      NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutQuad }
   }
   
    readonly property real volume: Services.PipewireService.defaultVolume
    readonly property bool muted: Services.PipewireService.defaultMuted

    Modules.PhosphorIcon {
        id: icon
        anchors.centerIn: parent
    
        icon: root.muted
            ? "speaker-x.svg"
            : root.volume < 0.5
                ? "speaker-low.svg"
                : "speaker-high.svg"
    
        color: root.muted ? Theme.batteryCritical : Theme.foreground
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            if (volumePopup.visible) {
                volumePopup.visible = false;
            } else {
                Services.PopupManager.requestOpen(volumePopup);
            }
        }
        
        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            const node = Services.PipewireService.defaultSink;
            if (node) {
                const newVol = Math.max(0, Math.min(1, node.audio.volume + delta));
                Services.PipewireService.setVolume(node, newVol);
            }
        }
    }

    Popups.VolumePopup {
        id: volumePopup
        anchor.item: root
        anchor.edges: Edges.Bottom
    }
}