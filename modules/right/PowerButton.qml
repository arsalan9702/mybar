import QtQuick
import Quickshell
import Quickshell.Io
import qs
import qs.modules as Modules

Rectangle {
    id: root
    implicitWidth: icon.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.barHeight
    radius: Theme.radius
    color: mouseArea.containsMouse ? Theme.hoverBackground : "transparent"

    Modules.PhosphorIcon {
        id: icon
        anchors.centerIn: parent
        icon: "power.svg"
        color: Theme.foreground
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: exitPromptProcess.running = true
    }

    Process {
        id: exitPromptProcess
        command: ["busctl", "--user", "call", "org.kde.LogoutPrompt", "/LogoutPrompt", "org.kde.LogoutPrompt", "promptAll"]
    }
}