import QtQuick
import QtQuick.Controls
import "components"

Item {
    id: root

    width: (typeof config !== "undefined" && config.ScreenWidth) ? config.ScreenWidth : Screen.width
    height: (typeof config !== "undefined" && config.ScreenHeight) ? config.ScreenHeight : Screen.height

    // Custom Font Loader
    FontLoader {
        id: aovFont
        source: "assets/fonts/Orbitron-Bold.ttf"
    }

    ThemeStyles { id: styles }

    // Persistent storage component
    Persistence {
        id: persistence
        onAccountChanged: function(username) {
            if (loginForm.username !== username) {
                loginForm.username = username;
            }
        }
    }

    // Session model instantiator
    Instantiator {
        id: sessionInstantiator
        model: (typeof sessionModel !== "undefined") ? sessionModel : null
        delegate: QtObject {
            property string sName: model.name || ""
        }
    }

    // User model instantiator
    Instantiator {
        id: userInstantiator
        model: (typeof userModel !== "undefined") ? userModel : null
        delegate: QtObject {
            property string uName: model.name || ""
        }
    }

    // State properties
    property int currentSessionIndex: {
        if (persistence.lastSessionIndex >= 0 && typeof sessionModel !== "undefined" && persistence.lastSessionIndex < sessionModel.count) {
            return persistence.lastSessionIndex;
        }
        if (typeof sessionModel !== "undefined" && sessionModel.lastIndex !== undefined) {
            return sessionModel.lastIndex;
        }
        return 0;
    }

    property string currentSessionName: {
        if (sessionInstantiator.count > 0 && currentSessionIndex >= 0 && currentSessionIndex < sessionInstantiator.count) {
            var s = sessionInstantiator.objectAt(currentSessionIndex);
            if (s && s.sName) return s.sName;
        }
        return "Hyprland";
    }

    // Terms accepted state
    property bool termsAccepted: true

    // Background system (video / static with fallback and parallax)
    Background {
        id: bg
        anchors.fill: parent
    }

    // Top-Left Maintenance / Auxiliary / Age Rating Controls
    TopLeftControls {
        id: topLeftControls
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Math.max(20, parent.width * 0.035)
        anchors.topMargin: Math.max(20, parent.height * 0.04)
        z: 10

        onRepairClicked: diagnosticsModal.visible = true
        onAuxiliaryClicked: offlineAuthModal.visible = true
    }

    // Top-Right Liên Quân / Arena of Valor Logo
    BrandLogo {
        id: brandLogo
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Math.max(24, parent.width * 0.04)
        anchors.topMargin: Math.max(22, parent.height * 0.045)
        z: 10
    }

    // Bottom Login Section Container
    Item {
        id: bottomSection
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width * 0.95, 960)
        height: Math.max(260, parent.height * 0.38)
        z: 20

        // 1. Credentials Login Form (Password input & status)
        LoginForm {
            id: loginForm
            anchors.bottom: buttonsRow.top
            anchors.bottomMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            username: {
                if (persistence.lastUser !== "") return persistence.lastUser;
                if (typeof userModel !== "undefined" && userModel.lastUser && userModel.lastUser !== "") return userModel.lastUser;
                if (userInstantiator.count > 0) {
                    var u = userInstantiator.objectAt(0);
                    return (u && u.uName) ? u.uName : "";
                }
                return "";
            }
            sessionIndex: root.currentSessionIndex
            sessionName: root.currentSessionName

            onSubmitLogin: function(user, pass, sessIdx) {
                root.performLogin(user, pass, sessIdx);
            }
        }

        // 2. Horizontal Action Buttons (Exact visual match from screenshot)
        Row {
            id: buttonsRow
            anchors.bottom: termsRow.top
            anchors.bottomMargin: 26
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Math.max(12, parent.width * 0.018)

            // Calculate responsive button width
            readonly property int btnWidth: Math.min(235, Math.max(160, (bottomSection.width - 60 - spacing * 3) / 3))

            // Blue Button (Left) - "Tiếp tục với Facebook"
            ActionButton {
                id: blueBtn
                buttonType: "blue"
                width: buttonsRow.btnWidth
                text: "Tiếp tục với Facebook"
                subtitle: (typeof config !== "undefined" && config.textLastLoginSubtitle) ? config.textLastLoginSubtitle : "Lần đăng nhập cuối"
                iconSource: "assets/icons/facebook.svg"
                onClicked: {
                    loginForm.clearError();
                    if (!loginForm.username || loginForm.username.trim() === "") {
                        loginForm.showError("Tên tài khoản không được để trống!");
                        return;
                    }
                    if (!loginForm.passwordText || loginForm.passwordText === "") {
                        loginForm.showError("Mật khẩu không được để trống!");
                        loginForm.focusPassword();
                        return;
                    }
                    root.performLogin(loginForm.username.trim(), loginForm.passwordText, root.currentSessionIndex);
                }
            }

            // White Button (Center) - "Đăng nhập Apple"
            ActionButton {
                id: whiteBtn
                buttonType: "white"
                width: buttonsRow.btnWidth
                text: "Đăng nhập Apple"
                iconSource: "assets/icons/apple.svg"
                onClicked: {
                    appleAuthModal.visible = true;
                }
            }

            // Gold/Orange Button (Right) - "Đăng nhập Garena"
            ActionButton {
                id: goldBtn
                buttonType: "gold"
                width: buttonsRow.btnWidth
                text: "Đăng nhập Garena"
                iconSource: "assets/icons/garena.svg"
                onClicked: {
                    garenaAuthModal.visible = true;
                }
            }

            // Circular Options Button (Far Right) - Chevron Up
            ActionButton {
                id: circleBtn
                buttonType: "circle"
                iconSource: "assets/icons/chevron_up.svg"
                onClicked: {
                    optionsDrawer.visible = true;
                }
            }
        }

        // 3. Terms & Information Checkbox Row
        Row {
            id: termsRow
            anchors.bottom: footerText.top
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            visible: (typeof config === "undefined" || config.showTerms !== "false")

            // Checkbox
            Rectangle {
                id: termsCheckbox
                width: 17
                height: 17
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: root.termsAccepted ? Qt.rgba(0.12, 0.35, 0.75, 0.9) : Qt.rgba(0.08, 0.12, 0.24, 0.6)
                border.width: 1.5
                border.color: root.termsAccepted ? "#38bdf8" : "#64748b"

                Image {
                    anchors.centerIn: parent
                    width: 11
                    height: 11
                    source: "assets/icons/check.svg"
                    fillMode: Image.PreserveAspectFit
                    visible: root.termsAccepted
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.termsAccepted = !root.termsAccepted
                }
            }

            // Label + Underlined golden link
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: (typeof config !== "undefined" && config.termsText) ? config.termsText : "Tôi đã đọc kỹ và đồng ý "
                    font.pixelSize: 11
                    font.bold: false
                    color: "#cbd5e1"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: termsLink
                    text: (typeof config !== "undefined" && config.termsLinkText) ? config.termsLinkText : "Điều khoản"
                    font.pixelSize: 11
                    font.bold: true
                    color: linkMouse.containsMouse ? "#fef08a" : "#ffd040"
                    font.underline: true
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        id: linkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: termsModal.visible = true
                    }
                }
            }
        }

        // 4. Subtle Footer / Build Info
        Text {
            id: footerText
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            text: (typeof config !== "undefined" && config.versionText) ? config.versionText : "4078584025384049"
            font.pixelSize: 9
            color: Qt.rgba(0.55, 0.65, 0.85, 0.45)
        }
    }

    // MODALS & DRAWERS (z: 100)

    // Session Selector Modal
    SessionSelector {
        id: sessionSelector
        anchors.fill: parent
        visible: false
        z: 100
        currentIndex: root.currentSessionIndex
        onSessionSelected: function(index, name) {
            root.currentSessionIndex = index;
            persistence.saveSessionIndex(index);
        }
        onCloseRequested: visible = false
    }

    // Apple Auth Modal (Sudo Accounts)
    AppleAuthModal {
        id: appleAuthModal
        anchors.fill: parent
        visible: false
        z: 100
        persistenceRef: persistence
        onUserSelected: function(chosenUser) {
            loginForm.username = chosenUser;
            persistence.saveUser(chosenUser);
            loginForm.focusPassword();
        }
        onCloseRequested: visible = false
    }

    // Garena Auth Modal (Standard Accounts & Registration)
    GarenaAuthModal {
        id: garenaAuthModal
        anchors.fill: parent
        visible: false
        z: 100
        persistenceRef: persistence
        onUserSelected: function(chosenUser) {
            loginForm.username = chosenUser;
            persistence.saveUser(chosenUser);
            loginForm.focusPassword();
        }
        onCloseRequested: visible = false
    }

    // 5v5 Offline Modal (Restricted Accounts)
    OfflineAuthModal {
        id: offlineAuthModal
        anchors.fill: parent
        visible: false
        z: 100
        persistenceRef: persistence
        onOfflineChosen: function(chosenUser) {
            loginForm.username = chosenUser;
            persistence.saveUser(chosenUser);
            loginForm.focusPassword();
        }
        onCloseRequested: visible = false
    }

    // Options Drawer (Chevrons up button - Single authoritative Session Selector)
    OptionsDrawer {
        id: optionsDrawer
        anchors.fill: parent
        visible: false
        z: 100
        onSessionSelectorRequested: {
            sessionSelector.visible = true;
        }
        onCloseRequested: visible = false
    }

    // Diagnostics Modal ("Sửa nhanh")
    DiagnosticsModal {
        id: diagnosticsModal
        anchors.fill: parent
        visible: false
        z: 100
        persistenceRef: persistence
        onReloadRequested: {
            persistence.reload();
            loginForm.clearError();
            loginForm.clearPassword();
        }
        onCloseRequested: visible = false
    }

    // Terms Modal ("Điều khoản")
    TermsModal {
        id: termsModal
        anchors.fill: parent
        visible: false
        z: 100
        onCloseRequested: visible = false
    }

    // Core Login Authentication Function
    function performLogin(username, password, sessionIdx) {
        if (!username || username.trim() === "") {
            loginForm.showError("Tên tài khoản không được để trống!");
            return;
        }

        if (!password || password === "") {
            loginForm.showError("Mật khẩu không được để trống!");
            loginForm.focusPassword();
            return;
        }

        if (typeof config !== "undefined" && config.termsRequired === "true" && !root.termsAccepted) {
            loginForm.showError("Vui lòng tích chọn đồng ý điều khoản trước khi đăng nhập!");
            return;
        }

        loginForm.authenticating = true;
        loginForm.clearError();

        // Remember user across sessions
        persistence.saveUser(username.trim());
        persistence.saveSessionIndex(sessionIdx);

        // Submit to SDDM greeter
        if (typeof sddm !== "undefined" && typeof sddm.login === "function") {
            sddm.login(username.trim(), password, sessionIdx);
        } else {
            console.log("SDDM greeter test mode: sddm.login called with user:", username, "session:", sessionIdx);
            loginTimer.start();
        }
    }

    Timer {
        id: loginTimer
        interval: 1200
        repeat: false
        onTriggered: {
            if (typeof sddm === "undefined") {
                loginForm.authenticating = false;
                loginForm.showError("Chế độ thử nghiệm: Không có daemon SDDM chạy thực tế.");
            }
        }
    }

    // SDDM Greeter Signal Connections
    Connections {
        target: (typeof sddm !== "undefined") ? sddm : null
        function onLoginSucceeded() {
            loginForm.authenticating = false;
            loginForm.clearPassword();
            persistence.saveUser(loginForm.username);
            persistence.saveSessionIndex(root.currentSessionIndex);
        }
        function onLoginFailed() {
            loginForm.authenticating = false;
            loginForm.clearPassword();
            var failMsg = (typeof config !== "undefined" && config.textLoginFailed) ? config.textLoginFailed : "Mật khẩu không chính xác hoặc xác thực thất bại!";
            loginForm.showError(failMsg);
            loginForm.focusPassword();
        }
        function onInformationMessage(message) {
            if (message && message !== "") {
                loginForm.showError(message);
            }
        }
    }

    // Suppress unwanted auto-popup of Qt Virtual Keyboard
    Connections {
        target: (typeof Qt !== "undefined" && Qt.inputMethod) ? Qt.inputMethod : null
        function onVisibleChanged() {
            if (!loginForm.virtualKeyboardRequested && Qt.inputMethod && Qt.inputMethod.visible) {
                Qt.inputMethod.hide();
            }
        }
    }

    Component.onCompleted: {
        if (typeof Qt !== "undefined" && Qt.inputMethod) {
            Qt.inputMethod.hide();
        }
        persistence.initStorage();
        if (persistence.lastUser !== "") {
            loginForm.username = persistence.lastUser;
        }
        if (persistence.lastSessionIndex >= 0) {
            root.currentSessionIndex = persistence.lastSessionIndex;
        }
    }
}
