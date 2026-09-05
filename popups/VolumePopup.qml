import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services as Services
import qs.popups
import qs.modules as Modules

PopupWindow {
    id: popup
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    visible: false
    grabFocus: true
    color: "transparent"

    Rectangle {
        id: background
        implicitWidth: Theme.popupWidth
        implicitHeight: contentColumn.implicitHeight + Theme.padding * 2
        color: Theme.background
        radius: Theme.popupRadius
        border.color: Theme.border
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.spacing

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "OUTPUT"
                    color: Theme.foregroundMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall - 1
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }
                Item {
                    implicitWidth: Theme.fontSizeSmall + 4
                    implicitHeight: Theme.fontSizeSmall + 4
                
                    Modules.PhosphorIcon {
                        anchors.centerIn: parent
                        implicitWidth: Theme.fontSizeSmall
                        implicitHeight: Theme.fontSizeSmall
                        icon: "gear-six.svg"
                        color: Theme.foregroundMuted
                    }
                
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsProcess.running = true
                    }
                }
            }

            DeviceRow {
                Layout.fillWidth: true
                node: Services.PipewireService.defaultSink
                isDefault: true
                onVolumeChanged: value => Services.PipewireService.setVolume(Services.PipewireService.defaultSink, value)
                onMuteToggled: Services.PipewireService.setMuted(Services.PipewireService.defaultSink, !Services.PipewireService.defaultSink.audio.muted)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 2
                height: 1
                color: Theme.border
            }

            Text {
                text: "INPUT"
                color: Theme.foregroundMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall - 1
                font.letterSpacing: 1
            }

            DeviceRow {
                Layout.fillWidth: true
                node: Services.PipewireService.defaultSource
                isDefault: true
                iconOn: "microphone.svg"
                iconOff: "microphone-slash.svg"
                onVolumeChanged: value => Services.PipewireService.setVolume(Services.PipewireService.defaultSource, value)
                onMuteToggled: Services.PipewireService.setMuted(Services.PipewireService.defaultSource, !Services.PipewireService.defaultSource.audio.muted)
            }
        }
    }

    Process {
        id: settingsProcess
        command: ["kcmshell6", "kcm_pulseaudio"]
    }
}