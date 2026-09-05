pragma Singleton
import Quickshell

Singleton {
    id: root
    property var activePopup: null

    function requestOpen(popup) {
        if (root.activePopup && root.activePopup !== popup) {
            root.activePopup.visible = false;
        }
        root.activePopup = popup;
        popup.visible = true;
    }
}