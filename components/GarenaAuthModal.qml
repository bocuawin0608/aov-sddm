import QtQuick
import QtQuick.Controls

Item {
    id: garenaModalRoot

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
        opacity: garenaModalRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: garenaModalRoot.closeRequested()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(460, parent.width * 0.92)
        height: Math.min(520, parent.height * 0.88)
        anchors.centerIn: parent
        radius: 14
        color: Qt.rgba(0.10, 0.08, 0.14, 0.96)
        border.width: 1.5
        border.color: "#f59e0b"
        clip: true

        scale: garenaModalRoot.visible ? 1.0 : 0.92
        opacity: garenaModalRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 56
            color: Qt.rgba(0.18, 0.08, 0.08, 0.98)
            border.width: 0.8
            border.color: Qt.rgba(0.9, 0.4, 0.1, 0.3)

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Image {
                    width: 24
                    height: 24
                    source: "assets/icons/garena.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "ĐĂNG NHẬP GARENA"
                        font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#fbbf24"
                    }
                    Text {
                        text: "Tài khoản tiêu chuẩn (Chỉ dùng lệnh cơ bản, không có sudo)"
                        font.pixelSize: 10
                        color: "#cbd5e1"
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
                    onClicked: garenaModalRoot.closeRequested()
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
                    color: Qt.rgba(0.35, 0.15, 0.08, 0.4)
                    border.width: 1.0
                    border.color: Qt.rgba(0.9, 0.5, 0.1, 0.4)

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        Image {
                            width: 16
                            height: 16
                            source: "assets/icons/user.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Tài khoản tiêu chuẩn có thể đăng nhập và sử dụng các lệnh cơ bản trong phiên người dùng. Không được phép chạy sudo và không thể can thiệp hệ thống."
                            font.pixelSize: 10
                            color: "#fed7aa"
                            wrapMode: Text.WordWrap
                            width: parent.width - 32
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Text {
                    text: "Tài khoản người dùng tiêu chuẩn:"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8fafc"
                }

                // Standard Users List (users who are NOT sudo)
                ListView {
                    id: standardListView
                    width: parent.width
                    height: Math.min(150, Math.max(48, contentHeight))
                    clip: true
                    spacing: 6
                    model: (typeof userModel !== "undefined") ? userModel : null

                    delegate: Item {
                        id: standardItemDelegate
                        readonly property bool isStandard: garenaModalRoot.persistenceRef ? !garenaModalRoot.persistenceRef.isSudoUser(model.name) : false
                        width: standardListView.width
                        height: isStandard ? 44 : 0
                        visible: isStandard

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: itemMouse.containsMouse ? Qt.rgba(0.45, 0.25, 0.10, 0.6) : Qt.rgba(0.20, 0.12, 0.10, 0.5)
                            border.width: 1.0
                            border.color: itemMouse.containsMouse ? "#fbbf24" : Qt.rgba(0.9, 0.5, 0.2, 0.3)

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.right: garenaSelectBtn.left
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                Image {
                                    width: 20
                                    height: 20
                                    source: "assets/icons/garena.svg"
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
                                        color: "#f8fafc"
                                    }
                                    Text {
                                        text: "Người dùng cơ bản (Không có sudo)"
                                        font.pixelSize: 9
                                        color: "#fdba74"
                                    }
                                }
                            }

                            Rectangle {
                                id: garenaSelectBtn
                                width: 76
                                height: 24
                                radius: 12
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                color: "#f59e0b"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Chọn"
                                    font.bold: true
                                    font.pixelSize: 11
                                    color: "#ffffff"
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    garenaModalRoot.userSelected(model.name);
                                    garenaModalRoot.closeRequested();
                                }
                            }
                        }
                    }
                }

                // Empty notice if no standard users found
                Text {
                    text: "(Hiện chưa có tài khoản tiêu chuẩn trên máy, bạn có thể tạo ngay bên dưới)"
                    font.pixelSize: 11
                    font.italic: true
                    color: "#94a3b8"
                    visible: standardListView.count === 0
                }

                // Section: Register new standard Account
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                Text {
                    text: "Đăng ký tài khoản tiêu chuẩn mới (Không sudo):"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8fafc"
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 7
                    color: Qt.rgba(0.06, 0.09, 0.18, 0.8)
                    border.width: newStandardInput.activeFocus ? 1.5 : 1.0
                    border.color: newStandardInput.activeFocus ? "#fbbf24" : Qt.rgba(1, 1, 1, 0.25)

                    TextInput {
                        id: newStandardInput
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
                            text: "Nhập tên tài khoản tiêu chuẩn mới (vd: player)..."
                            font.pixelSize: 12
                            color: "#64748b"
                            visible: !parent.text && !parent.activeFocus
                        }
                    }
                }

                // Register Button
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 7
                    color: regMouse.containsMouse ? "#d97706" : "#f59e0b"

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            width: 16
                            height: 16
                            source: "assets/icons/garena.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Đăng ký tài khoản Garena"
                            font.bold: true
                            font.pixelSize: 12
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: regMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var u = newStandardInput.text.trim();
                            if (u && garenaModalRoot.persistenceRef) {
                                if (garenaModalRoot.persistenceRef.registerUser(u, "standard")) {
                                    garenaModalRoot.userSelected(u);
                                    garenaModalRoot.closeRequested();
                                    newStandardInput.text = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: garenaModalRoot.closeRequested()
}
