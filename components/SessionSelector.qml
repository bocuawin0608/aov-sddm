import QtQuick
import QtQuick.Controls

Item {
    id: sessionSelectorRoot

    property int currentIndex: (typeof sessionModel !== "undefined" && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0

    Instantiator {
        id: sessInstantiator
        model: (typeof sessionModel !== "undefined") ? sessionModel : null
        delegate: QtObject {
            property string sessName: model.name || ""
        }
    }

    property string currentSessionName: {
        if (sessInstantiator.count > 0 && currentIndex >= 0 && currentIndex < sessInstantiator.count) {
            var obj = sessInstantiator.objectAt(currentIndex);
            if (obj && obj.sessName) return obj.sessName;
        }
        return "Hyprland";
    }

    signal sessionSelected(int index, string name)
    signal closeRequested()

    ThemeStyles { id: styles }

    function getSessionIcon(name) {
        if (!name) return "assets/icons/session_generic.svg";
        var lower = name.toLowerCase();
        if (lower.indexOf("hyprland") !== -1) return "assets/icons/session_hyprland.svg";
        if (lower.indexOf("plasma") !== -1) return "assets/icons/session_plasma.svg";
        if (lower.indexOf("wayland") !== -1 || lower.indexOf("niri") !== -1) return "assets/icons/session_wayland.svg";
        if (lower.indexOf("x11") !== -1 || lower.indexOf("openbox") !== -1 || lower.indexOf("lxqt") !== -1) return "assets/icons/session_x11.svg";
        return "assets/icons/session_generic.svg";
    }

    // Modal background overlay
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.65)
        opacity: sessionSelectorRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: sessionSelectorRoot.closeRequested()
        }
    }

    // Main Selection Dialog Card
    Rectangle {
        id: card
        width: Math.min(420, parent.width * 0.9)
        height: Math.min(460, parent.height * 0.8)
        anchors.centerIn: parent
        radius: 12
        color: styles.surfaceCard
        border.width: 1.5
        border.color: styles.borderCyan
        clip: true

        // Entrance animation
        scale: sessionSelectorRoot.visible ? 1.0 : 0.92
        opacity: sessionSelectorRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header bar
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52
            color: Qt.rgba(0.05, 0.09, 0.20, 0.95)
            border.width: 0.8
            border.color: styles.borderGlass

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Image {
                    width: 22
                    height: 22
                    source: "assets/icons/chevron_up.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CHỌN MÔI TRƯỜNG ĐỒ HỌA (SESSION)"
                    font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#f8fafc"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Close button
            Rectangle {
                width: 32
                height: 32
                radius: 16
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: closeArea.containsMouse ? Qt.rgba(0.9, 0.2, 0.2, 0.5) : "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: "assets/icons/close.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sessionSelectorRoot.closeRequested()
                }
            }
        }

        // Sessions List
        ListView {
            id: sessionList
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            clip: true
            spacing: 8
            model: (typeof sessionModel !== "undefined") ? sessionModel : null
            currentIndex: sessionSelectorRoot.currentIndex

            delegate: Rectangle {
                id: sessionItem
                width: sessionList.width
                height: 50
                radius: 8
                color: {
                    var isSelected = (index === sessionSelectorRoot.currentIndex);
                    if (itemMouse.pressed) return Qt.rgba(0.20, 0.40, 0.80, 0.6);
                    if (isSelected) return Qt.rgba(0.18, 0.38, 0.75, 0.45);
                    if (itemMouse.containsMouse) return Qt.rgba(0.14, 0.22, 0.40, 0.5);
                    return Qt.rgba(0.07, 0.11, 0.22, 0.4);
                }
                border.width: (index === sessionSelectorRoot.currentIndex || itemMouse.containsMouse) ? 1.5 : 0.8
                border.color: (index === sessionSelectorRoot.currentIndex) ? styles.borderCyan : (itemMouse.containsMouse ? "#60a5fa" : styles.borderGlass)

                // Item scale animation on hover
                scale: itemMouse.pressed ? 0.98 : (itemMouse.containsMouse ? 1.01 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Image {
                        width: 24
                        height: 24
                        source: sessionSelectorRoot.getSessionIcon(model.name)
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        width: parent.width - 80

                        Text {
                            text: model.name || "Session " + index
                            font.bold: true
                            font.pixelSize: 13
                            color: (index === sessionSelectorRoot.currentIndex) ? "#38bdf8" : "#f1f5f9"
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: (model.comment && model.comment !== "") ? model.comment : ((model.name && model.name.toLowerCase().indexOf("wayland") !== -1) ? "Wayland Desktop Session" : "Desktop Environment")
                            font.pixelSize: 10
                            color: "#94a3b8"
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    // Active checkmark badge
                    Image {
                        width: 18
                        height: 18
                        source: "assets/icons/check.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        visible: index === sessionSelectorRoot.currentIndex
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionSelectorRoot.currentIndex = index;
                        sessionSelectorRoot.sessionSelected(index, model.name);
                        sessionSelectorRoot.closeRequested();
                    }
                }
            }
        }
    }

    // Keyboard navigation
    Keys.onEscapePressed: sessionSelectorRoot.closeRequested()
    Keys.onUpPressed: {
        if (sessionList.currentIndex > 0) {
            sessionList.currentIndex--;
            sessionSelectorRoot.currentIndex = sessionList.currentIndex;
        }
    }
    Keys.onDownPressed: {
        if (sessionList.currentIndex < sessionList.count - 1) {
            sessionList.currentIndex++;
            sessionSelectorRoot.currentIndex = sessionList.currentIndex;
        }
    }
    Keys.onReturnPressed: {
        if (sessionList.currentIndex >= 0) {
            sessionSelectorRoot.sessionSelected(sessionList.currentIndex, sessionList.currentItem ? sessionList.currentItem.name : "");
            sessionSelectorRoot.closeRequested();
        }
    }
}
