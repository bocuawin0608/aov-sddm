import QtQuick
import QtQuick.Controls

Item {
    id: buttonRoot

    property string buttonType: "blue" // "blue", "white", "gold", "circle"
    property string text: ""
    property string subtitle: ""
    property string iconSource: ""
    property bool enabledState: true

    signal clicked()

    implicitWidth: buttonType === "circle" ? 42 : 220
    implicitHeight: 40

    ThemeStyles { id: styles }

    // Visual button body
    Rectangle {
        id: buttonBody
        anchors.fill: parent
        radius: buttonRoot.buttonType === "circle" ? width / 2 : 7
        clip: false

        // Gradient based on type
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    if (!buttonRoot.enabledState) return "#475569";
                    if (buttonRoot.buttonType === "blue") return mouseArea.pressed ? Qt.darker(styles.blueBtnStart, 1.15) : (mouseArea.containsMouse ? Qt.lighter(styles.blueBtnStart, 1.1) : styles.blueBtnStart);
                    if (buttonRoot.buttonType === "white") return mouseArea.pressed ? "#cbd5e1" : (mouseArea.containsMouse ? "#ffffff" : styles.whiteBtnStart);
                    if (buttonRoot.buttonType === "gold") return mouseArea.pressed ? Qt.darker(styles.goldBtnStart, 1.15) : (mouseArea.containsMouse ? Qt.lighter(styles.goldBtnStart, 1.1) : styles.goldBtnStart);
                    // circle
                    return mouseArea.pressed ? Qt.darker(styles.circleBtnBg, 1.2) : (mouseArea.containsMouse ? Qt.lighter(styles.circleBtnBg, 1.2) : styles.circleBtnBg);
                }
            }
            GradientStop {
                position: 1.0
                color: {
                    if (!buttonRoot.enabledState) return "#334155";
                    if (buttonRoot.buttonType === "blue") return mouseArea.pressed ? Qt.darker(styles.blueBtnEnd, 1.2) : styles.blueBtnEnd;
                    if (buttonRoot.buttonType === "white") return mouseArea.pressed ? "#94a3b8" : styles.whiteBtnEnd;
                    if (buttonRoot.buttonType === "gold") return mouseArea.pressed ? Qt.darker(styles.goldBtnEnd, 1.2) : styles.goldBtnEnd;
                    return mouseArea.pressed ? "#0f172a" : "#1e293b";
                }
            }
        }

        // Border styling
        border.width: mouseArea.containsMouse || buttonRoot.activeFocus ? 1.5 : 1.0
        border.color: {
            if (mouseArea.containsMouse || buttonRoot.activeFocus) {
                if (buttonRoot.buttonType === "blue") return "#93c5fd";
                if (buttonRoot.buttonType === "white") return "#64748b";
                if (buttonRoot.buttonType === "gold") return "#fef08a";
                return "#38bdf8";
            }
            if (buttonRoot.buttonType === "blue") return styles.blueBtnBorder;
            if (buttonRoot.buttonType === "white") return styles.whiteBtnBorder;
            if (buttonRoot.buttonType === "gold") return styles.goldBtnBorder;
            return styles.circleBtnBorder;
        }

        // Game glow when hovered / focused
        Rectangle {
            id: glowRing
            anchors.centerIn: parent
            width: parent.width + 6
            height: parent.height + 6
            radius: buttonBody.radius + 3
            color: "transparent"
            border.width: 1.5
            border.color: buttonRoot.buttonType === "gold" ? "#fbbf24" : (buttonRoot.buttonType === "white" ? "#94a3b8" : "#38bdf8")
            opacity: (mouseArea.containsMouse || buttonRoot.activeFocus) ? 0.6 : 0.0
            z: -1

            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        // Inner highlight line at top
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1.2
            radius: buttonBody.radius
            color: buttonRoot.buttonType === "white" ? Qt.rgba(1, 1, 1, 0.8) : Qt.rgba(1, 1, 1, 0.3)
        }

        // Content layout
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8

            Image {
                id: iconImg
                width: 18
                height: 18
                source: buttonRoot.iconSource
                visible: buttonRoot.iconSource !== ""
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                id: labelText
                text: buttonRoot.text
                font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                font.bold: true
                font.pixelSize: 13
                color: {
                    if (!buttonRoot.enabledState) return "#94a3b8";
                    if (buttonRoot.buttonType === "white") return styles.whiteBtnText;
                    return "#ffffff";
                }
                anchors.verticalCenter: parent.verticalCenter
                visible: buttonRoot.buttonType !== "circle"
            }
        }

        // Scale feedback on press
        scale: mouseArea.pressed ? 0.97 : (mouseArea.containsMouse ? 1.02 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }
    }

    // Subtitle below button (e.g. "Lần đăng nhập cuối")
    Text {
        id: subText
        text: buttonRoot.subtitle
        visible: buttonRoot.subtitle !== ""
        anchors.top: buttonBody.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: buttonBody.horizontalCenter
        font.pixelSize: 11
        font.bold: false
        color: styles.blueSubtitle
        opacity: 0.95
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: buttonRoot.enabledState
        onClicked: buttonRoot.clicked()
    }

    // Keyboard navigation
    Keys.onReturnPressed: buttonRoot.clicked()
    Keys.onEnterPressed: buttonRoot.clicked()
    Keys.onSpacePressed: buttonRoot.clicked()
}

