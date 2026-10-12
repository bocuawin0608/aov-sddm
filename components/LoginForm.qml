import QtQuick
import QtQuick.Controls

Item {
    id: loginFormRoot

    property string username: ""
    property int sessionIndex: 0
    property string sessionName: "Hyprland"
    property bool authenticating: false
    property string errorMessage: ""
    property bool manualUsernameMode: false
    property bool virtualKeyboardRequested: false
    property alias passwordText: passwordField.text
    property alias passwordItem: passwordField

    signal submitLogin(string user, string pass, int sessIdx)

    ThemeStyles { id: styles }

    implicitWidth: 380
    implicitHeight: formCol.height + 28

    // Focus password input helper
    function focusPassword() {
        passwordField.forceActiveFocus();
        if (!virtualKeyboardRequested && typeof Qt !== "undefined" && Qt.inputMethod) {
            Qt.inputMethod.hide();
        }
    }

    function toggleVirtualKeyboard() {
        if (typeof Qt !== "undefined" && Qt.inputMethod) {
            virtualKeyboardRequested = !virtualKeyboardRequested;
            if (virtualKeyboardRequested) {
                Qt.inputMethod.show();
            } else {
                Qt.inputMethod.hide();
            }
        }
    }

    function clearPassword() {
        passwordField.text = "";
    }

    function showError(msg) {
        loginFormRoot.errorMessage = msg;
        shakeAnim.restart();
    }

    function clearError() {
        loginFormRoot.errorMessage = "";
    }

    // Glass panel container
    Rectangle {
        id: panelBg
        anchors.fill: parent
        radius: 12
        color: Qt.rgba(0.06, 0.09, 0.20, 0.88)
        border.width: 1.5
        border.color: loginFormRoot.errorMessage !== "" ? styles.textError : styles.borderCyan

        // Electric cyan top line glow
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.7
            height: 2
            color: loginFormRoot.errorMessage !== "" ? "#f87171" : "#38bdf8"
            opacity: 0.9
        }

        // Error shake animation
        SequentialAnimation {
            id: shakeAnim
            loops: 2
            NumberAnimation { target: loginFormRoot; property: "x"; to: loginFormRoot.x - 8; duration: 40; easing.type: Easing.InOutQuad }
            NumberAnimation { target: loginFormRoot; property: "x"; to: loginFormRoot.x + 8; duration: 40; easing.type: Easing.InOutQuad }
            NumberAnimation { target: loginFormRoot; property: "x"; to: loginFormRoot.x; duration: 40; easing.type: Easing.InOutQuad }
        }
    }

    Column {
        id: formCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 16
        spacing: 12

        // 1. Active User Header Row
        Rectangle {
            id: userRow
            width: parent.width
            height: 42
            radius: 8
            color: Qt.rgba(0.10, 0.16, 0.32, 0.7)
            border.width: 1.0
            border.color: styles.borderGlass
            visible: !loginFormRoot.manualUsernameMode

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
                    text: loginFormRoot.username !== "" ? loginFormRoot.username : "Chưa chọn tài khoản"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#f8fafc"
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                }

                Text {
                    text: "(Hiện tại)"
                    font.pixelSize: 10
                    color: "#94a3b8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Manual Username Input (if in manual entry mode)
        Rectangle {
            id: manualUserBox
            width: parent.width
            height: 42
            radius: 8
            color: Qt.rgba(0.08, 0.12, 0.24, 0.85)
            border.width: usernameInput.activeFocus ? 1.5 : 1.0
            border.color: usernameInput.activeFocus ? styles.borderCyan : styles.borderGlass
            visible: loginFormRoot.manualUsernameMode

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Image {
                    width: 18
                    height: 18
                    source: "assets/icons/user.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: usernameInput
                    width: parent.width - 60
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 13
                    font.bold: true
                    color: "#ffffff"
                    text: loginFormRoot.username
                    clip: true
                    onTextChanged: loginFormRoot.username = text.trim()
                    Keys.onReturnPressed: passwordField.forceActiveFocus()
                    Keys.onTabPressed: passwordField.forceActiveFocus()

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Tên tài khoản Linux..."
                        color: "#64748b"
                        font.pixelSize: 13
                        visible: !parent.text && !parent.activeFocus
                    }
                }

                Text {
                    text: "✓"
                    font.pixelSize: 12
                    color: "#38bdf8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // 2. Password Input Box
        Rectangle {
            id: passwordBox
            width: parent.width
            height: 44
            radius: 8
            color: Qt.rgba(0.07, 0.11, 0.24, 0.90)
            border.width: passwordField.activeFocus ? 1.8 : 1.0
            border.color: passwordField.activeFocus ? styles.borderCyan : styles.borderGlass

            Row {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8

                Image {
                    width: 18
                    height: 18
                    source: "assets/icons/key.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: passwordField
                    width: parent.width - (vkbToggle.visible ? 98 : 70)
                    height: parent.height
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: 14
                    color: "#ffffff"
                    echoMode: showPasswordToggle.showPassword ? TextInput.Normal : TextInput.Password
                    inputMethodHints: Qt.ImhHiddenText | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                    clip: true
                    enabled: !loginFormRoot.authenticating

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (typeof config !== "undefined" && config.textEnterPasswordPlaceholder) ? config.textEnterPasswordPlaceholder : "Nhập mật khẩu..."
                        color: "#64748b"
                        font.pixelSize: 13
                        visible: !parent.text && !parent.activeFocus
                    }

                    onAccepted: {
                        if (!loginFormRoot.username || loginFormRoot.username.trim() === "") {
                            loginFormRoot.showError("Tên tài khoản không được để trống!");
                            return;
                        }
                        if (!text || text === "") {
                            loginFormRoot.showError("Mật khẩu không được để trống!");
                            passwordField.forceActiveFocus();
                            return;
                        }
                        loginFormRoot.submitLogin(loginFormRoot.username.trim(), text, loginFormRoot.sessionIndex);
                    }
                }

                // Virtual Keyboard Toggle button (only shown when virtual keyboard subsystem exists)
                Item {
                    id: vkbToggle
                    visible: (typeof Qt !== "undefined" && Qt.inputMethod)
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: loginFormRoot.virtualKeyboardRequested ? 1.0 : (mouseVkb.containsMouse ? 0.9 : 0.55)

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: "assets/icons/keyboard.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        id: mouseVkb
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            loginFormRoot.toggleVirtualKeyboard();
                        }
                    }
                }

                // Password Show / Hide toggle button
                Item {
                    id: showPasswordToggle
                    property bool showPassword: false
                    width: 26
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        anchors.centerIn: parent
                        width: 17
                        height: 17
                        source: showPasswordToggle.showPassword ? "assets/icons/eye_off.svg" : "assets/icons/eye.svg"
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: showPasswordToggle.showPassword = !showPasswordToggle.showPassword
                    }
                }
            }
        }

        // 3. Caps Lock Warning
        Row {
            width: parent.width
            spacing: 6
            visible: typeof keyboard !== "undefined" && keyboard && keyboard.capsLock
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                width: 14
                height: 14
                source: "assets/icons/key.svg"
                fillMode: Image.PreserveAspectFit
            }
            Text {
                text: (typeof config !== "undefined" && config.textCapslockWarning) ? config.textCapslockWarning : "Caps Lock đang bật!"
                color: "#f59e0b"
                font.pixelSize: 11
                font.bold: true
            }
        }

        // 4. Authentication Error Banner
        Rectangle {
            id: errorBanner
            width: parent.width
            height: errorText.contentHeight + 12
            radius: 6
            color: Qt.rgba(0.8, 0.15, 0.15, 0.35)
            border.width: 1.0
            border.color: "#ef4444"
            visible: loginFormRoot.errorMessage !== ""

            Text {
                id: errorText
                anchors.centerIn: parent
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: loginFormRoot.errorMessage
                color: "#fca5a5"
                font.pixelSize: 11
                font.bold: true
            }
        }

        // 5. Authenticating Loading Spinner
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            visible: loginFormRoot.authenticating

            Rectangle {
                width: 16
                height: 16
                radius: 8
                color: "transparent"
                border.width: 2.0
                border.color: "#38bdf8"
                anchors.verticalCenter: parent.verticalCenter

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 900
                }
            }

            Text {
                text: (typeof config !== "undefined" && config.textAuthenticating) ? config.textAuthenticating : "Đang xác thực..."
                font.pixelSize: 12
                font.bold: true
                color: "#38bdf8"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // 6. Active Session Indicator (Display only - session switching is in Options Drawer)
        Rectangle {
            width: parent.width
            height: 28
            radius: 6
            color: Qt.rgba(0.06, 0.10, 0.20, 0.4)
            border.width: 0.8
            border.color: styles.borderGlass

            Row {
                anchors.centerIn: parent
                spacing: 6

                Image {
                    width: 14
                    height: 14
                    source: "assets/icons/session_generic.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Môi trường hiện tại: " + loginFormRoot.sessionName
                    font.pixelSize: 11
                    color: "#94a3b8"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
