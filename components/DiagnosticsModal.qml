import QtQuick
import QtQuick.Controls

Item {
    id: diagRoot

    property var persistenceRef: null
    signal closeRequested()
    signal reloadRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.65)
        opacity: diagRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: diagRoot.closeRequested()
        }
    }

    Rectangle {
        id: card
        width: Math.min(460, parent.width * 0.92)
        height: Math.min(480, parent.height * 0.85)
        anchors.centerIn: parent
        radius: 12
        color: styles.surfaceCard
        border.width: 1.5
        border.color: styles.borderCyan
        clip: true

        scale: diagRoot.visible ? 1.0 : 0.92
        opacity: diagRoot.visible ? 1.0 : 0.0
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
                    source: "assets/icons/repair.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "SỬA NHANH & THÔNG TIN CHẨN ĐOÁN"
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
                    onClicked: diagRoot.closeRequested()
                }
            }
        }

        Column {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Thông tin môi trường hiển thị:"
                font.pixelSize: 12
                font.bold: true
                color: styles.textGold
            }

            // Diagnostic Info Rows
            Rectangle {
                width: parent.width
                height: infoCol.height + 16
                radius: 8
                color: Qt.rgba(0.06, 0.10, 0.22, 0.6)
                border.width: 1.0
                border.color: styles.borderGlass

                Column {
                    id: infoCol
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 10
                    spacing: 6

                    Text {
                        text: "• Độ phân giải màn hình: " + Screen.width + " x " + Screen.height + " (Device Ratio: " + Screen.devicePixelRatio + ")"
                        font.pixelSize: 12
                        color: "#e2e8f0"
                    }
                    Text {
                        text: "• Môi trường đồ họa: SDDM Qt6 Greeter (" + (Screen.width > 1920 ? "HiDPI / Ultrawide" : "Standard Resolution") + ")"
                        font.pixelSize: 12
                        color: "#e2e8f0"
                    }
                    Text {
                        text: "• Số phiên tìm thấy: " + (typeof sessionModel !== "undefined" ? sessionModel.count : 0) + " phiên (Wayland / X11)"
                        font.pixelSize: 12
                        color: "#e2e8f0"
                    }
                    Text {
                        text: "• Người dùng hệ thống: " + (typeof userModel !== "undefined" ? userModel.count : 0) + " tài khoản"
                        font.pixelSize: 12
                        color: "#e2e8f0"
                    }
                    Text {
                        text: "• Phiên bản chủ đề: Arena of Valor (Liên Quân) SDDM v1.0.0"
                        font.pixelSize: 12
                        color: "#38bdf8"
                    }
                }
            }

            Text {
                text: "Thao tác an toàn:"
                font.pixelSize: 12
                font.bold: true
                color: styles.textGold
            }

            // Safe action 1: Reload UI
            Rectangle {
                width: parent.width
                height: 40
                radius: 7
                color: reloadMouse.containsMouse ? Qt.rgba(0.20, 0.40, 0.80, 0.6) : Qt.rgba(0.12, 0.18, 0.35, 0.5)
                border.width: 1.0
                border.color: styles.borderCyan

                Text {
                    anchors.centerIn: parent
                    text: "↻ Làm mới trạng thái giao diện (Reload Greeter State)"
                    font.bold: true
                    font.pixelSize: 12
                    color: "#ffffff"
                }

                MouseArea {
                    id: reloadMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        diagRoot.reloadRequested();
                        diagRoot.closeRequested();
                    }
                }
            }

            // Safe action 2: Clear Saved Accounts
            Rectangle {
                width: parent.width
                height: 40
                radius: 7
                color: clearMouse.containsMouse ? Qt.rgba(0.60, 0.18, 0.18, 0.6) : Qt.rgba(0.18, 0.12, 0.20, 0.5)
                border.width: 1.0
                border.color: "#f87171"

                Text {
                    anchors.centerIn: parent
                    text: "🗑 Xóa bộ nhớ đệm tài khoản đã lưu (Reset Saved Accounts)"
                    font.bold: true
                    font.pixelSize: 12
                    color: "#fca5a5"
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (diagRoot.persistenceRef) {
                            diagRoot.persistenceRef.clearAll();
                        }
                        diagRoot.closeRequested();
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: diagRoot.closeRequested()
}

