import QtQuick

QtObject {
    id: styles

    // Theme Colors
    readonly property color bgCosmic: "#0b0e26"
    readonly property color surfaceGlass: Qt.rgba(0.06, 0.09, 0.18, 0.85)
    readonly property color surfaceCard: Qt.rgba(0.08, 0.12, 0.24, 0.92)
    readonly property color borderCyan: "#38bdf8"
    readonly property color borderGlass: Qt.rgba(0.40, 0.60, 0.90, 0.30)
    
    // Button palettes matching Arena of Valor screenshot
    readonly property color blueBtnStart: "#4d82ca"
    readonly property color blueBtnEnd: "#2b5da5"
    readonly property color blueBtnBorder: "#70a5f5"
    readonly property color blueBtnText: "#ffffff"
    readonly property color blueSubtitle: "#93c5fd"

    readonly property color whiteBtnStart: "#ffffff"
    readonly property color whiteBtnEnd: "#e2e8f0"
    readonly property color whiteBtnBorder: "#cbd5e1"
    readonly property color whiteBtnText: "#0f172a"

    readonly property color goldBtnStart: "#d99f62"
    readonly property color goldBtnEnd: "#b87c3b"
    readonly property color goldBtnBorder: "#fcd34d"
    readonly property color goldBtnText: "#ffffff"

    readonly property color circleBtnBg: "#1e293b"
    readonly property color circleBtnBorder: "#6366f1"

    readonly property color textPrimary: "#f8fafc"
    readonly property color textSecondary: "#94a3b8"
    readonly property color textMuted: "#64748b"
    readonly property color textGold: "#fbbf24"
    readonly property color textError: "#f87171"

    // Animation Timings
    readonly property int animQuick: 160
    readonly property int animNormal: 260
    readonly property int animSlow: 380

    // Easing curves
    readonly property var easeOut: Easing.OutCubic
    readonly property var easeInOut: Easing.InOutCubic
}

