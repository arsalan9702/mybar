import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs
import qs.services as Services
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
                spacing: Theme.spacing

                Text {
                    text: "BATTERY"
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

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing

                Text {
                    text: Math.round(Services.BatteryService.percentage * 100) + "%"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    Layout.fillWidth: true
                }

                Text {
                    text: {
                        if (Services.BatteryService.charging) {
                            const t = Services.BatteryService.formatTime(Services.BatteryService.timeToFull);
                            return t ? t + " until full" : "";
                        }
                        const t = Services.BatteryService.formatTime(Services.BatteryService.timeToEmpty);
                        return t ? t + " remaining" : "";
                    }
                    color: Theme.foregroundMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }


            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: Theme.radius
                color: Theme.hoverBackground
                clip: true
            
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
            
                    Repeater {
                        model: [
                            { label: "Efficient", profile: PowerProfile.PowerSaver },
                            { label: "Balanced", profile: PowerProfile.Balanced },
                            { label: "Power", profile: PowerProfile.Performance }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            readonly property bool active: Services.BatteryService.currentProfile === modelData.profile
                            readonly property bool disabled: modelData.profile === PowerProfile.Performance && !Services.BatteryService.hasPerformanceProfile
                            color: active ? Theme.accent : "transparent"
                            opacity: disabled ? 0.4 : 1
            
                            Behavior on color {
                                ColorAnimation { duration: Theme.animationFast }
                            }
            
                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: parent.active ? Theme.background : Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
            
                            MouseArea {
                                anchors.fill: parent
                                enabled: !parent.disabled
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Services.BatteryService.setProfile(modelData.profile)
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: settingsProcess
        command: ["kcmshell6", "kcm_powerdevilprofilesconfig"]
    }
}