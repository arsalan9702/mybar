import QtQuick
import QtQuick.Effects
import qs

Item {
    id: root
    implicitWidth: Theme.iconSize
    implicitHeight: Theme.iconSize

    property string icon: ""
    property color color: Theme.foreground

    Image {
        id: img
        anchors.fill: parent
        source: root.icon ? Qt.resolvedUrl("../assets/icons/" + root.icon) : ""
        sourceSize.width: Theme.iconSize
        sourceSize.height: Theme.iconSize

        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: root.color
        }
    }
}