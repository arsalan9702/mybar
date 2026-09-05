import QtQuick
import QtQuick.Controls
import qs
import qs.services as Services
import qs.popups as Popups

Slider {
    id: control
    implicitHeight: 16

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.sliderTrack

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.sliderFill

            Behavior on width {
                enabled: !control.pressed
                NumberAnimation { duration: Theme.animationFast }
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.pressed ? 14 : 12
        height: width
        radius: width / 2
        color: Theme.foreground
        border.color: Theme.sliderFill
        border.width: 2

        Behavior on width {
            NumberAnimation { duration: Theme.animationFast }
        }
    }
}