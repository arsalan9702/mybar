import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.modules as Modules

PopupWindow {
    id: popup
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    visible: false
    grabFocus: true
    color: "transparent"

    // The month currently being viewed (day is always reset to 1st)
    property date viewDate: new Date()

    readonly property date today: new Date()
    readonly property int viewYear: viewDate.getFullYear()
    readonly property int viewMonth: viewDate.getMonth()

    // Build a flat 42-cell grid (6 weeks) for the viewed month,
    // including leading/trailing days from adjacent months.
    readonly property var gridDays: {
        const firstOfMonth = new Date(viewYear, viewMonth, 1);
        const startOffset = firstOfMonth.getDay(); // 0 = Sunday
        const daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
        const cells = [];
        for (let i = 0; i < 42; i++) {
            const dayNum = i - startOffset + 1;
            const cellDate = new Date(viewYear, viewMonth, dayNum);
            cells.push({
                day: cellDate.getDate(),
                inCurrentMonth: cellDate.getMonth() === viewMonth,
                isToday: cellDate.toDateString() === today.toDateString()
            });
        }
        return cells;
    }

    function prevMonth() {
        viewDate = new Date(viewYear, viewMonth - 1, 1);
    }
    function nextMonth() {
        viewDate = new Date(viewYear, viewMonth + 1, 1);
    }

    onVisibleChanged: {
        if (visible) viewDate = new Date(); // reset to current month each time it's opened
    }

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

                Item {
                    implicitWidth: Theme.fontSizeSmall + 4
                    implicitHeight: Theme.fontSizeSmall + 4
                    Modules.PhosphorIcon {
                        anchors.centerIn: parent
                        implicitWidth: Theme.fontSizeSmall
                        implicitHeight: Theme.fontSizeSmall
                        icon: "caret-left.svg"
                        color: Theme.foreground
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.prevMonth()
                    }
                }

                Text {
                    text: Qt.formatDate(popup.viewDate, "MMMM yyyy")
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Item {
                    implicitWidth: Theme.fontSizeSmall + 4
                    implicitHeight: Theme.fontSizeSmall + 4
                    Modules.PhosphorIcon {
                        anchors.centerIn: parent
                        implicitWidth: Theme.fontSizeSmall
                        implicitHeight: Theme.fontSizeSmall
                        icon: "caret-right.svg"
                        color: Theme.foreground
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.nextMonth()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            // Day-of-week header
            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                Repeater {
                    model: ["S", "M", "T", "W", "T", "F", "S"]
                    delegate: Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.foregroundMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            // 6x7 day grid
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                Repeater {
                    model: popup.gridDays
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        radius: Theme.radius
                        color: modelData.isToday ? Theme.accent : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.day
                            color: {
                                if (modelData.isToday) return Theme.background;
                                if (!modelData.inCurrentMonth) return Theme.foregroundMuted;
                                return Theme.foreground;
                            }
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
            }
        }
    }
}