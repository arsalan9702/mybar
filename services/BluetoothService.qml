pragma Singleton
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool adapterEnabled: adapter?.enabled ?? false

    readonly property var allDevices: adapter ? adapter.devices.values : []
    readonly property var connectedDevices: allDevices.filter(d => d.connected)

    // Priority: audio devices matter more visually than input devices when
    // multiple things are connected at once (e.g. mouse + earbuds together).
    readonly property BluetoothDevice primaryConnectedDevice: {
        const audio = connectedDevices.find(d => d.icon.includes("audio") || d.icon.includes("headset") || d.icon.includes("headphone"));
        if (audio) return audio;
        return connectedDevices.length > 0 ? connectedDevices[0] : null;
    }

    function setAdapterEnabled(enabled) {
        if (adapter) adapter.enabled = enabled;
    }

    function setDiscovering(enabled) {
        if (adapter) adapter.discoverable = enabled;
    }

    function connectDevice(device) {
        device.connected = true;
    }

    function disconnectDevice(device) {
        device.connected = false;
    }

    function forgetDevice(device) {
        device.forget();
    }
}