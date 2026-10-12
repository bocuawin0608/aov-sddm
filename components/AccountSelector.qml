import QtQuick
import QtQuick.Controls

Item {
    id: accountSelectorRoot

    property var persistenceRef: null
    property string activeUsername: ""

    signal userChosen(string username)
    signal manualEntryRequested()
    signal closeRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.65)
        opacity: accountSelectorRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: accountSelectorRoot.closeRequested()
        }
    }

    // Modal Card
    Rectangle {
        id: card
        width: Math.min(440, parent.width * 0.92)
        height: Math.min(500, parent.height * 0.85)
        anchors.centerIn: parent
        radius: 12
        color: styles.surfaceCard
        border.width: 1.5
        border.color: styles.borderCyan
        clip: true

        scale: accountSelectorRoot.visible ? 1.0 : 0.92
        opacity: accountSelectorRoot.visible ? 1.0 : 0.0
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
                    source: "assets/icons/user.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CHỌN TÀI KHOẢN ĐĂNG NHẬP"
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
                    onClicked: accountSelectorRoot.closeRequested()
                }
            }
        }

        // Section: Saved / Recent Accounts
        Column {
            id: contentCol
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            spacing: 12

            Text {
                text: "Tài khoản đã lưu gần đây:"
                font.pixelSize: 12
                font.bold: true
                color: styles.textGold
                visible: savedList.count > 0
            }

            ListView {
                id: savedList
                width: parent.width
                height: Math.min(130, contentHeight)
                clip: true
                spacing: 6
                model: (accountSelectorRoot.persistenceRef && accountSelectorRoot.persistenceRef.savedUsers) ? accountSelectorRoot.persistenceRef.savedUsers : []
                visible: count > 0

                delegate: Rectangle {
                    id: savedItemRect
                    width: savedList.width
                    height: 42
                    radius: 7
                    color: itemMouse.containsMouse ? Qt.rgba(0.18, 0.32, 0.60, 0.6) : Qt.rgba(0.10, 0.16, 0.30, 0.5)
                    border.width: 1.0
                    border.color: modelData === accountSelectorRoot.activeUsername ? styles.borderCyan : styles.borderGlass

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Image {
                            width: 20
                            height: 20
                            source: "assets/icons/user.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData
                            font.pixelSize: 13
                            font.bold: true
                            color: modelData === accountSelectorRoot.activeUsername ? "#38bdf8" : "#f8fafc"
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 70
                            elide: Text.ElideRight
                        }

                        // Remove / Forget button
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: trashArea.containsMouse ? Qt.rgba(0.8, 0.2, 0.2, 0.6) : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                source: "assets/icons/trash.svg"
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                id: trashArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (accountSelectorRoot.persistenceRef) {
                                        accountSelectorRoot.persistenceRef.removeUser(modelData);
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.rightMargin: 35 // Leave trash button accessible
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            accountSelectorRoot.userChosen(modelData);
                            accountSelectorRoot.closeRequested();
                        }
                    }
                }
            }

            // Section: All System Users
            Text {
                text: "Tất cả người dùng hệ thống:"
                font.pixelSize: 12
                font.bold: true
                color: "#94a3b8"
            }

            ListView {
                id: systemUserList
                width: parent.width
                height: Math.max(100, contentCol.height - y - 60)
                clip: true
                spacing: 6
                model: (typeof userModel !== "undefined") ? userModel : null

                delegate: Rectangle {
                    width: systemUserList.width
                    height: 42
                    radius: 7
                    color: sysMouse.containsMouse ? Qt.rgba(0.18, 0.32, 0.60, 0.6) : Qt.rgba(0.08, 0.12, 0.24, 0.5)
                    border.width: 1.0
                    border.color: model.name === accountSelectorRoot.activeUsername ? styles.borderCyan : styles.borderGlass

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Image {
                            width: 20
                            height: 20
                            source: (model.icon && model.icon !== "") ? model.icon : "assets/icons/user.svg"
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (model.realName && model.realName !== "") ? (model.realName + " (" + model.name + ")") : (model.name || "User " + index)
                            font.pixelSize: 13
                            font.bold: true
                            color: model.name === accountSelectorRoot.activeUsername ? "#38bdf8" : "#f1f5f9"
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 40
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: sysMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            accountSelectorRoot.userChosen(model.name);
                            accountSelectorRoot.closeRequested();
                        }
                    }
                }
            }

            // Manual entry button
            Rectangle {
                width: parent.width
                height: 38
                radius: 7
                color: manualMouse.containsMouse ? Qt.rgba(0.20, 0.35, 0.70, 0.7) : Qt.rgba(0.12, 0.20, 0.40, 0.5)
                border.width: 1.0
                border.color: styles.borderCyan

                Text {
                    anchors.centerIn: parent
                    text: "+ Nhập tên tài khoản khác..."
                    font.bold: true
                    font.pixelSize: 12
                    color: "#e2e8f0"
                }

                MouseArea {
                    id: manualMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        accountSelectorRoot.manualEntryRequested();
                        accountSelectorRoot.closeRequested();
                    }
                }
            }
        }
    }

    Keys.onEscapePressed: accountSelectorRoot.closeRequested()
}
