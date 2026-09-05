//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
import Quickshell
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            property var modelData
            screen: modelData
        }
    }
}