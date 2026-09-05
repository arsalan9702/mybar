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
    // Fixed at the largest possible size (header + divider + up to 6 network rows).
    // Never resizes the actual window — only the Rectangle inside animates.
    implicitWidth: Theme.popupWidth
    implicitHeight: Theme.padding * 2 + 24 + Theme.spacing + 1 + Theme.spacing + (6 * 32) + Theme.spacing
    visible: false
    grabFocus: true
    color: "transparent"

    BackgroundEffect.blurRegion: Region {
        item: background
        radius: Theme.popupRadius
    }

    readonly property var sortedNetworks: {
        const nets = Services.NetworkService.wifiEnabled ? Services.NetworkService.availableNetworks : [];
        return [...nets].sort((a, b) => b.signalStrength - a.signalStrength);
    }

    Rectangle {
        id: background
        anchors.top: parent.top
        anchors.left: parent.left
        implicitWidth: Theme.popupWidth
        implicitHeight: contentColumn.implicitHeight + Theme.padding * 2
        radius: Theme.popupRadius
        color: Theme.glassBackground
        border.color: Theme.glassBorder
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
                    text: "WI-FI"
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
                    color: Services.NetworkService.wifiEnabled ? Theme.accent : Theme.border

                    Behavior on color {
                        ColorAnimation { duration: Theme.animationFast }
                    }

                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.foreground
                        y: 2
                        x: Services.NetworkService.wifiEnabled ? parent.width - width - 2 : 2
                        Behavior on x {
                            NumberAnimation { duration: Theme.animationFast; easing.type: Easing.OutQuad }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Services.NetworkService.setWifiEnabled(!Services.NetworkService.wifiEnabled)
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

            // Collapsible network-list section: height and opacity both
            // animate together, so toggling wifi shrinks/fades smoothly
            // instead of the popup snapping to a new size instantly.
            Item {
                Layout.fillWidth: true
                implicitHeight: Services.NetworkService.wifiEnabled ? networkSection.implicitHeight : 0
                clip: true
                opacity: Services.NetworkService.wifiEnabled ? 1 : 0

                Behavior on implicitHeight {
                    NumberAnimation { duration: Theme.animationNormal; easing.type: Easing.OutQuad }
                }
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animationNormal }
                }

                ColumnLayout {
                    id: networkSection
                    width: parent.width
                    spacing: Theme.spacing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        height: 1
                        color: Theme.border
                    }

                    Text {
                        visible: popup.sortedNetworks.length === 0
                        text: "Scanning..."
                        color: Theme.foregroundMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }

                    ListView {
                        id: networkList
                        visible: popup.sortedNetworks.length > 0
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(model.length, 6) * 32
                        clip: true
                        spacing: 2
                        model: popup.sortedNetworks

                        delegate: RowLayout {
                            width: networkList.width
                            height: 30
                            spacing: Theme.spacing

                            Item {
                                Layout.preferredWidth: Theme.fontSizeSmall
                                Layout.preferredHeight: Theme.fontSizeSmall

                                Modules.PhosphorIcon {
                                    anchors.fill: parent
                                    icon: "plugs-connected.svg"
                                    color: Theme.accent
                                    visible: modelData.connected
                                }
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
                                            Services.NetworkService.disconnectNetwork(modelData);
                                        } else {
                                            Services.NetworkService.connectToNetwork(modelData);
                                        }
                                    }
                                }
                            }

                            Text {
                                text: Math.round(modelData.signalStrength * 100) + "%"
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
        command: ["kcmshell6", "kcm_networkmanagement"]
    }
}