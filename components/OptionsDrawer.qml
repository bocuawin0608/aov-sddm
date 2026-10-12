import QtQuick
import QtQuick.Controls

Item {
    id: drawerRoot

    signal sessionSelectorRequested()
    signal closeRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.65)
        opacity: drawerRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: drawerRoot.closeRequested()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(380, parent.width * 0.9)
        height: Math.min(420, parent.height * 0.8)
        anchors.centerIn: parent
        radius: 12
        color: styles.surfaceCard
        border.width: 1.5
        border.color: styles.borderCyan
        clip: true

        scale: drawerRoot.visible ? 1.0 : 0.92
        opacity: drawerRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header
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
                    text: "TÙY CHỌN HỆ THỐNG & NGUỒN"
                    font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#f8fafc"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

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
                    onClicked: drawerRoot.closeRequested()
                }
            }
        }

        Column {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 14

            // 1. Session Selector Quick Action
            Rectangle {
                width: parent.width
                height: 48
                radius: 8
                color: sessMouse.containsMouse ? Qt.rgba(0.20, 0.35, 0.70, 0.6) : Qt.rgba(0.10, 0.16, 0.32, 0.5)
                border.width: 1.0
                border.color: styles.borderCyan

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    Image {
                        width: 22
                        height: 22
                        source: "assets/icons/session_generic.svg"
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            text: "Đổi môi trường đồ họa"
                            font.bold: true
                            font.pixelSize: 13
                            color: "#f8fafc"
                        }
                        Text {
                            text: "Hyprland, KDE Plasma, GNOME, etc."
                            font.pixelSize: 10
                            color: "#94a3b8"
                        }
                    }
                }

                MouseArea {
                    id: sessMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        drawerRoot.sessionSelectorRequested();
                        drawerRoot.closeRequested();
                    }
                }
            }

            // Power Actions Title
            Text {
                text: "Tùy chọn nguồn hệ thống:"
                font.pixelSize: 12
                font.bold: true
                color: styles.textGold
            }

            // Power Buttons Grid
            Grid {
                width: parent.width
                columns: 2
                spacing: 10

                // Shutdown
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 52
                    radius: 8
                    color: shutMouse.containsMouse ? Qt.rgba(0.40, 0.12, 0.12, 0.7) : Qt.rgba(0.12, 0.16, 0.28, 0.6)
                    border.width: 1.0
                    border.color: shutMouse.containsMouse ? "#ef4444" : styles.borderGlass
                    visible: typeof sddm === "undefined" || sddm.canPowerOff

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/power_shutdown.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: "Tắt máy"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#f87171"
                        }
                    }

                    MouseArea {
                        id: shutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm.canPowerOff) {
                                sddm.powerOff();
                            }
                        }
                    }
                }

                // Reboot
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 52
                    radius: 8
                    color: rebMouse.containsMouse ? Qt.rgba(0.35, 0.25, 0.10, 0.7) : Qt.rgba(0.12, 0.16, 0.28, 0.6)
                    border.width: 1.0
                    border.color: rebMouse.containsMouse ? "#f59e0b" : styles.borderGlass
                    visible: typeof sddm === "undefined" || sddm.canReboot

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/power_reboot.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: "Khởi động lại"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#fbbf24"
                        }
                    }

                    MouseArea {
                        id: rebMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm.canReboot) {
                                sddm.reboot();
                            }
                        }
                    }
                }

                // Suspend
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 52
                    radius: 8
                    color: suspMouse.containsMouse ? Qt.rgba(0.25, 0.15, 0.35, 0.7) : Qt.rgba(0.12, 0.16, 0.28, 0.6)
                    border.width: 1.0
                    border.color: suspMouse.containsMouse ? "#a855f7" : styles.borderGlass
                    visible: typeof sddm === "undefined" || sddm.canSuspend

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/power_suspend.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: "Ngủ tạm"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#c084fc"
                        }
                    }

                    MouseArea {
                        id: suspMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm.canSuspend) {
                                sddm.suspend();
                            }
                        }
                    }
                }

                // Hibernate
                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 52
                    radius: 8
                    color: hibMouse.containsMouse ? Qt.rgba(0.10, 0.25, 0.35, 0.7) : Qt.rgba(0.12, 0.16, 0.28, 0.6)
                    border.width: 1.0
                    border.color: hibMouse.containsMouse ? "#06b6d4" : styles.borderGlass
                    visible: typeof sddm === "undefined" || sddm.canHibernate

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/power_hibernate.svg"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: "Ngủ đông"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#38bdf8"
                        }
                    }

                    MouseArea {
                        id: hibMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sddm !== "undefined" && sddm.canHibernate) {
                                sddm.hibernate();
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: drawerRoot.closeRequested()
}

