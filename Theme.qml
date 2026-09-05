pragma Singleton
import QtQuick

QtObject {
    // Bar geometry
    readonly property int barHeight: 32
    readonly property int iconSize: 18
    readonly property int spacing: 8
    readonly property int padding: 6
    readonly property int radius: 6

    // Colors — base palette
    readonly property color background: "#000000"
    readonly property color foreground: "#ffffff"
    readonly property color foregroundMuted: "#9399b2"
    readonly property color hoverBackground: "#313244"
    readonly property color accent: "#89b4fa"

    // Battery status colors (thresholds consumed by BatteryButton, not defined here)
    readonly property color batteryCritical: "#f38ba8"   // <15%
    readonly property color batteryLow: "#f9e2af"          // <30%
    readonly property color batteryNormal: "#a6e3a1"       // >=30%
    readonly property color batteryCharging: "#89b4fa"

    // Typography
    readonly property string fontFamily: "Cascadia Mono NF"
    readonly property int fontSize: 25
    readonly property int fontSizeSmall: 16

    // Popup geometry
    readonly property int popupWidth: 320
    readonly property int popupRadius: 10
    readonly property int popupMargin: 8

    // Blur thingies
    readonly property color glassBackground: Qt.rgba(background.r, background.g, background.b, 0.45)
    readonly property color glassBorder: Qt.rgba(1, 1, 1, 0.06)
    readonly property color glassHighlight: Qt.rgba(1, 1, 1, 0.08)


    readonly property color border: "#45475a"
    readonly property color sliderTrack: "#45475a"
    readonly property color sliderFill: accent
    
    readonly property int animationFast: 100
    readonly property int animationNormal: 150
}