import QtQuick
import QtQuick.Layouts
import qs
import qs.modules as Modules

ColumnLayout {
    id: row
    spacing: 3

    property var node
    property bool isDefault: false
    property string iconOn: "speaker-high.svg"
    property string iconOff: "speaker-x.svg"

    signal setDefault()
    signal volumeChanged(real value)
    signal muteToggled()

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing
    
        Rectangle {
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            radius: 3
            color: row.isDefault ? Theme.accent : "transparent"
            border.color: row.isDefault ? Theme.accent : Theme.foregroundMuted
            border.width: 1
        }
    
        Text {
            text: row.node?.description ?? row.node?.name ?? "Unknown"
            color: row.isDefault ? Theme.foreground : Theme.foregroundMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideRight
            Layout.fillWidth: true
    
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.setDefault()
            }
        }
    
        Text {
            text: Math.round((row.node?.audio?.volume ?? 0) * 100) + "%"
            color: Theme.foregroundMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }
    
        Item {
            implicitWidth: Theme.fontSizeSmall + 4
            implicitHeight: Theme.fontSizeSmall + 4
    
            Modules.PhosphorIcon {
                anchors.centerIn: parent
                implicitWidth: Theme.fontSizeSmall
                implicitHeight: Theme.fontSizeSmall
                icon: row.node?.audio?.muted ? row.iconOff : row.iconOn
                color: row.node?.audio?.muted ? Theme.batteryCritical : Theme.foreground
            }
    
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.muteToggled()
            }
        }
    }

    StyledSlider {
        Layout.fillWidth: true
        from: 0
        to: 1
        value: row.node?.audio?.volume ?? 0
        onMoved: row.volumeChanged(value)
    }
}