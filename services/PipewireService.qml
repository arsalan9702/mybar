pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNode defaultSource: Pipewire.defaultAudioSource

    readonly property real defaultVolume: defaultSink?.audio?.volume ?? 0
    readonly property bool defaultMuted: defaultSink?.audio?.muted ?? false

    function setVolume(node, value) {
        if (node?.ready && node?.audio) {
            node.audio.volume = value;
        }
    }

    function setMuted(node, muted) {
        if (node?.ready && node?.audio) {
            node.audio.muted = muted;
        }
    }

    PwObjectTracker {
        objects: [defaultSink, defaultSource].filter(n => n !== null)
    }
}