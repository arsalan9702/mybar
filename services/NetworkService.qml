pragma Singleton
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property WifiDevice wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi) return device;
        }
        return null;
    }

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled

    readonly property WifiNetwork activeNetwork: {
        if (!wifiDevice) return null;
        for (const network of wifiDevice.networks.values) {
            if (network.connected) return network;
        }
        return null;
    }

    readonly property bool connected: activeNetwork !== null
    readonly property string ssid: activeNetwork?.name ?? ""
    readonly property real signalStrength: activeNetwork?.signalStrength ?? 0
    readonly property var availableNetworks: wifiDevice ? wifiDevice.networks.values : []

    function setWifiEnabled(enabled) {
        Networking.wifiEnabled = enabled;
    }

    function setScanning(enabled) {
        if (wifiDevice) wifiDevice.scannerEnabled = enabled;
    }

    function connectToNetwork(network) {
        network.connect();
    }

    function disconnectNetwork(network) {
        network.disconnect();
    }

    function forgetNetwork(network) {
        network.forget();
    }
}