import QtQuick
import QtQuick.Controls

Item {
    id: appleModalRoot

    property var persistenceRef: null
    property var userModelRef: null

    signal userSelected(string username)
    signal closeRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.70)
        opacity: appleModalRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: appleModalRoot.closeRequested()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(460, parent.width * 0.92)
        height: Math.min(520, parent.height * 0.88)
        anchors.centerIn: parent
        radius: 14
        color: Qt.rgba(0.08, 0.10, 0.16, 0.96)
        border.width: 1.5
        border.color: "#e2e8f0"
        clip: true

        scale: appleModalRoot.visible ? 1.0 : 0.92
        opacity: appleModalRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56
            color: Qt.rgba(0.12, 0.15, 0.22, 0.98)
            border.width: 0.8
            border.color: Qt.rgba(1, 1, 1, 0.15)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Image {
                    width: 22
                    height: 22
                    source: "assets/icons/apple.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "ĐĂNG NHẬP APPLE"
                        font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#ffffff"
                    }
                    Text {
                        text: "Tài khoản có quyền sudo (pacman) trên hệ thống"
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
                    onClicked: appleModalRoot.closeRequested()
                }
            }
        }

        ScrollView {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            clip: true

            Column {
                width: card.width - 28
                spacing: 14

                // Info banner
                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 8
                    color: Qt.rgba(0.15, 0.22, 0.35, 0.5)
                    border.width: 1.0
                    border.color: Qt.rgba(0.5, 0.7, 1.0, 0.3)

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        Image {
                            width: 16
                            height: 16
                            source: "assets/icons/key.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Các tài khoản sau thuộc nhóm sudo/wheel. Cho phép chạy lệnh sudo pacman quản trị hệ thống."
                            font.pixelSize: 10
                            color: "#cbd5e1"
                            wrapMode: Text.WordWrap
                            width: parent.width - 32
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Text {
                    text: "Danh sách tài khoản sudo đã tìm thấy:"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8fafc"
                }

                // Sudo Users List
                ListView {
                    id: sudoListView
                    width: parent.width
                    height: Math.min(160, contentHeight)
                    clip: true
                    spacing: 6
                    model: (typeof userModel !== "undefined") ? userModel : null

                    delegate: Item {
                        id: sudoItemDelegate
                        readonly property bool isSudo: appleModalRoot.persistenceRef ? appleModalRoot.persistenceRef.isSudoUser(model.name) : true
                        width: sudoListView.width
                        height: isSudo ? 44 : 0
                        visible: isSudo

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: itemMouse.containsMouse ? Qt.rgba(0.22, 0.30, 0.45, 0.7) : Qt.rgba(0.12, 0.16, 0.26, 0.6)
                            border.width: 1.0
                            border.color: itemMouse.containsMouse ? "#ffffff" : Qt.rgba(1, 1, 1, 0.2)

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.right: appleSelectBtn.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                Image {
                                    width: 20
                                    height: 20
                                    source: "assets/icons/apple.svg"
                                    fillMode: Image.PreserveAspectFit
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1
                                    Text {
                                        text: model.name || ""
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: "#ffffff"
                                    }
                                    Text {
                                        text: "Quyền quản trị (sudo pacman)"
                                        font.pixelSize: 9
                                        color: "#94a3b8"
                                    }
                                }
                            }

                            Rectangle {
                                id: appleSelectBtn
                                width: 76
                                height: 24
                                radius: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                color: "#ffffff"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Chọn"
                                    font.bold: true
                                    font.pixelSize: 11
                                    color: "#0f172a"
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appleModalRoot.userSelected(model.name);
                                    appleModalRoot.closeRequested();
                                }
                            }
                        }
                    }
                }

                // Section: Register new Sudo Account
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                Text {
                    text: "Tạo tài khoản quản trị (sudo) mới:"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8fafc"
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 7
                    color: Qt.rgba(0.06, 0.09, 0.18, 0.8)
                    border.width: newSudoInput.activeFocus ? 1.5 : 1.0
                    border.color: newSudoInput.activeFocus ? "#ffffff" : Qt.rgba(1, 1, 1, 0.25)

                    TextInput {
                        id: newSudoInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        font.pixelSize: 13
                        font.bold: true
                        color: "#ffffff"
                        clip: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Nhập tên tài khoản quản trị mới..."
                            font.pixelSize: 12
                            color: "#64748b"
                            visible: !parent.text && !parent.activeFocus
                        }
                    }
                }

                // Create Button
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 7
                    color: createMouse.containsMouse ? "#f1f5f9" : "#ffffff"

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 16
                            height: 16
                            source: "assets/icons/apple.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Tạo tài khoản Sudo"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#0f172a"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: createMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var u = newSudoInput.text.trim();
                            if (u && appleModalRoot.persistenceRef) {
                                if (appleModalRoot.persistenceRef.registerUser(u, "sudo")) {
                                    appleModalRoot.userSelected(u);
                                    appleModalRoot.closeRequested();
                                    newSudoInput.text = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: appleModalRoot.closeRequested()
}
