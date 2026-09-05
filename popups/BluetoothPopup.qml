import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services as Services
import qs.modules as Modules

import Quickshell.Wayland

PopupWindow {
    id: popup
    implicitWidth: Theme.popupWidth
    implicitHeight: Theme.padding * 2 + 24 + Theme.spacing + 1 + Theme.spacing + (6 * 32) + Theme.spacing
    visible: false
    grabFocus: true
    color: "transparent"

    BackgroundEffect.blurRegion: Region {
        item: background
        radius: Theme.popupRadius
    }
    
    function deviceIcon(device) {
        if (device.icon.includes("audio") || device.icon.includes("headset") || device.icon.includes("headphone")) return "headset.svg";
        if (device.icon.includes("mouse")) return "mouse-simple.svg";
        return "bluetooth.svg";
    }

    Rectangle {
        id: background
        anchors.top: parent.top
        anchors.left: parent.left
        implicitWidth: Theme.popupWidth
        implicitHeight: contentColumn.implicitHeight + Theme.padding * 2
        color: Theme.glassBackground
        border.color: Theme.glassBorder
        radius: Theme.popupRadius
        border.width: 1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.glassHighlight }
                GradientStop { position: 0.35; color: "transparent" }
            }
        }
        
        Behavior on implicitHeight {
            NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutQuad }
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Theme.padding
            spacing: Theme.spacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing

                Text {
                    text: "BLUETOOTH"
                    color: Theme.foregroundMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall - 1
                    font.letterSpacing: 1
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 18
                    radius: 9
                    color: Services.BluetoothService.adapterEnabled ? Theme.accent : Theme.border

                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.foreground
                        y: 2
                        x: Services.BluetoothService.adapterEnabled ? parent.width - width - 2 : 2
                        Behavior on x {
                            NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutQuad }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.BluetoothService.setAdapterEnabled(!Services.BluetoothService.adapterEnabled)
                    }
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

            Item {
                Layout.fillWidth: true
                implicitHeight: Services.BluetoothService.adapterEnabled ? deviceSection.implicitHeight : 0
                clip: true
                opacity: Services.BluetoothService.adapterEnabled ? 1 : 0

                Behavior on implicitHeight {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutQuad }
                }
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animationNormal }
                }

                ColumnLayout {
                    id: deviceSection
                    width: parent.width
                    spacing: Theme.spacing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        height: 1
                        color: Theme.border
                    }

                    Text {
                        visible: Services.BluetoothService.allDevices.length === 0
                        text: "No devices found"
                        color: Theme.foregroundMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    ListView {
                        id: deviceList
                        visible: Services.BluetoothService.allDevices.length > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(model.length, 6) * 32
                        clip: true
                        spacing: 2
                        model: Services.BluetoothService.allDevices

                        delegate: RowLayout {
                            width: deviceList.width
                            height: 30
                            spacing: Theme.spacing

                            Modules.PhosphorIcon {
                                Layout.preferredWidth: Theme.fontSizeSmall
                                Layout.preferredHeight: Theme.fontSizeSmall
                                icon: popup.deviceIcon(modelData)
                                color: modelData.connected ? Theme.accent : Theme.foregroundMuted
                            }

                            Text {
                                text: modelData.name
                                color: modelData.connected ? Theme.foreground : Theme.foregroundMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                                Layout.fillWidth: true

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.connected) {
                                            Services.BluetoothService.disconnectDevice(modelData);
                                        } else {
                                            Services.BluetoothService.connectDevice(modelData);
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: modelData.batteryAvailable
                                text: Math.round(modelData.battery * 100) + "%"
                                color: Theme.foregroundMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: settingsProcess
        command: ["kcmshell6", "kcm_bluetooth"]
    }
}