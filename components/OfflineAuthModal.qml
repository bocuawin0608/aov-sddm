import QtQuick
import QtQuick.Controls

Item {
    id: offlineModalRoot

    property var persistenceRef: null
    property var userModelRef: null

    signal offlineChosen(string username)
    signal closeRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.70)
        opacity: offlineModalRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: offlineModalRoot.closeRequested()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(460, parent.width * 0.92)
        height: Math.min(480, parent.height * 0.85)
        anchors.centerIn: parent
        radius: 14
        color: Qt.rgba(0.06, 0.10, 0.22, 0.96)
        border.width: 1.5
        border.color: "#38bdf8"
        clip: true

        scale: offlineModalRoot.visible ? 1.0 : 0.92
        opacity: offlineModalRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56
            color: Qt.rgba(0.08, 0.14, 0.32, 0.98)
            border.width: 0.8
            border.color: styles.borderGlass

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Image {
                    width: 24
                    height: 24
                    source: "assets/icons/game_5v5.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "5v5 OFFLINE (CHẾ ĐỘ NGOẠI TUYẾN)"
                        font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#38bdf8"
                    }
                    Text {
                        text: "Tài khoản tác vụ đơn giản • Xem YouTube cục bộ • Không Terminal"
                        font.pixelSize: 10
                        color: "#94a3b8"
                    }
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
                    onClicked: offlineModalRoot.closeRequested()
                }
            }
        }

        ScrollView {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 16
            clip: true

            Column {
                width: card.width - 32
                spacing: 14

                // Policy Cards
                Rectangle {
                    width: parent.width
                    height: 60
                    radius: 8
                    color: Qt.rgba(0.10, 0.18, 0.36, 0.5)
                    border.width: 1.0
                    border.color: styles.borderGlass

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            width: 22
                            height: 22
                            source: "assets/icons/game_5v5.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: "Quyền hạn tài khoản 5v5 Offline:"
                                font.bold: true
                                font.pixelSize: 12
                                color: "#f8fafc"
                            }
                            Text {
                                text: "• Chỉ mở trình phát xem YouTube / video nội bộ.\n• Không có quyền mở Terminal (vô hiệu hóa shell CLI).\n• Tuyệt đối không thể cài đặt phần mềm hay sửa file hệ thống."
                                font.pixelSize: 10
                                color: "#cbd5e1"
                            }
                        }
                    }
                }

                Text {
                    text: "Tài khoản khách ngoại tuyến được cấu hình:"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8fafc"
                }

                // Offline account chip
                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 8
                    color: offMouse.containsMouse ? Qt.rgba(0.18, 0.32, 0.65, 0.7) : Qt.rgba(0.10, 0.16, 0.32, 0.6)
                    border.width: 1.2
                    border.color: "#38bdf8"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: offSelectBtn.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/user.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text {
                                text: (typeof config !== "undefined" && config.offlineAccount) ? config.offlineAccount : "guest"
                                font.bold: true
                                font.pixelSize: 13
                                color: "#38bdf8"
                            }
                            Text {
                                text: "Tài khoản khách (Chỉ xem YouTube cục bộ, không terminal)"
                                font.pixelSize: 9
                                color: "#94a3b8"
                            }
                        }
                    }

                    Rectangle {
                        id: offSelectBtn
                        width: 80
                        height: 26
                        radius: 13
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        color: "#38bdf8"

                        Text {
                            anchors.centerIn: parent
                            text: "Đăng nhập"
                            font.bold: true
                            font.pixelSize: 11
                            color: "#0b0e26"
                        }
                    }

                    MouseArea {
                        id: offMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var u = (typeof config !== "undefined" && config.offlineAccount) ? config.offlineAccount : "guest";
                            if (offlineModalRoot.persistenceRef) {
                                offlineModalRoot.persistenceRef.registerUser(u, "offline");
                            }
                            offlineModalRoot.offlineChosen(u);
                            offlineModalRoot.closeRequested();
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: offlineModalRoot.closeRequested()
}
